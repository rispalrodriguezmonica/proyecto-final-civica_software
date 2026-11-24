{#
    fecha_segun_sede
    ----------------
    Convierte una fecha en texto a DATE según el formato de la sede del
    empleado. RecursosFunados guarda la fecha en el formato del país:
      - con guiones (Países Bajos)          -> aaaa-mm-dd
      - sedes de EE. UU. y Canadá           -> mm/dd/aaaa
      - el resto                            -> dd/mm/aaaa
    Se usa para fecha_inicio y fecha_fin: la regla se escribe una sola vez.
#}

{% macro fecha_segun_sede(columna, pais_iso) %}
    case
        when {{ columna }} like '%-%'       then to_date({{ columna }}, 'YYYY-MM-DD')
        when {{ pais_iso }} in ('US', 'CA') then to_date({{ columna }}, 'MM/DD/YYYY')
        else                                     to_date({{ columna }}, 'DD/MM/YYYY')
    end
{% endmacro %}