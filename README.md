
## 📊 Uber Ride Booking Analytics & Operations


![Data Model](Images/uber_thumbnail.png)

---

## 📈 Project Overview

- This project analyzes Uber ride booking data to uncover actionable business insights related to customer behavior, driver                 performance, revenue, booking trends, cancellations, payment preferences, and operational efficiency.

- The project uses PostgreSQL for database design and SQL analysis, followed by Python and Streamlit for visualization and deployment.

---

## 📈 Objectives

- Analyze booking patterns by month, day, and hour.

- Evaluate driver and customer performance using ratings.

- Identify revenue patterns across vehicle types and locations.

- Analyze ride cancellations and their reasons.

- Examine payment method preferences.

- Measure operational efficiency using pickup and trip time metrics.

- Generate business insights using advanced SQL queries.

---

## 📈 Tech Stack

- **Database               :**  PostgreSQL
- **Query Language         :**  SQL
- **Programming Language   :**  Python
- **Libraries              :**  Pandas, SQLAlchemy, Plotly, Seaborn, Streamlit
- **IDE:** VS Code
- **Version Control        :**  Git & GitHub

---

## 📈 Dataset Overview

- This section provides an overview of the dataset, including its   source, structure, scope, and key features used for analysis

### 🔹 Dataset Information

- **Dataset:** Uber Ride Analytics Dataset (2024)
- **Source:** Kaggle
- **Total Records:** 150,000
- **Time Period:** 2024
- **Location:** Delhi NCR (National Capital Region), India
- **Granularity:** One row represents one ride booking.


### 🔹 Features Included

- Booking Details
- Customer Information
- Vehicle Information
- Ride Information
- Payment Information
- Ratings
- Cancellation Details
- Operational Metrics

### 🔹 Dataset Link: [Uber Ride Booking Dataset](https://github.com/Chauhanekta21/Uber_Ride_Booking_Analytics/tree/main/Dataset/Raw)

---

## 📈 Analytics Workflow

```text
Raw Dataset (CSV)
        ↓
PostgreSQL Database
        ↓
Raw Data Import
        ↓
Data Inspection (SQL)
        ↓
Data Cleaning (SQL)
        ↓
Database Normalization
        ↓
ER Diagram
        ↓
Normalized Tables
        ↓
Data Loading
        ↓
SQL Analysis
        ↓
Views & Indexes
        ↓
Python + SQLAlchemy
        ↓
Streamlit Dashboard
        ↓
Project Deployment
```

---


## 📈 PostgreSQL Database Setup

- Created a PostgreSQL database named **`uber_ride_booking_db`** to store and manage the Uber Ride Booking dataset for SQL-based data       analysis.

---

## 📈 Raw Data Import

- Imported the raw CSV dataset into the **`raw_uber_bookings`** table using pgAdmin's Import/Export tool. The table contains all            original dataset features without modification. 

- During import, `"null"` string values were mapped to SQL `NULL` values to ensure proper data type handling and prevent import errors.


---


## 📈 Data Inspection

The raw dataset was inspected to understand its structure and assess overall data quality before performing any cleaning or transformation.

The raw dataset was inspected to understand its structure, data quality, consistency, and categorical values before performing any cleaning or transformation.

Step 01 — Dataset Preview: Previewed the raw dataset to verify that the imported records and columns were accessible in PostgreSQL.
Step 02 — Record Count: Confirmed the dataset contains 150,000 records and 21 columns.
Step 03 — Table Structure: Reviewed the table structure and column metadata of raw_uber_bookings.
Step 04 — Data Types: Reviewed the data type of each column to ensure values were stored appropriately.
Step 05 — Categorical Values: Inspected distinct values across booking_status, pickup/drop-off locations, customer cancellation reasons, driver cancellation reasons, and incomplete ride reasons to understand the categories present in the dataset.
Step 06 — NULL Values: Checked all columns for missing (NULL) values. Missing values were found mainly in ride metrics, cancellation-related fields, ratings, booking value, ride distance, and payment method.
Step 07 — NULL Validation: Validated the identified NULL values against booking_status. The results showed that the missing values correspond to expected ride outcomes. Conclusion: all identified NULL values are contextually valid and do not require imputation.
Step 08 — Blank Values: Checked relevant text columns for blank ('') values using TRIM(). Result: no blank values were found.
Step 09 — Booking ID Distribution: Compared total records with distinct booking_ids. Out of 150,000 records, 148,767 booking IDs are distinct, resulting in 1,233 additional records associated with repeated booking IDs.
Step 10 — Repeated Booking IDs: Identified booking IDs appearing more than once and investigated individual examples. Repeated IDs were found to contain different ride details rather than identical records. Conclusion: booking_id is not strictly unique in the dataset, and these records were retained.
Step 11 — Exact Duplicate Records: Compared all columns to identify completely identical records. Result: 0 exact duplicate records were found.
Step 12 — Customer ID Distribution: Compared total customer records with distinct customer_ids and identified customers with multiple bookings. Result: 148,788 distinct customers across 150,000 records. Individual customer records were also inspected and confirmed that repeated customer IDs represent multiple bookings rather than duplicate records.
Step 13 — Binary Ride Indicators: Inspected incomplete_rides, cancelled_rides_by_customer, and cancelled_rides_by_driver. Result: the columns contain only 1 or NULL values, confirming that they function as binary ride indicators. These columns will be standardized during the Cleaning stage.


---

## 📈 Data Cleaning





## Dataset Disclaimer

- This dataset is intended for educational purposes, portfolio development, and business analytics learning. It should not be considered    official Uber operational data.

---
