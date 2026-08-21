-- =========================================================
-- Promedio de calibración de racimo por edad, registrado por viaje.
-- =========================================================

alter table cosecha_viajes
  add column calibracion_edad_8 numeric,
  add column calibracion_edad_9 numeric,
  add column calibracion_edad_10 numeric,
  add column calibracion_edad_11 numeric,
  add column calibracion_edad_12 numeric;
