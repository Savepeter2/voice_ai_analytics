{{
  config(
        materialized='incremental',
        unique_key='session_id',
        on_schema_change='fail',
        incremental_strategy='merge'
    )
}}


SELECT 
    latest_se.session_id,
    latest_se.user_id,
    TRIM(LOWER(latest_se.channel)) AS channel,
    TRIM(LOWER(latest_se.language)) AS language,
    latest_se.total_duration_sec,
    latest_se.total_turns,
    TRIM(LOWER(latest_se.final_outcome)) AS final_outcome,
    TRIM(LOWER(latest_se.transfer_reason)) AS transfer_reason,
    latest_se.created_at AS session_created_at,

    {% if is_incremental() %}
        COALESCE(existing_sess.created_datetime, CURRENT_TIMESTAMP())
    {% else %}
        CURRENT_TIMESTAMP()
    {% endif %}
    AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 

FROM 
    {{ source('voice_ai_analytics_raw', 'voice_sessions') }} latest_se

{% if is_incremental() %}
    LEFT JOIN {{ this }} existing_sess
    ON latest_se.session_id = existing_sess.session_id
    WHERE existing_sess.session_id IS NULL
{% endif %}