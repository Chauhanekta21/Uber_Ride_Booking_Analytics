-- STEP05 : Uber Rides Booking Analysis Using SQL


-- Step 05.1: Overall Booking Performance
-- Total number of ride bookings
SELECT COUNT(*) AS total_bookings
FROM fact_ride_booking;


-- Bookings distribution across the 5 booking statuses
SELECT booking_status, 
	   COUNT(booking_id) AS total_bookings, 
	   ROUND((COUNT(booking_id)::NUMERIC / SUM(COUNT(*)) OVER() * 100), 2) AS booking_percentage
FROM fact_ride_booking
GROUP BY booking_status
ORDER BY total_bookings DESC;


-- Total booking value generated from all rides
SELECT COALESCE(SUM(booking_value), 0) AS total_booking_value
FROM fact_ride_booking;


-- Average booking value per ride
SELECT ROUND(COALESCE(AVG(booking_value), 0), 2) AS average_booking_value
FROM fact_ride_booking;


-- Average distance per ride
SELECT ROUND(COALESCE(AVG(ride_distance), 0), 2) AS average_distance
FROM fact_ride_booking;


-- Average VTAT and CTAT for completed rides
SELECT ROUND(COALESCE(AVG(avg_vtat), 0), 2) AS completed_avg_vtat, 
	   ROUND(COALESCE(AVG(avg_ctat), 0), 2) AS completed_avg_ctat
FROM fact_ride_booking
WHERE booking_status = 'Completed';

select MIN()







-- Step 05.2: Customer-Level Booking Analysis
-- How many unique customers have made bookings?
SELECT COUNT(customer_id) AS total_unique_customer
FROM dim_customer;


-- How many customers are repeat customers (more than one booking)?
SELECT COUNT(*) AS repeat_customer_count
FROM (
    SELECT customer_id
    FROM fact_ride_booking
    GROUP BY customer_id
    HAVING COUNT(booking_id) > 1
);


-- Average number of bookings per customer
SELECT ROUND(AVG(total_bookings), 2) AS avg_bookings_per_customer
FROM (
	SELECT customer_id, COUNT(booking_id) AS total_bookings
	FROM fact_ride_booking
	GROUP BY customer_id
) AS customer_bookings;


-- Top 10 most active customers based on booking count?
SELECT customer_id, COUNT(booking_id) AS total_bookings
FROM fact_ride_booking
GROUP BY customer_id
ORDER BY total_bookings DESC
LIMIT 10;


-- Percentage of customers are repeat vs one-time customers?
SELECT
    ROUND(COUNT(*) FILTER (WHERE total_bookings = 1)::NUMERIC / COUNT(*) * 100, 2) AS one_time_customer_percent,
	ROUND(COUNT(*) FILTER (WHERE total_bookings > 1)::NUMERIC / COUNT(*) * 100, 2) AS repeat_customer_percent
FROM (
    SELECT customer_id, COUNT(booking_id) AS total_bookings
    FROM fact_ride_booking
    GROUP BY customer_id
) AS customer_bookings;


-- Average booking value per customer?
SELECT ROUND(AVG(total_booking_value), 2) AS avg_booking_value_per_customer
FROM (
	SELECT customer_id, SUM(booking_value) AS total_booking_value
	FROM fact_ride_booking
	GROUP BY customer_id
) AS customer_booking_value;


-- Customers have generated the highest total booking value?
SELECT customer_id, COALESCE(SUM(booking_value), 0) AS total_booking_value
FROM fact_ride_booking
GROUP BY customer_id
ORDER BY total_booking_value DESC;


-- Average cancellation rate for customers?
SELECT ROUND(AVG(cancellation_rate), 2) AS avg_customer_cancellation_rate
FROM (
    SELECT customer_id,
           COUNT(*) FILTER (WHERE booking_status = 'Cancelled by Customer')::NUMERIC / COUNT(*) * 100 AS cancellation_rate
    FROM fact_ride_booking
    GROUP BY customer_id
) AS customer_cancellation;


