{# =============================================================================
   generate_schema_name (override de Cívica, día 6)
   =============================================================================
   Decide en qué schema escribe cada modelo:
     - Jobs de los entornos dev y pro  -> el schema tal cual (+schema).
                                          Ej: core
     - Jobs de CI                      -> prefijo + schema, para no pisar PRO.
                                          Ej: dbt_ci_core
     - IDE (desarrollo personal)       -> prefijo personal + schema.
                                          Ej: dbt_monica_core
   Sin este override, dbt SIEMPRE concatena target.schema + "_" + +schema.
   ============================================================================= #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- set invocation_context = env_var('DBT_CLOUD_INVOCATION_CONTEXT', '') -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- elif invocation_context != 'ci' and target.name in ['dev', 'pro'] -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}