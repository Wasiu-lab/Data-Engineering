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

Dimensional modeling is broader and incorporates both facts and dimensions, making it a more intuitive approach for designing data warehouses. *Fact modeling focuses exclusively on capturing measurable data for computational purposes.*

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
To proceed with the analysis, I'll focus on summarizing the purpose and structure of the files based on what they likely contain, then include them in the README draft. Let's revisit the project step by step, combining the provided files with the context of dimensional modeling.


# Dimensional Data Modeling with SQL

Dimensional data modeling is a cornerstone of data analytics, providing a structured approach to organize data for querying and reporting. This repository demonstrates practical SQL implementations of dimensional data modeling techniques, including fact modeling, cumulative calculations, and advanced date-based operations.

---

### 1. **Array Metric (Lab 3)**
   **File:** `array metric Lab 3.sql`  
   **Purpose:**  
   - Utilizes arrays to store and manipulate metrics efficiently.
   - Demonstrates advanced SQL techniques for handling multiple metrics in a single query.

   **Key Features:**  
   - Array functions for compact storage.
   - Aggregations using array-based data.

   **How to Use:**  
   - Run the query to compute metrics for players or entities stored in the dataset.
   - Use this technique for scenarios where multiple metrics need to be handled in parallel.

---

### 2. **Cumulative Table (Get Date List)**
   **File:** `Cumulative table to get the date list from user.sql`  
   **Purpose:**  
   - Builds a cumulative data structure based on a user-defined date range.
   - Retrieves metrics for all records up to a specified date.

   **Key Features:**  
   - Supports dynamic date filtering.
   - Enables analysis of trends over time.

   **How to Use:**  
   - Define a date range using input parameters.
   - Execute the query to fetch cumulative metrics.

---

### 3. **Date List Initialization**
   **File:** `date list int.sql`  
   **Purpose:**  
   - Creates and manages date lists for use in time-series analysis.
   - Facilitates operations involving calendars or timelines.

   **Key Features:**  
   - Populates date dimensions dynamically.
   - Supports queries requiring precise date tracking.

   **How to Use:**  
   - Load the script into your SQL environment.
   - Use the generated date list in other queries for filtering or grouping.

---

### 4. **Fact Modeling Table**
   **File:** `Fact modeling table.sql`  
   **Purpose:**  
   - Demonstrates the design and implementation of a fact table.
   - Provides a structured approach for capturing measurable business events.

   **Key Features:**  
   - Example schema for creating fact tables.
   - Implements measures like totals, averages, or counts.

   **How to Use:**  
   - Execute the script to create a fact table schema.
   - Populate it with metrics and connect it to related dimension tables.
   - 
### 5. **Dimensional Analysis**
 **File:** `dimensional analysis on 3 days.sql`
  **Purpose:**  
   - Focuses on analyzing metrics over three days.
   - Highlights changes in facts and dimensions across time.
     
  **Key Features:** 
   - Calculates retention, engagement, and change rates.
   - Combines fact and dimension modeling for advanced temporal insights.
     
**How to Use:** 
   - Run the script to analyze three consecutive days of activity.
   - Use for retention analysis, trend tracking, and daily performance reports.
