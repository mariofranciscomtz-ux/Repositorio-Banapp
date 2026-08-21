-- =========================================================
-- Identificación de racimos por conteo (finca/lote/semana),
-- reemplaza el enfoque de racimo individual para este módulo.
-- No toca `racimos`/`cosechas` (eso se rediseña después).
-- =========================================================

create table identificaciones_racimos (
  id uuid primary key default gen_random_uuid(),
  lote_id uuid not null references lotes(id) on delete restrict,
  fecha date not null default current_date,
  color_cinta text not null,
  vuelta text not null check (vuelta in ('primera', 'segunda')),
  cantidad_racimos integer not null check (cantidad_racimos > 0),
  identificado_por uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_identificaciones_lote on identificaciones_racimos(lote_id);
create index idx_identificaciones_fecha on identificaciones_racimos(fecha);

create trigger trg_identificaciones_updated_at
  before update on identificaciones_racimos
  for each row execute function set_updated_at();

alter table identificaciones_racimos enable row level security;

create policy "authenticated_full_access" on identificaciones_racimos
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Reportes: racimos por hectárea, por lote y por finca, agrupados por semana.
-- (Vistas para consultas directas / Power BI; la app móvil calcula esto
-- en el dispositivo a partir de la tabla base, ya que PowerSync no sincroniza vistas.)

create or replace view v_identificaciones_por_lote_semana as
select
  ir.lote_id,
  l.finca_id,
  l.nombre as lote_nombre,
  l.hectareas,
  date_trunc('week', ir.fecha)::date as semana,
  sum(ir.cantidad_racimos) as total_racimos,
  round(sum(ir.cantidad_racimos) / nullif(l.hectareas, 0), 2) as racimos_por_ha
from identificaciones_racimos ir
join lotes l on l.id = ir.lote_id
group by ir.lote_id, l.finca_id, l.nombre, l.hectareas, date_trunc('week', ir.fecha);

create or replace view v_identificaciones_por_finca_semana as
select
  finca_id,
  semana,
  sum(total_racimos) as total_racimos,
  sum(hectareas) as hectareas_total,
  round(sum(total_racimos) / nullif(sum(hectareas), 0), 2) as racimos_por_ha
from v_identificaciones_por_lote_semana
group by finca_id, semana;
