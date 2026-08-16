-- STEP03: Raw data Cleaning & Transformation


-- Step 01: Create a cleaned copy of the raw dataset
CREATE TABLE IF NOT EXISTS clean_uber_bookings AS
SELECT *
FROM raw_uber_bookings;



-- Step 02: Preview clean_uber_bookings tab
SELECT *
FROM clean_uber_bookings;



-- Step 03: Standardize binary ride indicators
UPDATE clean_uber_bookings
SET cancelled_rides_by_customer = COALESCE(cancelled_rides_by_customer, 0),
	cancelled_rides_by_driver = COALESCE(cancelled_rides_by_driver, 0),
	incomplete_rides = COALESCE(incomplete_rides, 0);

select *
from clean_uber_bookings;



-- Step 04: Rename columns for one-row-per-ride granularity
ALTER TABLE clean_uber_bookings
RENAME COLUMN cancelled_rides_by_customer TO cancelled_ride_by_customer;

ALTER TABLE clean_uber_bookings
RENAME COLUMN cancelled_rides_by_driver TO cancelled_ride_by_driver;

ALTER TABLE clean_uber_bookings
RENAME COLUMN incomplete_rides TO incomplete_ride;

ALTER TABLE clean_uber_bookings
RENAME COLUMN incomplete_rides_reason TO incomplete_ride_reason;


SELECT *
FROM clean_uber_bookings;



	