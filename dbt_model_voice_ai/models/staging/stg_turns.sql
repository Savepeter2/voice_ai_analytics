{{
  config(
        materialized='incremental',
        unique_key='turn_id',
        on_schema_change='fail',
        incremental_strategy='merge'
    )
}}


SELECT 
    latest_tu.turn_id,
    latest_tu.session_id,
    latest_tu.turn_number,
    TRIM(LOWER(latest_tu.speaker)) AS speaker,
    TRIM(LOWER(latest_tu.detected_intent)) AS detected_intent,
    latest_tu.intent_confidence,
    latest_tu.asr_confidence,
    TRIM(LOWER(latest_tu.error_type)) AS error_type,
    latest_tu.turn_duration_sec,
    latest_tu.created_at AS turn_created_at,

    {% if is_incremental() %}
        COALESCE(existing_turn.created_datetime, CURRENT_TIMESTAMP())
    {% else %}
        CURRENT_TIMESTAMP()
    {% endif %}
    AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 

FROM 
    {{ source('voice_ai_analytics_raw', 'voice_turns') }} latest_tu
{% if is_incremental() %}
    LEFT JOIN {{ this }} existing_turn
    ON latest_tu.turn_id = existing_turn.turn_id
    WHERE existing_turn.turn_id IS NULL
{% endif %}