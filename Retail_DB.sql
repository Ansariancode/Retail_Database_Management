CREATE DATABASE retail_db;
USE retail_db;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    city VARCHAR(100),
    province VARCHAR(100),
    role ENUM('buyer', 'seller')
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    seller_id INT,
    city VARCHAR(100),
    province VARCHAR(100),
    opening_year INT,
    FOREIGN KEY (seller_id) REFERENCES users(user_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    store_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    buyer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    payment_state ENUM('paid', 'unpaid'),
    FOREIGN KEY (buyer_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_item INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    card_id INT,
    amount FLOAT,
    payment_date DATE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE card_details (
    card_id INT PRIMARY KEY,
    buyer_id INT,
    card_number VARCHAR(20),
    card_type VARCHAR(50),
    expiry_date date,
    FOREIGN KEY (buyer_id) REFERENCES users(user_id)
);

CREATE TABLE product_comments (
    comment_id INT PRIMARY KEY,
    buyer_id INT,
    product_id INT,
    comment_text TEXT,
    comment_date DATE,
    FOREIGN KEY (buyer_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

select * from users;
select * from card_details;
select * from order_items;
select * from orders;
select * from payments;
select * from product_comments;
select * from products;
select * from stores;
 -- Q1 Find the product that has been ordered the most times.
 select p.product_name, SUM(oi.quantity) AS total_qty FROM order_items oi
 join products p on oi.product_id = p.product_id
 group by p.product_id, p.product_name
 order by total_qty desc; 
 
 -- Q2 Find all the orders that were placed for products that are sold by stores in the city of Toronto.
select o.order_id, p.product_name
from orders o
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
join stores s on p.store_id = s.store_id
where s.city = 'Toronto';

-- Q3 Find all the details of the buyers who have a phone number that starts with the contact number 91.
select *
from users
where role = 'buyer' and phone like '91%';


-- Q4 Display the address, starttime and endtime of the service points in the same city as that of  userid 5
SELECT store_name AS address, 
       opening_year AS starttime, 
       NULL AS endtime
FROM stores
WHERE city = (
    SELECT city 
    FROM users 
    WHERE user_id = 5
);

-- Q5 Display the total quantity of products from store with storeid 8 in the shopping cart
SELECT SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE p.store_id = 1;

-- Q6 Update the payment state of orders to unpaid which were created after year 2017 and with a total amount greater than 50.
UPDATE orders
SET payment_state = 'unpaid'
WHERE 
    STR_TO_DATE(order_date, '%Y-%m-%d') > '2017-12-31'
    AND total_amount > 50;

-- Q7 Update the name and contact phone number of the address where the province is Quebec and city is Montreal.
UPDATE users
SET name = 'UpdatedUser', phone = '9123456789'
WHERE city = 'Montreal' AND province = 'Quebec';
select * from users;


-- Q8 Delete the store which opened before year 2017
SELECT * FROM stores
WHERE opening_year < 2017;

DELETE FROM stores
WHERE store_id IN (
    SELECT store_id FROM (
        SELECT store_id FROM stores WHERE opening_year < 2017
    ) AS temp
);
select * from orders;

-- Q9 Create a report of all products whose price is above average price using subquery.
SELECT *
FROM products
WHERE price > (
    SELECT AVG(price) FROM products
);

-- Q10 Create a view of all product sales in 2016.
CREATE VIEW product_sales2018 AS
SELECT
    p.product_id,
    p.product_name,
    oi.quantity,
    o.order_date
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE YEAR(STR_TO_DATE(o.order_date, '%Y-%m-%d')) = 2018;

SELECT * FROM product_sales2018;

-- Q11 Retrieve all credit card payments and their associated order information
DESCRIBE payments;
SELECT * FROM payments LIMIT 5;
SELECT
    o.order_id,
    o.order_date,
    o.buyer_id,
    p.amount,
    p.payment_date
FROM
    payments p
JOIN
    orders o ON p.order_id = o.order_id;

-- Q12 Retrieve all stores and their associated managers
SELECT
    s.store_id,
    s.store_name,
    s.seller_id AS manager_id,
    u.name AS manager_name
FROM
    stores s
LEFT JOIN
    users u
ON
    s.seller_id = u.user_id AND u.role = 'seller';
    
-- Q13 Query the total quantity of products from store with storeid 8 in the shopping cart using a subquery.
SELECT SUM(oi.quantity) AS total_quantity
FROM order_items oi
WHERE oi.product_id IN (
    SELECT p.product_id
    FROM products p
    WHERE p.store_id = 3
);

-- Q14 Find all sellers who manage more than one store.

SELECT u.user_id, u.name
FROM users u
JOIN stores s ON u.user_id = s.seller_id
WHERE u.role = 'seller'
GROUP BY u.user_id, u.name
HAVING COUNT(s.store_id) > 1;


-- Q15 Retrieve the names of buyers who have made at least one order and have also left a comment on a product.
SELECT DISTINCT u.name AS commentors
FROM users u
WHERE u.role = 'buyer'
AND u.user_id IN (SELECT o.buyer_id FROM orders o)
AND u.user_id IN (SELECT pc.buyer_id FROM product_comments pc);

