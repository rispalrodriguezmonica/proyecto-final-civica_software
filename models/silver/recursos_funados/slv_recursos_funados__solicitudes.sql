-- =============================================================================
-- slv_recursos_funados__solicitudes
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Limpiezas (en este orden):
--   1. empleado_id: se quita el prefijo 'E' (E1234 -> 1234).
--   2. Huérfanas: se excluyen las solicitudes de empleados que no existen.
--   3. Fechas: el formato depende de la sede del empleado. Con guiones = ISO;
--      sedes de EE. UU. y Canadá = mm/dd/aaaa; el resto = dd/mm/aaaa.
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

        , case
              when fecha_inicio like '%-%'      then to_date(fecha_inicio, 'YYYY-MM-DD')
              when pais_iso in ('US', 'CA')     then to_date(fecha_inicio, 'MM/DD/YYYY')
              else                                   to_date(fecha_inicio, 'DD/MM/YYYY')
          end                                           as fecha_inicio_leida

        , case
              when fecha_fin like '%-%'         then to_date(fecha_fin, 'YYYY-MM-DD')
              when pais_iso in ('US', 'CA')     then to_date(fecha_fin, 'MM/DD/YYYY')
              else                                   to_date(fecha_fin, 'DD/MM/YYYY')
          end                                           as fecha_fin_leida

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
from ordenadas
qualify row_number() over (
    partition by empleado_id, fecha_inicio, fecha_fin, tipo_ausencia_codigo
    order by creada_en, solicitud_id
) = 1