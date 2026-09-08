-- =============================================================================
-- Airbnb NYC Lodging & Booking Market Analysis
-- Script 02: Exploratory Data Analysis, Pricing & Availability Distributions
-- Author: Harsh Jadav (https://github.com/jadavharsh109)
-- Database Engine: MySQL 8.0+
-- =============================================================================

USE air_bnb_db;

-- 1. Total count of property listings
SELECT COUNT(*) AS total_listings FROM Listings;

-- 2. Total count of booking records
SELECT COUNT(listing_id) AS total_booking_records FROM Booking_Details;

-- 3. Unique hosts active across New York City
SELECT COUNT(DISTINCT host_id) AS unique_host_count FROM Listings;

-- 4. Unique boroughs (neighbourhood groups)
SELECT DISTINCT neighbourhood_group FROM Listings;

-- 5. Count of unique micro-neighbourhoods
SELECT COUNT(DISTINCT neighbourhood) AS unique_neighbourhoods FROM Listings;

-- 6. Distinct accommodation room categories
SELECT DISTINCT room_type FROM Listings;

-- 7. All listings located in Brooklyn & Manhattan
SELECT * FROM Listings 
WHERE neighbourhood_group IN ('Brooklyn', 'Manhattan');

-- 8. High-level pricing extremes across all listings
SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(AVG(price), 2) AS avg_price
FROM Booking_Details;

-- 9. Minimum nights stay extremes
SELECT 
    MIN(minimum_nights) AS min_allowed_nights,
    MAX(minimum_nights) AS max_allowed_nights,
    ROUND(AVG(minimum_nights), 1) AS avg_minimum_nights
FROM Booking_Details;

-- 10. Citywide average annual availability (out of 365 days)
SELECT ROUND(AVG(availability_365), 1) AS avg_availability_days 
FROM Booking_Details;

-- 11. Highly available properties (available > 300 days/year)
SELECT listing_id, availability_365 
FROM Booking_Details 
WHERE availability_365 > 300;

-- 12. Volume of mid-tier luxury listings ($300 to $400/night)
SELECT COUNT(listing_id) AS listings_between_300_and_400
FROM Booking_Details 
WHERE price BETWEEN 300 AND 400;

-- 13. Short-stay friendly listings (minimum nights < 5)
SELECT COUNT(listing_id) AS short_stay_listings 
FROM Booking_Details 
WHERE minimum_nights < 5;

-- 14. Long-term extended stay listings (minimum nights > 100)
SELECT COUNT(listing_id) AS extended_stay_listings 
FROM Booking_Details 
WHERE minimum_nights > 100;

-- =============================================================================
-- Relational JOIN Explorations
-- =============================================================================

-- 15. Host name mapped to nightly listing price
SELECT l.host_name, b.price
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
ORDER BY b.price DESC
LIMIT 10;

-- 16. Nightly rate by room category
SELECT l.room_type, ROUND(AVG(b.price), 2) AS avg_price, MAX(b.price) AS max_price
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.room_type;

-- 17. Average minimum stay required by borough
SELECT l.neighbourhood_group, ROUND(AVG(b.minimum_nights), 1) AS avg_min_nights
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.neighbourhood_group
ORDER BY avg_min_nights DESC;

-- 18. Annual property availability by borough
SELECT l.neighbourhood_group, ROUND(AVG(b.availability_365), 1) AS avg_availability_365
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.neighbourhood_group
ORDER BY avg_availability_365 DESC;
