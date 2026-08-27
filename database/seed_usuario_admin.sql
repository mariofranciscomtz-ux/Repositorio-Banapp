-- Usuario administrador inicial. Nombre: Administrador · PIN: 1234
-- (hash sha256 de "1234", calculado fuera de la base de datos).
insert into usuarios (nombre, pin_hash)
values ('Administrador', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4');
