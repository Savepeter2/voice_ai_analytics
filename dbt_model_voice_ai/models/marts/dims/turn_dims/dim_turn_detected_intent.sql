{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_turn_detected_intent table from the voice turns staging model
-- this represents the intent detected during the turn (e.g., service_lookup, start_application)

WITH src_turn_detected_intent AS (
    SELECT  detected_intent AS turn_detected_intent
    FROM {{ ref('stg_turns') }}
    WHERE detected_intent IS NOT NULL
),
distinct_turn_detected_intent AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['turn_detected_intent']) }} AS turn_detected_intent_id,
        turn_detected_intent
    FROM src_turn_detected_intent
)

SELECT
    turn_detected_intent_id,
    turn_detected_intent,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_turn_detected_intent