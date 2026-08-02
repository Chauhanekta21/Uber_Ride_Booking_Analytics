-- STEP01: Created the raw_uber_bookings table and imported the original Uber Ride Booking dataset into PostgreSQL.

CREATE TABLE IF NOT EXISTS raw_uber_bookings (
    booking_date DATE,
    booking_time TIME,
    booking_id VARCHAR(50),
    booking_status VARCHAR(50),
    
    customer_id VARCHAR(50),
    
    vehicle_type VARCHAR(50),
    pickup_location VARCHAR(100),
    drop_location VARCHAR(100),
    
    avg_vtat DECIMAL(5,2),
    avg_ctat DECIMAL(5,2),
    
    cancelled_rides_by_customer INT,
    customer_cancellation_reason TEXT,
    
    cancelled_rides_by_driver INT,
    driver_cancellation_reason TEXT,
    
    incomplete_rides INT,
    incomplete_rides_reason TEXT,
    
    booking_value DECIMAL(10,2),
    ride_distance DECIMAL(10,2),
    
    driver_rating DECIMAL(3,2),
    customer_rating DECIMAL(3,2),
    
    payment_method VARCHAR(50)
);


SELECT * 
FROM raw_uber_bookings;

