
# Data Engineering Pipelines Management

## Pipeline Details

### 1. **Profit**
- **Unit-level profit needed for experiments**
- **Aggregate profit reported to investors**

### 2. **Growth**
- **Aggregate growth reported to investors**
- **Daily growth needed for experiments**

### 3. **Engagement**
- **Aggregate engagement reported to investors**

---

## Ownership Assignments

| Pipeline                          | Primary Owner       | Secondary Owner     |
|-----------------------------------|---------------------|---------------------|
| Unit-level profit                 | Data Engineer 1     | Data Engineer 3     |
| Aggregate profit                  | Data Engineer 2     | Data Engineer 4     |
| Aggregate growth                  | Data Engineer 3     | Data Engineer 1     |
| Daily growth                      | Data Engineer 4     | Data Engineer 2     |
| Aggregate engagement              | Data Engineer 1     | Data Engineer 4     |

---

## On-Call Schedule
- **Rotation Frequency**: Weekly rotation
- **Schedule**:
  - Week 1: Data Engineer 1
  - Week 2: Data Engineer 2
  - Week 3: Data Engineer 3
  - Week 4: Data Engineer 4
- **Holiday Considerations**:
  - Swap shifts when on-call aligns with a holiday.
  - Secondary owner serves as a backup during holidays.

---

## Run Books for Investor Reporting Pipelines

### Profit Pipeline (Aggregate Profit)
- **Steps**:
  1. Ensure data ingestion from financial systems is complete.
  2. Run data validation checks on raw profit data.
  3. Aggregate unit-level data into investor metrics.
  4. Store results in the reporting database.
  5. Send automated notifications on success or failure.
- **Checks**:
  - Monitor for missing or corrupted data.
  - Validate against previous reporting periods.

### Growth Pipeline (Aggregate Growth)
- **Steps**:
  1. Ingest growth metrics from multiple sources.
  2. Apply transformations to unify data formats.
  3. Calculate aggregate growth metrics.
  4. Validate results using benchmark thresholds.
  5. Store in investor dashboard tables.
- **Checks**:
  - Ensure all data sources are online.
  - Validate transformations for consistency.

### Engagement Pipeline (Aggregate Engagement)
- **Steps**:
  1. Ingest daily user engagement data.
  2. Normalize and clean the dataset.
  3. Calculate engagement metrics like DAU, MAU, etc.
  4. Generate reports for the investor dashboard.
  5. Trigger notifications upon completion.
- **Checks**:
  - Detect anomalies in daily data trends.
  - Ensure proper aggregation rules are applied.

---

## Potential Failures and Risks

### Profit Pipelines
- **Issues**:
  - Delayed data ingestion due to upstream system failures.
  - Incorrect aggregation logic leading to inaccurate reporting.

### Growth Pipelines
- **Issues**:
  - Missing data from external systems.
  - Bugs in transformation logic causing invalid metrics.

### Engagement Pipelines
- **Issues**:
  - Data spikes or drops indicating incorrect user behavior tracking.
  - Failure to complete daily processing within SLA windows.

---
