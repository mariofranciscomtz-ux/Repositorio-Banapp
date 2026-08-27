-- =========================================================
-- Permisos de finca por usuario. Un administrador ve todas las
-- fincas; un usuario normal solo ve las que se le asignen al
-- crearlo.
-- =========================================================

alter table usuarios add column es_admin boolean not null default false;

update usuarios set es_admin = true where nombre = 'Administrador';

create table usuario_fincas (
  usuario_id uuid not null references usuarios(id) on delete cascade,
  finca_id uuid not null references fincas(id) on delete cascade,
  primary key (usuario_id, finca_id)
);

alter table usuario_fincas enable row level security;

create policy "authenticated_full_access" on usuario_fincas
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

alter publication supabase_realtime add table usuario_fincas;
