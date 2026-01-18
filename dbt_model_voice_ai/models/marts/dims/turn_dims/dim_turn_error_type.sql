{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_turn_error_type table from the voice turns staging model
-- this represents the error type detected during the turn (e.g. misunderstanding, silence)

WITH src_turn_error_type AS (
    SELECT  error_type AS turn_error_type
    FROM {{ ref('stg_turns') }}
    WHERE error_type IS NOT NULL
),
distinct_turn_error_type AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['turn_error_type']) }} AS turn_error_type_id,
        turn_error_type
    FROM src_turn_error_type
)

SELECT
    turn_error_type_id,
    turn_error_type,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_turn_error_type