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


--Total distance travelled across all rides
SELECT COALESCE(SUM(ride_distance), 0) AS total_distance
FROM fact_ride_booking;


--Average distance per ride
SELECT ROUND(COALESCE(AVG(ride_distance), 0), 2) AS average_distance
FROM fact_ride_booking;


--Average VTAT and CTAT for completed rides
SELECT ROUND(COALESCE(AVG(avg_vtat), 0), 2) AS completed_avg_vtat, 
	   ROUND(COALESCE(AVG(avg_ctat), 0), 2) AS completed_avg_ctat
FROM fact_ride_booking
WHERE booking_status = 'Completed';








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

