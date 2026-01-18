{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_turn_speaker table from the voice sessions staging model
-- this reprensents the person who initiated the turn (e.g., system, user)

WITH src_turn_speaker AS (
    SELECT  speaker AS turn_speaker
    FROM {{ ref('stg_turns') }}
    WHERE speaker IS NOT NULL
),
distinct_turn_speaker AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['turn_speaker']) }} AS turn_speaker_id,
        turn_speaker
    FROM src_turn_speaker 
)

SELECT
    turn_speaker_id,
    turn_speaker,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_turn_speaker