

# SQL Indexing for Performance Analysis

This document outlines the process of identifying columns suitable for indexing and measuring the impact of these indexes on query performance using `EXPLAIN` or `EXPLAIN ANALYZE`.

## 1. Identifying High-Usage Columns

Indexes are special lookup tables that the database search engine can use to speed up data retrieval. They are most effective on columns that are:

* **Used in `WHERE` clauses:** To quickly filter rows (e.g., `WHERE email = '...'`, `WHERE location = '...'`).
* **Used in `JOIN` conditions:** To efficiently link rows between tables (e.g., `ON users.user_id = bookings.user_id`).
* **Used in `ORDER BY` clauses:** To sort results faster.
* **Used in `GROUP BY` clauses:** To aggregate data more efficiently.
* **Columns with `UNIQUE` constraints:** These are often implicitly indexed, but explicit indexing can sometimes provide more control.
* **Foreign Key (FK) columns:** These are almost always good candidates for indexing as they are fundamental to relational database operations (joins).

Based on the `alx-airbnb-database` schema and typical application usage, the following columns are identified as high-usage and suitable for indexing (beyond primary keys which are automatically indexed):

* **`Users`**: `email`, `first_name`, `last_name`
* **`Properties`**: `host_id`, `location`
* **`Bookings`**: `user_id`, `property_id`, `start_date`, `end_date`
* **`Payments`**: `booking_id`
* **`Reviews`**: `property_id`, `user_id`, `rating`
* **`Messages`**: `sender_id`, `recipient_id`, `sent_at`

## 2. Creating Indexes

The `database_index.sql` file contains the `CREATE INDEX` commands for the identified columns.

**To apply these indexes:**
1.  Ensure your database schema (from `schema.sql`) is already set up and populated with data.
2.  Copy the content of `database-adv-script/database_index.sql`.
3.  Paste it into your SQL environment's query editor.
4.  Execute the script.

**Content of `database-adv-script/database_index.sql`:**

```sql
-- database-adv-script/database_index.sql

-- This script contains SQL commands to create indexes on frequently queried columns
-- in the alx-airbnb-database schema to improve query performance.

-- Primary keys are automatically indexed by the database system, so we focus on:
-- 1. Foreign key columns (critical for JOIN performance).
-- 2. Columns frequently used in WHERE clauses, ORDER BY, or GROUP BY.
-- 3. Columns with UNIQUE constraints (often implicitly indexed, but explicit can be good).

-- Indexes for Users table:
-- user_id (PK) is already indexed.
-- email is UNIQUE and often used for login/lookup.
CREATE INDEX idx_users_email ON Users (email);
-- first_name, last_name might be used for searching.
CREATE INDEX idx_users_name ON Users (first_name, last_name);


-- Indexes for Properties table:
-- property_id (PK) is already indexed.
-- host_id is a Foreign Key, heavily used in joins.
CREATE INDEX idx_properties_host_id ON Properties (host_id);
-- location is frequently used for filtering properties.
CREATE INDEX idx_properties_location ON Properties (location);


-- Indexes for Bookings table:
-- booking_id (PK) is already indexed.
-- user_id and property_id are Foreign Keys, critical for joins.
CREATE INDEX idx_bookings_user_id ON Bookings (user_id);
CREATE INDEX idx_bookings_property_id ON Bookings (property_id);
-- start_date and end_date are often used in date range queries.
CREATE INDEX idx_bookings_dates ON Bookings (start_date, end_date);


-- Indexes for Payments table:
-- payment_id (PK) is already indexed.
-- booking_id is a Foreign Key and UNIQUE, crucial for linking payments to bookings.
CREATE INDEX idx_payments_booking_id ON Payments (booking_id);


-- Indexes for Reviews table:
-- review_id (PK) is already indexed.
-- property_id and user_id are Foreign Keys, used in joins and filtering reviews.
CREATE INDEX idx_reviews_property_id ON Reviews (property_id);
CREATE INDEX idx_reviews_user_id ON Reviews (user_id);
-- rating might be used for filtering/ordering reviews.
CREATE INDEX idx_reviews_rating ON Reviews (rating);


-- Indexes for Messages table:
-- message_id (PK) is already indexed.
-- sender_id and recipient_id are Foreign Keys, used for message lookups.
CREATE INDEX idx_messages_sender_id ON Messages (sender_id);
CREATE INDEX idx_messages_recipient_id ON Messages (recipient_id);
-- sent_at for ordering messages chronologically.
CREATE INDEX idx_messages_sent_at ON Messages (sent_at);
