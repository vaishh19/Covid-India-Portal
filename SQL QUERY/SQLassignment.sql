--------------------------------------------------------------------------------
-- SECTION A: HOTEL MANAGEMENT SYSTEM
--------------------------------------------------------------------------------
CREATE DATABASE hotel_db;
USE hotel_db;
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    phone_number VARCHAR(20),
    mail_id VARCHAR(100),
    billing_address TEXT
);

CREATE TABLE bookings (
    booking_id VARCHAR(50) PRIMARY KEY,
    booking_date TIMESTAMP,
    room_no VARCHAR(50),
    user_id VARCHAR(50) REFERENCES users(user_id)
);

CREATE TABLE items (
    item_id VARCHAR(50) PRIMARY KEY,
    item_name VARCHAR(100),
    item_rate DECIMAL(10, 2)
);

CREATE TABLE booking_commercials (
    id VARCHAR(50) PRIMARY KEY,
    booking_id VARCHAR(50) REFERENCES bookings(booking_id),
    bill_id VARCHAR(50),
    bill_date TIMESTAMP,
    item_id VARCHAR(50) REFERENCES items(item_id),
    item_quantity DECIMAL(10, 2)
);


INSERT INTO users VALUES ('21wrcxuy-67erfn', 'John Doe', '97XXXXXXXX', 'john.doe@example.com', 'XX, Street Y, ABC City');

INSERT INTO bookings VALUES 
('bk-09f3e-95hj', '2021-09-23 07:36:48', 'rm-bhf9-aerjn', '21wrcxuy-67erfn'),
('bk-q034-q4o', '2021-09-24 10:00:00', 'rm-extra-99', '21wrcxuy-67erfn'),
('bk-nov-test', '2021-11-15 12:00:00', 'rm-101', '21wrcxuy-67erfn');

INSERT INTO items VALUES 
('itm-a9e8-q8fu', 'Tawa Paratha', 18),
('itm-a07vh-aer8', 'Mix Veg', 89),
('itm-w978-23u4', 'Special Thali', 500);

INSERT INTO booking_commercials VALUES 
('q34r-3q4o8-q34u', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a9e8-q8fu', 3),
('q3o4-ahf32-o2u4', 'bk-09f3e-95hj', 'bl-0a87y-q340', '2021-09-23 12:03:22', 'itm-a07vh-aer8', 1),
('134lr-oyfo8-3qk4', 'bk-q034-q4o', 'bl-34qhd-r7h8', '2021-10-23 12:05:37', 'itm-w978-23u4', 3),
('nov-bill-01', 'bk-nov-test', 'bl-nov-001', '2021-11-15 13:00:00', 'itm-w978-23u4', 2);


-- Q1: User ID and last booked room_no
SELECT user_id, room_no FROM (
    SELECT user_id, room_no, ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY booking_date DESC) as rn 
    FROM bookings
) t WHERE rn = 1;

-- Q2: Booking ID and total billing (November 2021)
SELECT b.booking_id, SUM(bc.item_quantity * i.item_rate) as total_amount
FROM bookings b 
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE b.booking_date BETWEEN '2021-11-01' AND '2021-11-30 23:59:59'
GROUP BY b.booking_id;

-- Q3: Bill_id and amount > 1000 (October 2021)
SELECT bc.bill_id, SUM(bc.item_quantity * i.item_rate) as bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date BETWEEN '2021-10-01' AND '2021-10-31 23:59:59'
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;

-- Q4: Most and least ordered item of each month 2021
WITH MonthlyStats AS (
    SELECT EXTRACT(MONTH FROM bill_date) as month, item_id, SUM(item_quantity) as qty
    FROM booking_commercials WHERE EXTRACT(YEAR FROM bill_date) = 2021 GROUP BY 1, 2
),
RankedItems AS (
    SELECT *, 
    RANK() OVER(PARTITION BY month ORDER BY qty DESC) as r_max,
    RANK() OVER(PARTITION BY month ORDER BY qty ASC) as r_min
    FROM MonthlyStats
)
SELECT month, item_id, qty, CASE WHEN r_max = 1 THEN 'Most' ELSE 'Least' END as status
FROM RankedItems WHERE r_max = 1 OR r_min = 1;

-- Q5: Customers with second highest bill value of each month 2021
WITH MonthlyBills AS (
    SELECT EXTRACT(MONTH FROM bc.bill_date) as m, b.user_id, bc.bill_id, SUM(bc.item_quantity * i.item_rate) as total
    FROM booking_commercials bc JOIN bookings b ON bc.booking_id = b.booking_id JOIN items i ON bc.item_id = i.item_id
    WHERE EXTRACT(YEAR FROM bc.bill_date) = 2021 GROUP BY 1, 2, 3
),
Ranked AS (
    SELECT *, DENSE_RANK() OVER(PARTITION BY m ORDER BY total DESC) as rnk FROM MonthlyBills
)
SELECT m as Month, user_id, total FROM Ranked WHERE rnk = 2;


