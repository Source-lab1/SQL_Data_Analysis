-- USE mavenfuzzyfactory;

-- SELECT 
-- 	pageview_url,
--     COUNT(DISTINCT website_pageview_id) AS pvs
--     
-- FROM website_pageviews
-- WHERE website_pageview_id < 1000
-- GROUP BY pageview_url
-- ORDER BY pvs DESC; 


-- USE mavenfuzzyfactory;

-- CREATE TEMPORARY TABLE first_pageview
-- SELECT 
-- 	website_session_id,
--     MIN(website_pageview_id) AS min_pv_id
-- FROM website_pageviews
-- WHERE website_pageview_id < 1000
-- GROUP BY website_session_id;

-- SELECT 
-- 	website_pageviews.pageview_url AS landing_page,
--     COUNT(DISTINCT first_pageview.website_session_id) AS session_hitting_lander
-- FROM first_pageview
-- 	LEFT JOIN website_pageviews
-- 		ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
-- GROUP BY 
-- 	website_pageviews.pageview_url

-- Finding Top Website Page

-- USE mavenfuzzyfactory;

-- SELECT 
-- 	pageview_url,
--     COUNT(DISTINCT website_pageview_id) AS pvs
-- FROM website_pageviews
-- WHERE created_at < '2012-06-09'
-- GROUP BY
-- 	pageview_url
-- ORDER BY
-- 	pvs DESC;


-- Identifying Top Entry Pages

-- STEP 1: Find the first pageview for each session
-- STEP 2 : Find the url the customer saw on that first pageview
-- USE mavenfuzzyfactory;

-- CREATE TEMPORARY TABLE first_pv_per_session


-- SELECT 
-- 	website_session_id,
--     MIN(website_pageview_id) AS first_pv
-- FROM website_pageviews
-- WHERE created_at < '2012-06-12'
-- GROUP BY website_session_id;

-- SELECT 
-- 	website_pageviews.pageview_url AS landing_page_url ,
--     COUNT(DISTINCT first_pv_per_session.website_session_id) AS sessions_hitting_page
-- FROM first_pv_per_session
-- 	LEFT JOIN website_pageviews
-- 		ON first_pv_per_session.first_pv = website_pageviews.website_pageview_id
--         
-- GROUP BY
-- 	website_pageviews.pageview_url


# Landing Page Performance Testing

# Business Context : we want to see landing page performance for a certain time period

-- STEP 1 : find the first website_pageview_id for relevant sessions 
-- Step 2 : identify the landing page of each session
-- Step 3 : Counting pageviews for each session , to identify "bounces"
-- Step 4 :  summarizing total sessions and bounced sessions, by LP

--  finding the minimum website pageview id associated with each session we care about
USE mavenfuzzyfactory;


SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at BETWEEN "2014-01-01" AND "2014-02-01"
GROUP BY 
	website_pageviews.website_session_id;
    
    
-- same query as above but this time we are storing the dataset as a temporary table

CREATE TEMPORARY TABLE first_pageviews_demo
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
    AND website_sessions.created_at BETWEEN "2014-01-01" AND "2014-02-01"
GROUP BY 
	website_pageviews.website_session_id;

SELECT * FROM first_pageviews_demo;

-- next , we'll bring in the landing page to each session

CREATE TEMPORARY TABLE sessions_w_landing_page_demo
SELECT 
	first_pageviews_demo.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews_demo.min_pageview_id ; -- website pageview is the landing page view
        
SELECT * FROM sessions_w_landing_page_demo; -- QA only


-- next , we make a table to include a count of pageviews per session

-- first , I'll show you all of the sessions. Then we will limit to bounced sessions and create a temp table

CREATE TEMPORARY TABLE bounced_sessions_only

SELECT 
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
    
FROM sessions_w_landing_page_demo
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_w_landing_page_demo.website_session_id
    
GROUP BY
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page

HAVING 
	COUNT(website_pageviews.website_pageview_id) =1 ;
    
    
SELECT * FROM bounced_sessions_only; 

-- we will do this first , then we will summrize with a count after :


SELECT 
	sessions_w_landing_page_demo.landing_page,
    sessions_w_landing_page_demo.website_session_id,
    bounced_sessions_only.website_session_id AS bounced_website_session_id
FROM sessions_w_landing_page_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
ORDER BY
	sessions_w_landing_page_demo.website_session_id;


    
-- final output  

	-- we will use  the same query we previouly ran and a count of records]
    -- we will group by landing page, and then we'll add a bounce rate column
    
    
SELECT 
	sessions_w_landing_page_demo.landing_page,
    COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS sesions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions,
	COUNT(DISTINCT bounced_sessions_only.website_session_id)/COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS bounce_rate
FROM sessions_w_landing_page_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id

GROUP BY
	sessions_w_landing_page_demo.landing_page
ORDER BY
	bounce_rate DESC;


-- ASSIGNMENT Calculating Bounce Rates

-- STEP 1 : finding the first website_pageview_id for relevant sessions 
-- Step 2 : identify the landing page of each session
-- Step 3 : Counting pageviews for each session , to identify "bounces"
-- Step 4 :  summarizing by counting total sessions and bounced sessions



