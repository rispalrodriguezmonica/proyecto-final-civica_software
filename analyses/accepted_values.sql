-- =============================================================================
-- Perfilado · accepted_values · Valores distintos
-- =============================================================================
-- Pregunta: ¿qué valores aparecen realmente y cuántas filas tiene cada uno?
-- Destapa variantes de escritura (mayúsculas, idiomas, abreviaturas) y
-- sinónimos (dos valores que significan lo mismo).
-- =============================================================================

with empleados as (
    select * from {{ ref('stg_recursos_funados__empleados') }}
),

solicitudes as (
    select * from {{ ref('stg_recursos_funados__solicitudes') }}
)

select 'empleados.pais' as columna, pais as valor, count(*) as filas
from empleados
group by all

union all
select 'empleados.nombre_departamento', nombre_departamento, count(*)
from empleados
group by all

union all
select 'empleados.sexo', sexo, count(*)
from empleados
group by all

union all
select 'empleados.modalidad', modalidad, count(*)
from empleados
group by all

union all
select 'empleados.jornada', jornada, count(*)
from empleados
group by all

union all
select 'solicitudes.tipo_ausencia', tipo_ausencia, count(*)
from solicitudes
group by all

union all
select 'solicitudes.estado', estado, count(*)
from solicitudes
group by all

order by columna, filas desc