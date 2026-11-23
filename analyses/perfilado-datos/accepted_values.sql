-- =============================================================================
-- Perfilado 1 · Valores distintos de las columnas de categoría
-- =============================================================================
-- Pregunta: ¿qué valores aparecen realmente y cuántas filas tiene cada uno?
-- Destapa variantes de escritura (mayúsculas, idiomas, abreviaturas) y
-- sinónimos (dos valores que significan lo mismo).
-- =============================================================================

select 'sedes.pais' as columna, pais as valor, count(*) as filas
from {{ ref('stg_recursos_funados__sedes') }}
group by all

union all
select 'departamentos.nombre', nombre, count(*)
from {{ ref('stg_recursos_funados__departamentos') }}
group by all

union all
select 'empleados.sexo', sexo, count(*)
from {{ ref('stg_recursos_funados__empleados') }}
group by all

union all
select 'empleados.modalidad', modalidad, count(*)
from {{ ref('stg_recursos_funados__empleados') }}
group by all

union all
select 'empleados.jornada', jornada, count(*)
from {{ ref('stg_recursos_funados__empleados') }}
group by all

union all
select 'solicitudes.tipo_ausencia', tipo_ausencia, count(*)
from {{ ref('stg_recursos_funados__solicitudes') }}
group by all

union all
select 'solicitudes.estado', estado, count(*)
from {{ ref('stg_recursos_funados__solicitudes') }}
group by all

order by columna, filas desc