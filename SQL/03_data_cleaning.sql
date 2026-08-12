-- STEP03: Raw data Cleaning & Transformation


-- Step 01: Create a cleaned copy of the raw dataset
CREATE TABLE IF NOT EXISTS clean_uber_bookings AS
SELECT *
FROM raw_uber_bookings;


-- Step 02: Preview clean_uber_bookings tab
SELECT *
FROM clean_uber_bookings;