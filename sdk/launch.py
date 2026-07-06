"""
EC2 Launch — Method 4: Python Boto3 (AWS SDK)
Launches Amazon Linux 2023 + Nginx on t2.micro
SV Technologies — sv-technologies.in
"""

import boto3
import time
import base64

# ── Config — edit these ──────────────────────────────────────────
REGION        = "ap-south-1"
INSTANCE_TYPE = "t2.micro"
KEY_NAME      = "your-key-pair-name"   # replace with your key pair
SG_NAME       = "ec2-launch-demo-sg"
INSTANCE_NAME = "nginx-ec2-boto3"

# ── User data script ─────────────────────────────────────────────
USER_DATA = """#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
echo "<h1>Hello from EC2!</h1><p>Launched via Python Boto3</p>" > /usr/share/nginx/html/index.html
"""

def get_latest_al2023_ami(ec2_client):
    """Get the latest Amazon Linux 2023 AMI ID."""
    print("🔍  Finding latest Amazon Linux 2023 AMI...")
    response = ec2_client.describe_images(
        Owners=["amazon"],
        Filters=[
            {"Name": "name", "Values": ["al2023-ami-*-x86_64"]},
            {"Name": "state", "Values": ["available"]},
        ]
    )
    images = sorted(response["Images"], key=lambda x: x["CreationDate"], reverse=True)
    ami_id = images[0]["ImageId"]
    print(f"✅  AMI: {ami_id}")
    return ami_id


def get_or_create_security_group(ec2_client, vpc_id):
    """Create a security group allowing SSH (22) and HTTP (80)."""
    print("🔒  Setting up security group...")

    # Check if it already exists
    existing = ec2_client.describe_security_groups(
        Filters=[
            {"Name": "group-name", "Values": [SG_NAME]},
            {"Name": "vpc-id", "Values": [vpc_id]},
        ]
    )
    if existing["SecurityGroups"]:
        sg_id = existing["SecurityGroups"][0]["GroupId"]
        print(f"✅  Using existing security group: {sg_id}")
        return sg_id

    # Create new
    sg = ec2_client.create_security_group(
        GroupName=SG_NAME,
        Description="EC2 launch demo SG — SSH + HTTP",
        VpcId=vpc_id
    )
    sg_id = sg["GroupId"]

    ec2_client.authorize_security_group_ingress(
        GroupId=sg_id,
        IpPermissions=[
            {
                "IpProtocol": "tcp", "FromPort": 22, "ToPort": 22,
                "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "SSH"}]
            },
            {
                "IpProtocol": "tcp", "FromPort": 80, "ToPort": 80,
                "IpRanges": [{"CidrIp": "0.0.0.0/0", "Description": "HTTP"}]
            }
        ]
    )
    print(f"✅  Created security group: {sg_id}")
    return sg_id


def launch_ec2():
    ec2 = boto3.client("ec2", region_name=REGION)

    # Default VPC
    vpcs = ec2.describe_vpcs(Filters=[{"Name": "isDefault", "Values": ["true"]}])
    vpc_id = vpcs["Vpcs"][0]["VpcId"]
    print(f"✅  VPC: {vpc_id}")

    ami_id = get_latest_al2023_ami(ec2)
    sg_id  = get_or_create_security_group(ec2, vpc_id)

    print("🚀  Launching EC2 instance...")
    response = ec2.run_instances(
        ImageId           = ami_id,
        InstanceType      = INSTANCE_TYPE,
        KeyName           = KEY_NAME,
        MinCount          = 1,
        MaxCount          = 1,
        SecurityGroupIds  = [sg_id],
        UserData          = USER_DATA,
        NetworkInterfaces = [{
            "AssociatePublicIpAddress": True,
            "DeviceIndex": 0,
            "Groups": [sg_id]
        }],
        TagSpecifications = [{
            "ResourceType": "instance",
            "Tags": [{"Key": "Name", "Value": INSTANCE_NAME}]
        }]
    )

    instance_id = response["Instances"][0]["InstanceId"]
    print(f"✅  Instance launched: {instance_id}")

    # Wait for running
    print("⏳  Waiting for instance to be running...")
    waiter = ec2.get_waiter("instance_running")
    waiter.wait(InstanceIds=[instance_id])

    # Get public IP
    desc = ec2.describe_instances(InstanceIds=[instance_id])
    public_ip = desc["Reservations"][0]["Instances"][0].get("PublicIpAddress", "N/A")

    print()
    print("═" * 50)
    print("✅  EC2 Instance is RUNNING")
    print(f"   Instance ID : {instance_id}")
    print(f"   Public IP   : {public_ip}")
    print(f"   Website     : http://{public_ip}")
    print(f"   SSH         : ssh -i ~/.ssh/{KEY_NAME}.pem ec2-user@{public_ip}")
    print("═" * 50)
    print()
    print("⚠️  Wait ~60 seconds for Nginx to start, then open the URL.")
    print(f"🗑️  To terminate, run: python terminate.py {instance_id}")

    return instance_id


if __name__ == "__main__":
    launch_ec2()
