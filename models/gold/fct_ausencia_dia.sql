{{
    config(
        materialized='incremental',
        unique_key=['solicitud_id', 'fecha'],
        incremental_strategy='merge',
        on_schema_change='fail'
    )
}}

-- =============================================================================
-- fct_ausencia_dia
-- =============================================================================
-- Capa Gold: tabla de hechos de ausencias.
-- Grano: una fila = un día laborable de una solicitud (solicitud_id + fecha).
--
-- Incremental (merge por solicitud_id + fecha):
--   - Solo procesa las solicitudes cargadas en Bronze después de la última
--     procesada (cargado_en > máximo de esta tabla). Sigue la misma cadena
--     que slv_recursos_funados__solicitudes.
--   - Límite conocido: si una solicitud ya procesada cambia de fechas, sus
--     días antiguos no se borran sin --full-refresh.
--
-- Pasos:
--   1. Explotar cada solicitud en días (del inicio al fin), sin fines de semana.
--   2. Quitar los festivos del país de la sede del empleado.
--   3. Recalcular los días laborables de cada solicitud contando sus filas.
--   4. cuenta_para_indice: tipo discrecional (VAC, AP), de 1 a 5 días
--      laborables y APROBADA o PENDIENTE.
-- =============================================================================

with solicitudes as (
    select * from {{ ref('slv_recursos_funados__solicitudes') }}
    {% if is_incremental() %}
    where cargado_en > (select max(cargado_en) from {{ this }})
    {% endif %}
),

empleados as (
    select empleado_id, pais_iso from {{ ref('dim_empleado') }}
),

tipos as (
    select tipo_ausencia_codigo, es_discrecional from {{ ref('dim_tipo_ausencia') }}
),

laborables_calendario as (
    select fecha from {{ ref('dim_fecha') }}
    where not es_fin_de_semana
),

festivos as (
    select pais_iso, fecha from {{ ref('slv_recursos_funados__festivos') }}
),

-- una fila por cada dia entre inicio y fin (ya sin fines de semana)
explotadas as (
    select
          s.solicitud_id
        , c.fecha
        , s.empleado_id
        , e.pais_iso
        , s.tipo_ausencia_codigo
        , s.estado
        , s.cargado_en
    from solicitudes s
    inner join empleados e
        on s.empleado_id = e.empleado_id
    inner join laborables_calendario c
        on c.fecha between s.fecha_inicio and s.fecha_fin
),

-- quitar los festivos del pais del empleado
sin_festivos as (
    select ex.*
    from explotadas ex
    left join festivos f
        on  ex.pais_iso = f.pais_iso
        and ex.fecha    = f.fecha
    where f.fecha is null
),

-- dias laborables de cada solicitud
con_dias as (
    select
          sf.*
        , count(*) over (partition by sf.solicitud_id)  as dias_solicitud
        , coalesce(t.es_discrecional, false)            as es_discrecional
    from sin_festivos sf
    left join tipos t
        on sf.tipo_ausencia_codigo = t.tipo_ausencia_codigo
)

-- dias que cuentan para el índice
select
      solicitud_id
    , fecha
    , empleado_id
    , pais_iso
    , tipo_ausencia_codigo
    , estado
    , dias_solicitud
    , (
          es_discrecional
          and dias_solicitud between 1 and 5
          and estado in ('APROBADA', 'PENDIENTE')
      )                                                 as cuenta_para_indice
    , cargado_en
from con_dias