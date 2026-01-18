{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_session_final_outcome table from the voice sessions staging model

WITH src_session_final_outcome AS (

    SELECT  final_outcome AS session_final_outcome
    FROM {{ ref('stg_sessions') }}
    WHERE final_outcome IS NOT NULL
),
distinct_session_final_outcome AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['session_final_outcome']) }} AS session_final_outcome_id,
        session_final_outcome
    FROM src_session_final_outcome
)

SELECT
    session_final_outcome_id,
    session_final_outcome,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_session_final_outcome