--------------------------------------------------------------------------------
-- SECTION B: CLINIC MANAGEMENT SYSTEM
--------------------------------------------------------------------------------

CREATE DATABASE clinic_db;
USE clinic_db;
CREATE TABLE clinics (
    cid VARCHAR(50) PRIMARY KEY,
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE customer (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    mobile VARCHAR(20)
);

CREATE TABLE clinic_sales (
    oid VARCHAR(50) PRIMARY KEY,
    uid VARCHAR(50) REFERENCES customer(uid),
    cid VARCHAR(50) REFERENCES clinics(cid),
    amount DECIMAL(15, 2),
    datetime TIMESTAMP,
    sales_channel VARCHAR(50)
);

CREATE TABLE expenses (
    eid VARCHAR(50) PRIMARY KEY,
    cid VARCHAR(50) REFERENCES clinics(cid),
    description TEXT,
    amount DECIMAL(15, 2),
    datetime TIMESTAMP
);

-- 2. Insert Sample Data
INSERT INTO clinics VALUES ('cnc-01', 'XYZ clinic', 'lorem', 'ipsum', 'dolor'), ('cnc-02', 'ABC clinic', 'lorem', 'ipsum', 'dolor');
INSERT INTO customer VALUES ('cust-01', 'Jon Doe', '97XXXXXXXX'), ('cust-02', 'Jane Smith', '98XXXXXXXX');
INSERT INTO clinic_sales VALUES 
('ord-01', 'cust-01', 'cnc-01', 25000, '2021-09-23 12:00:00', 'sodat'),
('ord-02', 'cust-02', 'cnc-01', 15000, '2021-09-24 12:00:00', 'direct'),
('ord-03', 'cust-01', 'cnc-02', 5000, '2021-09-25 12:00:00', 'sodat');
INSERT INTO expenses VALUES ('exp-01', 'cnc-01', 'supplies', 500, '2021-09-23 07:00:00');

-- 3. SOLUTIONS FOR SECTION B
-- Q1: Revenue per sales channel (2021)
SELECT sales_channel, SUM(amount) as revenue FROM clinic_sales 
WHERE EXTRACT(YEAR FROM datetime) = 2021 GROUP BY sales_channel;

-- Q2: Top 10 valuable customers (2021)
SELECT uid, SUM(amount) as total_spent FROM clinic_sales 
WHERE EXTRACT(YEAR FROM datetime) = 2021 GROUP BY uid ORDER BY total_spent DESC LIMIT 10;

-- Q3: Month wise rev, exp, profit, status (2021)
WITH Rev AS (SELECT EXTRACT(MONTH FROM datetime) as m, SUM(amount) as r FROM clinic_sales WHERE EXTRACT(YEAR FROM datetime)=2021 GROUP BY 1),
     Exp AS (SELECT EXTRACT(MONTH FROM datetime) as m, SUM(amount) as e FROM expenses WHERE EXTRACT(YEAR FROM datetime)=2021 GROUP BY 1)
SELECT COALESCE(Rev.m, Exp.m) as month, COALESCE(r,0) as revenue, COALESCE(e,0) as expense, (COALESCE(r,0)-COALESCE(e,0)) as profit,
CASE WHEN (COALESCE(r,0)-COALESCE(e,0)) > 0 THEN 'profitable' ELSE 'not-profitable' END as status
FROM Rev FULL JOIN Exp ON Rev.m = Exp.m;

-- Q4: Most profitable clinic per city (Sept 2021)
WITH Profit AS (
    SELECT c.city, c.clinic_name, (SUM(COALESCE(s.amount,0)) - SUM(COALESCE(e.amount,0))) as p
    FROM clinics c LEFT JOIN clinic_sales s ON c.cid = s.cid AND EXTRACT(MONTH FROM s.datetime)=9
    LEFT JOIN expenses e ON c.cid = e.cid AND EXTRACT(MONTH FROM e.datetime)=9 GROUP BY 1, 2
)
SELECT city, clinic_name, p FROM (SELECT *, RANK() OVER(PARTITION BY city ORDER BY p DESC) as r FROM Profit) t WHERE r = 1;

-- Q5: Second least profitable clinic per state (Sept 2021)
WITH Profit AS (
    SELECT c.state, c.clinic_name, (SUM(COALESCE(s.amount,0)) - SUM(COALESCE(e.amount,0))) as p
    FROM clinics c LEFT JOIN clinic_sales s ON c.cid = s.cid AND EXTRACT(MONTH FROM s.datetime)=9
    LEFT JOIN expenses e ON c.cid = e.cid AND EXTRACT(MONTH FROM e.datetime)=9 GROUP BY 1, 2
)
SELECT state, clinic_name, p FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY state ORDER BY p ASC) as r FROM Profit) t WHERE r = 2;