-- Customers have the highest cancellation rate, considering only customers with at >=2 bookings?  
SELECT 
    customer_id, 
	COUNT(*) AS total_bookings,
    COUNT(*) FILTER (WHERE booking_status = 'Cancelled by Customer') AS cancelled_bookings,
    ROUND(COUNT(*) FILTER (WHERE booking_status = 'Cancelled by Customer')::NUMERIC / COUNT(*) * 100, 2) AS cancellation_rate
FROM fact_ride_booking
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY cancellation_rate DESC;


-- Do repeat customers have a higher average booking value than one-time customers?  
SELECT
    CASE
        WHEN total_bookings = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    ROUND(AVG(total_booking_value), 2) AS avg_booking_value
FROM (
    SELECT
        customer_id,
        COUNT(booking_id) AS total_bookings,
        SUM(booking_value) AS total_booking_value
    FROM fact_ride_booking
    GROUP BY customer_id
) AS customer_summary
GROUP BY customer_type;         







-- Step 05.3: Vehicle Performance
-- Total bookings made for each vehicle type
SELECT v.vehicle_type, COUNT(f.booking_id) AS total_bookings,
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type;


-- Percentage of bookings for each vehicle type were completed
SELECT v.vehicle_type, ROUND(COUNT(*) FILTER (WHERE f.booking_status = 'Completed')::NUMERIC / COUNT(*) * 100, 2) AS completion_rate
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY completion_rate DESC;


-- Cancellation rate for each vehicle type
SELECT v.vehicle_type, ROUND(COUNT(*) FILTER (WHERE f.booking_status IN ('Cancelled by Driver', 'Cancelled by Customer'))::NUMERIC / COUNT(*) * 100, 2) AS cancellation_rate
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY cancellation_rate DESC;


-- Average booking value for each vehicle type
SELECT v.vehicle_type, ROUND(AVG(f.booking_value), 2) AS avg_booking_value
FROM fact_ride_booking f 
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type        
ORDER BY avg_booking_value DESC;


-- Average ride distance for each vehicle type
SELECT v.vehicle_type, ROUND(AVG(f.ride_distance), 2) AS avg_ride_distance
FROM fact_ride_booking f 
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type        
ORDER BY avg_ride_distance DESC;


-- Average customer rating for each vehicle type
SELECT v.vehicle_type, ROUND(AVG(f.ride_distance), 2) AS avg_ride_distance
FROM fact_ride_booking f 
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type        
ORDER BY avg_ride_distance DESC;


-- Vehicle generated the highest total booking value
Select v.vehicle_type, SUM(f.booking_value) AS highest_booking_value
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY highest_booking_value DESC
LIMIT 1;


-- Vehicle has the highest average booking value
Select v.vehicle_type, ROUND(AVG(f.booking_value), 2) AS highest_avg_booking_value
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY highest_avg_booking_value DESC
LIMIT 1;


-- Vehicles have an above-average completion rate
SELECT v.vehicle_type, ROUND(COUNT(*) FILTER (WHERE f.booking_status = 'Completed')::NUMERIC/ COUNT(*) * 100,2) AS completion_rate
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
HAVING COUNT(*) FILTER (WHERE f.booking_status = 'Completed')::NUMERIC / COUNT(*) * 100 > (
        SELECT AVG(completion_rate)
        FROM (
            SELECT v2.vehicle_type, COUNT(*) FILTER (WHERE f2.booking_status = 'Completed')::NUMERIC / COUNT(*) * 100 AS completion_rate
            FROM fact_ride_booking f2
            JOIN dim_vehicle v2
            ON f2.vehicle_id = v2.vehicle_id
            GROUP BY v2.vehicle_type) AS vehicle_completion)
ORDER BY completion_rate DESC;
	  


-- Summary
SELECT v.vehicle_type, 
	   COUNT(f.booking_id) AS total_bookings,
	   ROUND(COUNT(*) FILTER (WHERE f.booking_status = 'Completed')::NUMERIC / COUNT(*) * 100, 2) AS completion_rate,
	   ROUND(COUNT(*) FILTER (WHERE f.booking_status IN ('Cancelled by Driver', 'Cancelled by Customer'))::NUMERIC / COUNT(*) * 100, 2) AS cancellation_rate,
	   ROUND(AVG(f.booking_value), 2) AS avg_booking_value,
	   ROUND(AVG(f.ride_distance), 2) AS avg_ride_distance,
	   ROUND(AVG(f.customer_rating), 2) AS avg_customer_rating
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type;







