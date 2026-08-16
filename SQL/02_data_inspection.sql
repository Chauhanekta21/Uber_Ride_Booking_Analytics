-- STEP02: Inspected the raw dataset for structure, data quality, and consistency.


-- Step 01: Preview the dataset
SELECT *
FROM raw_uber_bookings;



-- Step 02: Count total records
SELECT COUNT(*) AS total_records
FROM raw_uber_bookings;



-- Step 03: View table structure
SELECT *
FROM information_schema.columns
WHERE TABLE_NAME = 'raw_uber_bookings';



-- Step 04: Check column data types
SELECT column_name, data_type
FROM information_schema.columns
WHERE TABLE_NAME = 'raw_uber_bookings';




-- STEP 05: Inspect distinct categorical values across key columns
SELECT DISTINCT booking_status
FROM raw_uber_bookings;

SELECT DISTINCT pickup_location
FROM raw_uber_bookings;

SELECT DISTINCT drop_location
FROM raw_uber_bookings;

SELECT DISTINCT customer_cancellation_reason
FROM raw_uber_bookings;

SELECT DISTINCT driver_cancellation_reason
FROM raw_uber_bookings;

SELECT DISTINCT incomplete_rides_reason
FROM raw_uber_bookings;

SELECT DISTINCT vehicle_type
FROM raw_uber_bookings;




-- Step 06: Check missing values
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(booking_date) AS date_nulls,
    COUNT(*) - COUNT(booking_time) AS time_nulls,
    COUNT(*) - COUNT(booking_id) AS booking_id_nulls,
    COUNT(*) - COUNT(booking_status) AS booking_status_nulls,
    COUNT(*) - COUNT(customer_id) AS customer_id_nulls,
    COUNT(*) - COUNT(vehicle_type) AS vehicle_type_nulls,
    COUNT(*) - COUNT(pickup_location) AS pickup_location_nulls,
    COUNT(*) - COUNT(drop_location) AS drop_location_nulls,
    COUNT(*) - COUNT(avg_vtat) AS avg_vtat_nulls,
    COUNT(*) - COUNT(avg_ctat) AS avg_ctat_nulls,
    COUNT(*) - COUNT(cancelled_rides_by_customer) AS cancelled_by_customer_nulls,
    COUNT(*) - COUNT(customer_cancellation_reason) AS customer_reason_nulls,
    COUNT(*) - COUNT(cancelled_rides_by_driver) AS cancelled_by_driver_nulls,
    COUNT(*) - COUNT(driver_cancellation_reason) AS driver_reason_nulls,
    COUNT(*) - COUNT(incomplete_rides) AS incomplete_rides_nulls,
    COUNT(*) - COUNT(incomplete_rides_reason) AS incomplete_reason_nulls,
    COUNT(*) - COUNT(booking_value) AS booking_value_nulls,
    COUNT(*) - COUNT(ride_distance) AS ride_distance_nulls,
    COUNT(*) - COUNT(driver_rating) AS driver_ratings_nulls,
    COUNT(*) - COUNT(customer_rating) AS customer_rating_nulls,
    COUNT(*) - COUNT(payment_method) AS payment_method_nulls
FROM raw_uber_bookings;




-- STEP 07: Validate NULL values by booking status
SELECT
    booking_status,
    COUNT(*) AS total_rides,

    COUNT(*) FILTER (WHERE avg_vtat IS NULL) AS avg_vtat_nulls,
    COUNT(*) FILTER (WHERE avg_ctat IS NULL) AS avg_ctat_nulls,

    COUNT(*) FILTER (WHERE cancelled_rides_by_customer IS NULL) AS cancelled_by_customer_nulls,
    COUNT(*) FILTER (WHERE customer_cancellation_reason IS NULL) AS customer_reason_nulls,

    COUNT(*) FILTER (WHERE cancelled_rides_by_driver IS NULL) AS cancelled_by_driver_nulls,
    COUNT(*) FILTER (WHERE driver_cancellation_reason IS NULL) AS driver_reason_nulls,

    COUNT(*) FILTER (WHERE incomplete_rides IS NULL) AS incomplete_rides_nulls,
    COUNT(*) FILTER (WHERE incomplete_rides_reason IS NULL) AS incomplete_reason_nulls,

    COUNT(*) FILTER (WHERE booking_value IS NULL) AS booking_value_nulls,
    COUNT(*) FILTER (WHERE ride_distance IS NULL) AS ride_distance_nulls,

    COUNT(*) FILTER (WHERE driver_rating IS NULL) AS driver_ratings_nulls,
    COUNT(*) FILTER (WHERE customer_rating IS NULL) AS customer_rating_nulls,

    COUNT(*) FILTER (WHERE payment_method IS NULL) AS payment_method_nulls

