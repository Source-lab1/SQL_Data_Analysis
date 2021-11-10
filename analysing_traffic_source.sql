-- USE mavenfuzzyfactory;


-- SELECT 
-- 	utm_source,
--     utm_campaign,
--     http_referer,
--     COUNT(DISTINCT website_session_id) AS number_of_sessions
-- FROM website_sessions
-- WHERE created_at < '2012-04-12' 
-- GROUP BY
-- 	utm_source,
--     utm_campaign,
--     http_referer
--     
-- ORDER BY number_of_sessions DESC


 
-- USE mavenfuzzyfactory;


-- SELECT 
-- 	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
--     COUNT(DISTINCT orders.order_id) AS orders,
--      COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
-- FROM website_sessions
-- 	LEFT JOIN orders
-- 		ON orders.website_session_id = website_sessions.website_session_id
-- WHERE website_sessions.created_at < '2012-04-14'
-- 	AND utm_source = "gsearch"
--     AND utm_campaign = "nonbrand"
-- ;

-- Traffic Source Trending

-- USE mavenfuzzyfactory;

-- SELECT
-- 	YEAR(created_at) AS yr,
--     MIN(DATE(created_at)) AS week_started_at,
--     WEEK(created_at) AS wk,
--     COUNT(DISTINCT website_session_id) AS sessions
-- FROM website_sessions

-- WHERE created_at < '2012-05-10'
-- 	AND utm_source = 'gsearch'
--     AND utm_campaign = "nonbrand"
-- GROUP BY 
-- 	YEAR(created_at),
--     WEEK(created_at)

-- Traffic Source Bid Optimization 

-- USE mavenfuzzyfactory;

-- SELECT  
-- 	website_sessions.device_type,
--     COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
-- 	COUNT(DISTINCT orders.order_id) AS orders,
--     COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt
-- FROM website_sessions
-- 	LEFT JOIN orders
--     ON orders.website_session_id = website_sessions.website_session_id
-- WHERE website_sessions.created_at <'2012-05-11'
-- 	AND utm_source = 'gsearch'
--     AND utm_campaign = 'nonbrand'

-- GROUP BY 1


 -- Trending w Granular Segments / Traffic Source Segment Trending

USE mavenfuzzyfactory;

SELECT 
-- 	YEAR(created_at) yr,
-- 	WEEK(created_at) wk,
	MIN(DATE(created_at)) AS week_start_at,
	COUNT(DISTINCT CASE WHEN device_type ='desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type ='mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions
    -- COUNT(DISTINCT website_session_id) AS total_sessions


FROM website_sessions
	
WHERE website_sessions.created_at <'2012-06-09'
	AND website_sessions.created_at >'2012-04-15'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'

GROUP BY 
	YEAR(created_at),
    WEEK(created_at) 



