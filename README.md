
## 📊 Uber Ride Booking Analytics & Operations


![Data Model](Images/uber_thumbnail2.png)

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

- Verified the dataset was successfully imported into PostgreSQL.
  Confirmed the dataset contains 150,000 records and 21 columns.

- Reviewed the data type of each column to ensure values were stored correctly.

- Checked for missing (NULL) values across all columns.

- Identified expected missing values in columns related to cancellations, incomplete rides, ratings, ride distance, booking value, and      payment method.

- Checked all text columns for blank ('') values and confirmed that no blank values were present.

- Checked for duplicate booking_id values and found 1,233 repeated booking IDs.

- Verified that no exact duplicate rows exist when considering all columns.


---


## Dataset Disclaimer

- This dataset is intended for educational purposes, portfolio development, and business analytics learning. It should not be considered    official Uber operational data.

---
