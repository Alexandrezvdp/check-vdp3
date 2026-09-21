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
  operator_name text,
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

create unique index if not exists checklist_items_boat_position_idx on public.checklist_items(boat_id, position);

-- Check-lists TECHNIQUE VDP demandées. On met à jour les positions existantes
-- et on ajoute les nouveaux points sans supprimer les autres données.
DO $$
DECLARE b record;
BEGIN
  FOR b IN SELECT id,name FROM public.boats WHERE name <> 'Paris Etoile' LOOP
    INSERT INTO public.checklist_items(boat_id,title,position,active) VALUES
    (b.id,'Vérification de l''ensemble des locaux (fuite, eau dans les fonds, bruits anormaux,...)',1,true),
    (b.id,'Vérification niveau liquide de refroidissement moteurs',2,true),
    (b.id,'Vérification niveau huile appareil à gouverner',3,true),
    (b.id,'Vérification niveau huile étambot lignes d''arbres',4,true),
    (b.id,'Démarrage pack batteries Bâbord et Tribord',5,true),
    (b.id,'Essais appareil à gouverner normal et secours',6,true),
    (b.id,'Démarrage moteurs + test Embrayage Av/Ar',7,true),
    (b.id,'Vérification fonctionnement pompes de réfrigération moteur quand les moteurs sont en service',8,true),
    (b.id,'Contrôle Chargeur(s) batteries 24V',9,true),
    (b.id,'Essai Feux de navigation',10,true),
    (b.id,'Essai GPS',11,true),
    (b.id,'Essai VHF',12,true),
    (b.id,'Essai Interphonie',13,true),
    (b.id,'Essai Propulseur d''étrave',14,true),
    (b.id,'Essai Micro/Sono',15,true),
    (b.id,'Essai commande de l''appareil à gouverner normal et secours',16,true),
    (b.id,'Vérification AIS',17,true),
    (b.id,'Essai bascule distribution électrique AFE',18,true),
    (b.id,'Créer nouvelle croisière sur l''onglet journal de bord de BoatOn',19,true),
    (b.id,'Valider tâche préparation journalière sur BoatOn',20,true)
    ON CONFLICT DO NOTHING;
    UPDATE public.checklist_items ci SET title=v.title, active=true
    FROM (VALUES
      (1,'Vérification de l''ensemble des locaux (fuite, eau dans les fonds, bruits anormaux,...)'),
      (2,'Vérification niveau liquide de refroidissement moteurs'),(3,'Vérification niveau huile appareil à gouverner'),
      (4,'Vérification niveau huile étambot lignes d''arbres'),(5,'Démarrage pack batteries Bâbord et Tribord'),
      (6,'Essais appareil à gouverner normal et secours'),(7,'Démarrage moteurs + test Embrayage Av/Ar'),
      (8,'Vérification fonctionnement pompes de réfrigération moteur quand les moteurs sont en service'),
      (9,'Contrôle Chargeur(s) batteries 24V'),(10,'Essai Feux de navigation'),(11,'Essai GPS'),(12,'Essai VHF'),
      (13,'Essai Interphonie'),(14,'Essai Propulseur d''étrave'),(15,'Essai Micro/Sono'),
      (16,'Essai commande de l''appareil à gouverner normal et secours'),(17,'Vérification AIS'),
      (18,'Essai bascule distribution électrique AFE'),(19,'Créer nouvelle croisière sur l''onglet journal de bord de BoatOn'),
      (20,'Valider tâche préparation journalière sur BoatOn')
    ) v(position,title) WHERE ci.boat_id=b.id AND ci.position=v.position;
  END LOOP;

  FOR b IN SELECT id FROM public.boats WHERE name='Paris Etoile' LOOP
    INSERT INTO public.checklist_items(boat_id,title,position,active) VALUES
    (b.id,'Vérification de l''ensemble des locaux (fuite, eau dans les fonds, bruits anormaux,...)',1,true),
    (b.id,'Vérification niveau liquide de refroidissement ligne d''arbre',2,true),
    (b.id,'Vérification niveau huile appareil à gouverner',3,true),
    (b.id,'Nettoyage des filtres eau brut',4,true),
    (b.id,'Vérification niveau huile GENSET 1&2',5,true),
    (b.id,'Vérification niveau liquide de refroidissement GENSET 1&2',6,true),
    (b.id,'Vérification tension batteries à la timonerie',7,true),
    (b.id,'Démarrage GENSET 1&2',8,true),
    (b.id,'Démarrage moteurs + test Embrayage Av/Ar',9,true),
    (b.id,'Vérification pression huile GENSET 1&2',10,true),
    (b.id,'Vérification circulation eaux de réfrigération échappement',11,true),
    (b.id,'Essais Feux de navigation',12,true),(b.id,'Essai GPS',13,true),(b.id,'Essai VHF',14,true),
    (b.id,'Essai Interphonie',15,true),(b.id,'Essai Propulseur d''étrave',16,true),(b.id,'Essai Micro/Sono',17,true),
    (b.id,'Essai commande de l''appareil à gouverner normal et secours',18,true),(b.id,'Vérification AIS',19,true),
    (b.id,'Vérification ventilateurs variateurs moteurs Bd & Td',20,true),
    (b.id,'Vérification démarrage climatisation locaux techniques',21,true),
    (b.id,'Vérifications de l''ensemble des alimentations 24V des tableaux électriques',22,true)
    ON CONFLICT DO NOTHING;
    UPDATE public.checklist_items ci SET title=v.title, active=true
    FROM (VALUES
      (1,'Vérification de l''ensemble des locaux (fuite, eau dans les fonds, bruits anormaux,...)'),
      (2,'Vérification niveau liquide de refroidissement ligne d''arbre'),(3,'Vérification niveau huile appareil à gouverner'),
      (4,'Nettoyage des filtres eau brut'),(5,'Vérification niveau huile GENSET 1&2'),
      (6,'Vérification niveau liquide de refroidissement GENSET 1&2'),(7,'Vérification tension batteries à la timonerie'),
      (8,'Démarrage GENSET 1&2'),(9,'Démarrage moteurs + test Embrayage Av/Ar'),(10,'Vérification pression huile GENSET 1&2'),
      (11,'Vérification circulation eaux de réfrigération échappement'),(12,'Essais Feux de navigation'),(13,'Essai GPS'),
      (14,'Essai VHF'),(15,'Essai Interphonie'),(16,'Essai Propulseur d''étrave'),(17,'Essai Micro/Sono'),
      (18,'Essai commande de l''appareil à gouverner normal et secours'),(19,'Vérification AIS'),
      (20,'Vérification ventilateurs variateurs moteurs Bd & Td'),(21,'Vérification démarrage climatisation locaux techniques'),
      (22,'Vérifications de l''ensemble des alimentations 24V des tableaux électriques')
    ) v(position,title) WHERE ci.boat_id=b.id AND ci.position=v.position;
  END LOOP;
