-- =============================================================================
-- Test singular: ninguna solicitud termina antes de empezar
-- =============================================================================
-- 220 solicitudes llegaban con inicio y fin cambiados de sitio, y Silver las
-- ordena. Un test singular devuelve las filas que incumplen la regla:
-- ninguna fila = PASS.
-- =============================================================================

select *
from {{ ref('slv_recursos_funados__solicitudes') }}
where fecha_fin < fecha_inicio