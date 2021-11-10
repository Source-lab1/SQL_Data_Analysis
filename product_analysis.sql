-- Product Sales Analysis

-- SELECT 
-- 	COUNT(order_id) AS orders,
--     SUM(price_usd) AS revenue,
--     SUM(price_usd-cogs_usd) AS margin,
--     AVG(price_usd) AS average_order_value
-- FROM orders
-- WHERE order_id BETWEEN 100 AND 200
--     


-- Demo

-- SELECT
-- 	primary_product_id,
-- 	COUNT(order_id) AS orders,
--     SUM(price_usd) AS revenue,
--     SUM(price_usd - cogs_usd) AS margin,
--     AVG(price_usd) AS aov
--     
-- FROM orders
-- WHERE order_id BETWEEN 10000 AND 11000
-- GROUP BY 1
-- ORDER BY 2 DESC


-- Product Level Sales Analysis
USE mavenfuzzyfactory;

SELECT
	YEAR(created_at) yr,
    MONTH(created_at) AS mo,
	COUNT(DISTINCT order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY 
	YEAR(created_at),
    MONTH(created_at)
    
-- Product Launch Sales Analysis

USE mavenfuzzyfactory;


SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN primary_product_id = 1 THEN order_id ELSE NULL END) AS product_one_sessions,
    COUNT(DISTINCT CASE WHEN primary_product_id = 2 THEN order_id ELSE NULL END) AS product_two_sessions
    
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-04-05'
	AND website_sessions.created_at > '2012-04-01'
GROUP BY 1,2;


-- Product Pathing Analysis


-- Step 1 : Find the relevent/products pageviews with website_session_id
-- Step 2 : Find the next pageview id that occurs AFTER the product pageview
-- Step 3 : Find the pageview_url associated with any applicable next pageview_id
-- Step 4 : Summarize the data and analyze the pre vs post periods

-- Step 1 : Find the relevent/products pageviews with website_session_id

CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
    CASE
		WHEN created_at < '2013-01-06' THEN 'A. Pre_Product_2'
        WHEN created_at >= '2013-01-06' THEN "B. Post_Product_2"
        ELSE 'uh oh .. check logic'
	END AS time_period
FROM website_pageviews
WHERE created_at < '2013-04-06' -- date request
	AND created_at > '2012-10-06' -- start of 3 mo before product 2 launch
    AND pageview_url = '/products';
  
  
SELECT * FROM products_pageviews;
-- Step 2 : Find the next pageview id that occurs AFTER the product pageview

CREATE TEMPORARY TABLE sessions_w_next_pageview_id

SELECT
	products_pageviews.time_period,
    products_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews
	LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = products_pageviews.website_session_id
    AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
GROUP BY 1,2;
    
SELECT * FROM sessions_w_next_pageview_id;
-- Step 3 : Find the pageview_url associated with any applicable next pageview_id

CREATE TEMPORARY TABLE sessions_w_next_pageview_url

SELECT
	sessions_w_next_pageview_id.time_period,
    sessions_w_next_pageview_id.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url
FROM sessions_w_next_pageview_id
	LEFT JOIN website_pageviews
    ON website_pageviews.website_pageview_id = sessions_w_next_pageview_id.min_next_pageview_id;

-- just to show the distinct next pageview urls
SELECT DISTINCT next_pageview_url FROM sessions_w_next_pageview_url;

-- Step 4 : Summarize the data and analyze the pre vs post periods

-- pages /the-original-mr-fuzzy, /the-forever-love-bear

SELECT
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = ' /the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = ' /the-forever-love-bear' THEN website_session_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS pct_to_lovebear
FROM sessions_w_next_pageview_url
GROUP BY time_period;



-- Product Conversion Funnel

-- STEP 1 : SELECT  all pageviews for relavant sessions
-- STEP 2 : figure out which pageview urls to look for
-- STEP 3 : pull all pageviews and identify the funnel steps
-- Step 4 : create the session-level conversion funnel view
-- Step 5 : aggregate the data to assess funnel performance

