-- Carga de fincas y lotes reales (generado desde "Embolses Por lotes Año 2026.xlsx")

insert into fincas (nombre, departamento) values ('Costanera', 'Magdalena');
insert into fincas (nombre, departamento) values ('Dilia Esther', 'Magdalena');
insert into fincas (nombre, departamento) values ('Esmeralda', 'Magdalena');
insert into fincas (nombre, departamento) values ('Florida', 'Magdalena');
insert into fincas (nombre, departamento) values ('Gloria Mercedes', 'Magdalena');
insert into fincas (nombre, departamento) values ('Golondrina Nueva', 'Magdalena');
insert into fincas (nombre, departamento) values ('Golondrina Vieja', 'Magdalena');
insert into fincas (nombre, departamento) values ('La Maria', 'Magdalena');
insert into fincas (nombre, departamento) values ('Las Delicias', 'Magdalena');
insert into fincas (nombre, departamento) values ('Lucila Marina', 'Magdalena');
insert into fincas (nombre, departamento) values ('Macondo', 'Magdalena');
insert into fincas (nombre, departamento) values ('Milady', 'Magdalena');
insert into fincas (nombre, departamento) values ('Raquelita', 'Magdalena');
insert into fincas (nombre, departamento) values ('Tamacara', 'Magdalena');
insert into fincas (nombre, departamento) values ('Tropicana', 'Magdalena');

-- Lotes de Costanera
insert into lotes (finca_id, nombre, hectareas) select id, '01', 2.25 from fincas where nombre = 'Costanera';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 1.66 from fincas where nombre = 'Costanera';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 1.19 from fincas where nombre = 'Costanera';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 1.66 from fincas where nombre = 'Costanera';

-- Lotes de Dilia Esther
insert into lotes (finca_id, nombre, hectareas) select id, '01', 3.54 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 3.42 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 3 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 4.56 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 8.4 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 9.06 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '07', 1.77 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '08', 5.02 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '09', 7.64 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '10', 5.33 from fincas where nombre = 'Dilia Esther';
insert into lotes (finca_id, nombre, hectareas) select id, '11', 5.49 from fincas where nombre = 'Dilia Esther';

-- Lotes de Esmeralda
insert into lotes (finca_id, nombre, hectareas) select id, '01', 4.5 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 6.34 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 6.1 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 6.35 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 6.46 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 5.74 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '07', 5.32 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '08', 3.5 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '09', 4.5 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '10', 6.5 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '11', 8.1 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '12', 5.95 from fincas where nombre = 'Esmeralda';
insert into lotes (finca_id, nombre, hectareas) select id, '13', 7.44 from fincas where nombre = 'Esmeralda';

-- Lotes de Florida
insert into lotes (finca_id, nombre, hectareas) select id, '01', 4.74 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 4.77 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 5.39 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 4.3 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 7.21 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 5 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '07', 5.5 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '08', 5.2 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '09', 4.6 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '10', 5.1 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '11', 9.82 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '12', 8.7 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '13', 4.44 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '14', 7.36 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '15', 6.06 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '16', 6.46 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '17', 7.22 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '18', 7.51 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '19', 8.17 from fincas where nombre = 'Florida';
insert into lotes (finca_id, nombre, hectareas) select id, '20', 4.2 from fincas where nombre = 'Florida';

-- Lotes de Gloria Mercedes
insert into lotes (finca_id, nombre, hectareas) select id, '01', 6.15 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 4.83 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 6.21 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 7.79 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 7.36 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 7.7 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '07', 8.02 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '08', 5.53 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '09', 5.01 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '10', 4.97 from fincas where nombre = 'Gloria Mercedes';
insert into lotes (finca_id, nombre, hectareas) select id, '11', 3.11 from fincas where nombre = 'Gloria Mercedes';

-- Lotes de Golondrina Nueva
insert into lotes (finca_id, nombre, hectareas) select id, '01', 3.44 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 4.68 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 6.91 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 3.7 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 4.79 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 3 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '07', 5.2 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '08', 4.6 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '09', 4 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '10', 1.84 from fincas where nombre = 'Golondrina Nueva';
insert into lotes (finca_id, nombre, hectareas) select id, '11', 3.3 from fincas where nombre = 'Golondrina Nueva';

-- Lotes de Golondrina Vieja
insert into lotes (finca_id, nombre, hectareas) select id, '0', 3 from fincas where nombre = 'Golondrina Vieja';
insert into lotes (finca_id, nombre, hectareas) select id, '1', 5.78 from fincas where nombre = 'Golondrina Vieja';
insert into lotes (finca_id, nombre, hectareas) select id, '2', 3.53 from fincas where nombre = 'Golondrina Vieja';
insert into lotes (finca_id, nombre, hectareas) select id, '3', 2.46 from fincas where nombre = 'Golondrina Vieja';
insert into lotes (finca_id, nombre, hectareas) select id, '4', 3.26 from fincas where nombre = 'Golondrina Vieja';
insert into lotes (finca_id, nombre, hectareas) select id, '5', 2.32 from fincas where nombre = 'Golondrina Vieja';
insert into lotes (finca_id, nombre, hectareas) select id, '6', 3.91 from fincas where nombre = 'Golondrina Vieja';
insert into lotes (finca_id, nombre, hectareas) select id, '7', 6.38 from fincas where nombre = 'Golondrina Vieja';
insert into lotes (finca_id, nombre, hectareas) select id, '8', 3.12 from fincas where nombre = 'Golondrina Vieja';
insert into lotes (finca_id, nombre, hectareas) select id, '9', 5.76 from fincas where nombre = 'Golondrina Vieja';

