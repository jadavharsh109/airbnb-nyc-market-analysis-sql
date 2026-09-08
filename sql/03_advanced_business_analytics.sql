-- =============================================================================
-- Airbnb NYC Lodging & Booking Market Analysis
-- Script 03: Advanced Multi-Table Joins, Self-Joins & Market Economics
-- Author: Harsh Jadav (https://github.com/jadavharsh109)
-- Database Engine: MySQL 8.0+
-- =============================================================================

USE air_bnb_db;

-- =============================================================================
-- SECTION 1: Regional & Borough Market Aggregations
-- =============================================================================

-- Q1. Total pricing volume and max price by borough
SELECT 
    l.neighbourhood_group, 
    COUNT(l.id) AS total_listings,
    ROUND(SUM(b.price), 2) AS total_price_volume,
    ROUND(AVG(b.price), 2) AS avg_price,
    MAX(b.price) AS max_price
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.neighbourhood_group
ORDER BY total_price_volume DESC;

-- Q2. Maximum reviews per month recorded by micro-neighbourhood
SELECT 
    l.neighbourhood, 
    MAX(b.reviews_per_month) AS peak_reviews_per_month
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.neighbourhood
ORDER BY peak_reviews_per_month DESC
LIMIT 10;

-- Q3. Borough with the highest cumulative review count (Market Popularity)
SELECT 
    l.neighbourhood_group, 
    SUM(b.number_of_reviews) AS total_reviews
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.neighbourhood_group
ORDER BY total_reviews DESC
LIMIT 1;

-- =============================================================================
-- SECTION 2: Room Category Performance & Filtered Aggregations (HAVING)
-- =============================================================================

-- Q4. Average review velocity, night requirements, and price by room type
SELECT 
    l.room_type, 
    ROUND(AVG(b.price), 2) AS avg_price,
    ROUND(AVG(b.number_of_reviews), 1) AS avg_reviews,
    ROUND(AVG(b.minimum_nights), 1) AS avg_nights,
    MAX(b.price) AS max_price
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.room_type
ORDER BY avg_price DESC;

-- Q5. Room types where average nightly price is below $100
SELECT 
    l.room_type, 
    ROUND(AVG(b.price), 2) AS avg_price
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.room_type
HAVING AVG(b.price) < 100;

-- Q6. Neighbourhoods enforcing average minimum stays greater than 5 nights
SELECT 
    l.neighbourhood, 
    ROUND(AVG(b.minimum_nights), 1) AS avg_min_nights
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.neighbourhood
HAVING AVG(b.minimum_nights) > 5
ORDER BY avg_min_nights DESC;

-- =============================================================================
-- SECTION 3: Subqueries & Multi-Attribute Market Filters
-- =============================================================================

-- Q7. High-ticket listings ($200+) identified via subquery
SELECT * 
FROM Listings
WHERE id IN (
    SELECT listing_id 
    FROM Booking_Details 
    WHERE price > 200
)
LIMIT 10;

-- Q8. Listings in premium tourist enclaves ('Upper West Side', 'Williamsburg') priced over $100
SELECT 
    l.id, 
    l.host_name, 
    l.neighbourhood, 
    b.price
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
WHERE l.neighbourhood IN ('Upper West Side', 'Williamsburg') 
  AND b.price > 100
ORDER BY b.price DESC
LIMIT 10;

-- Q9. High-demand listings with 500+ reviews and 5+ reviews per month
SELECT 
    l.id, 
    l.name,
    l.host_name, 
    l.neighbourhood_group,
    b.number_of_reviews, 
    b.reviews_per_month
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
WHERE b.number_of_reviews > 500 
  AND b.reviews_per_month > 5
ORDER BY b.number_of_reviews DESC;

-- =============================================================================
-- SECTION 4: Self-Joins & Host Portfolio Concentration
-- =============================================================================

-- Q10. [SELF-JOIN] Identify pairs of distinct listings owned by the same host
SELECT 
    a.host_id,
    a.host_name,
    a.id AS listing_1_id, 
    b.id AS listing_2_id,
    a.neighbourhood AS neighbourhood_1,
    b.neighbourhood AS neighbourhood_2
FROM Listings a
JOIN Listings b ON a.host_id = b.host_id AND a.id < b.id
LIMIT 15;

-- Q11. Top 5 commercial multi-property hosts by total portfolio price
SELECT 
    l.host_id,
    l.host_name, 
    COUNT(l.id) AS total_properties_managed,
    ROUND(SUM(b.price), 2) AS portfolio_total_price
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
GROUP BY l.host_id, l.host_name
ORDER BY portfolio_total_price DESC
LIMIT 5;

-- Q12. Host operating the single most expensive property (Nested Subquery)
SELECT host_name, id, name
FROM Listings
WHERE id = (
    SELECT listing_id 
    FROM Booking_Details 
    ORDER BY price DESC 
    LIMIT 1
);

-- Q13. Text Mining: Characterize listings marketing 'cozy' in listing title
SELECT 
    COUNT(*) AS cozy_listing_count,
    ROUND(AVG(b.price), 2) AS avg_cozy_price
FROM Listings l
JOIN Booking_Details b ON l.id = b.listing_id
WHERE l.name LIKE '%cozy%';
