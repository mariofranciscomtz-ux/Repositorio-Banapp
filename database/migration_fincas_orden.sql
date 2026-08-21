-- =========================================================
-- Orden personalizado de fincas para el listado del menú principal.
-- =========================================================

alter table fincas
  add column orden integer;

update fincas set orden = 1 where nombre = 'Tamacara';
update fincas set orden = 2 where nombre = 'Florida';
update fincas set orden = 3 where nombre = 'Las Delicias';
update fincas set orden = 4 where nombre = 'Dilia Esther';
update fincas set orden = 5 where nombre = 'Golondrina Nueva';
update fincas set orden = 6 where nombre = 'Golondrina Vieja';
update fincas set orden = 7 where nombre = 'Gloria Mercedes';
update fincas set orden = 8 where nombre = 'Lucila Marina';
update fincas set orden = 9 where nombre = 'Esmeralda';
update fincas set orden = 10 where nombre = 'La Maria';
update fincas set orden = 11 where nombre = 'Tropicana';
update fincas set orden = 12 where nombre = 'Costanera';
update fincas set orden = 13 where nombre = 'Raquelita';
update fincas set orden = 14 where nombre = 'Milady';
update fincas set orden = 15 where nombre = 'Macondo';
