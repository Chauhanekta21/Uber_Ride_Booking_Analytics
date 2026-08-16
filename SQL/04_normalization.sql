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




-- Step 04.4 — Create dim_vehicle
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

SELECT *
FROM dim_vehicle;