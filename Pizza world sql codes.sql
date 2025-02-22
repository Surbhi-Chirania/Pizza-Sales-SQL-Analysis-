create database pizza_world;
use pizza_world;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);

CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL
);

-- 1. Retrieve the total number of orders placed

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
-- 2. Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(price * quantity), 2) AS total_revenue
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3. Identify the highest-priced pizza

SELECT 
    name, price
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- 4. What is the total revenue generated by each pizza size?

SELECT 
    size, ROUND(SUM(price * quantity), 2) AS total_rev_by_size
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size;

-- 5. Which pizza generates the highest total revenue?

SELECT 
    name, ROUND(SUM(price * quantity), 2) AS total_revenue
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY total_revenue DESC
LIMIT 1;

-- 6. What is the average revenue per order?

SELECT 
    ROUND(AVG(total_revenue), 2) AS avg_revenue
FROM
    (SELECT 
        order_id, SUM(price * quantity) AS total_revenue
    FROM
        pizzas
    INNER JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY order_id) AS order_totals;

-- 7. Analyze the cumulative revenue generated over time

SELECT order_date, sum(total_revenue) over (order by order_date) as cumulative_rev 
FROM
(SELECT 
    order_date, ROUND(SUM(price * quantity), 2) AS total_revenue
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    inner join orders
    on order_details.order_id = orders.order_id
    group by order_date) as revenue;

-- 8. What is the total sales revenue by month and season? 

SELECT 
    MONTHNAME(order_date) AS order_month,
    ROUND(SUM(price * quantity), 2) AS total_revenue
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        INNER JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY order_month
ORDER BY total_revenue DESC;

SELECT 
    CASE
        WHEN MONTH(order_date) IN (12 , 1, 2) THEN 'Winter'
        WHEN MONTH(order_date) IN (3 , 4, 5) THEN 'Spring'
        WHEN MONTH(order_date) IN (6 , 7, 8) THEN 'Summer'
        WHEN MONTH(order_date) IN (9 , 10, 11) THEN 'Fall'
    END AS season,
    ROUND(SUM(price * quantity), 2) AS total_revenue
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        INNER JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY season
ORDER BY total_revenue DESC;

