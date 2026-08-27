-- =========================================================
-- Ahora que la app consulta Supabase directamente (sin PowerSync),
-- cada tabla transaccional necesita finca_id propio para poder
-- filtrar sin hacer JOIN (Supabase Realtime .stream() no soporta
-- joins). cajas_procesadas ya lo tenia.
-- =========================================================

alter table identificaciones_racimos add column finca_id uuid references fincas(id);
alter table cosecha_viajes add column finca_id uuid references fincas(id);

update identificaciones_racimos ir set finca_id = l.finca_id
from lotes l where l.id = ir.lote_id;

update cosecha_viajes cv set finca_id = l.finca_id
from lotes l where l.id = cv.lote_id;
