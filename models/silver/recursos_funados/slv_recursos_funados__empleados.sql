-- =============================================================================
-- slv_recursos_funados__empleados
-- =============================================================================
-- Capa Silver: limpiar, deduplicar y normalizar.
-- Limpiezas:
--   - nombre y apellido: sin espacios sobrantes y con la inicial en mayúscula.
--   - email: sin espacios y en minúsculas. NO es único: hay personas distintas
--     con el mismo email (el perfilado lo demostró), así que no se deduplica.
--   - sexo: 13 variantes -> H, M o X; vacío = no informado (NULL).
--   - departamento_id: el 9 ('Mkt') se reasigna al 2 (Marketing).
--   - fecha_nacimiento: las imposibles (antes de 1940 o menos de 16 años al
--     darse de alta, p. ej. 1900-01-01 o 2030) se dejan a NULL.
--   - fecha_baja: si es anterior al alta, se deja a NULL (no se sabe la real).
-- La generación no se guarda: se calcula desde fecha_nacimiento (3FN).
-- =============================================================================

with empleados as (
    select * from {{ ref('stg_recursos_funados__empleados') }}
)

select
      empleado_id
    , initcap(trim(nombre))                         as nombre
    , initcap(trim(apellido))                       as apellido
    , lower(trim(email))                            as email

    , case
          when lower(trim(sexo)) in ('h', 'hombre', 'male', 'masculino')    then 'H'
          when lower(trim(sexo)) in ('m', 'f', 'mujer', 'female', 'femenino') then 'M'
          when lower(trim(sexo)) in ('x', 'no binario', 'other')            then 'X'
      end                                           as sexo

    , case
          when year(fecha_nacimiento) < 1940
            or fecha_nacimiento > dateadd('year', -16, fecha_alta)
          then null
          else fecha_nacimiento
      end                                           as fecha_nacimiento

    , sede_id
    , case when departamento_id = 9 then 2 else departamento_id end
                                                    as departamento_id
    , puesto
    , manager_id
    , fecha_alta
    , case when fecha_baja < fecha_alta then null else fecha_baja end
                                                    as fecha_baja
    , modalidad
    , jornada
from empleados