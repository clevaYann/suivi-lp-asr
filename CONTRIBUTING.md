# Règles de contribution

## Branches

| Branche | Créée depuis | Fusionnée dans | Usage |
|---|---|---|---|
| `main` | — | — | Production, protégée |
| `develop` | `main` | `main` | Intégration et recette, protégée |
| `feature/<id>-<description>` | `develop` | `develop` | Nouvelle fonctionnalité (ex. `feature/V3-calcul-indicateurs`) |
| `fix/<description>` | `develop` | `develop` | Correction de bug |
| `hotfix/<description>` | `main` | `main` puis `develop` | Correction urgente en production |

Noms en minuscules, mots séparés par des tirets. L'identifiant reprend l'exigence MoSCoW (V1…V6, E1…E3, C1) quand il y en a une.

## Cycle d'une fonctionnalité

1. Mettre `develop` à jour : `git switch develop && git pull`
2. Créer la branche : `git switch -c feature/V1-import-notes`
3. Commiter par petites étapes (voir ci-dessous) et pousser : `git push -u origin feature/V1-import-notes`
4. Ouvrir une Pull Request vers `develop` et demander une relecture.
5. Après approbation et une fois à jour avec `develop`, fusionner (« Squash and merge ») puis supprimer la branche.

## Messages de commit

Format [Conventional Commits](https://www.conventionalcommits.org/fr/), en français :

```
<type>(<portée>): <description courte à l'impératif>
```

Types : `feat` (fonctionnalité), `fix` (correction), `docs`, `style`, `refactor`, `test`, `chore` (outillage, dépendances), `perf`.

Exemples :

- `feat(import): importer le journal d'achèvement eLearn`
- `fix(indicateurs): corriger le calcul de l'assiduité sans séance`
- `chore(deps): mettre à jour Laravel Excel`

## Pull Requests

- Une PR = une fonctionnalité ou une correction.
- Au moins une approbation d'un autre membre avant la fusion.
- Les migrations Laravel sont incluses dans la PR qui modifie la base.
- Aucun fichier `.env`, export eLearn ni donnée réelle d'étudiant.

## Versions

Numérotation [SemVer](https://semver.org/lang/fr/) : `vMAJEUR.MINEUR.CORRECTIF`.

- `v0.x.y` : versions de sprint déployées en recette.
- `v1.0.0` : livraison du MVP (fin janvier 2027).

Pour une mise en production : PR `develop` → `main`, puis tag et release GitHub :

```bash
git switch main && git pull
git tag -a v1.0.0 -m "Livraison du MVP"
git push origin v1.0.0
```
