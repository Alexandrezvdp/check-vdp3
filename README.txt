CHECK VDP V3 — INSTALLATION

Architecture
- Application statique/PWA hébergée sur GitHub Pages.
- Supabase sert de base partagée pour la configuration des check-lists et le planning.
- Les résultats détaillés des check-lists ne sont pas enregistrés par cette version.
- Les photos ne sont pas envoyées sur un serveur : elles restent dans la page et doivent être jointes manuellement au mail.
- Les mails utilisent mailto: et doivent être envoyés manuellement.
- Matin et Soir sont désactivés (« à venir »).

1. CRÉER LE PROJET SUPABASE
- Créez un projet sur Supabase.
- Ouvrez SQL Editor.
- Collez et exécutez supabase_schema.sql.
- Dans Authentication > Users, créez un compte pour l'administrateur.
- Récupérez son UUID.
- Dans SQL Editor, exécutez :
  insert into public.profiles(id,email,role)
  values ('UUID','email','admin')
  on conflict (id) do update set role='admin',email=excluded.email;
- Créez ensuite les comptes opérateurs et ajoutez-les dans profiles avec role='operator'.

2. CONFIGURER L'APPLICATION
- Ouvrez config.js.
- Remplacez :
  VOTRE-PROJET.supabase.co
  VOTRE-CLE-PUBLISHABLE
- Utilisez uniquement la clé publishable/anon destinée au navigateur.
- Ne mettez jamais une clé service_role dans le navigateur.

3. TEST LOCAL
- Pour tester correctement la PWA et les appels réseau, utilisez un petit serveur HTTP local ou GitHub Pages.
- Vous pouvez simplement publier les fichiers sur GitHub Pages.

4. GITHUB PAGES
Dépôt prévu :
https://alexandrezvdp.github.io/check-vdp/

Placez à la racine :
index.html
config.js
manifest.webmanifest
sw.js
supabase_schema.sql (peut rester dans le dépôt mais n'est pas exécuté par le navigateur)

5. UTILISATION
- Administrateur : connexion > Administration pour modifier les points et gérer le planning.
- Opérateur : connexion > Planning pour voir ses tâches > Bateaux > Technique pour effectuer une checklist.
- Le calendrier est mensuel. Un clic sur un jour affiche les tâches du jour.
- « Réalisée » met à jour le planning partagé et ouvre un email prérempli à a.zinzius@vedettesdeparis.com.

IMPORTANT SÉCURITÉ
La V3 utilise Supabase Auth + Row Level Security. Le mot de passe d'administration n'est pas codé en clair dans l'application. Les droits sont déterminés par la table profiles.
