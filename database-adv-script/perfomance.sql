-- database-adv-script/perfomance.sql

-- Objective: Refactor complex queries to improve performance.

-- Initial Query: Retrieve all bookings along with user details, property details, and payment details.
-- This query uses multiple INNER JOINs to combine data from four tables:
-- Bookings, Users, Properties, and Payments.
SELECT
    B.booking_id,
    B.start_date,
    B.end_date,
    B.total_price AS booking_total_price,
    B.status AS booking_status,
    U.user_id,
    U.first_name,
    U.last_name,
    U.email AS user_email,
    P.property_id,
    P.name AS property_name,
    P.location,
    P.price_per_night,
    PY.payment_id,
    PY.amount AS payment_amount,
    PY.payment_date,
    PY.payment_method
FROM
    Bookings AS B
INNER JOIN
    Users AS U ON B.user_id = U.user_id
INNER JOIN
    Properties AS P ON B.property_id = P.property_id
INNER JOIN
    Payments AS PY ON B.booking_id = PY.booking_id
ORDER BY
    B.booking_id;

-- Notes on Initial Query Performance:
-- Without proper indexing, this query can be slow, especially on large datasets,
-- as the database might perform full table scans or inefficient nested loop joins.
-- The efficiency heavily relies on the database's ability to quickly find matching
-- rows in joined tables.


-- Refactored Query: Same data retrieval, optimized for performance via indexing.
-- For this specific data retrieval requirement (all details from all four tables),
-- the JOIN structure itself is inherently necessary. The primary "refactoring" for
-- performance here comes from ensuring optimal indexing on the join columns.
-- Assuming indexes (as defined in database_index.sql from previous steps) are applied on:
-- Bookings.user_id, Bookings.property_id, Payments.booking_id
-- (And primary keys like Users.user_id, Properties.property_id, Payments.payment_id are already indexed by default)
-- The query structure remains the same, but its execution plan will change dramatically.

SELECT
    B.booking_id,
    B.start_date,
    B.end_date,
    B.total_price AS booking_total_price,
    B.status AS booking_status,
    U.user_id,
    U.first_name,
    U.last_name,
    U.email AS user_email,
    P.property_id,
    P.name AS property_name,
    P.location,
    P.price_per_night,
    PY.payment_id,
    PY.amount AS payment_amount,
    PY.payment_date,
    PY.payment_method
FROM
    Bookings AS B
INNER JOIN
    Users AS U ON B.user_id = U.user_id
INNER JOIN
    Properties AS P ON B.property_id = P.property_id
INNER JOIN
    Payments AS PY ON B.booking_id = PY.booking_id
ORDER BY
    B.booking_id;

-- Explanation of Refactoring Strategy for this query:
-- 1. Indexing: The most significant performance improvement for multi-table joins
--    comes from having appropriate indexes on all foreign key columns involved in the JOIN conditions.
--    This allows the database to use efficient index scans instead of full table scans.
--    (Refer to `database_index.sql` for index creation.)
-- 2. Join Order (Database Optimizer's Job): Modern SQL query optimizers are highly
--    sophisticated and will typically determine the most efficient join order automatically
--    based on statistics and available indexes. Explicitly forcing join order is rarely
--    necessary unless you have deep knowledge of the data distribution and optimizer behavior.
-- 3. SELECT only necessary columns: While this query selects many columns as per the objective,
--    in real-world scenarios, selecting only the columns actually needed reduces data transfer
--    and processing overhead.
-- 4. Using appropriate JOIN types: INNER JOIN is correct here if you only want bookings that
--    have all associated user, property, and payment details. If you wanted bookings that
--    *might not* have a payment, a LEFT JOIN would be appropriate for Payments.
