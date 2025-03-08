# Autoscaling Data Point Handbook

**Purpose of Autoscaling Tracking**
The purpose of tracking autoscaling is to monitor the state of autoscaling features for cloud resources (like CPU, memory, or storage) over time. It tells us whether autoscaling was enabled or not at a particular timestamp and provides insights into whether resources were adjusted automatically or manually.

---

### **Key Terms**

- **Autoscaling**: A feature that automatically adjusts the allocation of resources (like CPU, memory, disk) based on the current load or performance metrics (e.g., CPU utilization or memory usage).
- **Resource Allocation**: The amount of computing resources (CPU, memory, disk) assigned to a server or instance.
- **Autoscaling_enabled**: A boolean flag (`TRUE` or `FALSE`) that indicates whether autoscaling was active at the time of the entry.

---

### **What Does Autoscaling_enabled Mean?**

The `autoscaling_enabled` field tells us whether the autoscaling feature is **active** for a resource at a specific point in time.

- **`TRUE`**: Autoscaling is enabled and could automatically adjust the resource allocation based on predefined rules and thresholds (e.g., CPU usage over 85% triggers scaling).
- **`FALSE`**: Autoscaling is disabled, meaning the system will not automatically adjust resource allocations. Any changes in resources must be done manually.

---

### **What Does Autoscaling_enabled Not Tell Us?**

- It does **not** tell us whether autoscaling **actually happened** or if resources were **actually adjusted**.
- It does **not** provide information about the reason for the resource change (whether autoscaling was triggered by a load spike, or if the change was manual).

---

### **How to Use the Data Points**

1. **When Autoscaling is Enabled (`TRUE`):**
    - **Resource Change**: If there’s a change in resource allocation (e.g., CPU increased from 2.00 to 2.50), and autoscaling is enabled, it’s likely that the change was made **automatically** due to the system’s scaling rules (e.g., CPU usage exceeding a threshold).
    
    Example:
    
    ```
    yaml
    CopyEdit
    Timestamp: 2025-02-22 10:00:00
    Server ID: srv-001
    Allocated CPU: 2.00
    Autoscaling Enabled: TRUE
    
    ```
    
    - **No Resource Change**: If the resource allocation stays the same (e.g., CPU remains 2.00), then autoscaling is active, but no scaling action was needed or triggered at that time.
    
    Example:
    
    ```
    yaml
    CopyEdit
    Timestamp: 2025-02-22 10:10:00
    Server ID: srv-001
    Allocated CPU: 2.00
    Autoscaling Enabled: TRUE
    
    ```
    
2. **When Autoscaling is Disabled (`FALSE`):**
    - **Manual Scaling**: If a resource change happens (e.g., CPU increased from 2.00 to 3.00) when autoscaling is disabled, the change was made **manually** by an administrator.
    
    Example:
    
    ```
    yaml
    CopyEdit
    Timestamp: 2025-02-22 10:20:00
    Server ID: srv-002
    Allocated CPU: 3.00
    Autoscaling Enabled: FALSE
    
    ```
    
    In this case, autoscaling wasn't enabled, so any resource changes would have been performed manually.
    
3. **When No Change in Resources**:
    - Even if there’s no change in the resource allocation (e.g., CPU stays at 2.00), the `autoscaling_enabled` field still logs whether autoscaling was enabled or not at that moment.
    
    Example (no change):
    
    ```
    yaml
    CopyEdit
    Timestamp: 2025-02-22 10:30:00
    Server ID: srv-003
    Allocated CPU: 2.00
    Autoscaling Enabled: TRUE
    
    ```
    

---

### **Why Does It Matter Whether Scaling Was Automatic or Manual?**

Employers and system administrators care about knowing whether resource changes were automatic or manual for several reasons:

