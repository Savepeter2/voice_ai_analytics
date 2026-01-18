{{
    config(
        materialized='table'
    )
}}

-- This refers to the  dim_users table from the users staging model

SELECT
    user_id,
    region,
    disability_flag,
    first_time_digital_user,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 

FROM {{ ref('stg_users') }}
