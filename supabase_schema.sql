-- CHECK VDP V3 — Supabase
-- À exécuter dans Supabase > SQL Editor.
-- Cette base stocke uniquement la configuration des check-lists et le planning.
-- Les résultats détaillés des check-lists ne sont PAS enregistrés par l'application.

create extension if not exists pgcrypto;

create table if not exists public.boats (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order int not null
);

create table if not exists public.checklist_items (
  id uuid primary key default gen_random_uuid(),
  boat_id uuid not null references public.boats(id) on delete cascade,
  title text not null,
  position int not null,
  active boolean not null default true
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  task_date date not null,
  boat_name text not null,
  operator_name text not null,
  task text not null,
  status text not null default 'todo' check (status in ('todo','done')),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  completed_by uuid
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'operator' check (role in ('admin','operator'))
);

insert into public.boats(name,sort_order) values
('Paris Iéna',1),('Paris Trocadéro',2),('Paris Montmartre',3),
('Paris Montparnasse',4),('Paris Etoile',5)
on conflict (name) do nothing;

insert into public.checklist_items(boat_id,title,position)
select b.id,v.title,v.position
from public.boats b
cross join lateral (
  values
  ('Vérification de l''ensemble des locaux (fuite, eau dans les fonds, bruits anormaux,... )',1),
  ('Vérification niveau liquide de refroidissement moteurs',2),
  ('Vérification niveau huile appareil à gouverner',3),
  ('Vérification niveau huile étambot lignes d''arbres',4),
  ('Démarrage pack batteries Bâbord et Tribord',5),
  ('Essais appareil à gouverner normal et secours',6),
  ('Démarrage moteurs + test Embrayage Av/Ar',7),
  ('Vérification fonctionnement pompes de réfrigération moteur quand les moteurs sont en service',8),
  ('Essais : Feux de navigation, GPS, VHF, Interphonie, Propulseur d''étrave, Micro/Sono, commande de l''appareil à gouverner normal et secours',9),
  ('Vérification AIS',10),
  ('Essai bascule distribution électrique AFE',11),
  ('Créer nouvelle croisière sur l''onglet journal de bord de BoatOn',12)
) v(title,position)
where b.name <> 'Paris Etoile'
and not exists (select 1 from public.checklist_items ci where ci.boat_id=b.id);

insert into public.checklist_items(boat_id,title,position)
select b.id,v.title,v.position
from public.boats b
cross join lateral (
  values
  ('Vérification de l''ensemble des locaux',1),
  ('Vérification niveau liquide de refroidissement ligne d''arbre',2),
  ('Vérification niveau huile appareil à gouverner',3),
  ('Nettoyage des filtres eau brut',4),
  ('Vérification niveau huile + liquide de refroidissement GENSET 1 et 2',5),
  ('Vérification tension batteries',6),
  ('Démarrage GENSET 1 et 2',7),
  ('Démarrage moteurs + test Embrayage Av/Ar',8),
  ('Vérification pression huile GENSET 1 et 2',9),
  ('Vérification circulation eaux de réfrigération échappement',10),
  ('Essais : Feux de navigation, GPS, VHF, Interphonie, Propulseur d''étrave, Micro/Sono, commande de l''appareil à gouverner normal et secours',11),
  ('Vérification AIS',12),
  ('Vérification ventilateurs variateur moteur',13),
  ('Alimentations 24 V',14)
) v(title,position)
where b.name='Paris Etoile'
and not exists (select 1 from public.checklist_items ci where ci.boat_id=b.id);

-- Fonction utilisée par les politiques RLS pour reconnaître un administrateur.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  );
$$;

alter table public.boats enable row level security;
alter table public.checklist_items enable row level security;
alter table public.tasks enable row level security;
alter table public.profiles enable row level security;

revoke all on public.boats, public.checklist_items, public.tasks, public.profiles from anon;
grant select on public.boats, public.checklist_items to authenticated;
grant select,insert,update,delete on public.tasks to authenticated;
grant select on public.profiles to authenticated;
grant update,insert,delete on public.checklist_items to authenticated;
grant update on public.boats to authenticated;

drop policy if exists boats_read on public.boats;
create policy boats_read on public.boats for select to authenticated using (true);

drop policy if exists checklist_read on public.checklist_items;
create policy checklist_read on public.checklist_items for select to authenticated using (true);

drop policy if exists checklist_admin_insert on public.checklist_items;
create policy checklist_admin_insert on public.checklist_items for insert to authenticated with check (public.is_admin());

drop policy if exists checklist_admin_update on public.checklist_items;
create policy checklist_admin_update on public.checklist_items for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists checklist_admin_delete on public.checklist_items;
create policy checklist_admin_delete on public.checklist_items for delete to authenticated using (public.is_admin());

drop policy if exists tasks_read on public.tasks;
create policy tasks_read on public.tasks for select to authenticated using (true);

drop policy if exists tasks_insert_admin on public.tasks;
create policy tasks_insert_admin on public.tasks for insert to authenticated with check (public.is_admin());

drop policy if exists tasks_update_operator on public.tasks;
create policy tasks_update_operator on public.tasks for update to authenticated using (true) with check (true);

drop policy if exists tasks_delete_admin on public.tasks;
create policy tasks_delete_admin on public.tasks for delete to authenticated using (public.is_admin());

drop policy if exists profiles_read on public.profiles;
create policy profiles_read on public.profiles for select to authenticated using (id = auth.uid() or public.is_admin());

-- Après avoir créé l'utilisateur administrateur dans Authentication > Users,
-- remplacez VOTRE-UUID-ADMIN par son UUID :
-- insert into public.profiles(id,email,role)
-- values ('VOTRE-UUID-ADMIN','votre-email','admin')
-- on conflict (id) do update set role='admin',email=excluded.email;

-- Exemple opérateur :
-- insert into public.profiles(id,email,role)
-- values ('UUID-OPERATEUR','operateur@example.com','operator')
-- on conflict (id) do update set role='operator',email=excluded.email;


-- Photos facultatives pour les tâches du planning.
alter table public.tasks add column if not exists photo_url text;

-- Stockage Supabase des photos de tâches. Le bucket est public afin que
-- les miniatures puissent être affichées directement dans le planning.
insert into storage.buckets (id, name, public)
values ('task-photos', 'task-photos', true)
on conflict (id) do update set public = true;

drop policy if exists task_photos_read on storage.objects;
create policy task_photos_read
on storage.objects for select
to authenticated
using (bucket_id = 'task-photos');

drop policy if exists task_photos_insert on storage.objects;
create policy task_photos_insert
on storage.objects for insert
to authenticated
with check (bucket_id = 'task-photos' and public.is_admin());

drop policy if exists task_photos_delete on storage.objects;
create policy task_photos_delete
on storage.objects for delete
to authenticated
using (bucket_id = 'task-photos' and public.is_admin());
