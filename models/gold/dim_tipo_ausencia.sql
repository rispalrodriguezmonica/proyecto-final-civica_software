-- =============================================================================
-- dim_tipo_ausencia
-- =============================================================================
-- Capa Gold: dimensión de tipos de ausencia.
-- Grano: una fila = un tipo de ausencia (VAC, AP, ENF).
-- es_discrecional: el empleado elige cuándo cogerlo (VAC y AP). Son los
-- únicos que cuentan para el índice: una baja por enfermedad no se elige
-- para coincidir con un lanzamiento.
-- =============================================================================

select
      tipo_ausencia_codigo
    , nombre
    , requiere_aprobacion
    , retribuida
    , es_discrecional
from {{ ref('slv_recursos_funados__tipos_ausencia') }}