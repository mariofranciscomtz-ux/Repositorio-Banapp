-- =========================================================
-- Cosecha por viajes: cada viaje es una carga transportada
-- desde un lote (25-30 racimos), con conteo por edad (8-12
-- semanas) y racimos recusados. No toca `racimos`/`cosechas`
-- (quedan sin usar, pendientes de una futura decisión).
-- =========================================================

create table cosecha_viajes (
  id uuid primary key default gen_random_uuid(),
  lote_id uuid not null references lotes(id) on delete restrict,
  fecha date not null default current_date,
  hora_registro timestamptz not null default now(),
  operario text,
  racimos_edad_8 integer not null default 0,
  racimos_edad_9 integer not null default 0,
  racimos_edad_10 integer not null default 0,
  racimos_edad_11 integer not null default 0,
  racimos_edad_12 integer not null default 0,
  racimos_recusados integer not null default 0,
  registrado_por uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_viaje_tiene_racimos check (
    racimos_edad_8 + racimos_edad_9 + racimos_edad_10 + racimos_edad_11
    + racimos_edad_12 + racimos_recusados > 0
  )
);

create index idx_cosecha_viajes_lote on cosecha_viajes(lote_id);
create index idx_cosecha_viajes_fecha on cosecha_viajes(fecha);

create trigger trg_cosecha_viajes_updated_at
  before update on cosecha_viajes
  for each row execute function set_updated_at();

alter table cosecha_viajes enable row level security;

create policy "authenticated_full_access" on cosecha_viajes
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

alter publication powersync add table "public"."cosecha_viajes";
