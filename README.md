# 🚀 Launch EC2 — 5 Ways

> **SV Technologies** — Cloud · DevOps · AI Training from Ongole
> 🌐 [sv-technologies.in](https://sv-technologies.in) · 📺 [@sv-technologies26](https://www.youtube.com/@sv-technologies26)

Launch an **Amazon Linux 2023** EC2 instance running **Nginx** with a simple HTML page — using 5 different methods.

---

## What Gets Deployed

Every method launches the same thing:

| Setting | Value |
|---|---|
| **OS** | Amazon Linux 2023 |
| **Instance type** | t2.micro (free tier) |
| **Web server** | Nginx |
| **Page served** | `<h1>Hello from EC2!</h1>` |
| **Port** | 80 (HTTP) |

---

## User Data Script

All 5 methods use the same startup script:

```bash
#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
echo "<h1>Hello from EC2!</h1>" > /usr/share/nginx/html/index.html
```

---

## The 5 Methods

| # | Method | File | Best For |
|---|---|---|---|
| 1 | [AWS Console](#method-1--aws-console) | — | Learning, one-off |
| 2 | [AWS CLI](#method-2--aws-cli) | [`cli/launch.sh`](./cli/launch.sh) | Quick scripts |
| 3 | [CloudFormation / Terraform](#method-3--iac) | [`iac/`](./iac/) | Production / repeatable |
| 4 | [Python Boto3 (SDK)](#method-4--python-boto3) | [`sdk/launch.py`](./sdk/launch.py) | Inside your apps |
| 5 | [AWS MCP (AI Agents)](#method-5--aws-mcp) | [`mcp/`](./mcp/) | AI-assisted workflows |

---

## Prerequisites

- [ ] AWS account — [aws.amazon.com/free](https://aws.amazon.com/free)
- [ ] A key pair created in EC2 (for SSH access)
- [ ] A security group with **port 22** (SSH) and **port 80** (HTTP) open
- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Python 3.8+ with `boto3` installed (for Method 4)

---

## Method 1 — AWS Console

Point and click in your browser. No tools needed.

**Steps:**

1. Go to [console.aws.amazon.com](https://console.aws.amazon.com) → search **EC2** → **Launch instance**
2. **Name:** `my-nginx-server`
3. **AMI:** Amazon Linux 2023 (free tier eligible)
4. **Instance type:** `t2.micro`
5. **Key pair:** select or create one
6. **Security group:** allow SSH (22) and HTTP (80)
7. **Advanced → User data:** paste the script from above
8. Click **Launch instance**

**After launch:**

- Wait ~2 minutes for the instance to pass health checks
- Copy the **Public IPv4 address** from the EC2 console
- Open `http://<public-ip>` in your browser
- You should see: **Hello from EC2!**

---

## Method 2 — AWS CLI

```bash
# clone the repo and run
bash cli/launch.sh
```

See full script: [`cli/launch.sh`](./cli/launch.sh)

**What the script does:**

1. Looks up the latest Amazon Linux 2023 AMI ID automatically
2. Runs `aws ec2 run-instances` with the user data script
3. Waits for the instance to be running
4. Prints the public IP address

**Requirements:** AWS CLI configured with `aws configure`

---

## Method 3 — IaC

Two options — both produce the same result.

### CloudFormation

```bash
aws cloudformation deploy \
  --template-file iac/cloudformation.yaml \
  --stack-name ec2-nginx-stack \
  --parameter-overrides KeyName=YOUR_KEY_PAIR_NAME
```

See: [`iac/cloudformation.yaml`](./iac/cloudformation.yaml)

### Terraform

```bash
cd iac/terraform
terraform init
terraform apply -var="key_name=YOUR_KEY_PAIR_NAME"
```

See: [`iac/terraform/`](./iac/terraform/)

**Why IaC?** Define once, deploy anywhere, destroy and rebuild in seconds.
Version-controlled infrastructure — track changes like code.

---

## Method 4 — Python Boto3

```bash
pip install boto3
python sdk/launch.py
```

See full script: [`sdk/launch.py`](./sdk/launch.py)

**What the script does:**

1. Creates a boto3 EC2 client
2. Calls `ec2.run_instances()` with all parameters
3. Polls until instance is running
4. Prints the public IP

Use this when you want to launch EC2 from inside your own application or automation pipeline.

---

## Method 5 — AWS MCP

**MCP (Model Context Protocol)** lets AI assistants like Claude call AWS APIs on your behalf.

```bash
# Install the AWS Labs MCP server
npm install -g @aws/aws-mcp-servers
aws-mcp-servers ec2
```

Then in Claude (or any MCP-compatible AI):

```
"Launch a t2.micro Amazon Linux 2023 EC2 instance in us-east-1
with Nginx installed and port 80 open."
```

Claude will call the EC2 API using your IAM credentials — your IAM permissions still apply.

See setup guide: [`mcp/README.md`](./mcp/README.md)

---

## Repo Structure

```
ec2-five-ways/
├── README.md                  ← you are here
├── cli/
│   └── launch.sh              ← AWS CLI script
├── iac/
│   ├── cloudformation.yaml    ← CloudFormation template
│   └── terraform/
│       ├── main.tf            ← Terraform config
│       ├── variables.tf
│       └── outputs.tf
├── sdk/
│   └── launch.py              ← Python Boto3 script
└── mcp/
    └── README.md              ← MCP setup guide
```

---

## Clean Up

**Always delete your resources when done to avoid charges.**

```bash
# Console
EC2 → Instances → select → Instance state → Terminate

# CLI
aws ec2 terminate-instances --instance-ids <INSTANCE_ID>

# CloudFormation
aws cloudformation delete-stack --stack-name ec2-nginx-stack

# Terraform
cd iac/terraform && terraform destroy

# Boto3
python sdk/terminate.py
```

---

## About SV Technologies

Live cloud training in **Telugu + English + Hindi** · Ongole, Andhra Pradesh

- 🌐 [sv-technologies.in](https://sv-technologies.in)
- 📺 [youtube.com/@sv-technologies26](https://www.youtube.com/@sv-technologies26)
- 👨‍🏫 Vishnu Rachapudi — 14x AWS Certified · AWS Community Builder (Security)

---

*Cloud · DevOps · AI — Ongole*