-- STEP 1 : SELECT  all pageviews for relavant sessions

-- pages /the-original-mr-fuzzy, /the-forever-love-bear
CREATE TEMPORARY TABLE sessions_seeing_product_pages
SELECT 
	website_session_id,
    website_pageview_id,
    pageview_url AS product_page_seen
FROM website_pageviews
WHERE created_at < '2013-04-10'
	AND created_at > '2013-01-06'
    AND pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear');
    
-- STEP 2 : figure out which pageview urls to look for


SELECT DISTINCT 
	website_pageviews.pageview_url
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
;
-- we'll look at the inner query first look at the pageview level results
-- then , turn it into a sub query and make it the summary with flags

-- STEP 3 : pull all pageviews and identify the funnel steps
-- /cart,/shipping,/billing,/billing-2,/thank-you-for-your-order


SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
ORDER BY
	sessions_seeing_product_pages.website_session_id,
    website_pageviews.created_at
;

-- Step 4 : create the session-level conversion funnel view

CREATE TEMPORARY TABLE session_product_level_made_it_flags
SELECT 
	website_session_id,
    CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
        WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
        ELSE 'uh oh.. check logic'
	END AS product_seen,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
ORDER BY
	sessions_seeing_product_pages.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY
	website_session_id,
    CASE
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
        WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
        ELSE 'uh oh.. check logic'
	END
;


-- Step 5 : aggregate the data to assess funnel performance

-- final out part 1 

SELECT
	product_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_product_level_made_it_flags
GROUP BY product_seen;

-- then final output part 2

SELECT
	product_seen,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS product_page_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_product_level_made_it_flags
GROUP BY product_seen;



-- Cross sell Analysis

SELECT
    orders.primary_product_id,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT CASE WHEN order_items.product_id =1 THEN orders.order_id ELSE NULL END) AS x_sell_prod1,
    COUNT(DISTINCT CASE WHEN order_items.product_id =2 THEN orders.order_id ELSE NULL END) AS x_sell_prod2,
    COUNT(DISTINCT CASE WHEN order_items.product_id =3 THEN orders.order_id ELSE NULL END) AS x_sell_prod3,
    
	COUNT(DISTINCT CASE WHEN order_items.product_id =1 THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT orders.order_id) AS x_sell_prod1_rt,
    COUNT(DISTINCT CASE WHEN order_items.product_id =2 THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT orders.order_id) AS x_sell_prod2_rt,
    COUNT(DISTINCT CASE WHEN order_items.product_id =3 THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT orders.order_id) AS x_sell_prod3_rt
FROM orders
	LEFT JOIN order_items
		ON order_items.order_id = orders.order_id
        AND order_items.is_primary_item = 0 -- cross sell only 
WHERE orders.order_id BETWEEN 10000 AND 11000
GROUP BY 1;

-- Assignment Cross- Sell Analysis 

-- STEP 1: Identify the relavent/cart page views and their sessions
-- STEP 2: See which of those /cart sessions clicked through to the shipping page
-- STEP 3: Find  the orders associated with the /cart sessions. Analyze products purchased , AOV
-- Step 4: Aggregate and analyze a summary of our findings

-- STEP 1: Identify the relavent/cart page views and their sessions
CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT 
	CASE 
		WHEN created_at < '2013-09-25' THEN 'A. Pre_Cross_Sell'
		WHEN created_at >= '2013-09-25' THEN 'B. Post_Cross_Sell'
		ELSE 'uh oh...check logic'
	END AS time_period,
	website_session_id AS cart_session_id,
    website_pageview_id AS cart_pageview_id
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND pageview_url = '/cart';
    
SELECT * FROM sessions_seeing_cart;

-- STEP 2: See which of those /cart sessions clicked through to the shipping page

