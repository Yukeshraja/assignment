# assignment

Arrise Solution assignment. Terraform + IAM for the five tasks. Written answers
are in [NOTES.md](./NOTES.md).

## Layout

```
task1-ec2-module/     5 EC2 instances from one input var (module in modules/ec2_instances)
  backend.tf          S3 backend + DynamoDB lock (Task 2)
task2-backend/        bootstrap for the state bucket + lock table
task3-iam/            multi-account IAM (account_a.tf, account_b.tf)
task4-ci-policy/      least-privilege CI policy (ci-policy.json + main.tf)
task5-bugfix/         broken.tf.txt vs fixed.tf
```

## Running

Each directory is its own Terraform root (the task1 module is consumed by
task1-ec2-module).

```bash
# state bucket + lock table first (local state)
cd task2-backend && terraform init && terraform apply

# init migrates task1 state into S3
cd ../task1-ec2-module && terraform init && terraform apply

# IAM (point creds at the right account first)
cd ../task3-iam && terraform init && terraform apply
cd ../task4-ci-policy && terraform init && terraform apply
```

Account IDs, AMI, bucket names, and key pairs are placeholders — swap them for
real values before applying.
