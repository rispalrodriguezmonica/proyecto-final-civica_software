-- =============================================================================
-- agg_indice_evento
-- =============================================================================
-- Capa Gold: índices de ausencia de cada evento. Responde a la pregunta del
-- proyecto: ¿los lanzamientos aumentan los días libres? ¿En quién?
-- Grano: una fila = un evento x un corte (Total, País, Generación,
-- Departamento) x un valor de ese corte (p. ej. País = España).
--
-- Definiciones (únicas; Power BI solo las lee):
--   índice = ausentes el día del evento / ausentes el día de comparación
--            (mismo día de la semana un año antes, de dim_evento)
--   - indice_dias_pedidos: ausentes por VAC o AP (métrica de Remote).
--   - indice_ausencia_real: ausentes por VAC, AP o ENF.
--   Los dos solo cuentan ausencias cortas (1 a 5 días), aprobadas o pendientes.
--   Eventos locales (pais_iso_ambito): solo cuentan empleados de ese país.
--   La plantilla de cada día se guarda como contexto.
--
-- Tabla (no incremental): es pequeña y cada evento compara con un año antes,
-- así que se recalcula entera en segundos. Lo caro (Silver y el fct) sí es
-- incremental.
-- =============================================================================

{% set cortes = {
    'Total':        "'Total'",
    'País':         'pais',
    'Generación':   'generacion',
    'Departamento': 'departamento'
} %}

with eventos as (
    select * from {{ ref('dim_evento') }}
),

empleados as (
    select * from {{ ref('dim_empleado') }}
),

-- Una fila por empleado y día, con los dos indicadores
ausencias as (
    select
          empleado_id
        , fecha
        , boolor_agg(cuenta_dias_pedidos)               as pedido
        , boolor_agg(cuenta_ausencia_real)              as real
    from {{ ref('fct_ausencia_dia') }}
    group by empleado_id, fecha
),

-- Las dos fechas de cada evento: la del evento y la de comparación
fechas as (
    select evento_id, 'evento' as momento, fecha_evento as fecha, pais_iso_ambito
    from eventos
    union all
    select evento_id, 'comparacion' as momento, fecha_comparacion as fecha, pais_iso_ambito
    from eventos
),

-- Plantilla de cada fecha: dado de alta ese día y, si el evento es local,
-- de ese país. Se marca si estuvo ausente (de cada tipo).
plantilla as (
    select
          f.evento_id
        , f.momento
        , e.empleado_id
        , e.pais
        , e.generacion
        , e.departamento
        , coalesce(a.pedido, false)                     as ausente_pedido
        , coalesce(a.real, false)                       as ausente_real
    from fechas f
    inner join empleados e
        on  e.fecha_alta <= f.fecha
        and (e.fecha_baja is null or e.fecha_baja > f.fecha)
        and (f.pais_iso_ambito is null or e.pais_iso = f.pais_iso_ambito)
    left join ausencias a
        on  a.empleado_id = e.empleado_id
        and a.fecha       = f.fecha
),

-- Un bloque por corte, generado con Jinja (la misma consulta, sin repetirla)
por_corte as (
    {% for nombre_corte, columna in cortes.items() %}
    select
          evento_id
        , '{{ nombre_corte }}'                                      as corte
        , {{ columna }}                                             as valor
        , count_if(momento = 'evento')                              as plantilla_evento
        , count_if(momento = 'comparacion')                         as plantilla_comparacion
        , count_if(momento = 'evento' and ausente_pedido)           as pedidos_evento
        , count_if(momento = 'comparacion' and ausente_pedido)      as pedidos_comparacion
        , count_if(momento = 'evento' and ausente_real)             as reales_evento
        , count_if(momento = 'comparacion' and ausente_real)        as reales_comparacion
    from plantilla
    group by 1, 2, 3
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
)

select
      p.evento_id
    , ev.nombre                                                     as evento
    , ev.tipo_evento
    , ev.fecha_evento
    , p.corte
    , p.valor
    , p.plantilla_evento
    , p.plantilla_comparacion
    , p.pedidos_evento
    , p.pedidos_comparacion
    , p.reales_evento
    , p.reales_comparacion
    , round(p.pedidos_evento / nullif(p.pedidos_comparacion, 0), 2)     as indice_dias_pedidos
    , round(p.reales_evento  / nullif(p.reales_comparacion, 0), 2)      as indice_ausencia_real
from por_corte p
inner join eventos ev
    on p.evento_id = ev.evento_id