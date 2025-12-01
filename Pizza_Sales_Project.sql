create database pizzahut;
use pizzahut;
create table orders(order_id int not null,order_date datetime not null,order_time time not null, primary key (order_id));

create table orderdetails(order_details_id int not null,pizza_id text not null,quantity int not null, primary key (order_details_id));


-- Questions And Answers


-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS total_Sales
FROM
    orderdetails o
        JOIN
    pizzas p ON p.pizza_id = o.pizza_id;



-- Identify the highest-priced pizza.
SELECT 
    p.name, p1.price
FROM
    pizza_types p
        JOIN
    pizzas p1 ON p.pizza_type_id = p1.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(o.order_details_id) AS total_count
FROM
    pizzas p
        JOIN
    orderdetails o USING (pizza_id)
GROUP BY p.size
ORDER BY total_count DESC
limit 1;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orderdetails ON orderdetails.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY quantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    p.category, SUM(o.quantity) AS quantity
FROM
    pizza_types p
        JOIN
    pizzas p1 USING (pizza_type_id)
        JOIN
    orderdetails o USING (pizza_id)
GROUP BY p.category
ORDER BY quantity DESC;



-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS count
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) as avg_pizzas_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(o1.quantity) AS quantity
    FROM
        orders o
    JOIN orderdetails o1 ON o.order_id = o1.order_id
    GROUP BY o.order_date) AS order_quantity;
    
    
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    p.name, SUM(o.quantity * p1.price) AS revenue
FROM
    pizza_types p
        JOIN
    pizzas p1 ON p.pizza_type_id = p1.pizza_type_id
        JOIN
    orderdetails o ON p1.pizza_id = o.pizza_id
GROUP BY p.name
ORDER BY revenue DESC
LIMIT 3;





-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    p.category,
    ROUND(SUM(o.quantity * p1.price) / (SELECT 
                    ROUND(SUM(o.quantity * p.price), 2) AS total_Sales
                FROM
                    orderdetails o
                        JOIN
                    pizzas p ON p.pizza_id = o.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types p
        JOIN
    pizzas p1 ON p.pizza_type_id = p1.pizza_type_id
        JOIN
    orderdetails o ON o.pizza_id = p1.pizza_id
GROUP BY p.category;



-- Analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over (order by order_date) AS cumulative_revenue
from 
(select orders.order_date,sum(orderdetails.quantity*pizzas.price) as revenue from orderdetails
join pizzas using(pizza_id)
join orders using(order_id)
group by order_date) as sales; 



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn from
(select pizza_types.category,pizza_types.name,
sum(orderdetails.quantity*pizzas.price) as revenue
from pizza_types join pizzas using(pizza_type_id)
join orderdetails using(pizza_id)
group by category,name) as a) as b where rn<=3;































