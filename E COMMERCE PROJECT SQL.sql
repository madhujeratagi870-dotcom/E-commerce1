#  Olist Store E ecommerce analysis Project | Mysql

# KPI 1 :Weekday Vs Weekend (orders_purchase_timestamp) Payment Statistics.
# KPI 2 :Number of Orders with review score 5 and payment type as credit card.
# KPI 3 :Average number of days taken for order_delivered_customer_date for pet_shop.
# KPI 4 :Average price and payment values from customers of sap paulo city.
# KPI 5 :Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.



# KPI 1 :Weekday Vs Weekend (orders_purchase_timestamp) Payment Statistics.

use olist_store_analysis;
SELECT * FROM olist_store_analysis.olist_orders_dataset;
SELECT * FROM olist_store_analysis.olist_order_payments_dataset;

select
kpi1.Day ,
concat(round(kpi1.total_payments /(select sum(payment_value) from olist_order_payments_dataset) *100,2)
, '%') as Percentage_Values

from 
(select ord.Day, sum(pmt.payment_value) as total_payments
from olist_order_payments_dataset as pmt
join
(select distinct order_id,
case 
when weekday(order_purchase_timestamp) in (5,6) then "Weekend"
else "Weekday"
end as Day
from olist_orders_dataset) as ord 
on ord.order_id = pmt.order_id
group by ord.Day) as kpi1 ;



# KPI 2 :Number of Orders with review score 5 and payment type as credit card.


SELECT * FROM olist_store_analysis.olist_order_reviews_dataset;
SELECT * FROM olist_store_analysis.olist_order_payments_dataset;

select
count(pmt.order_id) as Total_Orders
from 
olist_order_payments_dataset pmt
inner join olist_order_reviews_dataset rev on pmt.order_id = rev.order_id
where
rev.review_score = 5
and pmt.payment_type = 'credit_card';



# KPI 3 :Average number of days taken for order_delivered_customer_date for pet_shop.


SELECT * FROM olist_store_analysis.product_category_name_translation;
SELECT * FROM olist_store_analysis.olist_orders_dataset;
SELECT * FROM olist_store_analysis.olist_order_items_dataset;
SELECT * FROM olist_store_analysis.olist_products_dataset;

select
prod.product_category_name,
round(avg(datediff(ord.order_delivered_customer_date , order_purchase_timestamp)), 0) as Avg_delivery_days
from olist_orders_dataset ord

join 
(select product_id , Order_id,product_category_name
from olist_products_dataset
join olist_order_items_dataset using(product_id)) as prod
on ord.order_id = prod.order_id
where prod.product_category_name = "Pet_shop"
group by prod.product_category_name;



# KPI 4 :Average price and payment values from customers of sap paulo city.

SELECT * FROM olist_store_analysis.olist_order_items_dataset;
SELECT * FROM olist_store_analysis.olist_orders_dataset;
SELECT * FROM olist_store_analysis.olist_customers_dataset;
SELECT * FROM olist_store_analysis.olist_order_payments_dataset;


with orderItemsAvg AS (
select round(AVG(item.price)) AS avg_order_item_price
from olist_order_items_dataset item
join olist_orders_dataset ord ON item.order_id = ord.order_id
join olist_customers_dataset cust ON ord.customer_id = cust.customer_id
where cust.customer_city = "Sao Paulo"
)
select
(select avg_order_item_price from orderItemsAvg) AS avg_order_item_price,
round(AVG(pmt.payment_value)) AS avg_payment_value
from olist_order_payments_dataset pmt
join olist_orders_dataset ord ON pmt.order_id = ord.order_id
join olist_customers_dataset cust ON ord.customer_id = cust.customer_id
where cust.customer_city =   "Sao Paulo";



# KPI 5 :Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

SELECT * FROM olist_store_analysis.olist_order_reviews_dataset;
SELECT * FROM olist_store_analysis.olist_orders_dataset;
SELECT * FROM olist_store_analysis.olist_orders_dataset;

select
rew.review_score,
round(avg(datediff(ord.order_delivered_customer_date,order_purchase_timestamp)),0) as "Avg shipping days"
From olist_orders_dataset as ord
join olist_order_reviews_dataset as rew on rew.order_id = ord.order_id
group by rew.review_score
order by rew.review_score;

