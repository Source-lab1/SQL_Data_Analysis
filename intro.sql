-- USE mavenfuzzyfactory;

-- SELECT 
-- 	utm_content,
--     COUNT( DISTINCT website_session_id) AS sessions
-- FROM website_sessions
-- WHERE website_session_id BETWEEN 1000 AND 2000
-- GROUP BY 
-- 	utm_content 
-- ORDER BY COUNT(DISTINCT website_session_id) DESC;


-- USE mavenfuzzyfactory;

-- SELECT 
-- 	utm_content,
--     COUNT( DISTINCT website_session_id) AS sessions
-- FROM website_sessions
-- WHERE website_session_id BETWEEN 1000 AND 2000
-- GROUP BY 
-- 	utm_content
-- ORDER BY sessions DESC;

-- USE mavenfuzzyfactory;

-- SELECT 
-- 	utm_content,
--     COUNT( DISTINCT website_session_id) AS sessions
-- FROM website_sessions
-- WHERE website_session_id BETWEEN 1000 AND 2000
-- GROUP BY 
-- 	1
-- ORDER BY 2 DESC;

-- USE mavenfuzzyfactory;

-- SELECT
-- 	website_sessions.utm_content,
--     COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
--     COUNT(DISTINCT orders.order_id) AS orders,
--     COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
--     
-- FROM website_sessions
-- 	LEFT JOIN orders
-- 		ON orders.website_session_id = website_sessions.website_session_id
-- WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
-- GROUP BY 1
-- ORDER BY 2 DESC;


-- USE mavenfuzzyfactory;

-- SELECT
-- 	utm_source,
--     utm_campaign,
--     http_referer,
--     COUNT(DISTINCT website_session_id) AS sessions
--     
-- FROM website_sessions
-- WHERE website_sessions.created_at < '2012-04-12'
-- GROUP BY 
-- 	utm_source,
--     utm_campaign,
--     http_referer
-- ORDER BY sessions DESC;


-- USE mavenfuzzyfactory;


-- SELECT
--     -- YEAR(created_at),
-- --     WEEK(created_at),
--     MIN(DATE(created_at)),
--     COUNT(DISTINCT website_session_id) AS sessions
-- FROM website_sessions
-- WHERE website_session_id BETWEEN 100000 and 115000
-- GROUP BY 
-- 	YEAR(created_at),
--     WEEK(created_at)

-- USE mavenfuzzyfactory;

-- SELECT 
-- order_id,
-- primary_product_id,
-- items_purchased
--     
-- FROM orders
-- WHERE order_id BETWEEN 31000 AND 32000


-- USE mavenfuzzyfactory;

-- SELECT 
-- 	primary_product_id,
--     COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS order_w_1_items,
--     COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS order_w_2_items,
--     COUNT(DISTINCT order_id) AS total_orders
--     
-- FROM orders
-- WHERE order_id BETWEEN 31000 AND 32000
-- GROUP BY 1

