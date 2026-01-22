# Executive KPI Reconciliation – Problem Statement

Leadership dashboards show portfolio and transaction KPIs that drive operational, financial, and risk decisions.  
When these metrics shift unexpectedly or differ across systems, confidence in reporting erodes and decisions are delayed or misdirected.

This case study simulates a common scenario:

Multiple systems and layers report different values for the same KPIs:
- Transaction volume
- Active accounts
- Revenue and fee income
- Delinquency and charge-off rates

The objective of this project is to:

1. Trace each KPI from executive dashboard back to Snowflake source tables  
2. Identify where and why discrepancies arise  
3. Reconcile counts, balances, and rates across layers  
4. Establish a single, defensible version of the truth  
5. Document logic and lineage for audit and leadership review  

This mirrors real-world analytics work where analysts are accountable not just for producing numbers, but for proving their correctness.
