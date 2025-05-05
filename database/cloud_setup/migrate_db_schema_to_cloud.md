Migrate Local DB to Cloud VM via DBeaver
✅ Prerequisites
You’ve connected DBeaver to both:

Your local PostgreSQL DB

Your cloud PostgreSQL DB (via SSH tunnel, port 15432)

You’ve reset your postgres password and can connect

🪄 Method 1: Use DBeaver’s "Data Transfer" Tool (Recommended)

1. Open DBeaver
   Open both connections:

Your local database

Your cloud PostgreSQL database

2. Right-click your local database (source)
   Go to:

nginx
Copy
Edit
Tools → Data Transfer 3. In the popup:
Source: Your local DB

Target: Your cloud DB (choose the correct schema/database in the dropdown)

4. Transfer settings
   Choose:

✅ "Export DDL" (schema)

✅ "Export Data"

Click Next

5. Choose transfer method
   Use Insert or Insert or Update

Enable "Truncate target table" if you want to overwrite existing data

6. Start transfer
   Click Finish

DBeaver will now copy your tables, schemas, and data to the cloud DB

✅ To Confirm the Migration
Expand your cloud DB connection in DBeaver

Open the Schemas → public → Tables

Right-click a table → View Data → All Rows
✅ You should see the data from your local DB now in the cloud.

📝 Bonus: Using SQL Scripts (Manual Option)
If you prefer the manual way:

Right-click your local DB → Tools → Backup

Export as SQL with DDL and data

Connect to cloud DB → Right-click → SQL Editor → Open SQL Script

Paste the dump and run
