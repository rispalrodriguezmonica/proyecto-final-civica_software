-- =============================================================================
-- Perfilado · relationships · Huérfanos
-- =============================================================================
-- Pregunta: ¿cada clave que apunta a otra tabla encuentra a su "padre"?
-- Técnica: left join con la tabla padre y contar las filas sin padre.
-- En Silver se garantizará con el test relationships.
-- =============================================================================

with empleados as (
    select * from {{ ref('stg_recursos_funados__empleados') }}
),
movimientos as (
    select * from {{ ref('stg_recursos_funados__movimientos') }}
),
solicitudes as (
    select * from {{ ref('stg_recursos_funados__solicitudes') }}
),
paises as (
    select * from {{ ref('paises') }}
)

-- Empleados: el jefe existe
select 'empleados.manager_id -> empleados' as comprobacion,
       count_if(e.manager_id is not null and m.empleado_id is null) as huerfanos
from empleados e
left join empleados m on e.manager_id = m.empleado_id

-- Empleados: el seed de países traduce todos los países que llegan
union all
select 'empleados.pais -> seed paises',
       count_if(p.pais_origen is null)
from empleados e
left join paises p on e.pais = p.pais_origen

-- Movimientos: el empleado existe
union all
select 'movimientos.empleado_id -> empleados',
       count_if(e.empleado_id is null)
from movimientos mv
left join empleados e on mv.empleado_id = e.empleado_id

-- Solicitudes: el empleado existe (el id es texto; algunos llevan prefijo 'E')
union all
select 'solicitudes.empleado_id -> empleados (tal cual llega)',
       count_if(e.empleado_id is null)
from solicitudes so
left join empleados e on try_to_number(so.empleado_id) = e.empleado_id

union all
select 'solicitudes.empleado_id -> empleados (sin la E)',
       count_if(e.empleado_id is null)
from solicitudes so
left join empleados e on try_to_number(ltrim(so.empleado_id, 'E')) = e.empleado_id

-- Solicitudes: el aprobador existe
union all
select 'solicitudes.aprobador_id -> empleados',
       count_if(so.aprobador_id is not null and e.empleado_id is null)
from solicitudes so
left join empleados e on so.aprobador_id = e.empleado_id