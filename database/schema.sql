-- =========================================================
-- Esquema inicial - App Bananera
-- Módulos: fincas/lotes, racimos, cosecha, cajas procesadas
-- Motor: Postgres (Supabase)
-- =========================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------
-- Función genérica para mantener updated_at
-- ---------------------------------------------------------
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- =========================================================
-- FINCAS
-- =========================================================
create table fincas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  municipio text,
  departamento text not null default 'Magdalena',
  hectareas_totales numeric(10,2),
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_fincas_updated_at
  before update on fincas
  for each row execute function set_updated_at();

-- =========================================================
-- LOTES
-- =========================================================
create table lotes (
  id uuid primary key default gen_random_uuid(),
  finca_id uuid not null references fincas(id) on delete restrict,
  nombre text not null,
  hectareas numeric(10,2) not null,
  densidad_plantas_ha integer not null default 1800,
  plantas_estimadas integer generated always as (round(hectareas * densidad_plantas_ha)) stored,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (finca_id, nombre)
);

create index idx_lotes_finca on lotes(finca_id);

create trigger trg_lotes_updated_at
  before update on lotes
  for each row execute function set_updated_at();

-- =========================================================
-- CUADRILLAS
-- =========================================================
create table cuadrillas (
  id uuid primary key default gen_random_uuid(),
  finca_id uuid not null references fincas(id) on delete restrict,
  nombre text not null,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (finca_id, nombre)
);

create index idx_cuadrillas_finca on cuadrillas(finca_id);

create trigger trg_cuadrillas_updated_at
  before update on cuadrillas
  for each row execute function set_updated_at();

-- =========================================================
-- RACIMOS (identificación en edad 0)
-- =========================================================
create table racimos (
  id uuid primary key default gen_random_uuid(),
  lote_id uuid not null references lotes(id) on delete restrict,
  color_cinta text not null,
  fecha_identificacion date not null default current_date,
  identificado_por uuid references auth.users(id),
  estado text not null default 'activo'
    check (estado in ('activo', 'cosechado', 'descartado')),
  foto_url text,
  notas text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_racimos_lote on racimos(lote_id);
create index idx_racimos_estado on racimos(estado);
create index idx_racimos_fecha_id on racimos(fecha_identificacion);

create trigger trg_racimos_updated_at
  before update on racimos
  for each row execute function set_updated_at();

-- =========================================================
-- COSECHAS (cierra el racimo)
-- =========================================================
create table cosechas (
  id uuid primary key default gen_random_uuid(),
  racimo_id uuid not null unique references racimos(id) on delete restrict,
  fecha_cosecha date not null default current_date,
  calibracion numeric(4,2),        -- en 1/32 de pulgada
  largo_dedo_cm numeric(5,2),
  estado_fitosanitario text,
  motivo_corte text,
  cuadrilla_id uuid references cuadrillas(id),
  cortero_id uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_fecha_cosecha check (fecha_cosecha >= '2000-01-01')
);

create index idx_cosechas_racimo on cosechas(racimo_id);
create index idx_cosechas_fecha on cosechas(fecha_cosecha);
create index idx_cosechas_cuadrilla on cosechas(cuadrilla_id);

create trigger trg_cosechas_updated_at
  before update on cosechas
  for each row execute function set_updated_at();

-- Al registrar la cosecha, el racimo pasa a estado 'cosechado'
create or replace function marcar_racimo_cosechado()
returns trigger as $$
begin
  update racimos set estado = 'cosechado' where id = new.racimo_id;
  return new;
end;
$$ language plpgsql;

create trigger trg_cosecha_marca_racimo
  after insert on cosechas
  for each row execute function marcar_racimo_cosechado();

-- Vista con edad de cosecha calculada (racimo + cosecha)
create or replace view v_cosechas_detalle as
select
  c.id as cosecha_id,
  r.id as racimo_id,
  r.lote_id,
  l.finca_id,
  r.color_cinta,
  r.fecha_identificacion,
  c.fecha_cosecha,
  floor((c.fecha_cosecha - r.fecha_identificacion) / 7.0) as edad_semanas,
  c.calibracion,
  c.largo_dedo_cm,
  c.estado_fitosanitario,
  c.motivo_corte,
  c.cuadrilla_id,
  c.cortero_id
from cosechas c
join racimos r on r.id = c.racimo_id
join lotes l on l.id = r.lote_id;

-- =========================================================
-- TIPOS DE CAJA (marcas)
-- =========================================================
create table tipos_caja (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  peso_bruto_kg numeric(6,3) not null default 20,
  peso_neto_kg numeric(6,3) not null default 18.5,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_tipos_caja_updated_at
  before update on tipos_caja
  for each row execute function set_updated_at();

-- =========================================================
-- CAJAS PROCESADAS (conteo por tipo/marca)
-- =========================================================
create table cajas_procesadas (
  id uuid primary key default gen_random_uuid(),
  finca_id uuid not null references fincas(id) on delete restrict,
  lote_id uuid references lotes(id),
  tipo_caja_id uuid not null references tipos_caja(id) on delete restrict,
  cantidad_cajas integer not null check (cantidad_cajas > 0),
  fecha date not null default current_date,
  turno text check (turno in ('mañana', 'tarde', 'noche')),
  registrado_por uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_cajas_finca_fecha on cajas_procesadas(finca_id, fecha);
create index idx_cajas_tipo on cajas_procesadas(tipo_caja_id);
create index idx_cajas_lote on cajas_procesadas(lote_id);

create trigger trg_cajas_procesadas_updated_at
  before update on cajas_procesadas
  for each row execute function set_updated_at();

-- Vista resumen: cajas físicas por tipo y equivalente normalizado a 18,5 kg neto
create or replace view v_cajas_resumen as
select
  cp.finca_id,
  cp.lote_id,
  cp.fecha,
  tc.id as tipo_caja_id,
  tc.nombre as tipo_caja,
  sum(cp.cantidad_cajas) as cajas_fisicas,
  sum(cp.cantidad_cajas * tc.peso_bruto_kg) as peso_bruto_total_kg,
  sum(cp.cantidad_cajas * tc.peso_neto_kg) as peso_neto_total_kg,
  sum(cp.cantidad_cajas * tc.peso_neto_kg) / 18.5 as cajas_equivalentes_18_5
from cajas_procesadas cp
join tipos_caja tc on tc.id = cp.tipo_caja_id
group by cp.finca_id, cp.lote_id, cp.fecha, tc.id, tc.nombre;

-- =========================================================
-- ROW LEVEL SECURITY (placeholder)
-- Habilitado para poder usar PowerSync sync rules; las políticas
-- reales por rol (campo / supervisor / planta) se definen cuando
-- se diseñe el modelo de usuarios y permisos.
-- =========================================================
alter table fincas enable row level security;
alter table lotes enable row level security;
alter table cuadrillas enable row level security;
alter table racimos enable row level security;
alter table cosechas enable row level security;
alter table tipos_caja enable row level security;
alter table cajas_procesadas enable row level security;

create policy "authenticated_full_access" on fincas
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated_full_access" on lotes
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated_full_access" on cuadrillas
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated_full_access" on racimos
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated_full_access" on cosechas
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated_full_access" on tipos_caja
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authenticated_full_access" on cajas_procesadas
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
