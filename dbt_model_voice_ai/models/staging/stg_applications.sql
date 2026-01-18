{{
  config(
        materialized='incremental',
        unique_key='application_id',
        on_schema_change='fail',
        incremental_strategy='merge'
    )
}}


SELECT 
    latest_app.application_id,
    latest_app.session_id,
    latest_app.user_id,
    TRIM(LOWER(latest_app.service_code)) AS service_code,
    TRIM(LOWER(latest_app.channel)) AS channel,
    TRIM(LOWER(latest_app.status)) AS status,
    latest_app.time_to_submit_sec,
    latest_app.submitted_at,
    {% if is_incremental() %}
        COALESCE(existing_app.created_datetime, CURRENT_TIMESTAMP())
    {% else %}
        CURRENT_TIMESTAMP()
    {% endif %}
    AS created_datetime,
    CURRENT_TIMESTAMP() AS updated_datetime 

FROM 
    {{ source('voice_ai_analytics_raw', 'applications') }} latest_app

{% if is_incremental() %}
    LEFT JOIN {{ this }} existing_app
    ON latest_app.application_id = existing_app.application_id
    WHERE existing_app.application_id IS NULL
{% endif %}