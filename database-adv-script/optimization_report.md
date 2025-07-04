# Query Optimization Report: Complex Booking Details Retrieval

This report details the process of analyzing and (conceptually) refactoring a complex SQL query to improve its performance. The primary focus for this specific query involves leveraging database indexing for efficient multi-table joins.

## 1. Initial Query

The objective is to retrieve a comprehensive view of all bookings, including details about the user who made the booking, the property being booked, and the associated payment information.

**Query (as found in `perfomance.sql`):**

```sql
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