END $$;


-- Suivi journalier des niveaux et consommations huile / liquide de refroidissement.
create table if not exists public.fluid_logs (
  id uuid primary key default gen_random_uuid(),
  log_date date not null,
  boat_name text not null,
  equipment text not null,
  fluid_type text not null,
  quantity_added numeric(10,2),
  level_observation text,
  operator_name text,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  source text not null default 'Manuel' check (source in ('Checklist','Manuel'))
);

alter table public.fluid_logs add column if not exists source text not null default 'Manuel';

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
alter table public.fluid_logs enable row level security;

revoke all on public.boats, public.checklist_items, public.tasks, public.profiles from anon;
grant select on public.boats, public.checklist_items to authenticated;
grant select,insert,update,delete on public.tasks to authenticated;
grant select on public.profiles to authenticated;
grant select,insert,update on public.fluid_logs to authenticated;
grant delete on public.fluid_logs to authenticated;
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
drop policy if exists tasks_delete_authenticated on public.tasks;
create policy tasks_delete_authenticated on public.tasks
for delete to authenticated
using (true);

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



drop policy if exists fluid_logs_read on public.fluid_logs;
create policy fluid_logs_read on public.fluid_logs for select to authenticated using (true);
drop policy if exists fluid_logs_insert on public.fluid_logs;
create policy fluid_logs_insert on public.fluid_logs for insert to authenticated with check (true);
drop policy if exists fluid_logs_update on public.fluid_logs;
create policy fluid_logs_update on public.fluid_logs for update to authenticated using (true) with check (true);
drop policy if exists fluid_logs_delete on public.fluid_logs;
create policy fluid_logs_delete on public.fluid_logs for delete to authenticated using (public.is_admin());

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
with check (bucket_id = 'task-photos');

drop policy if exists task_photos_delete on storage.objects;
drop policy if exists task_photos_delete_authenticated on storage.objects;
create policy task_photos_delete
on storage.objects for delete
to authenticated
using (bucket_id = 'task-photos');
