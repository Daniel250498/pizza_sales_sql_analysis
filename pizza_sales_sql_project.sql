create database pizza_sales;

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

show tables;

-- text to date and time datatype.
alter table orders modify date date;   
alter table orders modify time time;

-- Retrieve the total number of orders placed.
select count(order_id) from orders;

-- Calculate the total revenue generated from pizza sales. 
select round(sum(o.quantity*p.price),1) as Total_sales from order_details o
join pizzas p on o.pizza_id=p.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    p.price, pi.name
FROM
    pizzas p
        JOIN
    pizza_types pi ON p.pizza_type_id = pi.pizza_type_id
WHERE
    p.price = (SELECT 
            MAX(price)
        FROM
            pizzas);

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(size) AS summ
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
GROUP BY size
ORDER BY summ DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(o.quantity) total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(o.quantity) total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id 
GROUP BY pt.category;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time), COUNT(ORDER_ID) AS summ
FROM
    pizza_sales.orders
GROUP BY HOUR(TIME)
ORDER BY summ DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from pizza_types group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(tol_quan), 1)
FROM
    (SELECT 
        ord.date AS mon, SUM(o.quantity) AS tol_quan
    FROM
        order_details o
    JOIN orders ord ON o.order_id = ord.order_id
    GROUP BY ord.date) AS total_quan_perday;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pi.name, SUM(o.quantity * p.price) AS revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types pi ON p.pizza_type_id = pi.pizza_type_id
GROUP BY pi.name
ORDER BY revenue DESC
LIMIT 3; 

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pi.name, round(SUM(o.quantity * p.price) / (select round(sum(o.quantity*p.price),1) as Total_sales 
                                          from order_details o
                                           join pizzas p on o.pizza_id=p.pizza_id) * 100,2) AS revenue_per
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types pi ON p.pizza_type_id = pi.pizza_type_id
GROUP BY pi.name;

-- Calculate the percentage contribution of each pizza category to total revenue.
 select pt.category, round(sum(o.quantity*p.price) / (select sum(o.quantity*p.price) as Total_sales 
                                          from order_details o
                                           join pizzas p on o.pizza_id=p.pizza_id) * 100,2) AS revenue_per
 from pizzas p
 join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
 join order_details o on p.pizza_id=o.pizza_id 
 group by pt.category;

-- Analyze the cumulative revenue generated over time.
select date, day_revenue,round(sum(day_revenue) over(order by date),0)as cum_revenue	 from
(select o.date,round(sum(od.quantity*p.price),2) AS day_revenue
 from order_details od  
join orders o on od.order_id=o.order_id
join pizzas P ON od.pizza_id=p.pizza_id
 group by o.date) as date_revenue;
 
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,category,revenue from
(select name,category,revenue, dense_rank() over(partition by category order by revenue desc) rnk from 
(select pt.name, pt.category,sum(od.quantity*p.price) as revenue from
order_details od join pizzas p on od.pizza_id=p.pizza_id
join pizza_types pt on p.pizza_type_id= pt.pizza_type_id
group by pt.name,pt.category)as tab) as tab1 
where rnk<=3;






