use pizzahut;

-- total number of orders placed

select count(order_id) as total_orders
from orders;

-- total revenue generated from pizza sales

select round(sum(o.quantity * p.price),2) as total_revenue
from order_details o
join pizzas p
on o.pizza_id=p.pizza_id;

-- Highest priced pizza

select pt.name,p.price
from pizza_types pt
join pizzas p
on pt.pizza_type_id=p.pizza_type_id
order by p.price desc
limit 1;

-- most common pizza size ordered

select p.size,count(o.quantity) 
as common_pizza
from order_details o
join pizzas p
on o.pizza_id=p.pizza_id
group by p.size
order by common_pizza desc;


-- top 5 most ordered pizza types along with their quantities

select pt.name,sum(o.quantity) as most_ordered
from pizza_types pt
join pizzas p
on pt.pizza_type_id=p.pizza_type_id
join order_details o
on o.pizza_id=p.pizza_id
group by pt.name
order by most_ordered desc
limit 5;

-- total quantity of each pizza category ordered

select p.category,sum(o.quantity) as quantity
from pizza_types p
join pizzas pp
on p.pizza_type_id=pp.pizza_type_id
join order_details o
on o.pizza_id=pp.pizza_id
group by p.category;

-- total orders per hour in a day

select hour(time),count(order_id) as total_orders_per_hour
from orders
group by hour(time)
order by total_orders_per_hour desc;


-- category wise distribution of pizzas

select category,count(name) as pizzas
from pizza_types
group by category;


-- group the orders by date calculate the avg number of pizzas sold per day

select round(avg(count_of_pizzas_per_day),0) 
as avg_pizza_sold
from
(select o.date,sum(oo.quantity) 
as count_of_pizzas_per_day
from orders o
join order_details oo
on o.order_id=oo.order_id
group by o.date) as order_table;

-- top 3 most ordered pizza types based on revenue

select p.name,sum(pp.price*o.quantity) as revenue
from pizza_types p
join pizzas pp
on p.pizza_type_id=pp.pizza_type_id
join order_details o
on o.pizza_id=pp.pizza_id
group by p.name
order by revenue desc
limit 3;  

-- percentage contribution  of each pizza category to total revenue

select p.category,round(sum(o.quantity*pp.price)
/(select round(sum(o.quantity * p.price),2) 
as total_revenue
from order_details o
join pizzas p
on o.pizza_id=p.pizza_id)*100,2)
as percentage
from pizza_types p
join pizzas pp
on p.pizza_type_id=pp.pizza_type_id
join order_details o
on o.pizza_id=pp.pizza_id
group by p.category;

-- cumilative revenue generated over time
select date,sum(revenue) over (order by date) 
as cum_revenue
from 
(select oo.date,sum(o.quantity*p.price) as revenue
from order_details o
join pizzas p
on o.pizza_id=p.pizza_id
join orders oo
on oo.order_id=o.order_id
group by oo.date) as sales;

-- top 3 pizza types for each category based on revenue
select category,name,revenue
from 
(select category,name,revenue,
rank() over (partition by category order by revenue desc)
 as ranking
from
(select pp.category,pp.name,sum(o.quantity * p.price)
 as revenue
from pizza_types pp
join pizzas p
on pp.pizza_type_id=p.pizza_type_id
join order_details o
on o.pizza_id=p.pizza_id
group by pp.category,pp.name) as b)as a
where ranking<=3
