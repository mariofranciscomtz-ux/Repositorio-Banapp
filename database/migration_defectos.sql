-- =========================================================
-- Detalle de racimos recusados por tipo de defecto, por viaje.
-- =========================================================

create table cosecha_viaje_defectos (
  id uuid primary key default gen_random_uuid(),
  viaje_id uuid not null references cosecha_viajes(id) on delete cascade,
  tipo_defecto text not null,
  cantidad integer not null check (cantidad > 0),
  created_at timestamptz not null default now()
);

create index idx_viaje_defectos_viaje on cosecha_viaje_defectos(viaje_id);

alter table cosecha_viaje_defectos enable row level security;

create policy "authenticated_full_access" on cosecha_viaje_defectos
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

alter publication powersync add table "public"."cosecha_viaje_defectos";
