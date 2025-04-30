Connecting to Oracle Cloud Compute Instance via SSH (PostgreSQL Server Setup)
After creating the cloud instance, the following steps were required to successfully connect to it and prepare it for database server hosting:

1. SSH Key Pair (During Instance Creation)
   During creation, I was prompted to upload a public SSH key.

I generated a key pair using a local tool (e.g., Git Bash or PuTTYgen).

Uploaded the .pub file when prompted.

Saved the private key as:
C:\Users\burha\.ssh\cimd_postgresql_key

2. Initial SSH Connection Failed
   Attempted to connect:

bash
Copy
Edit
ssh -i "/c/Users/burha/.ssh/cimd_postgresql_key" ubuntu@<public_ip>
Got this error:

pgsql
Copy
Edit
ssh: connect to host <public_ip> port 22: Connection timed out 3. Fixes Required (Network and Security)
a. Add Ingress Rule for Port 22 (SSH)
Go to VCN > Security Lists > Ingress Rules

Add rule:

Source CIDR: 0.0.0.0/0

Protocol: TCP

Destination Port Range: 22

Stateless: No

Note: Initially entered 22 in source port by mistake — it must be in destination port.

b. Setup Internet Gateway and Route Rule
Created an Internet Gateway under VCN

Route table → Add Route Rule:

Target Type: Internet Gateway

Destination CIDR: 0.0.0.0/0

c. Verify VNIC and Subnet
Go to Instance > Attached VNICs

Check:

Public IP is assigned (Ephemeral)

Subnet is public

VNIC is attached and active

4. Notes
   Ping does not work (ICMP blocked by default), but SSH still works.

If the instance is restarted, a new ephemeral public IP may be assigned.

Consider reserving a static public IP if needed.

On Unix systems, set private key permissions:

bash
Copy
Edit
chmod 400 cimd_postgresql_key 5. Final SSH Command (Successful)
Once everything was fixed, SSH succeeded with:

bash
Copy
Edit
ssh -i "/c/Users/burha/.ssh/cimd_postgresql_key" ubuntu@<public_ip>
