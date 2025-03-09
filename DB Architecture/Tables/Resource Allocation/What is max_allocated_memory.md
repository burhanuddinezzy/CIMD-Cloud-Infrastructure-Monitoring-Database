# What is max_allocated_memory?

`max_allocated_memory` **tracks the highest memory allocation recorded** for an application over a given period (e.g., per hour, day, or week).

### **Why Is This Useful?**

1️⃣ **Detecting Peak Usage** – Helps understand how much memory an application needs at its busiest times.

2️⃣ **Autoscaling & Capacity Planning** – Ensures your system scales up before hitting limits.

3️⃣ **Avoiding Performance Bottlenecks** – If peak usage is close to the limit, you may need more memory.

---

### **How It Works**

Every time the system monitors memory allocation, it checks:

- **Current allocated memory**
- **Historical max allocated memory**
- If the current allocation is higher than the recorded max, **update `max_allocated_memory`.**

🚀 **Example:**

| `timestamp` | `application_id` | `allocated_memory` | `max_allocated_memory` |
| --- | --- | --- | --- |
| 10:00 AM | App-1 | 500 MB | 500 MB |
| 10:05 AM | App-1 | 600 MB | 600 MB |
| 10:10 AM | App-1 | 550 MB | 600 MB |
| 10:15 AM | App-1 | 700 MB | 700 MB |

🔹 **At 10:10 AM:** Even though `allocated_memory` dropped to 550 MB, the `max_allocated_memory` **remains at 600 MB.**

🔹 **At 10:15 AM:** Since allocation spikes to 700 MB, the **max gets updated.**

---

### **Why Use an `INTEGER` Data Type?**

✅ **Memory allocation is always a whole number** (no need for decimals).

✅ **Easier & faster to compare values** in database queries.

✅ **Stored in MB or GB** for consistency.

---

### **Difference Between `max_allocated_memory` and `allocated_memory`?**

| **Metric** | **Meaning** |
| --- | --- |
| `allocated_memory` | The amount of memory currently assigned to an application. |
| `max_allocated_memory` | The highest memory allocation recorded over time. |

🔥 **TL;DR:**

- **Use `allocated_memory` for real-time monitoring.**
- **Use `max_allocated_memory` for long-term planning and auto-scaling decisions.**
