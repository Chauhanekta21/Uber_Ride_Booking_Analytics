-- STEP04: Normalize the cleaned Uber bookings data


-- Step 04.1: Create customer dimension table
CREATE TABLE IF NOT EXISTS dim_customer(
	customer_id VARCHAR(50) PRIMARY KEY
);

-- Step 04.2: Populate customer dimension
INSERT INTO dim_customer(customer_id)
SELECT DISTINCT customer_id
FROM clean_uber_bookings
WHERE customer_id IS NOT NULL;

-- Step 04.3: Validate customer dimension
SELECT COUNT(*) AS total_customers
FROM dim_customer;




-- Step 04.4 — Create vehicle dimension table
CREATE TABLE IF NOT EXISTS dim_vehicle(
	vehicle_id VARCHAR(10) PRIMARY KEY,
	vehicle_type VARCHAR(50) UNIQUE NOT NULL
);

-- Step 04.5: Generate vehicle IDs and insert vehicle types
INSERT INTO dim_vehicle(vehicle_id, vehicle_type)
SELECT 'V' || LPAD(ROW_NUMBER() OVER (ORDER BY vehicle_type)::TEXT, 2, '0') AS vehicle_id, vehicle_type
FROM(
	SELECT DISTINCT vehicle_type
	FROM clean_uber_bookings
	WHERE vehicle_type IS NOT NULL
) AS vehicles;





-- Step 04.6: Create location dimension table
CREATE TABLE IF NOT EXISTS dim_location(
	location_id VARCHAR(10) PRIMARY KEY,
	location_name VARCHAR(100) UNIQUE NOT NULL
);

-- Step 04.7: Generate location IDs and insert locations
INSERT INTO dim_location(location_id, location_name)
SELECT 'L' || LPAD(ROW_NUMBER() OVER (ORDER BY location_name)::TEXT, 3, '0') AS location_id, location_name
FROM (
	SELECT pickup_location AS location_name
	FROM clean_uber_bookings
	WHERE pickup_location IS NOT NULL

	UNION

	SELECT drop_location AS location_name
	FROM clean_uber_bookings
	WHERE drop_location IS NOT NULL
) AS locations;





-- Step 04.8: Create ride reason dimension table
CREATE TABLE IF NOT EXISTS dim_ride_reason(
	reason_id VARCHAR(10) PRIMARY KEY,
	reason_type VARCHAR(30) NOT NULL,
	reason VARCHAR(100) NOT NULL
)

-- Step 04.9: Add all ride reasons to the dimension
INSERT INTO dim_ride_reason(reason_id, reason_type, reason)
SELECT 'R' || LPAD(ROW_NUMBER() OVER (ORDER BY reason_type, reason)::TEXT, 2, '0') AS reason_id, reason_type, reason
FROM(
	SELECT 'Customer Cancellation' AS reason_type, customer_cancellation_reason AS reason
	FROM clean_uber_bookings
	WHERE customer_cancellation_reason IS NOT NULL

	UNION

	SELECT 'Driver Cancellation' AS reason_type, driver_cancellation_reason AS reason
	FROM clean_uber_bookings
	WHERE driver_cancellation_reason IS NOT NULL

	UNION 

	SELECT 'Incomplete Ride' AS reason_type, incomplete_ride_reason AS reason
	FROM clean_uber_bookings
	WHERE incomplete_ride_reason IS NOT NULL
) AS reasons;





-- Step 04.11: Create ride booking fact table
CREATE TABLE IF NOT EXISTS fact_ride_booking(
	ride_id BIGSERIAL PRIMARY KEY,
	booking_id VARCHAR(50),
    booking_date DATE,
    booking_time TIME,
    booking_status VARCHAR(30),

    customer_id VARCHAR(50),
    vehicle_id VARCHAR(10),
    pickup_location_id VARCHAR(10),
    drop_location_id VARCHAR(10),

	avg_vtat NUMERIC,
    avg_ctat NUMERIC,

    cancelled_ride_by_customer INTEGER,
    customer_reason_id VARCHAR(10),

    cancelled_ride_by_driver INTEGER,
    driver_reason_id VARCHAR(10),

    incomplete_ride INTEGER,
    incomplete_reason_id VARCHAR(10),

	booking_value NUMERIC,
    ride_distance NUMERIC,
    driver_rating NUMERIC,
    customer_rating NUMERIC,

    payment_method VARCHAR(50)
);

