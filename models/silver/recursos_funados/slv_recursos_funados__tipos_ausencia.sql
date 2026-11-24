-- =============================================================================
-- slv_recursos_funados__tipos_ausencia
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Sin suciedad. Se añade es_discrecional: días libres por decisión propia
-- (vacaciones, asuntos propios) frente a bajas por enfermedad. El índice de
-- días libres (criterio de Remote) solo cuenta los discrecionales.
-- =============================================================================

with tipos_ausencia as (
    select * from {{ ref('stg_recursos_funados__tipos_ausencia') }}
)

select
      tipo_ausencia_codigo
    , nombre
    , requiere_aprobacion
    , retribuida
    , tipo_ausencia_codigo in ('VAC', 'AP')     as es_discrecional
from tipos_ausencia