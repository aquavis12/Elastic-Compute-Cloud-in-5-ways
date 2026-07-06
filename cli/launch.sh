#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# EC2 Launch — Method 2: AWS CLI
# Launches Amazon Linux 2023 + Nginx on t2.micro
# SV Technologies — sv-technologies.in
# ─────────────────────────────────────────────────────────────────

set -e

# ── Config — edit these ──────────────────────────────────────────
REGION="ap-south-1"
INSTANCE_TYPE="t2.micro"
KEY_NAME="your-key-pair-name"          # replace with your key pair
SG_NAME="ec2-launch-demo-sg"
INSTANCE_NAME="nginx-ec2-cli"

# ── Get latest Amazon Linux 2023 AMI ────────────────────────────
echo "🔍  Finding latest Amazon Linux 2023 AMI in $REGION..."
AMI_ID=$(aws ec2 describe-images \
  --region "$REGION" \
  --owners amazon \
  --filters \
    "Name=name,Values=al2023-ami-*-x86_64" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" \
  --output text)
echo "✅  AMI: $AMI_ID"

# ── Get default VPC ──────────────────────────────────────────────
echo "🔍  Getting default VPC..."
VPC_ID=$(aws ec2 describe-vpcs \
  --region "$REGION" \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" \
  --output text)
echo "✅  VPC: $VPC_ID"

# ── Create security group ────────────────────────────────────────
echo "🔒  Creating security group..."
SG_ID=$(aws ec2 create-security-group \
  --region "$REGION" \
  --group-name "$SG_NAME" \
  --description "EC2 launch demo SG" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" \
  --output text 2>/dev/null || \
  aws ec2 describe-security-groups \
    --region "$REGION" \
    --filters "Name=group-name,Values=$SG_NAME" \
    --query "SecurityGroups[0].GroupId" \
    --output text)

aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$SG_ID" \
  --protocol tcp --port 22 --cidr 0.0.0.0/0 2>/dev/null || true

aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$SG_ID" \
  --protocol tcp --port 80 --cidr 0.0.0.0/0 2>/dev/null || true

echo "✅  Security Group: $SG_ID"

# ── User data script ─────────────────────────────────────────────
USER_DATA=$(cat <<'USERDATA'
#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
echo "<h1>Hello from EC2!</h1><p>Launched via AWS CLI</p>" > /usr/share/nginx/html/index.html
USERDATA
)

# ── Launch instance ──────────────────────────────────────────────
echo "🚀  Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
  --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --user-data "$USER_DATA" \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "✅  Instance launched: $INSTANCE_ID"

# ── Wait for running ─────────────────────────────────────────────
echo "⏳  Waiting for instance to be running..."
aws ec2 wait instance-running \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID"

# ── Get public IP ────────────────────────────────────────────────
PUBLIC_IP=$(aws ec2 describe-instances \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo ""
echo "═══════════════════════════════════════════"
echo "✅  EC2 Instance is RUNNING"
echo "   Instance ID : $INSTANCE_ID"
echo "   Public IP   : $PUBLIC_IP"
echo "   Website     : http://$PUBLIC_IP"
echo "   SSH         : ssh -i ~/.ssh/$KEY_NAME.pem ec2-user@$PUBLIC_IP"
echo "═══════════════════════════════════════════"
echo ""
echo "⚠️  Wait ~60 seconds for Nginx to start, then open the URL above."
echo "🗑️  To terminate: aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION"