-- Lotes de La Maria
insert into lotes (finca_id, nombre, hectareas) select id, '1', 4.52 from fincas where nombre = 'La Maria';
insert into lotes (finca_id, nombre, hectareas) select id, '2', 2.07 from fincas where nombre = 'La Maria';
insert into lotes (finca_id, nombre, hectareas) select id, '3', 3.7 from fincas where nombre = 'La Maria';

-- Lotes de Las Delicias
insert into lotes (finca_id, nombre, hectareas) select id, '01', 4.18 from fincas where nombre = 'Las Delicias';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 3.15 from fincas where nombre = 'Las Delicias';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 3.22 from fincas where nombre = 'Las Delicias';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 3.55 from fincas where nombre = 'Las Delicias';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 3.08 from fincas where nombre = 'Las Delicias';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 5.14 from fincas where nombre = 'Las Delicias';
insert into lotes (finca_id, nombre, hectareas) select id, '07', 4.94 from fincas where nombre = 'Las Delicias';
insert into lotes (finca_id, nombre, hectareas) select id, '08', 4.11 from fincas where nombre = 'Las Delicias';
insert into lotes (finca_id, nombre, hectareas) select id, '09', 3.27 from fincas where nombre = 'Las Delicias';
insert into lotes (finca_id, nombre, hectareas) select id, '10', 3.48 from fincas where nombre = 'Las Delicias';

-- Lotes de Lucila Marina
insert into lotes (finca_id, nombre, hectareas) select id, '01', 2.49 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 2.83 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 2.53 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 2.82 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 3.52 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 4.9 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '07', 4.56 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '08', 4.75 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '09', 7.78 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '10', 9.15 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '11', 9.74 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '12', 10.65 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '13', 9.52 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '14', 9.48 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '15', 8 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '16', 8 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '17', 7.46 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '18', 12.23 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '19', 7.86 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '20', 5.49 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '21', 4.05 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '22', 5.32 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '23', 4.23 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '24', 4.15 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '25', 4.92 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '26', 4.92 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '27', 4.92 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '28', 4.92 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '29', 4.92 from fincas where nombre = 'Lucila Marina';
insert into lotes (finca_id, nombre, hectareas) select id, '30', 5.03 from fincas where nombre = 'Lucila Marina';

-- Lotes de Macondo
insert into lotes (finca_id, nombre, hectareas) select id, '01', 1.53 from fincas where nombre = 'Macondo';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 6.79 from fincas where nombre = 'Macondo';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 6.4 from fincas where nombre = 'Macondo';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 3.4 from fincas where nombre = 'Macondo';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 4.8 from fincas where nombre = 'Macondo';

-- Lotes de Milady
insert into lotes (finca_id, nombre, hectareas) select id, '01', 0.97 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 1.42 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 3.89 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 4.11 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 3.75 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 3.21 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '07', 3.46 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '08', 5.4 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '09', 5.14 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '10', 4 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '11', 3.7 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '12', 1.9 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '13', 5.37 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '14', 4.71 from fincas where nombre = 'Milady';
insert into lotes (finca_id, nombre, hectareas) select id, '15', 5.97 from fincas where nombre = 'Milady';

-- Lotes de Raquelita
insert into lotes (finca_id, nombre, hectareas) select id, '01', 6.82 from fincas where nombre = 'Raquelita';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 6.58 from fincas where nombre = 'Raquelita';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 8.05 from fincas where nombre = 'Raquelita';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 4.74 from fincas where nombre = 'Raquelita';

-- Lotes de Tamacara
insert into lotes (finca_id, nombre, hectareas) select id, '01', 5.4 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 6 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 6.91 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 6.66 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 6.4 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 6.57 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '07', 7.81 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '08', 4.34 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '09', 4.21 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '10', 4.21 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '11', 8.8 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '12', 12.14 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '13', 7.41 from fincas where nombre = 'Tamacara';
insert into lotes (finca_id, nombre, hectareas) select id, '14', 10.59 from fincas where nombre = 'Tamacara';
-- PENDIENTE: falta confirmar hectareaje real del lote 15
insert into lotes (finca_id, nombre, hectareas) select id, '15', 0 from fincas where nombre = 'Tamacara';

-- Lotes de Tropicana
insert into lotes (finca_id, nombre, hectareas) select id, '01', 1.5 from fincas where nombre = 'Tropicana';
insert into lotes (finca_id, nombre, hectareas) select id, '02', 2.5 from fincas where nombre = 'Tropicana';
insert into lotes (finca_id, nombre, hectareas) select id, '03', 2.35 from fincas where nombre = 'Tropicana';
insert into lotes (finca_id, nombre, hectareas) select id, '04', 2.08 from fincas where nombre = 'Tropicana';
insert into lotes (finca_id, nombre, hectareas) select id, '05', 1.07 from fincas where nombre = 'Tropicana';
insert into lotes (finca_id, nombre, hectareas) select id, '06', 10 from fincas where nombre = 'Tropicana';
