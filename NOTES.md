# Notes

## Task 1 — which instance is protected and why

All 5 instances come from the single `instances` map and are created with
`for_each`. `web` uses io2 and `batch` uses io1, so the io1/io2 requirement is
covered.

The protected one (`prevent_destroy`) is `web`. It's the public entry point and
the one I put on the io2 root volume, so it's the most expensive and the one I'd
least want to lose to an accidental destroy or replace. A web box also tends to
carry the stuff that's annoying to rebuild (certs, EIP/DNS pointing at it), so
guarding it is the obvious pick.

One gotcha: `prevent_destroy` only accepts a literal, you can't feed it a
variable or `each.value`. So I split the map in locals and gave the protected
instance its own resource block with the lifecycle guard hardcoded. Everything
still comes from one input map.

## Task 2 — local state vs S3 + lock

With local state there's no lock. If two people run `apply` at the same time,
they both plan against the same starting state and both change real infra. The
state files then diverge and whichever writes last overwrites the other, so
resources from the losing run get orphaned (they exist in AWS but aren't in
state anymore). Worst case the state file itself gets corrupted.

The S3 backend puts state in one shared place, and the DynamoDB table gives you
a lock. Before touching state, Terraform writes a lock row (keyed on LockID). A
second apply tries to grab the same lock, sees it's held, and fails fast with a
"state locked" error instead of racing. Once the first run finishes the lock is
released and the second person retries against the updated state. S3 versioning
also lets you roll back a bad write.

Order: apply `task2-backend` first (local state), then `terraform init` in
`task1-ec2-module` to move state into S3.

## Task 3

### Q1 — real access keys for engine and ci in prod?

No. Long-lived IAM user access keys are the thing I'd avoid. They don't expire,
they leak easily (committed to a repo, baked into an image, dumped in a log),
and rotating them is a pain.

For `ci` I'd use short-lived creds instead — OIDC federation (GitHub Actions /
GitLab can assume a role with `sts:AssumeRoleWithWebIdentity`), so the pipeline
gets temp creds per run and there's no stored secret. If the CI system can't do
OIDC, IAM Roles Anywhere or a scoped role with an external ID.

For `engine` (a person) I'd use IAM Identity Center / SSO through the company
IdP, again short-lived sessions, not a standalone user with permanent keys.

I did it with access keys here because the task literally asks for programmatic
IAM users, but that's the one part I'd push back on for real.

### Q2 — trust Account A root vs roleB's ARN?

It changes who can assume roleC.

Trusting `...:root` means "anyone in Account A who also has `sts:AssumeRole`
permission can assume this." You're handing the decision to Account A — if an
admin there later gives some other user permission to assume roleC, it works,
and Account B never signed off.

Trusting roleB's exact ARN means only roleB can assume it, period. Even an
Account A admin with `sts:AssumeRole` on `*` can't, because the trust policy
just doesn't name them. That's the requirement ("only roleB, nothing else in
Account A"), so the principal is `role/roleB`, not root.

## Task 4 — what I left out of the ci policy

Policy is in `task4-ci-policy/ci-policy.json` (and the same thing as Terraform in
`main.tf`). It grants: ECR push to one repo, `RegisterTaskDefinition` +
`UpdateService`/`DescribeServices` on one service, a scoped `iam:PassRole`, and
`GetObject`/`ListBucket` on one bucket.

Left out on purpose:

- No `s3:PutObject` — the task says *read* artifacts, so read-only.
- No repo admin (`CreateRepository`, `DeleteRepository`, lifecycle). CI pushes,
  it doesn't manage the repo.
- No `CreateService`/`DeleteService`/`CreateCluster`/`RunTask`. It deploys to an
  existing service by updating it.
- No wildcard `iam:PassRole` — scoped to the two ECS roles and only when passed
  to ecs-tasks. That's the classic escalation hole.
- No `ec2:*`, `logs:*`, describe-everything, no managed policies like
  PowerUserAccess. None of it is needed for push + deploy + read.

So if the ci creds leak, the blast radius is one repo, one service, and read on
one bucket.

## Task 5 — the two bugs

Broken version is `broken.tf.txt`, fix is `fixed.tf`.

**Bug 1, trust policy.** The principal was `arn:...:user/roleB`, but roleB is a
*role*. When roleB assumes roleC, STS evaluates the call as roleB's role
identity, so the trust has to name `role/roleB`. With `user/roleB` it points at
a principal that doesn't exist and the assume-role call is denied every time.
Fix: `user/` → `role/`.

**Bug 2, permissions policy.** It had `s3:*` on `Resource = "*"`, i.e. every
bucket in the account. The requirement is one named bucket. Fix: scope to the
bucket ARN and the object ARN (`/*`) — you need both, since bucket-level actions
like `ListBucket` hit the bucket ARN and object-level actions like `GetObject`
hit the `/*` ARN.