FROM raw_uber_bookings
GROUP BY booking_status
ORDER BY booking_status;




-- Step 08: Check blank values in text columns
SELECT
    COUNT(*) FILTER (WHERE TRIM(booking_id) = '') AS booking_id_blank,
    COUNT(*) FILTER (WHERE TRIM(booking_status) = '') AS booking_status_blank,
    COUNT(*) FILTER (WHERE TRIM(customer_id) = '') AS customer_id_blank,
    COUNT(*) FILTER (WHERE TRIM(vehicle_type) = '') AS vehicle_type_blank,
    COUNT(*) FILTER (WHERE TRIM(pickup_location) = '') AS pickup_location_blank,
    COUNT(*) FILTER (WHERE TRIM(drop_location) = '') AS drop_location_blank,
    COUNT(*) FILTER (WHERE TRIM(Customer_cancellation_reason) = '') AS customer_reason_blank,
    COUNT(*) FILTER (WHERE TRIM(driver_cancellation_reason) = '') AS driver_reason_blank,
    COUNT(*) FILTER (WHERE TRIM(incomplete_rides_reason) = '') AS incomplete_reason_blank,
    COUNT(*) FILTER (WHERE TRIM(payment_method) = '') AS payment_method_blank
FROM raw_uber_bookings;



-- Step 09: Check for leading/trailing spaces in text columns
SELECT *
FROM raw_uber_bookings
WHERE
    booking_id <> TRIM(booking_id)
    OR booking_status <> TRIM(booking_status)
    OR customer_id <> TRIM(customer_id)
    OR vehicle_type <> TRIM(vehicle_type)
    OR pickup_location <> TRIM(pickup_location)
    OR drop_location <> TRIM(drop_location)
    OR customer_cancellation_reason <> TRIM(customer_cancellation_reason)
    OR driver_cancellation_reason <> TRIM(driver_cancellation_reason)
    OR incomplete_rides_reason <> TRIM(incomplete_rides_reason)
    OR payment_method <> TRIM(payment_method);



-- Step 10: Check duplicate records
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT(booking_id)) AS distinct_rows, 
	   COUNT(*) - COUNT(DISTINCT(booking_id)) AS duplicate_rows
FROM raw_uber_bookings;




-- STEP 11: Check duplicate booking IDs
SELECT booking_id, COUNT(*) AS duplicate_count
FROM raw_uber_bookings
GROUP BY booking_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Checking few individual booking_ids
SELECT *
FROM raw_uber_bookings
WHERE booking_id = 'CNR9603232';  




-- Step 12: Check for exact duplicate rows
SELECT *,
       COUNT(*) AS duplicate_count
FROM raw_uber_bookings
GROUP BY
    booking_date, booking_time, booking_id, booking_status, customer_id,
    vehicle_type, pickup_location, drop_location,
    avg_vtat, avg_ctat,
    cancelled_rides_by_customer,
    customer_cancellation_reason,
    cancelled_rides_by_driver,
    driver_cancellation_reason,
    incomplete_rides,
    incomplete_rides_reason,
    booking_value,
    ride_distance,
    driver_rating,
    customer_rating,
    payment_method
HAVING COUNT(*) > 1;




-- STEP 13: Inspect customer ID uniqueness and repeated customer records
-- Sub-step 13.1: Compare total customer records with distinct customers
SELECT COUNT(customer_id) AS total_records, COUNT(DISTINCT(customer_id)) AS distint_customer_count,
	   COUNT(customer_id) - COUNT(DISTINCT(customer_id)) AS duplicate_count
FROM raw_uber_bookings;

-- Sub-step 13.2: Identify customers with multiple bookings
SELECT customer_id, count(*) AS duplicate_count
FROM raw_uber_bookings
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 30;

-- Sub-step 13.3: Inspect an individual customer with multiple bookings
SELECT *
FROM raw_uber_bookings
WHERE customer_id = 'CID6715450';




