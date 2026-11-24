-- =============================================================================
-- Perfilado 3 · Vacíos
-- =============================================================================
-- Pregunta: ¿cuántos NULL hay en cada columna?
-- Un vacío no siempre es un error: hay que decidir si es normal (fecha_baja de
-- alguien en activo) o un dato que falta y debería estar.
-- =============================================================================

with empleados as (
    select * from {{ ref('stg_recursos_funados__empleados') }}
),

solicitudes as (
    select * from {{ ref('stg_recursos_funados__solicitudes') }}
)

select 'empleados' as tabla, 'nombre' as columna, count_if(nombre is null) as vacios, count(*) as filas from empleados
union all select 'empleados', 'email',            count_if(email is null),            count(*) from empleados
union all select 'empleados', 'sexo',             count_if(sexo is null),             count(*) from empleados
union all select 'empleados', 'fecha_nacimiento', count_if(fecha_nacimiento is null), count(*) from empleados
union all select 'empleados', 'sede_id',          count_if(sede_id is null),          count(*) from empleados
union all select 'empleados', 'departamento_id',  count_if(departamento_id is null),  count(*) from empleados
union all select 'empleados', 'manager_id',       count_if(manager_id is null),       count(*) from empleados
union all select 'empleados', 'fecha_alta',       count_if(fecha_alta is null),       count(*) from empleados
union all select 'empleados', 'fecha_baja',       count_if(fecha_baja is null),       count(*) from empleados

union all select 'solicitudes', 'empleado_id',     count_if(empleado_id is null),     count(*) from solicitudes
union all select 'solicitudes', 'tipo_ausencia',   count_if(tipo_ausencia is null),   count(*) from solicitudes
union all select 'solicitudes', 'fecha_inicio',    count_if(fecha_inicio is null),    count(*) from solicitudes
union all select 'solicitudes', 'fecha_fin',       count_if(fecha_fin is null),       count(*) from solicitudes
union all select 'solicitudes', 'dias_laborables', count_if(dias_laborables is null), count(*) from solicitudes
union all select 'solicitudes', 'estado',          count_if(estado is null),          count(*) from solicitudes
union all select 'solicitudes', 'motivo',          count_if(motivo is null),          count(*) from solicitudes
union all select 'solicitudes', 'aprobador_id',    count_if(aprobador_id is null),    count(*) from solicitudes