### Introduction to Fact Data Modeling and How It Differs from Dimensional Data Modeling

Fact data modeling and dimensional data modeling are critical techniques in the world of data analytics, each with unique purposes and structures tailored to different aspects of a database.

#### **What is Fact Data Modeling?**
Fact data modeling focuses on storing and analyzing quantitative metrics (facts) related to business processes. Examples include sales revenue, player statistics, or website traffic. These facts are usually numeric and are often aggregated for reporting purposes (e.g., total sales, average scores).

---

### **Fact Data Modeling vs. Dimensional Data Modeling**

| Feature                | Fact Data Modeling                          | Dimensional Data Modeling                |
|------------------------|---------------------------------------------|------------------------------------------|
| **Purpose**            | Focuses on quantitative measures (facts).  | Combines facts and dimensions for analysis. |
| **Core Components**    | Fact tables only.                          | Fact and dimension tables.               |
| **Complexity**         | Less intuitive for non-technical users.    | Designed for ease of understanding.      |
| **Data Relationships** | More normalized.                           | Often denormalized for performance.      |
| **Usage**              | Best for heavy analytics and aggregation.  | Ideal for business intelligence and reporting. |

Dimensional modeling is broader and incorporates both facts and dimensions, making it a more intuitive approach for designing data warehouses. Fact modeling focuses exclusively on capturing measurable data for computational purposes.

---

### **Understanding Slowly Changing Dimensions (SCD)**

**What is SCD?**  
Slowly Changing Dimensions (SCD) are techniques used to manage the historical evolution of dimension data. When attributes of a dimension, like a player's team or a customer’s address, change over time, SCD ensures the database captures these changes without losing historical context.

---

### **Types of SCD and Their Usage**

1. **Type 1 (Overwrite):**  
   The simplest form, where old data is overwritten with new data.  
   **When to Use:**  
   - When historical accuracy isn’t critical.  
   - Example: Correcting a spelling mistake.

2. **Type 2 (Versioning):**  
   Creates a new row for each change, preserving history.  
   **When to Use:**  
   - When tracking historical changes is essential.  
   - Example: Player moving to a new team while keeping past team affiliations.

3. **Type 3 (Adding a Column):**  
   Adds a column for the most recent change, limited to tracking one change.  
   **When to Use:**  
   - When only the current and previous states are required.  
   - Example: Keeping track of a promotion.

---

### **When to Use SCD**

Use SCD when you need to:
- Maintain historical accuracy of changes over time.
- Analyze trends or the impact of attribute changes on business metrics.
- Implement systems where data lineage and traceability are critical (e.g., customer relationship management or sports analytics).

