-- =============================================================================
-- slv_recursos_funados__sedes
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Normalización: RecursosFunados exporta la sede repetida en cada empleado
-- (6.871 filas). Aquí se extrae una fila por sede (11).
-- Limpieza: el país llega con criterios mezclados; se traduce a ISO con el
-- seed paises.
-- =============================================================================

with empleados as (
    select * from {{ ref('stg_recursos_funados__empleados') }}
),

paises as (
    select * from {{ ref('paises') }}
),

sedes as (
    select distinct
          sede_id
        , nombre_sede
        , ciudad
        , pais
        , zona_horaria
    from empleados
)

select
      s.sede_id
    , s.nombre_sede             as nombre
    , s.ciudad
    , p.pais_iso
    , s.zona_horaria
from sedes s
left join paises p
    on s.pais = p.pais_origen