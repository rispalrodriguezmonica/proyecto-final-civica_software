-- =============================================================================
-- dim_fecha
-- =============================================================================
-- Capa Gold: dimensión calendario.
-- Grano: una fila = un día.
-- Rango: 2024-01-01 a 2026-12-31 (cubre las ausencias, las fechas de
-- comparación de un año antes y los datos de diciembre).
-- Los festivos NO van aquí porque dependen del país de cada sede; se cruzan
-- en fct_ausencia_dia.
-- =============================================================================

with dias as (
    -- generator crea N filas vacías; seq4() las numera 0, 1, 2...
    select dateadd('day', seq4(), '2024-01-01'::date) as fecha
    from table(generator(rowcount => 1096))
)

select
      fecha
    , year(fecha)                               as anio
    , month(fecha)                              as mes
    , monthname(fecha)                          as nombre_mes
    , day(fecha)                                as dia
    , dayofweekiso(fecha)                       as dia_semana      -- 1 = lunes ... 7 = domingo
    , dayname(fecha)                            as nombre_dia
    , dayofweekiso(fecha) in (6, 7)             as es_fin_de_semana
    , weekiso(fecha)                            as semana_iso
from dias