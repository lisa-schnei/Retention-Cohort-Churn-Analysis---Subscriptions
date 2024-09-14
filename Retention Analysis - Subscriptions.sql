----------------------------------------------------
-- MODULE 3 SPRINT 1 : RETENTION, COHORTS & CHURN --
----------------------------------------------------

-- Author: Lisa Schneider
-- Date: July 2024
-- Tool used: BigQuery

-- EXPLORATORY ANALYSIS & DATA PREPERATION

# Understanding the timeframes for subscription start and end dates
# Start date is a Sunday and end date is a Sunday. Therefore makes most sense to run the week from Sunday-Saturday. 
SELECT MIN(subscription_start) AS min_start,
MAX(subscription_start) AS max_start,
MIN(subscription_end) AS min_end,
MAX(subscription_end) AS max_end
FROM `turing_data_analytics.subscriptions`;


# Checking for duplicates in user_pseudo_id - 4.208 duplicates
SELECT COUNT(DISTINCT user_pseudo_id)
FROM `turing_data_analytics.subscriptions`


# several accounts having up to 3 subscriptions
SELECT user_pseudo_id,
COUNT(*) AS count
FROM `turing_data_analytics.subscriptions`
GROUP BY user_pseudo_id
ORDER BY COUNT(*) DESC;

# Looking into one example of duplicated subscriptions - 2 active subscription, 1 inactive, but having different categories. Number of subscriptions should therefore not go by unique user_pseudo_id. 
SELECT *
FROM `turing_data_analytics.subscriptions`
WHERE user_pseudo_id = '21683663.4440188892'

# Getting a first overview of number of subscriptions started per week
WITH cohort_data AS (
  SELECT subscription_start,
  user_pseudo_id,
  DATE_TRUNC(subscription_start, WEEK) AS week_start, # extracting weekstart date column running Sunday - Saturday (Sunday is default weekstart in BigQuery)
  subscription_end
  FROM `turing_data_analytics.subscriptions`
)

SELECT week_start,
  COUNT(user_pseudo_id) AS subscriptions
FROM cohort_data
GROUP BY week_start
ORDER BY week_start;

# Setting up the overview of users retained per cohort for the following 6 weeks
WITH cohorts AS (
  SELECT DISTINCT # adding DISTINCT here applies to the full table, pulling distinct combinations of all columns in order to not eliminate users with multiple subscriptions
  user_pseudo_id,
  category,
  subscription_end,
  subscription_start,
  DATE_TRUNC(subscription_start, WEEK) AS week_start # extracting cohorts per week starting Sunday (default for DATE_TRUNC week is start on Sunday)
  FROM `turing_data_analytics.subscriptions`
)

SELECT 
cohorts.week_start,
SUM(CASE WHEN cohorts.subscription_end >= cohorts.week_start OR cohorts.subscription_end IS NULL THEN 1 ELSE 0 END) AS week_0, 
SUM(CASE WHEN cohorts.subscription_end > DATE_ADD(cohorts.week_start, INTERVAL 1 WEEK) OR cohorts.subscription_end IS NULL THEN 1 ELSE 0 END) AS week_1,
SUM(CASE WHEN cohorts.subscription_end > DATE_ADD(cohorts.week_start, INTERVAL 2 WEEK) OR cohorts.subscription_end IS NULL THEN 1 ELSE 0 END) AS week_2,
SUM(CASE WHEN cohorts.subscription_end > DATE_ADD(cohorts.week_start, INTERVAL 3 WEEK) OR cohorts.subscription_end IS NULL THEN 1 ELSE 0 END) AS week_3,
SUM(CASE WHEN cohorts.subscription_end > DATE_ADD(cohorts.week_start, INTERVAL 4 WEEK) OR cohorts.subscription_end IS NULL THEN 1 ELSE 0 END) AS week_4,
SUM(CASE WHEN cohorts.subscription_end > DATE_ADD(cohorts.week_start, INTERVAL 5 WEEK) OR cohorts.subscription_end IS NULL THEN 1 ELSE 0 END) AS week_5,
SUM(CASE WHEN cohorts.subscription_end > DATE_ADD(cohorts.week_start, INTERVAL 6 WEEK) OR cohorts.subscription_end IS NULL THEN 1 ELSE 0 END) AS week_6
FROM cohorts AS cohorts
GROUP BY 1
ORDER BY 1;


# Preparing full datatable with additional weekstart column for visualisation in Google Sheets.
# category and country columns are kept in there to also investigate differences in the analysis. 

SELECT *,
DATE_SUB(subscription_start, INTERVAL EXTRACT(DAYOFWEEK FROM subscription_start) - 1 DAY) AS week_start
FROM `turing_data_analytics.subscriptions`
ORDER BY week_start;
