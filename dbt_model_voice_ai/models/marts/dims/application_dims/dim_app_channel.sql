{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_app_channel table from the application staging model
-- this represents the submission channel for the application (e.g., web, mobile)

WITH src_app_channel AS (
    SELECT  channel AS app_channel
    FROM {{ ref('stg_applications') }}
    WHERE channel IS NOT NULL
),
distinct_app_channel AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['app_channel']) }} AS app_channel_id,
        app_channel
    FROM src_app_channel
)

SELECT
    app_channel_id,
    app_channel,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_app_channel