-- Step 05.4: Booking Cancellation Analysis
-- Total bookings cancelled by customers vs drivers
SELECT booking_status, COUNT(*) AS total_bookings
FROM fact_ride_booking
GROUP BY booking_status
HAVING booking_status IN ('Cancelled by Driver', 'Cancelled by Customer')
ORDER BY total_bookings DESC;


-- Percentage of all bookings were customer vs driver cancellations
SELECT
    ROUND(COUNT(*) FILTER (WHERE booking_status = 'Cancelled by Customer')::NUMERIC / COUNT(*) * 100, 2) AS customer_cancellation_percentage,
	ROUND(COUNT(*) FILTER (WHERE booking_status = 'Cancelled by Driver')::NUMERIC / COUNT(*) * 100, 2) AS driver_cancellation_percentage
FROM fact_ride_booking;


-- Top cancellation reasons for customers
SELECT r.reason, COUNT(*) AS cancellation_count
FROM fact_ride_booking f
JOIN dim_ride_cancellation_reason r
ON f.customer_reason_id = r.reason_id
WHERE f.booking_status = 'Cancelled by Customer'
GROUP BY r.reason
ORDER BY cancellation_count DESC;


-- Top cancellation reasons for drivers
SELECT r.reason, COUNT(*) AS cancellation_count
FROM fact_ride_booking f
JOIN dim_ride_cancellation_reason r
ON f.driver_reason_id = r.reason_id
WHERE f.booking_status = 'Cancelled by Driver'
GROUP BY r.reason
ORDER BY cancellation_count DESC;


-- Pickup locations have the highest cancellation rates
SELECT
    l.location_name AS pickup_location,
    COUNT(*) AS total_bookings,
    COUNT(*) FILTER (WHERE f.booking_status IN ('Cancelled by Customer', 'Cancelled by Driver')) AS cancelled_bookings,
    ROUND(COUNT(*) FILTER (WHERE f.booking_status IN ('Cancelled by Customer', 'Cancelled by Driver'))::NUMERIC / COUNT(*) * 100, 2) AS cancellation_rate
FROM fact_ride_booking f
JOIN dim_location l
ON f.pickup_location_id = l.location_id
GROUP BY l.location_name
HAVING COUNT(*) >= 100
ORDER BY cancellation_rate DESC
LIMIT 10;


-- For each vehicle type, compare customer cancellations vs driver cancellations.
SELECT v.vehicle_type, 
       COUNT(*) FILTER (WHERE f.booking_status = 'Cancelled by Customer') AS customer_cancellations,
       COUNT(*) FILTER (WHERE f.booking_status = 'Cancelled by Driver') AS driver_cancellations
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY v.vehicle_type;







-- Step 05.5: Location Analysis
-- Top 10 pickup locations by booking count
SELECT l.location_name, COUNT(f.booking_id) AS total_bookings
FROM fact_ride_booking f
JOIN dim_location l
ON l.location_id = f.pickup_location_id
GROUP BY l.location_name
ORDER BY total_bookings DESC
LIMIT 10;


-- Top 10 drop locations by booking count
SELECT l.location_name, COUNT(f.booking_id) AS total_bookings
FROM fact_ride_booking f
JOIN dim_location l
ON l.location_id = f.drop_location_id
GROUP BY l.location_name
ORDER BY total_bookings DESC
LIMIT 10;


-- Most common pickup → drop routes
SELECT
    pickup.location_name AS pickup_location,
    drop.location_name AS drop_location,
    COUNT(f.booking_id) AS total_bookings
FROM fact_ride_booking f
JOIN dim_location pickup
ON f.pickup_location_id = pickup.location_id
JOIN dim_location drop
ON f.drop_location_id = drop.location_id
GROUP BY pickup.location_name, drop.location_name
ORDER BY total_bookings DESC
LIMIT 10;


-- Routes have the highest number of completed rides
SELECT
    pickup.location_name AS pickup_location,
    dropoff.location_name AS drop_location,
    COUNT(f.booking_id) AS completed_rides
FROM fact_ride_booking f
JOIN dim_location pickup
    ON f.pickup_location_id = pickup.location_id
