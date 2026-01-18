{{
  config(
        materialized='incremental',
        unique_key='session_id',
        on_schema_change='fail',
        incremental_strategy='merge'
    )
}}


SELECT 
    latest_sm.session_id,
    latest_sm.avg_asr_confidence,
    latest_sm.avg_intent_confidence,
    latest_sm.misunderstanding_rate,
    latest_sm.silence_rate,
    TRIM(LOWER(latest_sm.recovery_success)) AS recovery_success,
    TRIM(LOWER(latest_sm.escalation_flag)) AS escalation_flag,

    {% if is_incremental() %}
        COALESCE(existing_sm.created_datetime, CURRENT_TIMESTAMP())
    {% else %}
        CURRENT_TIMESTAMP()
    {% endif %}
    AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 

FROM 
    {{ source('voice_ai_analytics_raw', 'voice_ai_metrics') }} latest_sm

{% if is_incremental() %}
    LEFT JOIN {{ this }} existing_sm
    ON latest_sm.session_id = existing_sm.session_id
    WHERE existing_sm.session_id IS NULL
{% endif %}