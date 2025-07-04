# SQL Subqueries Practice: alx-airbnb-database

This repository focuses on mastering SQL `SUBQUERY` operations through practical exercises on a simulated Airbnb-like booking system database. It includes the database schema, sample data, and solutions to specific subquery challenges.

## Project Structure
* `database-adv-script/schema.sql`: Contains the SQL DDL (Data Definition Language) for creating all necessary tables (`Users`, `Properties`, `Bookings`, `Reviews`, etc.) and DML (Data Manipulation Language) for inserting predictable sample data. This is crucial for setting up the database environment to run the subqueries.
* `database-adv-script/subqueries.sql`: Contains the SQL queries that address the specific subquery objectives outlined below.
* `README.md`: This file, providing an overview and instructions for the subquery exercises.

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
-- The data inserted uses pre-defined UUIDs for predictable exercise results.

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

    FOREIGN KEY (host_id) REFERENCES Users(user_id) ON DELETE CASCADE
);


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

    FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    CHECK (end_date >= start_date)
);


-- Table: Payments
-- Description: Records payments for bookings.
CREATE TABLE Payments (
    payment_id UUID PRIMARY KEY, -- Primary Key, UUID
    booking_id UUID UNIQUE NOT NULL, -- Foreign Key to Bookings table, one payment per booking
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0), -- Amount paid, positive value
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Automatically set payment timestamp
    payment_method VARCHAR(50) NOT NULL, -- Changed ENUM to VARCHAR for broader compatibility

    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE
);


-- Table: Reviews
-- Description: Stores reviews written by users for properties.
CREATE TABLE Reviews (
    review_id UUID PRIMARY KEY, -- Primary Key, UUID
    property_id UUID NOT NULL, -- Foreign Key to Properties table
    user_id UUID NOT NULL, -- Foreign Key to Users table (reviewer)
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5), -- Rating between 1 and 5
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Automatically set creation timestamp

    FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
