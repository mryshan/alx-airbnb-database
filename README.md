
# alx-airbnb-database: SQL Joins Practice

This repository is dedicated to mastering SQL `JOIN` operations through practical exercises on a simulated Airbnb-like booking system database. It includes the full database schema, sample data, and solutions to complex join queries.

## Project Structure
 `database-adv-script/schema.sql`: Contains the SQL DDL (Data Definition Language) for creating all tables (`Users`, `Properties`, `Bookings`, `Payments`, `Reviews`, `Messages`) and DML (Data Manipulation Language) for inserting predictable sample data.
* `database-adv-script/joins_queries.sql`: Contains the SQL queries that address the join objectives outlined below.
* `README.md`: This file, providing an overview and instructions.

## Database Setup

To begin, you need to set up the database schema and populate it with the sample data.

**Instructions:**
1.  Open a SQL environment (e.g., [DB-Fiddle](https://www.db-fiddle.com/), PostgreSQL client, etc.).
    * If using DB-Fiddle, ensure the SQL dialect is set to PostgreSQL for `INTERVAL` support, though the `CREATE TABLE` statements are adjusted for broader compatibility (e.g., `VARCHAR` instead of `ENUM`).
2.  **Clear the entire content of your SQL environment's schema/setup panel.**
3.  Copy the complete content from `database-adv-script/schema.sql`.
4.  Paste it into the schema/setup panel of your SQL environment.
5.  Execute the script to build your database and populate it with data.

**Content of `database-adv-script/schema.sql`:**

```sql
-- database-adv-script/schema.sql

-- This script sets up the database schema for a booking system.
-- It includes definitions for Users, Properties, Bookings, Payments, Reviews, and Messages.
-- The data inserted uses pre-defined UUIDs for predictable join exercise results.

-- Section 1: Drop Existing Tables
-- This ensures a clean slate, useful for development or re-running the script.
-- Tables are dropped in reverse order of their foreign key dependencies.
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Messages;
DROP TABLE IF EXISTS Properties;
DROP TABLE IF EXISTS Users;

-- Section 2: Create Tables

-- Table: Users
-- Description: Stores information about users, including guests, hosts, and admins.
CREATE TABLE Users (
    user_id UUID PRIMARY KEY, -- Primary Key, UUID
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL, -- Email must be unique
    password_hash VARCHAR(255) NOT NULL, -- Storing hashed password
    phone_number VARCHAR(20), -- Optional
    role VARCHAR(50) NOT NULL, -- Changed ENUM to VARCHAR for broader compatibility (e.g., SQLite in DB-Fiddle)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Automatically set creation timestamp
);

-- Note: Indexes are commented out here for maximum compatibility across various SQL environments
-- (especially simplified ones like DB-Fiddle's default SQLite setup).
-- In a production database, these would be beneficial for performance.
-- CREATE INDEX idx_users_email ON Users (email);


-- Table: Properties
-- Description: Stores information about properties listed by hosts.
CREATE TABLE Properties (
    property_id UUID PRIMARY KEY, -- Primary Key, UUID
    host_id UUID NOT NULL, -- Foreign Key to Users table (host)
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL CHECK (price_per_night > 0), -- Price per night, positive value
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Automatically set creation timestamp
    -- updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Removed ON UPDATE CURRENT_TIMESTAMP for broader compatibility

    FOREIGN KEY (host_id) REFERENCES Users(user_id) ON DELETE CASCADE -- If a host is deleted, their properties are deleted
);

-- CREATE INDEX idx_properties_host_id ON Properties (host_id);
-- CREATE INDEX idx_properties_location ON Properties (location);


-- Table: Bookings
-- Description: Stores information about property bookings made by guests.
CREATE TABLE Bookings (
    booking_id UUID PRIMARY KEY, -- Primary Key, UUID
    property_id UUID NOT NULL, -- Foreign Key to Properties table
    user_id UUID NOT NULL, -- Foreign Key to Users table (guest)
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price > 0), -- Total price, positive value
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- Changed ENUM to VARCHAR for broader compatibility
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Automatically set creation timestamp

    FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE, -- If property deleted, bookings for it are deleted
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE, -- If user deleted, their bookings are deleted
    CHECK (end_date >= start_date) -- Ensure end date is not before start date
);

-- CREATE INDEX idx_bookings_property_id ON Bookings (property_id);
-- CREATE INDEX idx_bookings_user_id ON Bookings (user_id);


-- Table: Payments
-- Description: Records payments for bookings.
CREATE TABLE Payments (
    payment_id UUID PRIMARY KEY, -- Primary Key, UUID
    booking_id UUID UNIQUE NOT NULL, -- Foreign Key to Bookings table, one payment per booking
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0), -- Amount paid, positive value
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Automatically set payment timestamp
    payment_method VARCHAR(50) NOT NULL, -- Changed ENUM to VARCHAR for broader compatibility

    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE -- If booking deleted, payment is deleted
);

-- CREATE INDEX idx_payments_booking_id ON Payments (booking_id);


-- Table: Reviews
-- Description: Stores reviews written by users for properties.
CREATE TABLE Reviews (
    review_id UUID PRIMARY KEY, -- Primary Key, UUID
    property_id UUID NOT NULL, -- Foreign Key to Properties table
    user_id UUID NOT NULL, -- Foreign Key to Users table (reviewer)
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5), -- Rating between 1 and 5
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Automatically set creation timestamp

    FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE, -- If property deleted, reviews for it are deleted
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE -- If user deleted, their reviews are deleted
);

-- CREATE INDEX idx_reviews_property_id ON Reviews (property_id);
-- CREATE INDEX idx_reviews_user_id ON Reviews (user_id);


-- Table: Messages
-- Description: Stores messages exchanged between users.
CREATE TABLE Messages (
    message_id UUID PRIMARY KEY, -- Primary Key, UUID
    sender_id UUID NOT NULL, -- Foreign Key to Users table (sender)
    recipient_id UUID NOT NULL, -- Foreign Key to Users table (recipient)
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Automatically set sent timestamp

    FOREIGN KEY (sender_id) REFERENCES Users(user_id) ON DELETE CASCADE, -- If sender deleted, their sent messages are deleted
    FOREIGN KEY (recipient_id) REFERENCES Users(user_id) ON DELETE CASCADE, -- If recipient deleted, their received messages are deleted
    CHECK (sender_id != recipient_id) -- A user cannot send a message to themselves (optional, but good practice)
);

-- CREATE INDEX idx_messages_sender_id ON Messages (sender_id);
-- CREATE INDEX idx_messages_recipient_id ON Messages (recipient_id);


-- Section 3: Insert Data
-- This data uses hardcoded UUIDs for predictable results during SQL JOIN practice.

-- Specific UUIDs for Users
INSERT INTO Users (user_id, first_name, last_name, email, phone_number, password_hash, role) VALUES
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'sheikh', 'ahmed', 'ahmed.shee@gmail.com', '0712567898', 'hashed_123', 'guest'),
    ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'vishal', 'shan', 'vishh.shal@gmail.com', '07111247652', 'hashed_234', 'guest'),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Salma', 'hassan', 'salma.hassan@gmail.com', '0726777798', 'hashed_345', 'guest'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Unbooked', 'User', 'unbooked@example.com', '0700000000', 'hashed_456', 'guest'); -- User with no booking for FULL OUTER JOIN

-- Specific UUIDs for Properties
INSERT INTO Properties (property_id, host_id, name, description, location, price_per_night) VALUES
    ('p1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Shanzu view Hotel', 'Hotel with swimmingpool and fast WiFi.', 'shanzu', 35.00), -- Hosted by Sheikh Ahmed
    ('p2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sunshine cottages', 'wake up to sunshine views and nap to the sound of leaves', 'mombasa', 80.00), -- Hosted by Vishal Shan
    ('p3eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Property with No Reviews', 'Just a place with no feedback', 'Kilifi', 50.00); -- For LEFT JOIN practice, has no review

-- Specific UUIDs and linkages for Bookings
INSERT INTO Bookings (booking_id, user_id, property_id, start_date, end_date, status, total_price) VALUES
    ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'p1eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', CURRENT_DATE + INTERVAL '7 days', CURRENT_DATE + INTERVAL '10 days', 'confirmed', 105.00), -- Sheikh Ahmed booked Shanzu
    ('b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'p2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', CURRENT_DATE + INTERVAL '15 days', CURRENT_DATE + INTERVAL '18 days', 'confirmed', 240.00), -- Vishal Shan booked Sunshine
    ('b3eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'p2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', CURRENT_DATE + INTERVAL '20 days', CURRENT_DATE + INTERVAL '22 days', 'pending', 160.00), -- Sheikh Ahmed booked Sunshine again
    ('b4eebc99-c0b-4ef8-bb6d-6bb9bd380a11', '99999999-9999-9999-9999-999999999999', 'p1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', CURRENT_DATE + INTERVAL '25 days', CURRENT_DATE + INTERVAL '28 days', 'confirmed', 200.00); -- Booking with non-existent user_id for FULL OUTER JOIN

-- Specific UUIDs for Payments (linked to predictable bookings)
INSERT INTO Payments (payment_id, booking_id, amount, payment_method) VALUES
    ('pay1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 105.00, 'credit_card'),
    ('pay2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 240.00, 'paypal');

-- Specific UUIDs for Reviews
INSERT INTO Reviews (review_id, user_id, property_id, rating, comment) VALUES
    ('r1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'p1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 5, 'Absolutely lovely! Clean and well-furnished.'),
    ('r2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'p2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 4, 'Great views, quiet place.');

-- Specific UUIDs for Messages
INSERT INTO Messages (message_id, sender_id, recipient_id, message_body) VALUES
    ('m1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'Hello, how many guests are allowed?');