JOIN dim_location dropoff
    ON f.drop_location_id = dropoff.location_id
WHERE f.booking_status = 'Completed'
GROUP BY pickup.location_name, dropoff.location_name
ORDER BY completed_rides DESC
LIMIT 10;


-- Average booking value by pickup location
SELECT l.location_name AS pickup_location, ROUND(AVG(f.booking_value), 2) AS avg_booking_value
FROM fact_ride_booking f
JOIN dim_location l
ON f.pickup_location_id = l.location_id
GROUP BY l.location_name
ORDER BY avg_booking_value DESC;


-- Which pickup locations have the highest average ride distance
SELECT
    l.location_name AS pickup_location,
    COUNT(f.booking_id) AS total_bookings,
    ROUND(AVG(f.ride_distance), 2) AS avg_ride_distance
FROM fact_ride_booking f
JOIN dim_location l
ON f.pickup_location_id = l.location_id
GROUP BY l.location_name
HAVING COUNT(f.booking_id) >= 100
ORDER BY avg_ride_distance DESC
LIMIT 10;


-- Top 10 completion rate by pickup location
SELECT
    l.location_name AS pickup_location,
    COUNT(f.booking_id) AS total_bookings,
    ROUND(COUNT(*) FILTER (WHERE f.booking_status = 'Completed')::NUMERIC / COUNT(*) * 100, 2) AS completion_rate
FROM fact_ride_booking f
JOIN dim_location l
ON f.pickup_location_id = l.location_id
GROUP BY l.location_name
HAVING COUNT(f.booking_id) >= 100
ORDER BY completion_rate DESC
LIMIT 10;


-- Which pickup locations generate the highest total booking value?
SELECT l.location_name AS pickup_location,
       SUM(f.booking_value) AS total_booking_value
FROM fact_ride_booking f
JOIN dim_location l
ON f.pickup_location_id = l.location_id
GROUP BY l.location_name
ORDER BY total_booking_value DESC
LIMIT 10;


-- Which routes have the highest cancellation rate, considering routes with at least 50 bookings?
SELECT
    pickup.location_name AS pickup_location,
    dropoff.location_name AS drop_location,
    COUNT(f.booking_id) AS total_bookings,
    COUNT(*) FILTER (WHERE f.booking_status IN ('Cancelled by Customer', 'Cancelled by Driver')) AS cancelled_bookings,
    ROUND(COUNT(*) FILTER (WHERE f.booking_status IN ('Cancelled by Customer', 'Cancelled by Driver'))::NUMERIC / COUNT(*) * 100, 2) AS cancellation_rate
FROM fact_ride_booking f
JOIN dim_location pickup
ON f.pickup_location_id = pickup.location_id
JOIN dim_location dropoff
ON f.drop_location_id = dropoff.location_id
GROUP BY pickup.location_name, dropoff.location_name
HAVING COUNT(f.booking_id) >= 10
ORDER BY cancellation_rate DESC
LIMIT 10;


-- Which locations show high demand but low completion rates?
SELECT l.location_name AS pickup_location,
       COUNT(f.booking_id) AS total_bookings,
       ROUND(COUNT(*) FILTER (WHERE f.booking_status = 'Completed')::NUMERIC / COUNT(*) * 100, 2) AS completion_rate
FROM fact_ride_booking f
JOIN dim_location l
ON f.pickup_location_id = l.location_id
GROUP BY l.location_name
HAVING COUNT(f.booking_id) > (
        SELECT AVG(total_bookings)
        FROM (
            SELECT pickup_location_id, COUNT(*) AS total_bookings
            FROM fact_ride_booking
            GROUP BY pickup_location_id) t
    )
    AND
    COUNT(*) FILTER (WHERE f.booking_status = 'Completed')::NUMERIC / COUNT(*) * 100 < (
        SELECT AVG(completion_rate)
        FROM (
            SELECT
                pickup_location_id,
                COUNT(*) FILTER (WHERE booking_status = 'Completed')::NUMERIC / COUNT(*) * 100 AS completion_rate
            FROM fact_ride_booking
            GROUP BY pickup_location_id) t
    )
ORDER BY total_bookings DESC;




 
