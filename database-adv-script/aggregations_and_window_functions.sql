-- database-adv-script/aggregations_and_window_functions.sql

-- Objective 1: Total Bookings by Each User (COUNT and GROUP BY)
-- Write a query to find the total number of bookings made by each user.
-- This uses the COUNT aggregate function to count bookings and GROUP BY to summarize per user.
SELECT
    U.user_id,
    U.first_name,
    U.last_name,
    U.email,
    COUNT(B.booking_id) AS total_bookings_made
FROM
    Users AS U
LEFT JOIN -- Use LEFT JOIN to include users who have made 0 bookings
    Bookings AS B ON U.user_id = B.user_id
GROUP BY
    U.user_id, U.first_name, U.last_name, U.email
ORDER BY
    total_bookings_made DESC;

-- Expected Output (based on provided sample data):
-- sheikh ahmed: 2 bookings
-- vishal shan: 1 booking
-- Salma hassan: 0 bookings
-- Unbooked User: 0 bookings
-- (The booking by '9999...' user will not be associated with a user here, as it's an unmatched booking)


-- Objective 2: Rank Properties by Total Bookings (Window Functions: ROW_NUMBER, RANK)
-- Use a window function to rank properties based on the total number of bookings they have received.
-- We'll first count bookings per property, then apply ranking functions.
SELECT
    property_id,
    property_name,
    total_bookings,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) AS row_num_rank,
    RANK() OVER (ORDER BY total_bookings DESC) AS rank_rank
FROM (
    SELECT
        P.property_id,
        P.name AS property_name,
        COUNT(B.booking_id) AS total_bookings
    FROM
        Properties AS P
    LEFT JOIN -- Use LEFT JOIN to include properties with 0 bookings
        Bookings AS B ON P.property_id = B.property_id
    GROUP BY
        P.property_id, P.name
) AS PropertyBookings
ORDER BY
    total_bookings DESC;

-- Expected Output (based on provided sample data):
-- p2eebc99... (Sunshine cottages): 2 bookings (ROW_NUMBER=1, RANK=1)
-- p1eebc99... (Shanzu view Hotel): 1 booking (ROW_NUMBER=2, RANK=2)
-- p3eebc99... (Property with No Reviews): 0 bookings (ROW_NUMBER=3, RANK=3)
