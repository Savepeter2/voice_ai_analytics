{{
    config(
        materialized='table'
    )
}}

-- This refers to the dim_session_transfer_reason table from the voice sessions staging model

WITH src_session_transfer_reason AS (

    SELECT  transfer_reason AS session_transfer_reason
    FROM {{ ref('stg_sessions') }}
    WHERE transfer_reason IS NOT NULL
),
distinct_session_transfer_reason AS (
    SELECT DISTINCT
        {{ dbt_utils.generate_surrogate_key(['session_transfer_reason']) }} AS session_transfer_reason_id,
        session_transfer_reason
    FROM src_session_transfer_reason
)

SELECT
    session_transfer_reason_id,
    session_transfer_reason,
    CURRENT_TIMESTAMP() AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 
FROM distinct_session_transfer_reason