-- STEP 14: Inspect binary ride indicator columns
SELECT DISTINCT incomplete_rides, cancelled_rides_by_customer, cancelled_rides_by_driver
FROM raw_uber_bookings;



-- STEP 15: Check for invalid negative values
SELECT *
FROM raw_uber_bookings
WHERE avg_vtat < 0
   OR avg_ctat < 0
   OR booking_value < 0
   OR ride_distance < 0
   OR driver_rating < 0
   OR customer_rating < 0;




-- STEP 16: Check for statistical outliers using the IQR method

WITH stats AS (
    SELECT
        percentile_cont(0.25) WITHIN GROUP (ORDER BY avg_vtat) AS vtat_q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY avg_vtat) AS vtat_q3,

        percentile_cont(0.25) WITHIN GROUP (ORDER BY avg_ctat) AS ctat_q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY avg_ctat) AS ctat_q3,

        percentile_cont(0.25) WITHIN GROUP (ORDER BY booking_value) AS value_q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY booking_value) AS value_q3,

        percentile_cont(0.25) WITHIN GROUP (ORDER BY ride_distance) AS distance_q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY ride_distance) AS distance_q3,

        percentile_cont(0.25) WITHIN GROUP (ORDER BY driver_rating) AS driver_q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY driver_rating) AS driver_q3,

        percentile_cont(0.25) WITHIN GROUP (ORDER BY customer_rating) AS customer_q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY customer_rating) AS customer_q3
    FROM raw_uber_bookings
),

outliers AS (
    SELECT
        COUNT(*) FILTER (
            WHERE avg_vtat < vtat_q1 - 1.5 * (vtat_q3 - vtat_q1)
               OR avg_vtat > vtat_q3 + 1.5 * (vtat_q3 - vtat_q1)
        ) AS vtat_outliers,

        COUNT(*) FILTER (
            WHERE avg_ctat < ctat_q1 - 1.5 * (ctat_q3 - ctat_q1)
               OR avg_ctat > ctat_q3 + 1.5 * (ctat_q3 - ctat_q1)
        ) AS ctat_outliers,

        COUNT(*) FILTER (
            WHERE booking_value < value_q1 - 1.5 * (value_q3 - value_q1)
               OR booking_value > value_q3 + 1.5 * (value_q3 - value_q1)
        ) AS booking_value_outliers,

        COUNT(*) FILTER (
            WHERE ride_distance < distance_q1 - 1.5 * (distance_q3 - distance_q1)
               OR ride_distance > distance_q3 + 1.5 * (distance_q3 - distance_q1)
        ) AS distance_outliers,

        COUNT(*) FILTER (
            WHERE driver_rating < driver_q1 - 1.5 * (driver_q3 - driver_q1)
               OR driver_rating > driver_q3 + 1.5 * (driver_q3 - driver_q1)
        ) AS driver_rating_outliers,

        COUNT(*) FILTER (
            WHERE customer_rating < customer_q1 - 1.5 * (customer_q3 - customer_q1)
               OR customer_rating > customer_q3 + 1.5 * (customer_q3 - customer_q1)
        ) AS customer_rating_outliers
    FROM raw_uber_bookings
    CROSS JOIN stats
)

SELECT *
FROM outliers;



-- STEP 17: Validate rating and booking value ranges
SELECT
    MIN(driver_rating) AS min_driver_rating,
    MAX(driver_rating) AS max_driver_rating,
    MIN(customer_rating) AS min_customer_rating,
    MAX(customer_rating) AS max_customer_rating,
    MIN(booking_value) AS min_booking_value,
    MAX(booking_value) AS max_booking_value
FROM raw_uber_bookings;




-- STEP 18: Validate booking values by booking status
SELECT
    booking_status,
    MIN(booking_value) AS min_value,
    MAX(booking_value) AS max_value,
    AVG(booking_value) AS avg_value
FROM raw_uber_bookings
WHERE booking_value IS NOT NULL
GROUP BY booking_status
ORDER BY booking_status;




-- STEP 19: Inspect high-value bookings
SELECT
    booking_value,
    ride_distance,
    vehicle_type,
    pickup_location,
    drop_location
FROM raw_uber_bookings
WHERE booking_value > 1000
ORDER BY booking_value DESC
LIMIT 30;