USE mavenfuzzyfactory;

CREATE TEMPORARY TABLE first_pageview
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE created_at < '2012-06-16'
GROUP BY 
	website_pageviews.website_session_id;

SELECT * FROM first_pageview;


        
-- next , we'll bring in the landing page to each session, like last time , but restrict to home only
-- This is redundant in this case , since all is to to homepage



CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT 
	first_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageview
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageview.min_pageview_id -- website pageview is the landing page view
WHERE website_pageviews.pageview_url ='/home';
        
SELECT * FROM sessions_w_home_landing_page;

-- then a table to have count of pageviews per session
-- then limit it to just bounced_sessions

CREATE TEMPORARY TABLE bounced_sessions

SELECT 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
    
FROM sessions_w_home_landing_page
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id
    
GROUP BY
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page

HAVING 
	COUNT(website_pageviews.website_pageview_id) =1 ;
    
    
SELECT * FROM bounced_sessions; 


-- we'll do first this just to show what's in this query, then we will count them after :


SELECT 
    sessions_w_home_landing_page.website_session_id,
    bounced_sessions.website_session_id AS bounced_website_session_id
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY
	sessions_w_home_landing_page.website_session_id;


-- Now we will count them

SELECT 
    COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_session,
    COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS bounce_rate
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id


-- Analyzing Landing Page Tests
-- It is Similar to previous Test one extra step we have / lander started

-- Step 0 : find out when the new page / lander launched 
-- STEP 1 : finding the first website_pageview_id for relevant sessions 
-- Step 2 : identify the landing page of each session
-- Step 3 : Counting pageviews for each session , to identify "bounces"
-- Step 4 :  summarizing by counting total sessions and bounced sessions

USE mavenfuzzyfactory;

SELECT 
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL

-- first_created_at : 2012-06-19 11:05:54 
-- first_pageview_id : 23504


CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at < '2012-07-28' -- precribed by the assigment
        AND website_pageviews.website_pageview_id > 23504 -- the min_pageview_id we found for
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY
	website_pageviews.website_session_id;
    
SELECT * FROM first_test_pageviews;
    
-- next we'll bring landing page to each session , like last time , but restricting to homw or lander-1 this time

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_home_landing_page
SELECT 
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id -- website pageview is the landing page view
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

SELECT * FROM nonbrand_test_sessions_w_home_landing_page;

-- then a table to have count of pageviews per session
-- then limit it to just bounced_sessions

CREATE TEMPORARY TABLE nobrand_test_bounced_sessions

SELECT 
	nonbrand_test_sessions_w_home_landing_page.website_session_id,
    nonbrand_test_sessions_w_home_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
    
FROM nonbrand_test_sessions_w_home_landing_page
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = nonbrand_test_sessions_w_home_landing_page.website_session_id
    
GROUP BY
	nonbrand_test_sessions_w_home_landing_page.website_session_id,
    nonbrand_test_sessions_w_home_landing_page.landing_page

HAVING 
	COUNT(website_pageviews.website_pageview_id) =1 ;
    
    
SELECT * FROM nobrand_test_bounced_sessions;
    
-- DO the first to show then count them after;

SELECT
	nonbrand_test_sessions_w_home_landing_page.landing_page,
    nonbrand_test_sessions_w_home_landing_page.website_session_id,
    nobrand_test_bounced_sessions.website_session_id AS bounced_website_session_id
FROM nonbrand_test_sessions_w_home_landing_page
	LEFT JOIN nobrand_test_bounced_sessions
    ON nobrand_test_bounced_sessions.website_session_id = nonbrand_test_sessions_w_home_landing_page.website_session_id

ORDER BY
	nonbrand_test_sessions_w_home_landing_page.website_session_id;


-- Final step

SELECT
	nonbrand_test_sessions_w_home_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_sessions_w_home_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT nobrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT nobrand_test_bounced_sessions.website_session_id)/COUNT(DISTINCT nonbrand_test_sessions_w_home_landing_page.website_session_id) AS bounce_rate
FROM nonbrand_test_sessions_w_home_landing_page
	LEFT JOIN nobrand_test_bounced_sessions
    ON nobrand_test_bounced_sessions.website_session_id = nonbrand_test_sessions_w_home_landing_page.website_session_id
GROUP BY 
	nonbrand_test_sessions_w_home_landing_page.landing_page;
    
-- Landing Page Trend Analysis


-- STEP 1 : finding the first website_pageview_id for relevant sessions 
-- Step 2 : identify the landing page of each session
-- Step 3 : Counting pageviews for each session , to identify "bounces"
-- Step 4 :  summarizing by week (bounce rate, session to each lander)

USE mavenfuzzytactory;

CREATE TEMPORARY TABLE session_w_min_pv_id_and_view_count
SELECT
	website_sessions.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
	LEFT JOIN website_pageviews 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-06-01' -- precribed by the assigment
	AND website_sessions.created_at < '2012-08-31' -- precribed by the assigment
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	website_sessions.website_session_id;
    
