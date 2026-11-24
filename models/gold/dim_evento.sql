-- =============================================================================
-- dim_evento
-- =============================================================================
-- Capa Gold: dimensión de eventos (lanzamientos de videojuegos, deportes...).
-- Grano: una fila = un evento.
-- Origen: seed eventos.
--
-- Columnas añadidas:
--   - es_global: el evento afecta a todas las sedes (sin país de ámbito).
--   - fecha_comparacion: el mismo día de la semana un año antes
--     (fecha - 364 días = 52 semanas exactas). Se compara un lunes con un
--     lunes, porque los días libres dependen mucho del día de la semana.
-- =============================================================================

with eventos as (
    select * from {{ ref('eventos') }}
)

select
      evento_id
    , nombre
    , tipo_evento
    , fecha_evento
    , pais_iso_ambito
    , pais_iso_ambito is null                       as es_global
    , dateadd('day', -364, fecha_evento)            as fecha_comparacion
from eventos