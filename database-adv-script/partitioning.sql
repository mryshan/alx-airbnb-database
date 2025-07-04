-- database-adv-script/partitioning.sql

-- Objective: Implement table partitioning to optimize queries on large datasets.
-- This script demonstrates how to partition the 'Bookings' table by 'start_date'.

-- IMPORTANT:
-- 1. This script assumes a PostgreSQL-compatible environment.
-- 2. Partitioning benefits are most evident with large datasets. Our sample data is small,
--    so the performance gains might not be dramatic in EXPLAIN ANALYZE, but the concept is demonstrated.
-- 3. Foreign key constraints need to be re-established after dropping/recreating the table.

-- Step 1: Drop dependent tables first (Payments depends on Bookings)
DROP TABLE IF EXISTS Payments;
-- Drop the original Bookings table if it exists
DROP TABLE IF EXISTS Bookings;

-- Step 2: Create the master partitioned table for Bookings
-- This table itself will not hold data directly, but defines the partitioning scheme.
CREATE TABLE Bookings (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price > 0),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    -- Foreign keys will be added to the child partitions or managed carefully.
    -- For simplicity in DB-Fiddle, we might omit FKs on the master table definition
    -- and re-add them after child tables are created if needed, or rely on the original schema.
) PARTITION BY RANGE (start_date);

-- Step 3: Create child partition tables
-- Each child table holds a specific range of data.
-- We'll create partitions for a few years around the current date.
-- Adjust these ranges based on your actual data distribution.

-- Partition for bookings starting in 2024
CREATE TABLE bookings_2024 PARTITION OF Bookings
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Partition for bookings starting in 2025
CREATE TABLE bookings_2025 PARTITION OF Bookings
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Partition for bookings starting in 2026 (future bookings)
CREATE TABLE bookings_2026 PARTITION OF Bookings
FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- Add foreign key constraints to the child tables
-- In PostgreSQL, FKs should often be on the master table, but for range partitioning
-- and specific use cases, they might be added to children or handled differently.
-- For this simplified example, we'll assume the original FKs were sufficient or re-add them.
-- Note: DB-Fiddle's SQLite might not support FKs on partitioned tables directly,
-- so this might need to be run in a full PostgreSQL environment.
ALTER TABLE bookings_2024 ADD CONSTRAINT fk_bookings_2024_property_id FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE;
ALTER TABLE bookings_2024 ADD CONSTRAINT fk_bookings_2024_user_id FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE;

ALTER TABLE bookings_2025 ADD CONSTRAINT fk_bookings_2025_property_id FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE;
ALTER TABLE bookings_2025 ADD CONSTRAINT fk_bookings_2025_user_id FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE;

ALTER TABLE bookings_2026 ADD CONSTRAINT fk_bookings_2026_property_id FOREIGN KEY (property_id) REFERENCES Properties(property_id) ON DELETE CASCADE;
ALTER TABLE bookings_2026 ADD CONSTRAINT fk_bookings_2026_user_id FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE;

-- Step 4: Re-create the Payments table (as it depends on Bookings)
CREATE TABLE Payments (
    payment_id UUID PRIMARY KEY,
    booking_id UUID UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE
);

-- Step 5: Insert data into the partitioned Bookings table
-- Data inserted into the master table will automatically be routed to the correct partition.
-- (This data block should be copied from your schema.sql for bookings and payments)
INSERT INTO Bookings (booking_id, user_id, property_id, start_date, end_date, status, total_price) VALUES
    ('b1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'p1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', CURRENT_DATE + INTERVAL '7 days', CURRENT_DATE + INTERVAL '10 days', 'confirmed', 105.00),
    ('b2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'p2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', CURRENT_DATE + INTERVAL '15 days', CURRENT_DATE + INTERVAL '18 days', 'confirmed', 240.00),
    ('b3eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'p2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', CURRENT_DATE + INTERVAL '20 days', CURRENT_DATE + INTERVAL '22 days', 'pending', 160.00),
    ('b4eebc99-c0b-4ef8-bb6d-6bb9bd380a11', '99999999-9999-9999-9999-999999999999', 'p1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', CURRENT_DATE + INTERVAL '25 days', CURRENT_DATE + INTERVAL '28 days', 'confirmed', 200.00);

INSERT INTO Payments (payment_id, booking_id, amount, payment_method) VALUES
    ('pay1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'b1eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 105.00, 'credit_card'),
    ('pay2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 'b2eebc99-c0b-4ef8-bb6d-6bb9bd380a11', 240.00, 'paypal');

-- Note: The other tables (Users, Properties, Reviews, Messages) are assumed to be
-- already created and populated by `schema.sql` and do not need to be re-created here.