CREATE TEMPORARY TABLE cart_sessions_seeing_another_page
SELECT  
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    MIN(website_pageviews.website_pageview_id) AS pv_id_after_cart
FROM sessions_seeing_cart
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_cart.cart_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_cart.cart_pageview_id
GROUP BY 1,2
HAVING
	MIN(website_pageviews.website_pageview_id) IS NOT NULL;
	
    
CREATE TEMPORARY TABLE pre_post_sessions_orders
SELECT 
	time_period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
    
FROM sessions_seeing_cart
	INNER JOIN orders
		ON sessions_seeing_cart.cart_session_id = orders.website_session_id;
         
-- first we'lll look at this select statement
-- then we'll turn it into a subquery

SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicker_another_page,
    CASE WHEN pre_post_sessions_orders.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_orders.items_purchased,
	pre_post_sessions_orders.price_usd
FROM sessions_seeing_cart
	LEFT JOIN cart_sessions_seeing_another_page
		ON sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
	LEFT JOIN pre_post_sessions_orders
		ON sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
ORDER BY
	cart_session_id;
    
-- SELECT * FROM pre_post_sessions_orders

-- SELECT * FROM cart_sessions_seeing_another_page

-- SELECT * FROM  pre_post_sessions_orders

SELECT
	time_period,
    COUNT(DISTINCT cart_session_id) AS cart_sessions,
    SUM(clicked_to_another_page) AS clickthroughs,
    SUM(clicked_to_another_page)/COUNT(DISTINCT cart_session_id) AS cart_ctr,
    SUM(placed_order) AS orders_placed,
    SUM(items_purchased) AS products_purchased,
    SUM(items_purchased)/ SUM(placed_order) AS products_per_order,
    SUM(price_usd) AS revenue,
    SUM(price_usd)/SUM(placed_order) AS aov,
    SUM(price_usd)/COUNT(DISTINCT cart_session_id) AS rev_cart_session
FROM( 
SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_orders.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_orders.items_purchased,
	pre_post_sessions_orders.price_usd
FROM sessions_seeing_cart
	LEFT JOIN cart_sessions_seeing_another_page
		ON sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
	LEFT JOIN pre_post_sessions_orders
		ON sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
ORDER BY
	cart_session_id
) AS full_data
GROUP BY time_period;


-- Portfolio Expansion Analysis

SELECT 
	CASE 
		WHEN website_sessions.created_at < '2013-12-12' THEN 'A. Pre_Birthday_Bear'
		WHEN website_sessions.created_at >= '2013-12-12' THEN 'B. Post_Birthday_Bear'
		ELSE 'uh oh...check logic'
	END AS time_period,
    --COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    --COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    -- SUM(orders.price_usd) AS total_revenue,
    -- SUM(orders.items_purchased) AS total_products_sold,
    SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS average_order_value,
    SUM(orders.items_purchased)/COUNT(DISTINCT orders.order_id) AS products_per_order,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
        
WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1;

-- Product Refund Analysis Demo

SELECT 
	order_items.order_id,
    order_items.order_item_id,
    order_items.price_usd AS price_paid_usd,
    order_items.created_at,
    order_item_refunds.order_item_refund_id,
    order_item_refunds.refund_amount_usd,
    order_item_refunds.created_at
FROM order_items
	LEFT JOIN order_item_refunds
		ON order_item_refunds.order_item_id = order_items.order_item_id
WHERE order_items.order_id IN ( 3489,32049,27061)
;

-- Assignment Product Refund Rate

SELECT
	YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_orders,
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_item_refunds.order_item_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_refund_rt,
	COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_orders,
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_item_refunds.order_item_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_refund_rt,
	COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_orders,
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_item_refunds.order_item_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_refund_rt,
	COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_orders,
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_item_refunds.order_item_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_refund_rt

FROM order_items
	LEFT JOIN order_item_refunds
		ON order_items.order_item_id = order_item_refunds.order_item_id
WHERE order_items.created_at < '2014-10-15'
GROUP BY 1,2