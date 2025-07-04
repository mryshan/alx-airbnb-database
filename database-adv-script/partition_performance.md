# Table Partitioning for Query Optimization

This report details the implementation of table partitioning on the `Bookings` table and the observation of its impact on query performance, particularly for date-range queries.

## 1. Understanding Table Partitioning

Table partitioning is a database technique that divides a large table into smaller, more manageable pieces called partitions. Each partition stores a specific subset of the table's data, based on a defined partitioning key (e.g., `start_date` in our case).

**Why Partition?**
* **Improved Query Performance:** When queries filter data based on the partitioning key (e.g., `WHERE start_date BETWEEN '...' AND '...'`), the database can scan only the relevant partitions, ignoring the rest of the data. This significantly reduces the amount of data the database needs to read and process.
* **Easier Maintenance:** Operations like `DELETE` or `ARCHIVE` old data become faster by dropping entire partitions instead of deleting individual rows.
* **Reduced Index Size:** Indexes on individual partitions are smaller and more efficient than one large index on the entire table.

## 2. Implementing Partitioning on `Bookings` Table

The `partitioning.sql` script demonstrates how to transform the `Bookings` table into a partitioned table based on the `start_date` column.

**Steps to Implement:**
1.  **Backup Data (Crucial in Production):** Always back up your data before making structural changes.
2.  **Drop Dependent Tables:** Tables that have foreign key relationships with `Bookings` (like `Payments`) must be dropped or temporarily disabled before `Bookings` can be dropped and re-created as a partitioned table.
3.  **Create the Master Partitioned Table:** Define `Bookings` with `PARTITION BY RANGE (start_date)`. This master table acts as a logical container.
4.  **Create Child Partitions:** Create individual tables (e.g., `bookings_2024`, `bookings_2025`) using `CREATE TABLE ... PARTITION OF Bookings FOR VALUES FROM ... TO ...`.
5.  **Re-establish Foreign Keys:** Re-create the `Payments` table and its foreign key to `Bookings`. Foreign keys from other tables (like `Users` and `Properties`) to `Bookings` should also be re-established, often on the child partitions for range partitioning in PostgreSQL.
6.  **Re-insert Data:** Insert the original booking data. The database automatically routes each row to its correct child partition based on the `start_date`.

**To apply the partitioning:**
1.  Ensure your `Users`, `Properties`, `Reviews`, and `Messages` tables are already created and populated (from `schema.sql`).
2.  Copy the content of `database-adv-script/partitioning.sql`.
3.  Paste it into your SQL environment's query editor.
4.  Execute the script.

## 3. Testing Query Performance on Partitioned Table

We will use `EXPLAIN ANALYZE` to observe how queries behave on the partitioned table compared to a non-partitioned one.

### Test Query Example (Date Range):

```sql
-- Fetch bookings for a specific date range (e.g., within 2025)
SELECT *
FROM Bookings
WHERE start_date >= '2025-01-01' AND start_date < '2026-01-01';
