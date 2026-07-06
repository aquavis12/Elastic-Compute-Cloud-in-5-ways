"""
Terminate EC2 instance by ID.
Usage: python terminate.py <instance-id>
"""
import sys
import boto3

REGION = "ap-south-1"

def terminate(instance_id):
    ec2 = boto3.client("ec2", region_name=REGION)
    ec2.terminate_instances(InstanceIds=[instance_id])
    print(f"🗑️  Terminating {instance_id}...")
    waiter = ec2.get_waiter("instance_terminated")
    waiter.wait(InstanceIds=[instance_id])
    print("✅  Instance terminated.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python terminate.py <instance-id>")
        sys.exit(1)
    terminate(sys.argv[1])
