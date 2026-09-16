-- STEP05 : Uber Rides Booking Analysis Using SQL


-- Step 05.1: Overall Booking Performance
-- Total number of ride bookings
SELECT COUNT(*) AS total_bookings
FROM fact_ride_booking;


--Bookings distribution across the 5 booking statuses
SELECT booking_status, 
	   COUNT(booking_id) AS total_bookings, 
	   ROUND((COUNT(booking_id)::NUMERIC / SUM(COUNT(*)) OVER() * 100), 2) AS booking_percentage
FROM fact_ride_booking
GROUP BY booking_status
ORDER BY total_bookings DESC;


--Total booking value generated from all rides
SELECT COALESCE(SUM(booking_value), 0) AS total_booking_value
FROM fact_ride_booking;


--Average booking value per ride
SELECT ROUND(COALESCE(AVG(booking_value), 0), 2) AS average_booking_value
FROM fact_ride_booking;


--Average distance per ride
SELECT ROUND(COALESCE(AVG(ride_distance), 0), 2) AS average_distance
FROM fact_ride_booking;


--Average VTAT and CTAT for completed rides
SELECT ROUND(COALESCE(AVG(avg_vtat), 0), 2) AS completed_avg_vtat, 
	   ROUND(COALESCE(AVG(avg_ctat), 0), 2) AS completed_avg_ctat
FROM fact_ride_booking
WHERE booking_status = 'Completed';

select MIN()







-- Step 05.2: Customer-Level Booking Analysis
--How many unique customers have made bookings?
SELECT COUNT(customer_id) AS total_unique_customer
FROM dim_customer;


--How many customers are repeat customers (more than one booking)?
SELECT COUNT(*) AS repeat_customer_count
FROM (
    SELECT customer_id
    FROM fact_ride_booking
    GROUP BY customer_id
    HAVING COUNT(booking_id) > 1
);


--Average number of bookings per customer
SELECT ROUND(AVG(total_bookings), 2) AS avg_bookings_per_customer
FROM (
	SELECT customer_id, COUNT(booking_id) AS total_bookings
	FROM fact_ride_booking
	GROUP BY customer_id
) AS customer_bookings;


--Who are the top 10 most active customers based on booking count?
SELECT customer_id, COUNT(booking_id) AS total_bookings
FROM fact_ride_booking
GROUP BY customer_id
ORDER BY total_bookings DESC
LIMIT 10;


--What percentage of customers are repeat vs one-time customers?
SELECT
    ROUND(COUNT(*) FILTER (WHERE total_bookings = 1)::NUMERIC / COUNT(*) * 100, 2) AS one_time_customer_percent,
	ROUND(COUNT(*) FILTER (WHERE total_bookings > 1)::NUMERIC / COUNT(*) * 100, 2) AS repeat_customer_percent
FROM (
    SELECT customer_id, COUNT(booking_id) AS total_bookings
    FROM fact_ride_booking
    GROUP BY customer_id
) AS customer_bookings;


--What is the average booking value per customer?
SELECT ROUND(AVG(total_booking_value), 2) AS avg_booking_value_per_customer
FROM (
	SELECT customer_id, SUM(booking_value) AS total_booking_value
	FROM fact_ride_booking
	GROUP BY customer_id
) AS customer_booking_value;


--Which customers have generated the highest total booking value?
SELECT customer_id, COALESCE(SUM(booking_value), 0) AS total_booking_value
FROM fact_ride_booking
GROUP BY customer_id
ORDER BY total_booking_value DESC;


--What is the average cancellation rate for customers?
SELECT ROUND(AVG(cancellation_rate), 2) AS avg_customer_cancellation_rate
FROM (
    SELECT customer_id,
           COUNT(*) FILTER (WHERE booking_status = 'Cancelled by Customer')::NUMERIC / COUNT(*) * 100 AS cancellation_rate
    FROM fact_ride_booking
    GROUP BY customer_id
) AS customer_cancellation;


--Which customers have the highest cancellation rate, considering only customers with at >=2 bookings?  
SELECT 
    customer_id, 
	COUNT(*) AS total_bookings,
    COUNT(*) FILTER (WHERE booking_status = 'Cancelled by Customer') AS cancelled_bookings,
    ROUND(COUNT(*) FILTER (WHERE booking_status = 'Cancelled by Customer')::NUMERIC / COUNT(*) * 100, 2) AS cancellation_rate
FROM fact_ride_booking
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY cancellation_rate DESC;


--Do repeat customers have a higher average booking value than one-time customers?  
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
-- total bookings made for each vehicle type
SELECT v.vehicle_type, COUNT(f.booking_id) AS total_bookings,
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type;


--percentage of bookings for each vehicle type were completed
SELECT v.vehicle_type, ROUND(COUNT(*) FILTER (WHERE f.booking_status = 'Completed')::NUMERIC / COUNT(*) * 100, 2) AS completion_rate
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY completion_rate DESC;


--cancellation rate for each vehicle type
SELECT v.vehicle_type, ROUND(COUNT(*) FILTER (WHERE f.booking_status IN ('Cancelled by Driver', 'Cancelled by Customer'))::NUMERIC / COUNT(*) * 100, 2) AS cancellation_rate
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY cancellation_rate DESC;


--average booking value for each vehicle type
SELECT v.vehicle_type, ROUND(AVG(f.booking_value), 2) AS avg_booking_value
FROM fact_ride_booking f 
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type        
ORDER BY avg_booking_value DESC;


--average ride distance for each vehicle type
SELECT v.vehicle_type, ROUND(AVG(f.ride_distance), 2) AS avg_ride_distance
FROM fact_ride_booking f 
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type        
ORDER BY avg_ride_distance DESC;


--average customer rating for each vehicle type
SELECT v.vehicle_type, ROUND(AVG(f.ride_distance), 2) AS avg_ride_distance
FROM fact_ride_booking f 
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type        
ORDER BY avg_ride_distance DESC;


--vehicle generated the highest total booking value
Select v.vehicle_type, SUM(f.booking_value) AS highest_booking_value
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY highest_booking_value DESC
LIMIT 1;


--vehicle has the highest average booking value
Select v.vehicle_type, ROUND(AVG(f.booking_value), 2) AS highest_avg_booking_value
FROM fact_ride_booking f
JOIN dim_vehicle v
ON f.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY highest_avg_booking_value DESC
LIMIT 1;


--vehicles have an above-average completion rate
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
	  


-- summary
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




