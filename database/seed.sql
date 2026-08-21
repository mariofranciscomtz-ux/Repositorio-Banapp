-- Datos maestros iniciales para poder probar la app end-to-end.
-- Ajusta nombres reales de tus fincas/lotes cuando quieras.

insert into fincas (nombre, municipio, hectareas_totales)
values ('Finca Demo', 'Zona Bananera', 6.5);

insert into lotes (finca_id, nombre, hectareas)
select id, 'Lote 1', 6.5 from fincas where nombre = 'Finca Demo';

insert into tipos_caja (nombre, peso_bruto_kg, peso_neto_kg)
values
  ('Estándar 18.5', 20, 18.5),
  ('Premium', 20, 19);
