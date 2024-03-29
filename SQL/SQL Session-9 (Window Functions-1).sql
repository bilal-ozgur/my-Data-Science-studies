--SQL SESSION-9, (Window Functions-1)

--Window Functions (WF) vs. GROUP BY
--Let's review the following two queries for differences between GROUP BY and WF.
---------------------------------------------------------------------

--QUESTION: Write a query that returns the total stock amount of each product in the stock table.
--(�r�nlerin stock say�lar�n� bulunuz)

-----with Group By

SELECT	product_id,
		SUM(quantity) AS total_stock
FROM product.stock
GROUP BY product_id
ORDER BY 1

-----with WF

SELECT	DISTINCT product_id,
		SUM(quantity) OVER(PARTITION BY product_id) AS total_stock
FROM product.stock;


--///////////////////////////////
--QUESTION: Write a query that returns average product prices of brands. 
--(markalara g�re ort. �r�n fiyatlar�n� hem Group By hem de Window Functions ile hesaplay�n�z)

-----with Group By

SELECT	brand_id,
		AVG(list_price) AS avg_price
FROM product.product
GROUP BY brand_id;

---with WF

SELECT	DISTINCT brand_id,
		AVG(list_price) OVER(PARTITION BY brand_id) AS avg_price
FROM	product.product;


-------------------------------------------------------------------------
--1. ANALYTIC AGGREGATE FUNCTIONS
--MIN() - MAX() - AVG() - SUM() - COUNT()
-------------------------------------------------------------------------

--QUESTION: What is the cheapest product price for each category?
--(Her bir kategorideki en ucuz �r�n�n fiyat�)

SELECT	DISTINCT category_id,
		MIN(list_price) OVER(PARTITION BY category_id) AS cheapest_price
FROM	product.product;


--///////////////////////////////
--QUESTION:	How many different product in the product table?
--(product tablosunda toplam ka� farkl� �r�n bulunmaktad�r)

SELECT	DISTINCT COUNT(product_id) OVER() AS num_of_products
FROM	product.product;


--///////////////////////////////
--QUESTION: How many different product in the order_item table?
--(order_item tablosunda ka� farkl� �r�n bulunmaktad�r)

SELECT	COUNT(DISTINCT product_id) OVER() --GIVES ERROR--
FROM	sale.order_item;

SELECT	*,COUNT(product_id) OVER(PARTITION BY product_id) 
FROM	sale.order_item;

--------------------

SELECT COUNT(DISTINCT product_id)
FROM	sale.order_item;


SELECT DISTINCT COUNT(product_id) OVER() AS cnt_products
FROM (
		SELECT DISTINCT product_id
		FROM sale.order_item ) AS subq


--///////////////////////////////
--QUESTION: Write a query that returns how many products are in each order?
--(her sipari�te ka� �r�n oldu�unu d�nd�ren bir sorgu yaz�n)


----WINDOWS FUNCTION
SELECT	DISTINCT order_id,
		SUM(quantity) OVER(PARTITION BY order_id) AS [quantity]
FROM sale.order_item;

----GROUP BY
SELECT order_id, SUM(quantity) AS [quantity]
FROM sale.order_item
GROUP BY order_id;


--///////////////////////////////
--QUESTION: Write a query that returns the number of products in each category of brands.
--(her bir markan�n farkl� kategorilerdeki �r�n say�lar�)

SELECT	DISTINCT
		category_id,
		brand_id,
		COUNT(product_id) OVER(PARTITION BY category_id,brand_id) AS num_of_products
FROM product.product


-------------------------------------------------------------------------
--WINDOW FRAMES
-------------------------------------------------------------------------

SELECT *
FROM product.product

SELECT brand_id, model_year,
	COUNT(product_id) OVER() cnt_product,
	COUNT(product_id) OVER(PARTITION BY brand_id) ,
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year),
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
					RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
					ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
					ROWS BETWEEN 1 PRECEDING AND CURRENT ROW),
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
					ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
					RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM product.product


-------------------------------------------------------------------------
--2. ANALYTIC NAVIGATION FUNCTIONS
-------------------------------------------------------------------------

