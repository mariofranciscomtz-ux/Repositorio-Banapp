-- =========================================================
-- Habilita Supabase Realtime para las tablas que la app escucha
-- en vivo con .stream(). Sin esto, cada suscripcion falla con
-- "RealtimeSubscribeException / channelError".
-- =========================================================

alter publication supabase_realtime add table usuarios;
alter publication supabase_realtime add table fincas;
alter publication supabase_realtime add table lotes;
alter publication supabase_realtime add table tipos_caja;
alter publication supabase_realtime add table identificaciones_racimos;
alter publication supabase_realtime add table cosecha_viajes;
alter publication supabase_realtime add table cajas_procesadas;
