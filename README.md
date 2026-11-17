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
| Environnement de développement | Docker (mêmes versions que Lakartxela : Apache, PHP 8.5, MySQL 5.7.28) |

## Environnements

| Environnement | Où | Branche | Données |
|---|---|---|---|
| Développement | Poste de chaque développeur, sous Docker (`docker compose up`) | `feature/*` | Fictives (seeders) |
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

## Installation locale (Docker)

L'environnement de développement tourne sous Docker et reproduit Lakartxela : Apache + PHP 8.5 et MySQL 5.7.28. Personne n'a besoin d'installer PHP, Composer, Node.js ni MySQL sur son poste. Docker ne sert qu'au développement : la recette et la production tournent directement sur Lakartxela.

Prérequis : [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows, macOS) ou Docker Engine avec le plugin Compose (Linux), et Git.

### Services

| Service | Rôle | Adresse sur le poste |
|---|---|---|
| `app` | Laravel servi par Apache + PHP 8.5 (`docker/php/Dockerfile`) | http://localhost:8000 |
| `mysql` | MySQL 5.7.28, bases `suivi_lp_asr` et `suivi_lp_asr_test` | `localhost:3307` (client SQL externe) |
| `node` | Vite : recompile CSS et JavaScript à chaque modification | http://localhost:5173 |
| `phpmyadmin` | Consultation de la base | http://localhost:8080 |
| `selenium` | Chrome pour les tests Laravel Dusk (lancé à la demande) | — |

### Premier lancement

```bash
git clone https://github.com/clevaYann/suivi-lp-asr.git
cd suivi-lp-asr
git switch develop
cp .env.example .env                              # déjà configuré pour Docker
docker compose up -d --build                      # 1er lancement : quelques minutes
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate --seed
```

L'application est sur http://localhost:8000. Au premier démarrage, le conteneur `app` lance `composer install` et le conteneur `node` lance `npm install` : attendre la fin (`docker compose logs -f app node`) avant d'ouvrir la page.

### Au quotidien

```bash
docker compose up -d                              # démarrer
docker compose down                               # arrêter (la base est conservée)
docker compose logs -f app                        # journaux Apache / PHP
docker compose exec app php artisan migrate       # toute commande artisan
docker compose exec app composer require <paquet> # dépendances PHP
docker compose exec node npm install <paquet>     # dépendances JavaScript
docker compose exec app bash                      # shell dans le conteneur
```

Après un `git pull` qui modifie `composer.lock` ou `package-lock.json`, relancer `docker compose exec app composer install` ou `docker compose restart node`. Après une modification de `docker/`, reconstruire l'image avec `docker compose up -d --build`.

Pour repartir d'une base vide : `docker compose exec app php artisan migrate:fresh --seed`. Pour tout supprimer, base comprise : `docker compose down -v`.

### Bon à savoir

- Le code est partagé avec le conteneur : les modifications faites dans l'éditeur sont prises en compte immédiatement.
- `vendor/` et `node_modules/` restent dans des volumes Docker (sinon chaque requête prend plusieurs secondes sous Windows). Ils n'apparaissent donc pas dans le dossier du projet ; pour l'autocomplétion de l'éditeur, on peut lancer `composer install` sur le poste en plus.
- Ports déjà pris sur le poste : les changer dans `.env` (`APP_PORT`, `FORWARD_DB_PORT`, `PHPMYADMIN_PORT`).
- phpMyAdmin : utilisateur `suivi`, mot de passe `suivi` (ou `root` / `root`), comme dans `.env`.
- Le fichier `.env` est lu à la fois par Laravel et par Docker Compose (variables `DB_*`). Changer `DB_DATABASE`, `DB_USERNAME` ou `DB_PASSWORD` après le premier lancement demande de recréer la base : `docker compose down -v`.
- Sans Docker : PHP 8.5, Composer, Node.js et MySQL 5.7 en local, avec `DB_HOST=127.0.0.1` dans `.env`, puis `php artisan serve` et `npm run dev`.

## Tests

Les tests utilisent une base MySQL dédiée `suivi_lp_asr_test` (voir `phpunit.xml`), créée automatiquement par Docker au premier lancement (`docker/mysql/init`).

```bash
docker compose exec app php artisan test          # tests unitaires et d'intégration (PHPUnit)

docker compose --profile dusk up -d selenium      # démarre Chrome pour Dusk
docker compose exec -e APP_URL=http://suivi-lp-asr.test app php artisan dusk
docker compose --profile dusk stop selenium       # arrête Chrome
```

Dusk pilote le Chrome du conteneur `selenium`, qui joint l'application à l'adresse `http://suivi-lp-asr.test` (d'où `APP_URL`).

GitHub Actions lance `php artisan test` sur une base MySQL 5.7 à chaque Pull Request vers `develop` ou `main` (`.github/workflows/tests.yml`).

## Documentation du code

La documentation technique est générée par [Doxygen](https://www.doxygen.nl) à partir des commentaires `/** … */` du dossier `app/`.

```bash
docker compose exec app doxygen Doxyfile        # génère docs/html (non versionné)
```

À chaque tag `v*`, le workflow `.github/workflows/docs.yml` la régénère et la publie sur GitHub Pages : https://clevayann.github.io/suivi-lp-asr/

## Déploiement (recette et production)

Lakartxela ne dispose ni de Docker ni de Node.js : les CSS et le JavaScript sont compilés en amont, sur un poste de l'équipe.

```bash
docker compose run --rm node npm run build        # génère public/build
# sur le serveur :
git pull
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan optimize
```

Chaque environnement a son propre fichier `.env` (`APP_ENV`, `APP_DEBUG=false` en recette et en production). Le fichier `.env` n'est jamais versionné.

## Données personnelles

Aucune donnée réelle d'étudiant ne doit être commitée : ni export eLearn, ni dump de base. Les tests et la recette utilisent des données fictives ou anonymisées.