-- 9. Calculate the percentage contribution of each pizza category to total revenue
    
 SELECT 
    category,
    ROUND(SUM(price * quantity) / (SELECT 
                    ROUND(SUM(price * quantity), 2) AS total_revenue
                FROM
                    pizzas
                        INNER JOIN
                    order_details ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS percent_revenue
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
ORDER BY percent_revenue DESC;

-- 10. What is the most common pizza size ordered?

SELECT 
    size, SUM(quantity) AS total_quantity
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY size
ORDER BY total_quantity DESC
LIMIT 1;

-- 11. What is the average number of pizzas ordered per customer?

SELECT 
    AVG(total_pizzas) AS avg_pizzas_per_order
FROM
    (SELECT 
        order_id, SUM(quantity) AS total_pizzas
    FROM
        order_details
    GROUP BY order_id) AS order_totals;

-- 12. Which day of the week generates the most pizza sales?

SELECT 
    DAYNAME(order_date) AS day_of_week,
    SUM(quantity) AS total_pizzas_sold
FROM
    order_details
        INNER JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY day_of_week
ORDER BY total_pizzas_sold DESC
LIMIT 1;

-- 13. What time of day are most pizzas ordered?

SELECT 
    HOUR(order_time) AS order_hour,
    SUM(quantity) AS total_pizzas_ordered
FROM
    order_details
        INNER JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY order_hour
ORDER BY total_pizzas_ordered DESC
LIMIT 1; 

-- 14. How often do customers order multiple pizzas in a single order?

SELECT 
    COUNT(order_id) AS multiple_pizza_orders
FROM
    (SELECT 
        order_id, SUM(quantity)
    FROM
        order_details
    GROUP BY order_id
    HAVING SUM(quantity) > 1) AS multiple_pizzas;
    
-- 15. Do customers prefer different pizza sizes based on time of day (e.g., more large pizzas at dinner)?

SELECT 
    HOUR(order_time) AS order_hour,
    size,
    SUM(quantity) AS total_pizzas_ordered
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        INNER JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY order_hour , size
ORDER BY order_hour, total_pizzas_ordered desc;

-- 16. How does ordering behavior differ between weekdays and weekends?

SELECT 
    CASE
        WHEN WEEKDAY(order_date) IN (0 , 1, 2, 3, 4) THEN 'Weekdays'
        WHEN WEEKDAY(order_date) IN (5 , 6) THEN 'Weekend'
    END AS day_type,
    SUM(quantity) AS total_pizzas_ordered
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY day_type;

-- 17. List the top 5 most ordered pizza types along with their quantities

SELECT 
    name, SUM(quantity) AS total_qty
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY total_qty DESC
LIMIT 5;

-- 18. Which pizza category generate the highest quantity sold?

SELECT 
    category, SUM(quantity) as total_quantity
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
ORDER BY total_quantity DESC
LIMIT 1;

-- 19. Which pizzas have the lowest number of orders?

SELECT 
    pizza_id, SUM(quantity) AS total_pizzas_sold
FROM
    order_details
GROUP BY pizza_id
ORDER BY total_pizzas_sold ASC
LIMIT 5;

-- 20. Which 5 pizzas have the highest quantity sold?

SELECT 
    pizza_id, SUM(quantity)
FROM
    order_details
GROUP BY pizza_id
ORDER BY SUM(quantity) DESC
LIMIT 5;

-- 21. Determine the top 3 most ordered pizza types based on revenue for each pizza category

SELECT name, total_revenue FROM
(SELECT name, category, total_revenue, 
rank() over (partition by category order by total_revenue desc) as ranking
from
(SELECT 
    name, category, ROUND(SUM(price * quantity), 2) AS total_revenue
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name, category) as a) as b
where ranking<=3;

-- 22. How do pizza orders vary by month or season?

SELECT 
    MONTHNAME(order_date) AS order_month,
    SUM(quantity) AS total_pizzas_sold
FROM
    order_details
        INNER JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY order_month
ORDER BY total_pizzas_sold DESC;

SELECT 
    CASE
        WHEN MONTH(order_date) IN (12 , 1, 2) THEN 'Winter'
        WHEN MONTH(order_date) IN (3 , 4, 5) THEN 'Spring'
        WHEN MONTH(order_date) IN (6 , 7, 8) THEN 'Summer'
        WHEN MONTH(order_date) IN (9 , 10, 11) THEN 'Fall'
    END AS season,
    SUM(quantity) AS total_pizzas_ordered
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY season
ORDER BY FIELD(season,
        'Winter',
        'Spring',
        'Summer',
        'Fall');

-- 23. How does the quantity sold of each pizza category trend throughout the year?

SELECT 
    MONTH(order_date) AS month,
    category,
    SUM(quantity) AS total_quantity
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        INNER JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY month , category
ORDER BY total_quantity DESC;

-- 24. What has been the monthly quantity sold of vegetarian pizzas compared to non-vegetarian pizzas over the past year?

SELECT 
    MONTH(order_date) AS month,
    SUM(CASE
        WHEN category = 'Veggie' THEN quantity
        ELSE 0
    END) AS veg_qty,
    SUM(CASE
        WHEN category != 'Veggie' THEN quantity
        ELSE 0
    END) AS non_veg_qty
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        INNER JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY month;

-- 25. What is the average time between orders throughout the day?

SELECT order_date, AVG(time_diff) AS avg_time_between_orders_in_minutes
FROM (
    SELECT o.order_date, 
           TIMESTAMPDIFF(MINUTE, LAG(o.order_time) OVER (PARTITION BY o.order_date ORDER BY o.order_time), o.order_time) AS time_diff
    FROM orders as o
) AS time_diffs
WHERE time_diff IS NOT NULL
GROUP BY order_date
ORDER BY order_date;
    
-- 26. What is the distribution of order value (how many orders fall in low, medium, or high price ranges)?

SELECT 
    CASE 
        WHEN order_total < 20 THEN 'Low'  -- Orders below $20 are considered low-value
        WHEN order_total BETWEEN 20 AND 50 THEN 'Medium'  -- Orders between $20 and $50 are medium-value
        ELSE 'High'  -- Orders above $50 are high-value
    END AS order_value_category,
    COUNT(order_id) AS total_orders
FROM (
    SELECT 
        orders.order_id, 
        SUM(quantity * price) AS order_total
    FROM 
        orders 
    JOIN 
        order_details 
    ON 
        orders.order_id = order_details.order_id
    JOIN 
        pizzas 
    ON 
        order_details.pizza_id = pizzas.pizza_id
    GROUP BY 
        orders.order_id
) AS order_totals
GROUP BY 
    order_value_category;  
    
-- 27. What is the total number of pizzas sold in each quarter?

SELECT 
    QUARTER(order_date) AS quarter, SUM(quantity) AS sales
FROM
    orders
        INNER JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY QUARTER(order_date)
ORDER BY quarter;

-- 28. Group the orders by date and calculate the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(total_orders), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        order_date, SUM(quantity) AS total_orders
    FROM
        orders
    INNER JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS order_qty;
