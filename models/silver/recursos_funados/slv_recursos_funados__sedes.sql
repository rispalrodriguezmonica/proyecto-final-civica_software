-- =============================================================================
-- slv_recursos_funados__sedes
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Limpieza: el país llega con criterios mezclados (España, Italy, IE, USA...).
-- Se traduce a código ISO con el seed paises, el mismo formato que usan los
-- festivos, para que sedes y festivos se puedan cruzar.
-- =============================================================================

with sedes as (
    select * from {{ ref('stg_recursos_funados__sedes') }}
),

paises as (
    select * from {{ ref('paises') }}
)

select
      s.sede_id
    , s.nombre
    , s.ciudad
    , p.pais_iso
    , s.zona_horaria
    , s.fecha_apertura
from sedes s
left join paises p
    on s.pais = p.pais_origen