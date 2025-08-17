# Amazon Sales Data: SQL Cleaning, Transformation, and Analysis

## Overview

This SQL script file (`Amazon-Sales-Data.sql`) is the core of the data engineering phase for the Amazon Sales Analysis project. It is designed to be executed in a MySQL environment to perform a full-cycle data preparation process, starting from raw data ingestion and concluding with an analysis-ready dataset.

The script handles data cleaning, transformation, and pre-aggregation of key business metrics. Furthermore, it establishes an automated data pipeline using SQL triggers to ensure the sales data remains up-to-date with each new sale matched with the Item_ID, demonstrating a robust back-end solution for real-time analytics.

## Key Features

*   **Data Cleaning:** Implements checks for duplicate entries using Window Functions (Row_Numbers) and handles them to ensure data integrity.
*   **Data Transformation:**
    *   Corrects data types for key columns (`Item Weight`, `Sales`, `Rating`, etc.) from `TEXT` to appropriate numeric formats like `DOUBLE` for accurate statistical analysis.
    *   Standardizes column names to improve readability and ease of use in downstream applications (e.g., `Item Identifier` to `Item_ID`).
    *   Cleans and maps categorical data to consistent values (e.g., standardizing `Item Status` fields).
*   **Automated Data Pipeline (SQL Triggers):**
    *   **`add_purchase_to_sales`:** An `AFTER INSERT` trigger on a `Product_Tracker` table that automatically populates the main sales table with a new record at the time of purchase.
    *   **`update_sales_with_warehouse_on_dispatch`:** An `AFTER UPDATE` trigger on a `Warehouse_Inventory` table that enriches the sales record with logistics details (e.g., `Warehouse_ID`, `Location_type`) once an item is marked as dispatched.
*   **KPI & Granular Analysis Queries:** Contains a comprehensive set of pre-written queries to calculate:
    *   High-level KPIs like Total Sales, Average Sale, Total Products Sold, and Average Rating.
    *   Granular metrics segmented by `Item_status`, `Category`, `Location`, and `Warehouse Establishment Year`.
*   **Chart-Ready Aggregations:** Includes queries designed to directly feed visualizations, such as calculating the percentage of sales by warehouse size and location.

## How to Use This Script

1.  **Database Setup:** Ensure a MySQL server is running. Create a database (e.g., `Amazon_Sales`).
2.  **Data Loading:** Load the raw sales data (e.g., from the provided JSON or CSV file) into an initial table named `sales`.
3.  **Script Execution:** Run this SQL script in your MySQL client. It will:
    *   Create a cleaned, duplicated table `sales2` to preserve the raw data.
    *   Perform all the cleaning and transformation steps on `sales2`.
    *   Create the necessary triggers for the automated pipeline (assuming `Product_Tracker` and `Warehouse_Inventory` tables exist in your work environment).

## SQL Pipeline Highlights

This script showcases several key SQL capabilities for building a robust data backend:

1.  **Idempotent Design:** A duplicate table (`sales2`) is created to ensure that the cleaning and transformation logic can be re-run without affecting the raw source data.
2.  **Advanced Functions:** Utilizes window functions (`ROW_NUMBER() OVER PARTITION BY`) for efficient duplicate detection.
3.  **Event-Driven Automation:** The use of `DELIMITER` and `CREATE TRIGGER` statements builds an event-driven system where the sales data is automatically updated based on actions in other parts of the database ecosystem.
4.  **Dynamic Calculations:** Employs `CASE` statements and subqueries (Common Table Expressions or `CTEs`) to perform complex conditional aggregations, such as pivoting sales data by item status for different locations.

## Integration

The final `sales2` table is the "single source of truth" for this project. It is designed to be directly connected to:
*   **Python:** For deeper exploratory data analysis using Pandas.
*   **Power BI:** As the data source for the interactive Business Intelligence dashboard.

## Requirements

*   MySQL Server (Note, using a different platform like Postgres and/or SQL Server may change certain syntax slightly, so proceed accordingly)
*   Appropriate user privileges to `CREATE TABLE`, `ALTER TABLE`, and `CREATE TRIGGER`.
*   The existence of `Product_Tracker` and `Warehouse_Inventory` tables/databases for the triggers to function correctly.
