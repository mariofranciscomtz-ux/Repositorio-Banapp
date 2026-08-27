import 'package:powersync/powersync.dart';

const schema = Schema([
  Table('usuarios', [
    Column.text('nombre'),
    Column.text('pin_hash'),
  ]),
  Table('fincas', [
    Column.text('nombre'),
    Column.real('latitud'),
    Column.real('longitud'),
    Column.integer('orden'),
  ]),
  Table('lotes', [
    Column.text('finca_id'),
    Column.text('nombre'),
    Column.real('hectareas'),
  ]),
  Table('identificaciones_racimos', [
    Column.text('lote_id'),
    Column.text('fecha'),
    Column.text('color_cinta'),
    Column.text('vuelta'),
    Column.integer('cantidad_racimos'),
    Column.text('identificado_por'),
    Column.text('operario_id'),
  ]),
  Table('cosecha_viajes', [
    Column.text('lote_id'),
    Column.text('fecha'),
    Column.text('hora_registro'),
    Column.text('operario'),
    Column.integer('racimos_edad_8'),
    Column.integer('racimos_edad_9'),
    Column.integer('racimos_edad_10'),
    Column.integer('racimos_edad_11'),
    Column.integer('racimos_edad_12'),
    Column.integer('racimos_recusados'),
    Column.real('calibracion_edad_8'),
    Column.real('calibracion_edad_9'),
    Column.real('calibracion_edad_10'),
    Column.real('calibracion_edad_11'),
    Column.real('calibracion_edad_12'),
    Column.text('operario_id'),
  ]),
  Table('cosecha_viaje_defectos', [
    Column.text('viaje_id'),
    Column.text('tipo_defecto'),
    Column.integer('cantidad'),
  ]),
  Table('tipos_caja', [
    Column.text('nombre'),
    Column.real('peso_bruto_kg'),
    Column.real('peso_neto_kg'),
  ]),
  Table('cajas_procesadas', [
    Column.text('finca_id'),
    Column.text('lote_id'),
    Column.text('tipo_caja_id'),
    Column.integer('cantidad_cajas'),
    Column.text('fecha'),
    Column.text('operario_id'),
  ]),
]);