-- Step 04.12: Insert data into fact_ride_booking
INSERT INTO fact_ride_booking (
    booking_id,
    booking_date,
    booking_time,
    booking_status,
    customer_id,
    vehicle_id,
    pickup_location_id,
    drop_location_id,
    avg_vtat,
    avg_ctat,
    cancelled_ride_by_customer,
    customer_reason_id,
    cancelled_ride_by_driver,
    driver_reason_id,
    incomplete_ride,
    incomplete_reason_id,
    booking_value,
    ride_distance,
    driver_rating,
    customer_rating,
    payment_method
)
SELECT
    c.booking_id,
    c.booking_date,
    c.booking_time,
    c.booking_status,
    c.customer_id,
    v.vehicle_id,
    pl.location_id,
    dl.location_id,
    c.avg_vtat,
    c.avg_ctat,
    c.cancelled_ride_by_customer,
    cr.reason_id,
    c.cancelled_ride_by_driver,
    dr.reason_id,
    c.incomplete_ride,
    ir.reason_id,
    c.booking_value,
    c.ride_distance,
    c.driver_rating,
    c.customer_rating,
    c.payment_method

FROM clean_uber_bookings c

LEFT JOIN dim_vehicle v
    ON c.vehicle_type = v.vehicle_type

LEFT JOIN dim_location pl
    ON c.pickup_location = pl.location_name

LEFT JOIN dim_location dl
    ON c.drop_location = dl.location_name

LEFT JOIN dim_ride_reason cr
    ON c.customer_cancellation_reason = cr.reason
    AND cr.reason_type = 'Customer Cancellation'

LEFT JOIN dim_ride_reason dr
    ON c.driver_cancellation_reason = dr.reason
    AND dr.reason_type = 'Driver Cancellation'

LEFT JOIN dim_ride_reason ir
    ON c.incomplete_ride_reason = ir.reason
    AND ir.reason_type = 'Incomplete Ride';






-- Step 04.13: Validate fact table data
-- Verify that the inserted records, ride IDs, and dimension mappings are correct.

-- Check total records
SELECT COUNT(*) AS total_rides
FROM fact_ride_booking;

-- Check ride ID uniqueness
SELECT COUNT(*) AS total_ids,
       COUNT(DISTINCT ride_id) AS unique_ids
FROM fact_ride_booking;

-- Check dimension ID mappings
-- All mandatory dimension mappings should have 0 missing values.
SELECT
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer,
    COUNT(*) FILTER (WHERE vehicle_id IS NULL) AS missing_vehicle,
    COUNT(*) FILTER (WHERE pickup_location_id IS NULL) AS missing_pickup,
    COUNT(*) FILTER (WHERE drop_location_id IS NULL) AS missing_drop
FROM fact_ride_booking;

-- Preview fact table records
SELECT *
FROM fact_ride_booking;





-- Step 04.14: Add foreign key relationships
-- Connect the fact table with its dimension tables.
ALTER TABLE fact_ride_booking
ADD CONSTRAINT fk_customer
FOREIGN KEY(customer_id)
REFERENCES dim_customer(customer_id);

ALTER TABLE fact_ride_booking
ADD CONSTRAINT fk_vehicle
FOREIGN KEY(vehicle_id)
REFERENCES dim_vehicle(vehicle_id);

ALTER TABLE fact_ride_booking
ADD CONSTRAINT fk_pickup_location
FOREIGN KEY (pickup_location_id)
REFERENCES dim_location(location_id);

ALTER TABLE fact_ride_booking
ADD CONSTRAINT fk_drop_location
FOREIGN KEY (drop_location_id)
REFERENCES dim_location(location_id);

ALTER TABLE fact_ride_booking
ADD CONSTRAINT fk_customer_reason
FOREIGN KEY (customer_reason_id)
REFERENCES dim_ride_reason(reason_id);

ALTER TABLE fact_ride_booking
ADD CONSTRAINT fk_driver_reason
FOREIGN KEY (driver_reason_id)
REFERENCES dim_ride_reason(reason_id);

ALTER TABLE fact_ride_booking
ADD CONSTRAINT fk_incomplete_reason
FOREIGN KEY (incomplete_reason_id)
REFERENCES dim_ride_reason(reason_id);