--It's mandatory to use ORDER BY.

--******FIRST_VALUE()*****--
--/////////////////////////////////


select *, first_value(first_name) over(order by first_name) 
from sale.staff;

select *, first_value(first_name) over(order by last_name) 
from sale.staff;


--QUESTION: Write a query that returns first order date by month.
--(Her ay i�in ilk sipari� tarihini bulunuz)

SELECT 
	DISTINCT
	YEAR(order_date) AS ord_year,
	MONTH(order_date) AS ord_month,
	FIRST_VALUE(order_date) OVER(PARTITION BY YEAR(order_date), MONTH(order_date) ORDER BY order_date) AS first_order_date
FROM sale.orders;


--QUESTION: Write a query that returns customers and their most valuable order with total amount of it.

SELECT  DISTINCT
		customer_id,
		FIRST_VALUE(order_id) OVER(PARTITION BY customer_id ORDER BY total_amount DESC) AS mv_order,
		FIRST_VALUE(total_amount) OVER(PARTITION BY customer_id ORDER BY total_amount DESC) AS mv_order_net_price
FROM	(
		SELECT	customer_id, b.order_id,
				SUM(quantity * list_price * (1-discount)) AS total_amount
		FROM	sale.orders AS a, sale.order_item AS b
		WHERE	a.order_id = b.order_id
		GROUP BY customer_id, b.order_id
		--ORDER BY customer_id, b.order_id
		) AS subq


--/////////////////////////////////
--******LAST_VALUE()*****--


--QUESTION: Write a query that returns last order date by month.
--(Her ay i�in son sipari� tarihini bulunuz)


SELECT 
	DISTINCT
	YEAR(order_date) AS ord_year,
	MONTH(order_date) AS ord_month,
	order_date,
	LAST_VALUE(order_date) OVER(PARTITION BY YEAR(order_date), MONTH(order_date) 
						ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_order_date
FROM sale.orders;


--/////////////////////////////////
--******LAG() & LEAD()*****--


--LAG() SYNTAX

/*LAG(return_value ,offset [,default]) 
OVER (
    [PARTITION BY partition_expression, ... ]
    ORDER BY sort_expression [ASC | DESC], ...
)*/


--QUESTION: Write a query that returns the order date of the one previous sale of each staff (use the LAG function)
--(Her bir personelin bir �nceki sat���n�n sipari� tarihini yazd�r�n�z)

SELECT  order_id,
		first_name,
		last_name,
		order_date,
		LAG(order_date) OVER(PARTITION BY a.staff_id ORDER BY order_date) AS previous_order
		
FROM	sale.orders AS a,
		sale.staff AS b
WHERE	a.staff_id = b.staff_id;


----------------------------------

--LEAD() SYNTAX

/*LEAD(return_value ,offset [,default]) 
OVER (
    [PARTITION BY partition_expression, ... ]
    ORDER BY sort_expression [ASC | DESC], ...
)*/

--QUESTION: Write a query that returns the order date of the one next sale of each staff (use the LEAD function)
--(Her bir personelin bir sonraki sat���n�n sipari� tarihini yazd�r�n�z)


SELECT  order_id,
		first_name,
		last_name,
		order_date,
		LEAD(order_date) OVER(PARTITION BY a.staff_id ORDER BY order_date) AS next_order
		
FROM	sale.orders AS a,
		sale.staff AS b
WHERE	a.staff_id = b.staff_id;


--QUESTION: Write a query that returns the difference order count between the current month and the next month for each year. 
--(Her bir y�l i�in pe� pe�e gelen aylar�n sipari� say�lar� aras�ndaki farklar� bulunuz)


SELECT  order_year,
		order_month,
		cnt_of_orders,
		cnt_of_orders - LEAD(cnt_of_orders) OVER (PARTITION BY order_year ORDER BY order_year) AS [difference]

FROM (
		SELECT	DISTINCT
				YEAR(order_date) AS order_year,
				MONTH(order_date) AS order_month,
				COUNT(order_id) OVER(PARTITION BY YEAR(order_date), MONTH(order_date)) AS cnt_of_orders
		FROM sale.orders
	) AS subq;
