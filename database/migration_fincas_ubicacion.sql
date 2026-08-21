-- =========================================================
-- Ubicación geográfica de fincas (para pronóstico del tiempo).
-- Coordenadas convertidas de grados/minutos/segundos a decimal.
-- =========================================================

alter table fincas
  add column latitud numeric(9,6),
  add column longitud numeric(9,6);

update fincas set latitud = 10.932319, longitud = -74.176464 where nombre = 'Gloria Mercedes';
update fincas set latitud = 10.921372, longitud = -74.171083 where nombre = 'Milady';
update fincas set latitud = 10.911569, longitud = -74.176900 where nombre = 'La Maria';
update fincas set latitud = 10.853319, longitud = -74.194928 where nombre = 'Tropicana';
update fincas set latitud = 10.841844, longitud = -74.177950 where nombre = 'Esmeralda';
update fincas set latitud = 10.835433, longitud = -74.175464 where nombre = 'Golondrina Nueva';
update fincas set latitud = 10.832561, longitud = -74.182369 where nombre = 'Costanera';
update fincas set latitud = 10.834214, longitud = -74.168753 where nombre = 'Golondrina Vieja';
update fincas set latitud = 10.832761, longitud = -74.167836 where nombre = 'Dilia Esther';
update fincas set latitud = 10.835244, longitud = -74.155933 where nombre = 'Raquelita';
update fincas set latitud = 10.783394, longitud = -74.123631 where nombre = 'Tamacara';
update fincas set latitud = 10.789769, longitud = -74.135258 where nombre = 'Florida';
update fincas set latitud = 10.797142, longitud = -74.142081 where nombre = 'Las Delicias';
update fincas set latitud = 10.751956, longitud = -74.144542 where nombre = 'Macondo';
update fincas set latitud = 10.555436, longitud = -74.229753 where nombre = 'Lucila Marina';
