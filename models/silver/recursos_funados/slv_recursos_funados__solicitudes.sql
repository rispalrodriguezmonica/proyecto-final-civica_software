{{
    config(
        materialized='incremental',
        unique_key='solicitud_id',
        incremental_strategy='merge',
        on_schema_change='fail'
    )
}}

-- =============================================================================
-- slv_recursos_funados__solicitudes
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Grano: una fila = una solicitud de días libres única (sin reenvíos).
--
-- Incremental (merge por solicitud_id):
--   - Primera ejecución o --full-refresh: procesa todas las solicitudes.
--   - Siguientes: solo las cargadas en Bronze después de la última procesada
--     (cargado_en > máximo de esta tabla).
--   - Límite conocido: la deduplicación (paso 7) solo compara las filas del
--     lote nuevo entre sí; un reenvío que llegue en un lote posterior al
--     original no se detectaría sin --full-refresh.
--
-- Limpiezas (en este orden):
--   1. empleado_id: se quita el prefijo 'E' (E1234 -> 1234).
--   2. Huérfanas: se excluyen las solicitudes de empleados que no existen.
--   3. Fechas: el formato depende de la sede del empleado (macro
--      fecha_segun_sede). Con guiones = ISO; sedes de EE. UU. y Canadá =
--      mm/dd/aaaa; el resto = dd/mm/aaaa.
--   4. Si la fecha de fin es anterior a la de inicio, vienen cambiadas: se
--      intercambian.
--   5. estado y tipo_ausencia: variantes -> valores normalizados.
--   6. dias_laborables: se extrae el número ('3 días' -> 3). Los vacíos se
--      recalculan en Gold al explotar cada solicitud en días.
--   7. Duplicados: la misma solicitud enviada dos veces (mismo empleado,
--      inicio, fin y tipo). Se queda la primera por creada_en. Se deduplica
--      DESPUÉS de limpiar, para que las variantes no oculten duplicados.
-- =============================================================================

with solicitudes as (
    select * from {{ ref('stg_recursos_funados__solicitudes') }}
    {% if is_incremental() %}
    where cargado_en > (select max(cargado_en) from {{ this }})
    {% endif %}
),

empleados as (
    select empleado_id, sede_id from {{ ref('slv_recursos_funados__empleados') }}
),

sedes as (
    select sede_id, pais_iso from {{ ref('slv_recursos_funados__sedes') }}
),

-- Pasos 1 y 2: id limpio y país de la sede. El inner join excluye las huérfanas.
con_pais as (
    select
          so.*
        , try_to_number(ltrim(so.empleado_id, 'E'))     as empleado_id_limpio
        , se.pais_iso
    from solicitudes so
    inner join empleados e
        on try_to_number(ltrim(so.empleado_id, 'E')) = e.empleado_id
    inner join sedes se
        on e.sede_id = se.sede_id
),

-- Pasos 3, 5 y 6: interpretar fechas y normalizar textos
limpias as (
    select
          solicitud_id
        , empleado_id_limpio                            as empleado_id

        , case
              when lower(trim(tipo_ausencia)) in ('vac', 'vacaciones', 'vacation')          then 'VAC'
              when lower(trim(tipo_ausencia)) in ('ap', 'asuntos propios', 'personal day')  then 'AP'
              when lower(trim(tipo_ausencia)) in ('enf', 'enfermedad', 'sick leave')        then 'ENF'
          end                                           as tipo_ausencia_codigo

        , creada_en

        , {{ fecha_segun_sede('fecha_inicio', 'pais_iso') }}  as fecha_inicio_leida
        , {{ fecha_segun_sede('fecha_fin', 'pais_iso') }}     as fecha_fin_leida

        , try_to_number(regexp_substr(dias_laborables, '[0-9]+'))
                                                        as dias_laborables

        , case
              when lower(trim(estado)) like 'aprob%'
                or lower(trim(estado)) = 'approved'     then 'APROBADA'
              when lower(trim(estado)) like 'rechaz%'
                or lower(trim(estado)) = 'rejected'     then 'RECHAZADA'
              when lower(trim(estado)) like 'cancel%'   then 'CANCELADA'
              when lower(trim(estado)) like 'pend%'     then 'PENDIENTE'
          end                                           as estado

        , motivo
        , aprobador_id
        , cargado_en
    from con_pais
),

-- Paso 4: si vienen cambiadas, la menor es el inicio y la mayor el fin
ordenadas as (
    select
          *
        , least(fecha_inicio_leida, fecha_fin_leida)    as fecha_inicio
        , greatest(fecha_inicio_leida, fecha_fin_leida) as fecha_fin
    from limpias
)

-- Paso 7: deduplicar, quedándose con la primera enviada
select
      solicitud_id
    , empleado_id
    , tipo_ausencia_codigo
    , creada_en
    , fecha_inicio
    , fecha_fin
    , dias_laborables
    , estado
    , motivo
    , aprobador_id
    , cargado_en
from ordenadas
qualify row_number() over (
    partition by empleado_id, fecha_inicio, fecha_fin, tipo_ausencia_codigo
    order by creada_en, solicitud_id
) = 1