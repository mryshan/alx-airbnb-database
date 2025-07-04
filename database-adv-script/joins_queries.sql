

  -- database-adv-script/joins_queries.sql

-- Objective 1: INNER JOIN - Bookings and Users
-- Retrieve all bookings and the respective users who made those bookings.
-- This query combines rows from Bookings and Users tables where there is a match on user_id.
-- Bookings without a matching user (e.g., the one with user_id '9999...') will be excluded.
SELECT
    B.booking_id,
    B.start_date,
    B.end_date,
    B.total_price,
    B.status,
    U.first_name,
    U.last_name,
    U.email
FROM
    Bookings AS B  -- Alias Bookings table as 'B' for brevity
INNER JOIN
    Users AS U ON B.user_id = U.user_id; -- Alias Users table as 'U' and join on the common user_id


-- Objective 2: LEFT JOIN - Properties and Reviews
-- Retrieve all properties and their reviews, including properties that have no reviews.
-- This query returns all rows from the Properties table (left table).
-- If a property has matching reviews in the Reviews table, those details are included.
-- If a property has no reviews, the review-related columns will show NULL.
SELECT
    P.property_id,
    P.name AS property_name, -- Renaming 'name' to 'property_name' for clarity in results
    P.location,
    R.rating,
    R.comment
FROM
    Properties AS P  -- This is our "left" table, aliased as 'P'
LEFT JOIN
    Reviews AS R ON P.property_id = R.property_id; -- Join with Reviews table (aliased as 'R') on property_id


-- Objective 3: FULL OUTER JOIN - Users and Bookings
-- Retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user.
-- Note: SQLite (often used by DB-Fiddle) does not natively support FULL OUTER JOIN.
-- The workaround below combines a LEFT JOIN and a UNION ALL with a filtered LEFT JOIN.
-- The first part gets all users and their bookings.
-- The second part gets bookings that have no matching user, and combines them.
SELECT
    U.user_id,
    U.first_name,
    U.last_name,
    B.booking_id,
    B.start_date,
    B.status
FROM
    Users AS U
LEFT JOIN
    Bookings AS B ON U.user_id = B.user_id

UNION ALL

SELECT
    NULL AS user_id, -- Explicitly set user columns to NULL for unmatched bookings
    NULL AS first_name,
    NULL AS last_name,
    B.booking_id,
    B.start_date,
    B.status
FROM
    Bookings AS B
LEFT JOIN
    Users AS U ON B.user_id = U.user_id
WHERE
    U.user_id IS NULL; -- This crucial WHERE clause ensures we only pick bookings that DID NOT find a match in the first LEFT JOIN
