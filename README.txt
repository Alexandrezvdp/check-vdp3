TECHNIQUE VDP — INSTALLATION

Version comprenant :
- 5 bateaux et check-lists Technique mises à jour.
- Planning partagé avec création de tâche. Le nom de l’opérateur est facultatif.
- Photo facultative sur une tâche du planning.
- Suppression des tâches par l’administrateur.
- Suivi journalier des niveaux et quantités ajoutées d’huile et de liquide de refroidissement.
- Matin et Soir restent « à venir ».

SUPABASE
1. Ouvrir le projet check-vdp.
2. SQL Editor > New query.
3. Remplacer le contenu par le fichier supabase_schema.sql de ce ZIP.
4. Run.
5. Ne jamais utiliser une clé service_role dans config.js.

IMPORTANT
Le SQL est prévu pour faire évoluer la base existante : il utilise des ALTER/CREATE IF NOT EXISTS et met à jour les points de checklist.

GITHUB PAGES
Remplacer les fichiers du dépôt avec ceux de ce ZIP.
