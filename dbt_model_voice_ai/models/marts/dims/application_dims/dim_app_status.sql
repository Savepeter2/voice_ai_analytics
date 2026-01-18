{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_app_status table from the application staging model
-- this represents the status of the application (e.g. completed, failed)

WITH src_app_status AS (
    SELECT  status AS app_status
    FROM {{ ref('stg_applications') }}
    WHERE status IS NOT NULL
),
distinct_app_status AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['app_status']) }} AS app_status_id,
        app_status
    FROM src_app_status
)

SELECT
    app_status_id,
    app_status,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_app_status
