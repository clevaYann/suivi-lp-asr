# Application de suivi des étudiants de la LP ASR

Projet SAÉ S5.01 — BUT 3 Informatique, parcours IAMSI (D), IUT de Bayonne et du Pays Basque, 2026-2027.

Application web qui centralise les exports eLearn (notes, achèvement des activités), l'assiduité et les relances des étudiants de la Licence professionnelle ASR, pour remplacer le suivi manuel sous Excel de Jennifer Lesbats et Marta Toribio.

## Équipe

| Membre | Rôle |
|---|---|
| BOUSSOU Jarlin | Développeur |
| GIMENEZ Paul | Scrum Master, développeur |
| HOARAU Erwan | Développeur |
| RAMIREZ Angel | Proxy Product Owner, développeur |

## Périmètre (MoSCoW)

**Vital (MVP, fin janvier 2027)**

- V1 – Importer les exports eLearn (CSV/Excel : notes, achèvement)
- V2 – Partager les données entre les deux responsables (base commune)
- V3 – Calculer 3 indicateurs : assiduité, progression, performance
- V4 – Tableau de bord des étudiants à surveiller
- V5 – Protection des données (RGPD, gestion des droits)
- V6 – Éco-conception et mesure de l'empreinte

**Essentiel**

- E1 – Brouillons de relance personnalisés par IA
- E2 – Historique des indicateurs et des relances
- E3 – Paramétrage des dates d'UE et des seuils d'alerte

**Confort** : C1 – 2 indicateurs saisis à la main (feedback/corrections, charge de travail)

**Luxe (hors MVP)** : L1 – Collecte automatique via l'API eLearn

## Stack technique

| Domaine | Choix |
|---|---|
| Hébergement | Lakartxela (serveur web de l'IUT, Apache) |
| Langage serveur | PHP 8.5 |
| Framework | Laravel 12 (MVC) |
| Vues | Blade, HTML, CSS, un peu de JavaScript (Vite) |
| Base de données | MySQL 5.7 (Eloquent ORM + migrations) |
| Import CSV / Excel | Laravel Excel (PhpSpreadsheet) |

## Environnements

| Environnement | Où | Branche | Données |
|---|---|---|---|
| Développement | Poste de chaque développeur (`php artisan serve` + `npm run dev`) | `feature/*` | Fictives (seeders) |
| Recette | Instance séparée sur Lakartxela | `develop` | Fictives ou anonymisées |
| Production | Lakartxela | `main` (version taguée) | Réelles (RGPD) |

## Gestion des versions

```
feature/*  ──PR + relecture──▶  develop  ──recette validée──▶  main  ──tag vX.Y.Z──▶  production
```

- `main` : code en production, uniquement via une Pull Request depuis `develop`. Chaque mise en production est taguée (`v0.1.0`, `v1.0.0`…).
- `develop` : branche d'intégration, déployée en recette.
- `feature/<id>-<description>` : une branche par fonctionnalité, créée depuis `develop` (ex. `feature/V1-import-notes`).
- `fix/<description>` : correction de bug, créée depuis `develop`.
- `hotfix/<description>` : correction urgente en production, créée depuis `main` puis fusionnée dans `main` et `develop`.

Aucun push direct sur `main` ni sur `develop` : tout passe par une Pull Request relue par au moins un autre membre. Le détail des règles (commits, PR, versions) est dans [CONTRIBUTING.md](CONTRIBUTING.md).

## Installation locale

Prérequis : PHP 8.5, Composer, Node.js et npm, MySQL.

```bash
git clone https://github.com/clevaYann/suivi-lp-asr.git
cd suivi-lp-asr
git switch develop
composer install
npm install
cp .env.example .env
php artisan key:generate
# renseigner DB_DATABASE, DB_USERNAME et DB_PASSWORD dans .env
php artisan migrate --seed
php artisan serve      # dans un terminal
npm run dev            # dans un autre terminal
```

## Tests

Les tests utilisent une base MySQL dédiée `suivi_lp_asr_test` (voir `phpunit.xml`), à créer une fois en local.

```bash
php artisan test                 # tests unitaires et d'intégration (PHPUnit)
php artisan dusk:chrome-driver   # une seule fois, installe ChromeDriver
php artisan dusk                 # tests de bout en bout dans le navigateur (Laravel Dusk)
```

GitHub Actions lance `php artisan test` sur une base MySQL 5.7 à chaque Pull Request vers `develop` ou `main` (`.github/workflows/tests.yml`).

## Documentation du code

La documentation technique est générée par [Doxygen](https://www.doxygen.nl) à partir des commentaires `/** … */` du dossier `app/`.

```bash
doxygen Doxyfile                 # génère docs/html (non versionné)
```

À chaque tag `v*`, le workflow `.github/workflows/docs.yml` la régénère et la publie sur GitHub Pages : https://clevayann.github.io/suivi-lp-asr/

## Déploiement (recette et production)

Lakartxela ne dispose pas de Node.js : les CSS et le JavaScript sont compilés en amont.

```bash
npm run build
# sur le serveur :
git pull
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan optimize
```

Chaque environnement a son propre fichier `.env` (`APP_ENV`, `APP_DEBUG=false` en recette et en production). Le fichier `.env` n'est jamais versionné.

## Données personnelles

Aucune donnée réelle d'étudiant ne doit être commitée : ni export eLearn, ni dump de base. Les tests et la recette utilisent des données fictives ou anonymisées.
