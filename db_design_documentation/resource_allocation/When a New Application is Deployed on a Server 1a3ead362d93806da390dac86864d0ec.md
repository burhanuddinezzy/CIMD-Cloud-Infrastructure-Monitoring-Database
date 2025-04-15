# When a New Application is Deployed on a Server

- If a **new application** is assigned resources on a server for the first time.
- Example: A **database application** gets deployed on a server, and it gets **8GB RAM, 4 CPU cores, and 200GB disk space**.

📌 **Example Entry:**

| `server_id` | `app_id` | `allocated_memory` | `allocated_cpu` | `allocated_disk_space` | `timestamp` |
| --- | --- | --- | --- | --- | --- |
| `s123` | `appX` | 8192 MB | 4.00 Cores | 200 GB | 2025-02-22 10:00:00 |

---

### **2️⃣ When Resource Allocation Changes (Scaling Up or Down)**

- If an app’s allocated resources change (e.g., autoscaling, manual adjustments).
- Example: A **machine learning model** needs **more CPU & memory** due to a high workload.

🔄 **New Row Example (Resource Increase at 2 PM)**

| `server_id` | `app_id` | `allocated_memory` | `allocated_cpu` | `allocated_disk_space` | `timestamp` |
| --- | --- | --- | --- | --- | --- |
| `s123` | `appX` | 16384 MB | 6.00 Cores | 200 GB | 2025-02-22 14:00:00 |

❗ **Why a new row instead of updating the old one?**

- **Historical tracking**: If we just updated the row, we’d lose the record of the original allocation (8GB → 16GB).
- **Trend analysis**: Helps track how resource needs evolve over time.

---

### **3️⃣ When an Application Moves to a New Server**

- If an application **migrates to a different server**, a **new row** is created.
- Example: A **web service** moves from **Server A** to **Server B** due to load balancing.

📌 **Example Entries:**

| `server_id` | `app_id` | `allocated_memory` | `timestamp` |
| --- | --- | --- | --- |
| `s123` | `appX` | 4096 MB | 2025-02-22 08:00:00 |
| `s456` | `appX` | 4096 MB | 2025-02-22 09:30:00 |

---

### **4️⃣ When an Application is Stopped or Deallocated**

- If an app is **shut down** or **deallocated**, we could add an entry with `allocation_status = 'deallocated'`
- Example: A temporary **batch processing job** that no longer needs resources.

📌 **Example Entries:**

| `server_id` | `app_id` | `allocated_memory` | `allocation_status` | `timestamp` |
| --- | --- | --- | --- | --- |
| `s123` | `appX` | 8192 MB | `active` | 2025-02-22 10:00:00 |
| `s123` | `appX` | 8192 MB | `deallocated` | 2025-02-22 18:00:00 |

---

### **TL;DR – When is a New Row Added?**

✅ **First-time resource allocation for an application** on a server.

✅ **Scaling up/down** (changes in allocated resources).

✅ **Server migration** (app moves to another server).

✅ **Deallocation (app stops using resources).**

🔹 Instead of updating old records, a **new row helps track resource history!**

Is that how you were thinking about it, or does this still feel unclear?