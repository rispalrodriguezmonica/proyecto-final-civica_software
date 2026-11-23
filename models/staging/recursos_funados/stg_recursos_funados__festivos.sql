-- =============================================================================
-- stg_recursos_funados__festivos
-- =============================================================================
-- Capa Staging: relación 1:1 con Bronze. Solo renombrado y casteado.
-- Aquí no se deduplica: si hay festivos repetidos, se resuelve en Silver.
-- =============================================================================

with source as (
    select * from {{ source('recursos_funados', 'festivos') }}
),

renamed as (
    select
          pais_iso
        , fecha::date                   as fecha
        , nombre                        as nombre_festivo
        , _fichero_origen               as fichero_origen
        , _cargado_en                   as cargado_en
    from source
)

select * from renamed