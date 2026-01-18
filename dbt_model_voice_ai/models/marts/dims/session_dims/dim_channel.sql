{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_channel table from the voice sessions staging model

WITH src_channel AS (

    SELECT  channel
    FROM {{ ref('stg_sessions') }}
    WHERE channel IS NOT NULL
),
distinct_channel AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['channel']) }} AS channel_id,
        channel
    FROM src_channel
)

SELECT
    channel_id,
    channel,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_channel