-- SELECT * FROM session_w_min_pv_id_and_view_count;


CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at

SELECT 
	session_w_min_pv_id_and_view_count.website_session_id,
    session_w_min_pv_id_and_view_count.first_pageview_id,
    session_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
    
FROM session_w_min_pv_id_and_view_count
	LEFT JOIN website_pageviews
		ON session_w_min_pv_id_and_view_count.first_pageview_id =  website_pageviews.website_pageview_id;
        
        
SELECT * FROM sessions_w_counts_lander_and_created_at;


-- Final Output 
USE sessions_w_counts_lander_and_created_at;

SELECT
-- 	YEARWEEK(DATE(session_created_at)) AS year_week,
    MIN(DATE(session_created_at)) AS week_start_date,
--     COUNT(DISTINCT website_session_id) AS total_sessions,
--     COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
	COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions

FROM sessions_w_counts_lander_and_created_at

GROUP BY
	YEARWEEK(DATE(session_created_at));
    
    

--  Concept Building Conversio Funnels Using Testing Conversions

SELECT * FROM website_pageviews WHERE website_session_id = 1059


-- Demo On Building Conversion Funnels
-- Business Context
	-- we want to build a mini conversion funnel, from/lander-2 to /cart
    -- we want to know how many people reach each step , and also dropoff rates
    -- for simplicity of the demo , we're looking at /lander-2 traffic only
    -- for simplicity of the demo, we're looking at customers who like Mr Fuzzy only
    
-- Step -1 : select all pageviews for relavent sessions
-- Step-2 : indentify each relavant pageviews as the specific funnel step
-- Step-3 : create the session-level conversion funnel view
-- Step-4 : aggregate the data to assess funnel performance

-- first I will show you all of the pageviews we care about
-- then , I will remove the comments from my flag columns one by one to show you what that looks like


SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
	AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
GROUP BY
	website_sessions.website_session_id,
    website_pageviews.created_at;

-- next, we will put the previous query inside a sub query (similar to temporary tables)
-- we will group by website_session_id, and take MAX() of each of the flags
-- this MAX() becomes a made_it flag for that session , to show the session made it there

SELECT 
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM (
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
	AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
GROUP BY
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level

GROUP BY 
	website_session_id
    
-- next, we will turn it into temp table

CREATE TEMPORARY TABLE session_level_made_it_flags_demo
SELECT 
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
FROM (
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
	AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
GROUP BY
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level

GROUP BY 
	website_session_id
;


SELECT * FROM session_level_made_it_flags_demo


-- Then this would produce the final output (part 1)


SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)
		/COUNT(DISTINCT website_session_id) AS lander_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)
    / COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS product_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) 
    /COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mr_fuzzy_clickthrough_rate
FROM session_level_made_it_flags_demo;



-- Building Conversion Funnels

-- Step-1 : select all pageviews for relavent sessions
-- Step-2 : indentify each relavant pageviews as the specific funnel step
-- Step-3 : create the session-level conversion funnel view
-- Step-4 : aggregate the data to assess funnel performance


USE mavenfuzzyfactory;


-- Lets' look at the first, then we will use it as subquery to do a session summary around it


SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
   --  website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-08-05' AND '2014-09-05'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = "nonbrand"
GROUP BY
	website_sessions.website_session_id,
    website_pageviews.created_at;
    
    
-- then show this as a session level view of how far the session made it

SELECT 
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thank_you_made_it
FROM (
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-08-05' AND '2014-09-05'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = "nonbrand"
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY
	website_session_id;
    
    
-- then we will turn it into a temporary table

CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT 
	website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thank_you_made_it
FROM (
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-08-05' AND '2014-09-05'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = "nonbrand"
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY
	website_session_id;
    
    
SELECT * 
FROM session_level_made_it_flags
WHERE thank_you_made_it = 1
-- then this would produce the final output

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it =1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it =1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it =1 THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping_made_it =1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it =1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thank_you_made_it =1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flags;

-- billing is equal to zero don't know why

-- then this is the final output part 2 - click rates

SELECT 
    COUNT(DISTINCT CASE WHEN product_made_it =1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it =1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_made_it =1 THEN website_session_id ELSE NULL END) AS product_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it =1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it =1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
	COUNT(DISTINCT CASE WHEN shipping_made_it =1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it =1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it =1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it =1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thank_you_made_it =1 THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN billing_made_it =1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_level_made_it_flags;

-- Analysing Conversion Funnel Test

USE mavenfuzzyfactory;

-- first , finding the starting point to frame the analysis;

SELECT 
	MIN(website_pageviews.website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2'
-- first_pv_id = 53550

-- first we'll look at this without orders, then we'll add in orders

SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id

WHERE website_pageviews.website_pageview_id >= 53550
	AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2');
    
    
-- same as above, just wrapping as a subquery and summarizing
-- final analysis output

SELECT 
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS billing_to_order_rt
    
FROM (
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id

WHERE website_pageviews.website_pageview_id >= 53550
	AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS billing_sessions_w_orders
GROUP BY
	billing_version_seen
    