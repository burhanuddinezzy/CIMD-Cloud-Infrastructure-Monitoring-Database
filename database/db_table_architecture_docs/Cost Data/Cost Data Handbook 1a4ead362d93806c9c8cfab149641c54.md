# Cost Data Handbook

The **Cost Data** table contains a comprehensive set of data points for tracking the operational costs of servers, though there are some possible additional data points or refinements that could be considered depending on your specific use case. Here's a breakdown of the existing columns and whether any additional ones might be needed:

## Cost Data Columns

- **`server_id` (UUID, Foreign Key)**
    - **Purpose**: Identifies the server whose cost is being tracked.
    - **How I Thought of Including It**: The cost must be linked to specific servers to ensure accurate tracking.
    - **Why I Thought of Including It**: It ensures each cost record corresponds to a unique server, facilitating detailed cost analysis per server.
    - **Data Type Used & Why**: `UUID` ensures global uniqueness and compatibility with other tables that reference `server_id`, providing consistency across the database.
- **`region` (VARCHAR(20))**
    - **Purpose**: Captures the geographical location of the server, which influences pricing models.
    - **How I Thought of Including It**: Cloud providers often have different pricing for different regions, so tracking the region is essential for accurate cost assessment.
    - **Why I Thought of Including It**: Helps in cost analysis by enabling comparison of pricing between different regions and adjusting for any regional pricing disparities.
    - **Data Type Used & Why**: `VARCHAR(20)` is ideal for region codes (e.g., `us-east-1`), which are short and non-numeric.
- **`timestamp` (TIMESTAMP)**
    - **Purpose**: Captures when the cost calculation was made.
    - **How I Thought of Including It**: Necessary for tracking cost changes over time and identifying trends or patterns.
    - **Why I Thought of Including It**: Enables time-series analysis and trend identification, which is crucial for budgeting and forecasting.
    - **Data Type Used & Why**: `TIMESTAMP` ensures precise recording of the date and time, which is essential for financial tracking.
- **`cost_per_hour` (DECIMAL(10,2))**
    - **Purpose**: Stores the hourly operational cost of the server.
    - **How I Thought of Including It**: This is essential for calculating total costs dynamically based on the server’s runtime.
    - **Why I Thought of Including It**: Provides real-time cost tracking, making it easier to compute total costs over various periods and optimize server resource allocation.
    - **Data Type Used & Why**: `DECIMAL(10,2)` is ideal for precise financial calculations, ensuring accuracy in the cost value.
- **`total_monthly_cost` (DECIMAL(10,2))**
    - **Purpose**: Represents the aggregated cost of the server over a month.
    - **How I Thought of Including It**: This helps avoid recalculating costs frequently and provides a quick snapshot of monthly expenses.
    - **Why I Thought of Including It**: Improves efficiency in reporting and cost analysis by providing an easy-to-access monthly total without the need for complex queries.
    - **Data Type Used & Why**: `DECIMAL(10,2)` ensures financial figures are accurate, especially for aggregating costs at a monthly level.
- **`team_allocation` (VARCHAR(50))**
    - **Purpose**: Assigns the cost responsibility to a specific team or department.
    - **How I Thought of Including It**: Needed for internal billing and budget allocation within organizations that have multiple teams or departments sharing infrastructure.
    - **Why I Thought of Including It**: Ensures accountability and transparency in cost distribution, helping with departmental budgets and financial tracking.
    - **Data Type Used & Why**: `VARCHAR(50)` allows flexibility in naming departments, giving enough space to store team or department identifiers.
    - **How It Knows Which Team or Function is Causing the Cost**: Teams are typically assigned based on which resources they provision, the projects associated with a server, or tagging policies within cloud providers. Organizations often track this by linking servers to project budgets or cost centers.
    - **Examples**:
        - If a machine learning research team spins up high-performance GPU servers, those costs are allocated under "AI Research."
        - If DevOps provisions servers for CI/CD automation, their associated costs are recorded under "DevOps."
        - If a marketing team runs cloud-based analytics tools, their infrastructure is categorized under "Marketing Operations."
- **`cost_adjustment` (DECIMAL(10,2))**
    - **Purpose**: Captures any adjustments made to the cost, such as discounts or promotions.
    - **How I Thought of Including It**: Adjustments are often part of cost tracking, such as promotional discounts or custom billing arrangements that reduce the cost.
    - **Why I Thought of Including It**: Allows for tracking modifications in cost, ensuring more accurate financial records.
    - **Data Type Used & Why**: `DECIMAL(10,2)` provides precise financial calculations for adjustments, ensuring accurate cost tracking.
    - **How Adjustments Are Applied**: The `cost_adjustment` is applied after `cost_per_hour` and `total_monthly_cost`. The final cost calculation must take adjustments into account:
        
        ```
        SELECT
            server_id,
            total_monthly_cost,
            cost_adjustment,
            GREATEST(0, total_monthly_cost + cost_adjustment) AS final_cost
        FROM cost_data;
        ```
        
    - **Handling Negative Adjustments**:
        - If `cost_adjustment` is larger than `total_monthly_cost`, you need logic to ensure costs don’t go negative.
        - Possible solutions:
            - **Cap at zero**: Ensure final cost is `MAX(0, total_monthly_cost + cost_adjustment)`.
            - **Allow carryover credits**: Store excess negative adjustments separately for future billing cycles.
        - **Example in Python**:
            
            ```
            def calculate_final_cost(total_cost, adjustment):
                final_cost = max(0, total_cost + adjustment)
                unused_credit = abs(total_cost + adjustment) if (total_cost + adjustment) < 0 else 0
                return final_cost, unused_credit
            ```
            
    - **Tracking Discounts and Their Sources**:
        - Discounts can be tracked based on promotions, long-term commitments, or negotiated enterprise agreements.
        - Cloud providers often offer cost reductions for:
            - Committed-use discounts (e.g., reserving cloud resources for a year).
            - Usage-based discounts (e.g., bulk pricing tiers).
            - Promotional credits.
        - Example:
            - If an organization receives a $500 credit per month, the `cost_adjustment` column will reflect `500.00`, reducing the final total monthly cost.

## Additional Considerations

- **Interaction with Other Tables**: This data must be structured to link with resource allocation, billing, and team ownership records.
- **Ensuring Accuracy**: Data validation should prevent negative costs where applicable and properly allocate adjustments across teams.
- **Business Logic Implementation**: Final cost calculations and credit rollovers need to be handled in code, ensuring cost transparency.

By implementing these rules, organizations can ensure accurate cost tracking, optimize expenses, and maintain clear accountability for server-related expenditures.