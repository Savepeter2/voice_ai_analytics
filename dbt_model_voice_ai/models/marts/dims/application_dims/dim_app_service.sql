{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_app_service table from the application staging model
-- this represents the government service the user is applying for (e.g. BIRTH_CERT, LAND)

WITH src_app_service AS (
    SELECT  service_code AS app_service_code
    FROM {{ ref('stg_applications') }}
    WHERE service_code IS NOT NULL
),
distinct_app_service AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['app_service_code']) }} AS app_service_id,
        app_service_code
    FROM src_app_service
)

SELECT
    app_service_id,
    app_service_code,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_app_service
