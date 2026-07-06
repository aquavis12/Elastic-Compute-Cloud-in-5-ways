# Method 5 — AWS MCP (AI Agents)

> **SV Technologies** · [← Back to main README](../README.md)

---

## What is MCP?

**MCP (Model Context Protocol)** is an open standard that lets AI assistants
like Claude call external tools and APIs — including AWS — on your behalf.

AWS Labs provides an official MCP server that exposes EC2, S3, and other
AWS services as tools that an AI can call.

> You describe what you want in plain English.
> The AI calls the AWS API using your IAM credentials.
> **Your IAM permissions still apply — the AI cannot do anything you can't.**

---

## Setup

### 1 — Install Node.js (required)

```bash
# macOS
brew install node

# Ubuntu/Debian
sudo apt install nodejs npm

# Amazon Linux
sudo dnf install -y nodejs
```

### 2 — Install the AWS Labs MCP server

```bash
npm install -g @aws-labs/mcp-server-aws
```

### 3 — Configure AWS credentials

```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region, Output format
```

### 4 — Connect to Claude Desktop

Add this to your Claude Desktop config file:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "aws": {
      "command": "npx",
      "args": ["-y", "@aws-labs/mcp-server-aws"],
      "env": {
        "AWS_REGION": "ap-south-1"
      }
    }
  }
}
```

Restart Claude Desktop.

---

## Launch EC2 with a Prompt

Once MCP is connected, type this in Claude:

```
Launch a t2.micro EC2 instance in ap-south-1 with:
- AMI: Amazon Linux 2023
- Security group: allow port 22 and port 80
- User data: install nginx, start it, and put
  "<h1>Hello from EC2!</h1>" in the default page
- Tag the instance Name = nginx-ec2-mcp
```

Claude will:
1. Find the latest Amazon Linux 2023 AMI
2. Create or reuse a security group
3. Call `ec2:RunInstances` with the user data script
4. Return the instance ID and public IP

---

## Example Conversation

```
You:    "Launch a t2.micro Amazon Linux 2023 EC2 with Nginx on port 80"

Claude: "I'll launch that for you. Finding the latest AMI..."
        [calls ec2:DescribeImages]
        "AMI found: ami-0abcd1234..."
        [calls ec2:RunInstances]
        "✅ Instance i-0abc123 is launching.
         Public IP: 13.x.x.x
         Visit: http://13.x.x.x (ready in ~60 seconds)"

You:    "Terminate that instance when I'm done"

Claude: [calls ec2:TerminateInstances]
        "✅ Instance terminated."
```

---

## IAM Permissions Required

Your IAM user or role needs these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeImages",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RunInstances",
        "ec2:DescribeInstances",
        "ec2:TerminateInstances",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Useful MCP Prompts

```
# Describe your running instances
"List all my running EC2 instances in ap-south-1"

# Stop an instance
"Stop instance i-0abc123456"

# Check instance status
"What is the status of instance i-0abc123456?"

# Launch with specific settings
"Launch a t3.micro Amazon Linux 2023 instance with a 20GB root volume,
Nginx installed, and the name tag 'my-web-server' in ap-south-1"
```

---

## More Resources

- [AWS Labs MCP Servers on GitHub](https://github.com/awslabs/mcp)
- [MCP Protocol Documentation](https://modelcontextprotocol.io)
- [Claude Desktop MCP Guide](https://docs.anthropic.com/claude/docs/mcp)

---

*SV Technologies · sv-technologies.in*
