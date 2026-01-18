{{
  config(
        materialized='view',
    )
}}

SELECT 
user_id, 
TRIM(LOWER(region)) AS region,
TRIM(LOWER(disability_flag)) AS disability_flag,
TRIM(LOWER(first_time_digital_user)) AS first_time_digital_user
FROM 
{{ source('voice_ai_analytics_raw', 'users') }}