1. **Automation vs. Human Intervention**:
    - **Automatic Scaling**: If scaling was done automatically, it means the system is handling performance demands dynamically without human intervention. This is important for reducing operational overhead and ensuring efficient resource management, especially in high-traffic or unpredictable environments.
    - **Manual Scaling**: If scaling was done manually, it indicates that human intervention was required to meet performance demands, which may suggest a lack of optimization, delays in responding to load changes, or suboptimal configuration of autoscaling policies. Frequent manual scaling may also increase operational complexity and costs.
2. **Troubleshooting and Performance Analysis**:
    - Knowing whether a scaling event was automatic or manual helps to pinpoint issues in the system. For example, if resource allocation is not meeting demand, an administrator can check if autoscaling is properly configured or if manual intervention is required too often.
    - **Automatic Scaling**: If resources automatically scaled up but performance still degraded, it might indicate that autoscaling thresholds need adjustment.
    - **Manual Scaling**: If scaling is being done manually, it could point to delays in detecting issues or insufficient monitoring alerts.
3. **Cost Management**:
    - Automatic scaling can help optimize costs by dynamically adjusting resources based on demand. However, improper autoscaling configurations might result in overprovisioning or underprovisioning.
    - Manual intervention often involves planned adjustments, but frequent manual scaling can incur higher costs, as resources may be manually adjusted too late or too early.
4. **System Reliability and Resilience**:
    - **Automatic Scaling**: A well-configured autoscaling system improves system reliability by ensuring that the infrastructure adapts to traffic loads without human intervention. This is particularly valuable for businesses operating at scale or in real-time environments.
    - **Manual Scaling**: Relying on manual scaling can lead to delayed reactions to system load, which can result in poor user experience or downtime, especially in cloud environments where demand can spike unexpectedly.
5. **Efficiency and Compliance**:
    - **Automatic Scaling** helps in adhering to best practices for resource management and optimization, and it may be a requirement for systems with Service Level Agreements (SLAs) that guarantee a specific performance level.
    - **Manual Scaling** indicates a lack of automation, which might be a compliance or operational concern in environments requiring high levels of uptime or performance guarantees.

---

### **Example Scenarios**

### Scenario 1: Autoscaling Triggered

```
yaml
CopyEdit
Timestamp: 2025-02-22 10:00:00
Server ID: srv-001
Allocated CPU: 2.00
Autoscaling Enabled: TRUE

Timestamp: 2025-02-22 10:10:00
Server ID: srv-001
Allocated CPU: 2.50
Autoscaling Enabled: TRUE

Timestamp: 2025-02-22 10:20:00
Server ID: srv-001
Allocated CPU: 3.00
Autoscaling Enabled: TRUE

```

- **Explanation**: Autoscaling was enabled, and the CPU allocation increased over time (likely due to autoscaling being triggered based on system load).

### Scenario 2: Manual Scaling

```
yaml
CopyEdit
Timestamp: 2025-02-22 10:00:00
Server ID: srv-002
Allocated CPU: 2.00
Autoscaling Enabled: FALSE

Timestamp: 2025-02-22 10:10:00
Server ID: srv-002
Allocated CPU: 2.00
Autoscaling Enabled: FALSE

Timestamp: 2025-02-22 10:20:00
Server ID: srv-002
Allocated CPU: 3.00
Autoscaling Enabled: FALSE

```

- **Explanation**: Autoscaling was disabled, and the CPU allocation was manually increased.

---

### **Conclusion**

- The **`autoscaling_enabled`** field provides a snapshot of whether autoscaling was active at the time of the entry.
- It does **not** directly indicate whether autoscaling actually **occurred**—only if autoscaling could have occurred if conditions were met.
- To determine if scaling occurred, look for changes in resource allocation and compare them with autoscaling’s status (enabled or disabled).
- **Employers care** about whether scaling was automatic or manual because it impacts efficiency, cost management, troubleshooting, system reliability, and compliance. Understanding the nature of scaling helps to ensure that resources are allocated in an optimized and reliable way.