-- Demo 

USE mavenfuzzyfactory;

SELECT
	website_session_id,
    created_at,
    HOUR(created_at) AS hr,
	WEEKDAY(created_at) AS wkday, -- 0 =  Mon, 1 = Tues, etc
    CASE 
		WHEN WEEKDAY(created_at) = 0 THEN 'Monday'
        WHEN WEEKDAY(created_at) = 1 THEN 'Tuesday'
        ELSE 'Other Day'
	END AS clean_weekday,
    QUARTER(created_at) AS qtr,
    MONTH(created_at) AS mo,
    DATE(created_at) AS date_,
    WEEK(created_at) AS wk

FROM website_sessions

WHERE website_session_id BETWEEN 150000 AND 155000;


-- Analysing Seasonality


USE mavenfuzzyfactory;

SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 1,2;


-- Another on by week

USE mavenfuzzyfactory;

SELECT
	YEAR(website_sessions.created_at) AS yr,
    WEEK(website_sessions.created_at) AS wk,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 1,2;

-- Another on by date

USE mavenfuzzyfactory;

SELECT
	YEAR(website_sessions.created_at) AS yr,
    WEEK(website_sessions.created_at) AS wk,
    MIN(DATE(website_sessions.created_at)) AS week_start,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 1,2;

-- Analyzing Business Patterns
SELECT
	hr,
    -- ROUND(AVG(website_sessions),1) AS avg_sessions,
    ROUND(AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END),1) AS mon,
    ROUND(AVG(CASE WHEN wkday =  1 THEN website_sessions ELSE NULL END),1) AS tues,
   ROUND(AVG(CASE WHEN wkday =  2  THEN website_sessions ELSE NULL END),1) AS weds,
    ROUND(AVG(CASE WHEN wkday = 3 THEN website_sessions ELSE NULL END),1) AS thus,
    ROUND(AVG(CASE WHEN wkday =  4 THEN website_sessions ELSE NULL END),1) AS fri,
   ROUND(AVG(CASE WHEN wkday = 5  THEN website_sessions ELSE NULL END),1) AS sat,
   ROUND(AVG(CASE WHEN wkday = 6  THEN website_sessions ELSE NULL END),1) AS sun
FROM (
SELECT 
	DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
    HOUR( created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3
) AS daily_hoyrly_sessions
GROUP BY 1
ORDER BY 1