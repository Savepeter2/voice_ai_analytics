{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_language table from the voice sessions staging model

WITH src_language AS (

    SELECT  language
    FROM {{ ref('stg_sessions') }}
    WHERE language IS NOT NULL
),
distinct_language AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['language']) }} AS language_id,
        language
    FROM src_language
)

SELECT
    language_id,
    language,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_language