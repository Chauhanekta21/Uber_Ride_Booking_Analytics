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


SELECT * FROM dim_ride_reason;







