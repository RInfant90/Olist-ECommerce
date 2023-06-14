----- OList ECommerce Queries

-----1. Top selling product categories
WITH BestSellers AS
(
SELECT sell.seller_id, sell.seller_state, t.product_category_name_english,
count(itm.product_id) num_items_sold,
round(sum(pymt.payment_value),2) pymt_totals
FROM olist_order_payments_dataset pymt
JOIN olist_order_items_dataset itm
ON pymt.order_id = itm.order_id 
JOIN olist_products_dataset prod
ON itm.product_id = prod.product_id 
JOIN product_category_name_translation t
ON prod.product_category_name = t.product_category_name 
JOIN olist_sellers_dataset sell
ON itm.seller_id = sell.seller_id 
group by t.product_category_name_english 
ORDER BY pymt_totals DESC, sell.seller_id, sell.seller_state, t.product_category_name_english
)
SELECT BestSellers.product_category_name_english,
sum(pymt_totals) OVER (PARTITION BY seller_id) AS state_pymt_total
FROM BestSellers
ORDER BY state_pymt_total DESC, pymt_totals DESC 



-----2. Top 10 states with the most customer sales
---SP-Sao Paulo, RJ-RiodeJaneiro, MG-MinasGerais, RS-RioGrandeDoSul
---PR-Parana, BA-Bahia, SC-Santa Catarina, DF-Distrito Federal 
---GO-Goias, ES-Espiritu Santo
SELECT cust.customer_state,
count(ord.order_id) order_count,
round(sum(pymt.payment_value),2) pymt_totals
FROM olist_orders_dataset ord
JOIN olist_customers_dataset cust
ON ord.customer_id = cust.customer_id 
JOIN olist_order_payments_dataset pymt
ON ord.order_id = pymt.order_id 
GROUP BY cust.customer_state 
ORDER BY pymt_totals DESC 
LIMIT 10



-----3. how top selling products sell in top 5 best selling states
WITH BestSellers AS
(
SELECT sell.seller_id, sell.seller_state, t.product_category_name_english,
count(itm.product_id) num_items_sold,
round(sum(pymt.payment_value),2) pymt_totals
FROM olist_order_payments_dataset pymt
JOIN olist_order_items_dataset itm
ON pymt.order_id = itm.order_id 
JOIN olist_products_dataset prod
ON itm.product_id = prod.product_id 
JOIN product_category_name_translation t
ON prod.product_category_name = t.product_category_name 
JOIN olist_sellers_dataset sell
ON itm.seller_id = sell.seller_id 
--WHERE sell.seller_state IN ('SP', 'RJ', 'MG', 'RS', 'PR')
group by t.product_category_name_english 
ORDER BY pymt_totals DESC, sell.seller_state, t.product_category_name_english
--LIMIT 10
)
SELECT BestSellers.seller_state, BestSellers.product_category_name_english,pymt_totals,
sum(pymt_totals) OVER (PARTITION BY seller_state) AS state_pymt_total
FROM BestSellers
ORDER BY state_pymt_total DESC, pymt_totals DESC 

 

-----4. Top sellers
--what ARE the most popular sellers selling (SELLER STATE, DOESNT ANSWER Q)
WITH BestSellers AS
(
SELECT sell.seller_id, sell.seller_state, t.product_category_name_english,
count(itm.product_id) num_items_sold,
round(sum(pymt.payment_value),2) pymt_totals
FROM olist_order_payments_dataset pymt
JOIN olist_order_items_dataset itm
ON pymt.order_id = itm.order_id 
JOIN olist_products_dataset prod
ON itm.product_id = prod.product_id 
JOIN product_category_name_translation t
ON prod.product_category_name = t.product_category_name 
JOIN olist_sellers_dataset sell
ON itm.seller_id = sell.seller_id 

--GROUP BY t.product_category_name_english 
group by sell.seller_id --what most popular sellers sell 
--group by t.product_category_name_english -- best selling items overall
--group by sell.seller_state, t.product_category_name_english --best selling by state
ORDER BY pymt_totals DESC, sell.seller_id, sell.seller_state, t.product_category_name_english
)

SELECT *,
sum(pymt_totals) OVER (PARTITION BY seller_id) AS state_pymt_total
FROM BestSellers
ORDER BY state_pymt_total DESC, pymt_totals DESC 



----5. Products sold by top 5 sellers
WITH BestSellers AS
(
SELECT sell.seller_id, sell.seller_state, t.product_category_name_english, 
round(SUM(payment_value),2) AS pymt_totals
--
FROM olist_order_payments_dataset ord
JOIN olist_order_items_dataset itm
ON ord.order_id = itm.order_id 
JOIN olist_sellers_dataset sell
ON itm.seller_id = sell.seller_id
JOIN olist_products_dataset prod
ON itm.product_id = prod.product_id 
JOIN product_category_name_translation t
ON prod.product_category_name = t.product_category_name 
---WHERE seller_state IN ('SP', 'RJ', 'MG')
group by sell.seller_id, sell.seller_state, t.product_category_name_english --best selling by state
ORDER BY pymt_totals DESC, sell.seller_state, t.product_category_name_english
)

SELECT *,
sum(pymt_totals) OVER (PARTITION BY seller_id) AS state_pymt_total
FROM BestSellers
ORDER BY state_pymt_total DESC, pymt_totals DESC, BestSellers.product_category_name_english
--LIMIT 40



----6. Seller id with most sales by payment type 
WITH SellerTotals AS 
(
SELECT osd.seller_id, osd.seller_state, oopd.payment_type,
round(SUM(payment_value),2) AS payment_totals
--
FROM olist_order_payments_dataset oopd 
JOIN olist_order_items_dataset ooid
ON oopd.order_id = ooid.order_id 
JOIN olist_sellers_dataset osd 
ON ooid.seller_id = osd.seller_id 
GROUP BY osd.seller_id, oopd.payment_type 
ORDER BY osd.seller_id, oopd.payment_type, payment_totals DESC 
)
SELECT *,
sum(payment_totals) OVER (PARTITION BY seller_id) AS payment_totals_per_seller
FROM SellerTotals
ORDER BY payment_totals_per_seller DESC, payment_totals DESC  



-----7. Which payment type is most popular
--credit card, but made payment_installments 
--boleto being the 2nd favorable; is a cash payment method
SELECT payment_type, --count(payment_type) AS num_payment, 
round(sum(payment_value),2) AS payment_totals
FROM olist_order_payments_dataset oopd 
GROUP BY payment_type
ORDER BY payment_totals DESC 




