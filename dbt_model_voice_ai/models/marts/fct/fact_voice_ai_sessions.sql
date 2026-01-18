{{ 
    config(
        materialized='incremental',
        unique_key='session_id',
        on_schema_change='fail',
        incremental_strategy='merge'
    )
}}
-- This cte computes session-level application aggregation since one session can have multiple applications
with applications_session_level AS (
    SELECT
        session_id,
        COUNT(application_id) AS application_count,
        MAX(
            CASE
                WHEN status = 'completed' THEN 1
                ELSE 0
            END
        ) AS any_completed_application
    FROM stg_applications
    GROUP BY session_id
) ,
fct_session as (

SELECT 
    ss.session_id,
    su.user_id,
    dc.channel_id,
    dl.language_id,
    dfo.session_final_outcome_id,
    dtr.session_transfer_reason_id,
    sl.application_count,
    svm.recovery_success,
    svm.escalation_flag,
    ss.total_duration_sec,
    ss.total_turns,
    ss.session_created_at,
    svm.avg_asr_confidence,
    svm.avg_intent_confidence,
    svm.misunderstanding_rate,
    svm.silence_rate

FROM 
    {{ ref('stg_sessions') }} ss 

LEFT JOIN 
      {{ ref('stg_users') }} su
ON 
    su.user_id = ss.user_id
LEFT JOIN 
    {{ ref('dim_channel') }} dc
ON 
    ss.channel = dc.channel
LEFT JOIN 
    {{ ref('dim_language') }} dl
ON 
    ss.language = dl.language
LEFT JOIN 
    {{ ref('dim_sess_final_outcome') }} dfo
ON 
    ss.final_outcome = dfo.session_final_outcome
LEFT JOIN 
    {{ ref('dim_sess_transfer_reason') }} dtr
ON
    ss.transfer_reason = dtr.session_transfer_reason
LEFT JOIN 
    applications_session_level sl
ON 
    ss.session_id = sl.session_id
LEFT JOIN 
    {{ ref('stg_voice_ai_metrics') }} svm
ON
    ss.session_id = svm.session_id
),

fact_voice_ai_sessions as (
    select 
    fs.*,

    {% if is_incremental() %}
        COALESCE(existing_fct.created_datetime, CURRENT_TIMESTAMP())
    {% else %}
        CURRENT_TIMESTAMP()
    {% endif %}
    AS created_datetime,

    CURRENT_TIMESTAMP() AS updated_datetime 
    
    from 
        fct_session fs

    {% if is_incremental() %}
    left join {{ this }} existing_fct
    on fs.session_id = existing_fct.session_id
    where existing_fct.session_id is null
    {% endif %}
)
select 
    *
from
    fact_voice_ai_sessions





