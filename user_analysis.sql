SELECT
	order_items.order_id,
    order_items.order_item_id,
    order_items.price_usd AS price_paid_usd,
    order_items.created_at,
    order_item_refunds.refund_amount_usd,
    order_item_refunds.refund_amount_usd,
    order_item_refunds.created_at,
    DATEDIFF(order_item_refunds.created_at,order_items.created_at) AS days_order_to_refund
FROM order_items
	LEFT JOIN order_item_refunds
		ON order_item_refunds.order_item_id = order_items.order_item_id
WHERE order_items.order_id IN (3489,32049,27061);


-- Identifying Repeat Visitors

-- Step 1: Identify the relavent new sessions
-- Step 2: Use the user_id values form Step 1 to find any repeat sessions those users had
-- Step 3: Analyze the data at the user level (how many sessions did each user have ?)
-- Step 4: Aggregate the user-level analysis to generate your behavioural analysis

CREATE TEMPORARY TABLE sessions_w_repeats

SELECT 
	new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    website_sessions.website_session_id AS repeat_session_id
FROM
(
SELECT
	user_id,
    website_session_id
FROM website_sessions
WHERE created_at < '2014-11-01' -- the date of the assignment
	AND created_at >= '2014-01-01' -- prescribed data range in assignment
    AND is_repeat_session =0 -- new sessions only
) AS new_sessions
	LEFT JOIN website_sessions
    ON website_sessions.user_id = new_sessions.user_id
    AND website_sessions.is_repeat_session =1 -- was a repeat session ( redundant , but goof to illustrate)
    AND website_sessions.website_session_id > new_sessions.website_session_id
    AND website_sessions.created_at < '2014-11-01' -- the date of the assignment
	AND website_sessions.created_at >= '2014-01-01' -- prescribed date range in assignment
    
;

-- SELECT * FROM sessions_w_repeats


SELECT * FROM sessions_w_repeats;


SELECT
	repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM
(
SELECT
	user_id,
    COUNT(DISTINCT new_session_id) AS new_sessions,
    COUNT(DISTINCT repeat_session_id) AS repeat_sessions
FROM sessions_w_repeats
GROUP BY 1
ORDER BY 3 DESC
) AS user_level
GROUP BY 1
;

-- Analyzing Repeat Behavior


-- Step 1: Identify the relavent new sessions
-- Step 2: Use the user_id values form Step 1 to find any repeat sessions those users had
-- Step 3: Find the created_at times for first and second sessions
-- Step 4 : Find the differences between first and second sessions at a user level
-- Step 5: Aggregate the user-level data to find the average , min , max


CREATE TEMPORARY TABLE sessions_w_repeats_for_time_diff

SELECT 
	new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    new_sessions.created_at AS new_session_created_at,
    website_sessions.website_session_id AS repeat_session_id,
    website_sessions.created_at AS repeat_session_created_at
FROM
(
SELECT
	user_id,
    website_session_id, 
    created_at
FROM website_sessions
WHERE created_at < '2014-11-03' -- the date of the assignment
	AND created_at >= '2014-01-01' -- prescribed data range in assignment
    AND is_repeat_session =0 -- new sessions only
) AS new_sessions
	LEFT JOIN website_sessions
    ON website_sessions.user_id = new_sessions.user_id
    AND website_sessions.is_repeat_session =1 -- was a repeat session ( redundant , but goof to illustrate)
    AND website_sessions.website_session_id > new_sessions.website_session_id -- session was later than new sessions
    AND website_sessions.created_at < '2014-11-03' -- the date of the assignment
	AND website_sessions.created_at >= '2014-01-01' -- prescribed date range in assignment
    
;    


---------------

CREATE TEMPORARY TABLE users_first_to_second
SELECT
	user_id,
    DATEDIFF(second_session_created_at,new_session_created_at) AS days_first_to_second_session
FROM
(
SELECT
	user_id,
    new_session_id,
    new_session_created_at,
    MIN(repeat_session_id) AS second_session_id,
    MIN(repeat_session_created_at) AS second_session_created_at
FROM sessions_w_repeats_for_time_diff
WHERE repeat_session_id IS NOT NULL
GROUP BY 1,2,3
) AS first_second;

SELECT * FROM users_first_to_second;

SELECT
	AVG(days_first_to_second_session) AS avg_days_first_to_second,
    MIN(days_first_to_second_session) AS min_days_first_to_second,
    MAX(days_first_to_second_session) AS max_days_first_to_second

FROM users_first_to_second;


-- New Vs Repeat Channel Patterns

SELECT
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at < '2014-11-05' -- the date of the assignment
	AND created_at >= '2014-01-01' -- prescribed data range in assignment
GROUP BY 1,2,3
ORDER BY 5 DESC;


SELECT
	CASE
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN "organinc_search"
        WHEN utm_campaign = "nonbrand" THEN "paid_nonbrand"
        WHEN utm_campaign = "brand" THEN "paid_brand"
        WHEN utm_source IS NULL AND http_referer IS NULL THEN "direct_type_in"
        WHEN utm_source = "socialbook" THEN "paid_social"
	END AS channel_group,
		-- utm_source,
        -- utm_campaign,
        -- http_referer,
        COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
        COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at < '2014-11-05'
	AND created_at >= '2014-01-01'
GROUP BY 1;

-- New VS Repeat Performance

USE mavenfuzzyfactory;
 
SELECT
	is_repeat_session,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
    
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2014-11-08' -- the date of the assignment
	AND website_sessions.created_at >= '2014-01-01' -- prescribed data range in assignment
GROUP BY 1
 
 



