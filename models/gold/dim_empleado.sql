-- =============================================================================
-- dim_empleado
-- =============================================================================
-- Capa Gold: dimensión de empleados, desnormalizada para Power BI.
-- Grano: una fila = un empleado, con su situación ACTUAL (sede y
-- departamento de hoy; sin historial).
-- Junta: empleados + sedes + países (seed) + departamentos + generaciones
-- (seed).
-- No incluye nombre ni email: no hacen falta para el análisis y son datos
-- personales.
-- Valores por defecto:
--   - Sin departamento asignado -> 'Sin departamento'.
--   - Sin fecha de nacimiento válida (o fuera de los rangos) -> 'Desconocida'.
-- =============================================================================

with empleados as (
    select * from {{ ref('slv_recursos_funados__empleados') }}
),

sedes as (
    select * from {{ ref('slv_recursos_funados__sedes') }}
),

paises as (
    select pais_iso, nombre, continente from {{ ref('paises') }}
),

departamentos as (
    select * from {{ ref('slv_recursos_funados__departamentos') }}
),

generaciones as (
    select * from {{ ref('generaciones') }}
)

select
      e.empleado_id
    , e.sexo
    , e.fecha_nacimiento
    , coalesce(g.nombre, 'Desconocida')         as generacion
    , e.sede_id
    , s.nombre                                  as sede
    , s.ciudad
    , s.pais_iso
    , p.nombre                                  as pais
    , p.continente
    , e.departamento_id
    , coalesce(d.nombre, 'Sin departamento')    as departamento
    , e.puesto
    , e.modalidad
    , e.jornada
    , e.fecha_alta
    , e.fecha_baja
    , e.fecha_baja is null                      as esta_activo
from empleados e
left join sedes s
    on e.sede_id = s.sede_id
left join paises p
    on s.pais_iso = p.pais_iso
left join departamentos d
    on e.departamento_id = d.departamento_id
left join generaciones g
    on year(e.fecha_nacimiento) between g.anio_desde and g.anio_hasta