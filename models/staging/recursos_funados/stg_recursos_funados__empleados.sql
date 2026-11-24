-- =============================================================================
-- stg_recursos_funados__empleados
-- =============================================================================
-- Capa Staging: relación 1:1 con Bronze. Solo renombrado y casteado.
-- Guarda el estado ACTUAL de cada empleado (el historial está en movimientos).
-- nombre, apellido, email y sexo llegan sucios (espacios, mayúsculas,
-- variantes): se dejan como texto y se limpian en Silver.
-- =============================================================================

with source as (
    select * from {{ source('recursos_funados', 'empleados') }}
),

renamed as (
    select
          empleado_id::number           as empleado_id
        , nombre
        , apellido
        , email
        , sexo
        , fecha_nacimiento::date        as fecha_nacimiento
        , sede_id::number               as sede_id
        , nombre_sede
        , ciudad
        , pais
        , zona_horaria
        , departamento_id::number       as departamento_id
        , departamento                  as nombre_departamento
        , puesto
        , manager_id::number            as manager_id
        , fecha_alta::date              as fecha_alta
        , fecha_baja::date              as fecha_baja
        , modalidad
        , jornada
        , _fichero_origen               as fichero_origen
        , _cargado_en                   as cargado_en
    from source
)

select * from renamed