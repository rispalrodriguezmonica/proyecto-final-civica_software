-- =============================================================================
-- stg_recursos_funados__departamentos
-- =============================================================================
-- Capa Staging: relación 1:1 con Bronze. Solo renombrado y casteado.
-- =============================================================================

with source as (
    select * from {{ source('recursos_funados', 'departamentos') }}
),

renamed as (
    select
          departamento_id::number       as departamento_id
        , nombre
        , _fichero_origen               as fichero_origen
        , _cargado_en                   as cargado_en
    from source
)

select * from renamed