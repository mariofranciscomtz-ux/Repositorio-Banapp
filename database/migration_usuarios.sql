-- =========================================================
-- Usuarios internos (trabajadores de campo). Login liviano por
-- nombre + PIN de 4 digitos, independiente del login de Supabase
-- (que se usa una sola vez por dispositivo para sincronizar).
-- =========================================================

create table usuarios (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  pin_hash text not null,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_usuarios_updated_at
  before update on usuarios
  for each row execute function set_updated_at();

alter table usuarios enable row level security;

create policy "authenticated_full_access" on usuarios
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

alter publication powersync add table "public"."usuarios";

-- Identifica que trabajador (de la tabla usuarios, no auth.users) hizo
-- cada registro. Aditivo: no toca las columnas existentes.
alter table identificaciones_racimos add column operario_id uuid references usuarios(id);
alter table cosecha_viajes add column operario_id uuid references usuarios(id);
alter table cajas_procesadas add column operario_id uuid references usuarios(id);
