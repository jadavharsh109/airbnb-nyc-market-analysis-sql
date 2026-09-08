-- =============================================================================
-- Airbnb NYC Lodging & Booking Market Analysis
-- Script 01: Relational Schema Architecture & Data Ingestion
-- Author: Harsh Jadav (https://github.com/jadavharsh109)
-- Database Engine: MySQL 8.0+
-- =============================================================================

CREATE DATABASE IF NOT EXISTS air_bnb_db;
USE air_bnb_db;

-- -----------------------------------------------------------------------------
-- 1. Table: Listings
-- Core listing catalogue capturing host metadata, location, and property type
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Booking_Details;
DROP TABLE IF EXISTS Listings;

CREATE TABLE Listings (
    id                      INT             NOT NULL,
    name                    VARCHAR(255)    NULL,
    host_id                 INT             NOT NULL,
    host_name               VARCHAR(100)    NULL,
    neighbourhood_group     VARCHAR(50)     NOT NULL,
    neighbourhood           VARCHAR(100)    NOT NULL,
    room_type               VARCHAR(50)     NOT NULL,
    CONSTRAINT pk_listings PRIMARY KEY (id)
);

CREATE INDEX idx_listings_host ON Listings(host_id);
CREATE INDEX idx_listings_neighbourhood ON Listings(neighbourhood_group, neighbourhood);

-- -----------------------------------------------------------------------------
-- 2. Table: Booking_Details
-- Dynamic reservation attributes including pricing, minimum stay, and reviews
-- -----------------------------------------------------------------------------
CREATE TABLE Booking_Details (
    listing_id                      INT             NOT NULL,
    price                           DECIMAL(10,2)   NOT NULL,
    minimum_nights                  INT             NOT NULL,
    number_of_reviews               INT             NOT NULL,
    reviews_per_month               FLOAT           NULL,
    calculated_host_listings_count  INT             NOT NULL,
    availability_365                INT             NOT NULL,
    CONSTRAINT fk_booking_listing FOREIGN KEY (listing_id) REFERENCES Listings(id) ON DELETE CASCADE
);

CREATE INDEX idx_booking_listing ON Booking_Details(listing_id);
CREATE INDEX idx_booking_price ON Booking_Details(price);

-- -----------------------------------------------------------------------------
-- Data Ingestion Instructions
-- -----------------------------------------------------------------------------
/*
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'data/listing.csv'
INTO TABLE Listings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, host_id, host_name, neighbourhood_group, neighbourhood, room_type);

LOAD DATA LOCAL INFILE 'data/Booking_details.csv'
INTO TABLE Booking_Details
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(listing_id, price, minimum_nights, number_of_reviews, @v_reviews_per_month, calculated_host_listings_count, availability_365)
SET reviews_per_month = NULLIF(@v_reviews_per_month, '');
*/

-- -----------------------------------------------------------------------------
-- Ingestion Verification
-- -----------------------------------------------------------------------------
SELECT 'Listings' AS table_name, COUNT(*) AS record_count FROM Listings
UNION ALL
SELECT 'Booking_Details', COUNT(*) FROM Booking_Details;
