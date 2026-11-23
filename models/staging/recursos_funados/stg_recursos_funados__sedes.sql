-- =============================================================================
-- stg_recursos_funados__sedes
-- =============================================================================
-- Capa Staging: relación 1:1 con Bronze. Solo renombrado y casteado.
-- pais llega con criterios mezclados (nombre, código, idioma): se deja como
-- texto y se normaliza en Silver.
-- =============================================================================

with source as (
    select * from {{ source('recursos_funados', 'sedes') }}
),

renamed as (
    select
          sede_id::number               as sede_id
        , nombre_sede                   as nombre
        , ciudad
        , pais
        , zona_horaria
        , fecha_apertura::date          as fecha_apertura
        , _fichero_origen               as fichero_origen
        , _cargado_en                   as cargado_en
    from source
)

select * from renamed