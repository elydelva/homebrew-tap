# Frame Homebrew Tap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publier un catalogue Homebrew conventionnel avec `frame` comme première CLI installable.

**Architecture:** Chaque push sur `frame/release` publie une nouvelle version CLI et quatre archives binaires immuables, puis ouvre ou actualise une PR de formule dans `homebrew-tap`. Les contrôles du tap autorisent sa fusion automatique ; `main` du tap devient alors le catalogue distribué par Homebrew.

**Tech Stack:** Bun 1.3.11, GitHub Actions, GitHub Releases, Homebrew Formula/Ruby.

**Spec:** `docs/superpowers/specs/2026-09-29-frame-tap.md`

## État constaté le 29 septembre 2026

- `homebrew-tap` est vide, sans premier commit ; le dépôt GitHub existe mais est privé.
- `frame` est public. `bun run build:bin` compile `dist/frame`, mais la CI ne conserve qu'un artefact Linux temporaire. Aucune GitHub Release ni aucun tag n'est publié.
- `release-please` gère plusieurs composants. Son signal global `releases_created` peut être vrai sans release CLI ; utiliser les sorties spécifiques à `apps/cli`.
- La version de la CLI est codée dans `apps/cli/src/cli.ts` (`0.1.1`), tandis que le manifeste release-please indique `0.1.0` ; vérifier et réconcilier cette différence avant la première release.
- `frame` n'a pas de branche `release` distante. `homebrew-tap` a `allow_auto_merge: false` ; sa branche `main` n'a pas encore de règle de protection.

## Contraintes globales

- Formule nommée `Formula/frame.rb`, classe `Frame`, commande publique `brew install elydelva/tap/frame`.
- Quatre cibles : `darwin-arm64`, `darwin-x64`, `linux-arm64`, `linux-x64` ; aucune URL mouvante ni empreinte factice.
- Même numéro de version entre la release du composant CLI, les quatre archives, `frame --version` et la formule.
- Chaque push de `frame/release` destiné à la publication porte une version CLI nouvelle ; une version déjà publiée échoue sans remplacer le tag ni les archives.
- La PR du tap est créée après publication et vérification des quatre assets ; l'auto-fusion attend tous les contrôles requis du tap.
- La publication distante et le passage du dépôt tap en public sont des opérations distinctes de la préparation locale.

## Fichiers et responsabilités

| Dépôt | Fichier | Responsabilité |
| --- | --- | --- |
| `frame` | `.github/workflows/release-please.yml`, `release-please-config.json`, `.release-please-manifest.json` | Garder les releases des autres composants sur `main` sans publier la CLI depuis cette branche. |
| `frame` | `.github/workflows/release-cli.yml` | Sur push `release`, contrôler la version, publier les archives et mettre à jour la PR du tap. |
| `frame` | `package.json` | Commande locale de compilation ciblée si nécessaire. |
| `frame` | `apps/cli/src/cli.ts` | Version visible par `frame --version`, synchronisée avec la release. |
| `homebrew-tap` | `Formula/frame.rb` | Métadonnées, plateformes, empreintes, installation et test. |
| `homebrew-tap` | `.github/workflows/ci.yml` | Vérification de la formule et installation sur les plateformes couvertes. |
| `homebrew-tap` | Règles GitHub de `main` | Contrôles obligatoires et auto-fusion des PR de mise à jour. |
| `homebrew-tap` | `README.md` | Catalogue et commandes utilisateur. |
| `homebrew-tap` | `CONTRIBUTING.md` | Procédure d'ajout et de mise à jour des formules. |

## Review Focus

- Un push sur `main` ou une release d'un autre composant ne doit pas modifier le tap : vérifier que seule `frame/release` déclenche le workflow CLI.
- Deux pushes avec la même version ne doivent jamais écraser un tag ou un asset : le second doit échouer avant publication.
- Une archive d'une autre version ou architecture ne doit pas entrer dans la formule : comparer version, cible et SHA-256 avant installation.
- Une archive valide mais sans bit exécutable doit être installée avec les permissions adaptées : tester l'exécution après `brew install`.
- La formule doit échouer clairement sur une plateforme non couverte : vérifier les conditions de plateforme dans l'audit et la matrice CI.
- Une PR qui échoue l'audit ou l'installation ne doit pas fusionner ; vérifier les règles de `main` et le statut de l'auto-fusion.
- Un tap privé ne permet pas la commande publique documentée : vérifier la visibilité et l'installation depuis une machine sans accès au dépôt avant annonce.

---

### Task 1: Définir la branche `release` et publier la CLI à chaque push

**Files:** créer `frame/.github/workflows/release-cli.yml` ; modifier `frame/.github/workflows/release-please.yml`, `frame/release-please-config.json`, `frame/.release-please-manifest.json`, `frame/package.json` si utile, et `frame/apps/cli/src/cli.ts` pour la version.

**Interfaces:** consomme chaque push sur `release` et la version `V` de `apps/cli/package.json` ; produit le tag `frame-vV` et les assets `frame-V-darwin-arm64.tar.gz`, `frame-V-darwin-x64.tar.gz`, `frame-V-linux-arm64.tar.gz`, `frame-V-linux-x64.tar.gz`, chacun contenant un exécutable `frame`.

- [ ] Créer la branche `release` depuis `main` ; définir dans `CONTRIBUTING.md` que chaque push de publication augmente `apps/cli/package.json.version`. Synchroniser `apps/cli/src/cli.ts`, retirer `apps/cli` du manifeste/configuration release-please et du groupe de versions liées, puis retirer l'étape npm de la CLI du job de `main` pour éviter une seconde publication CLI concurrente. Traiter la distribution npm séparément : le paquet public `frame` ne correspond pas à ce dépôt.
- [ ] Ajouter `release-cli.yml` sur `push` de `release` : checkout du SHA poussé, installation Bun depuis `.bun-version`, vérification que `V` est inédit et que `frame --version` vaut `V`, puis compilation des quatre cibles et création des archives avec leurs SHA-256.
- [ ] Sur chaque OS disponible dans la matrice, extraire l'archive native et vérifier `frame --version == V`, `frame --help` et le format de l'exécutable ; bloquer l'upload si le contrôle échoue. Documenter explicitement toute cible qui ne peut pas être exécutée en CI.
- [ ] Créer le tag immuable `frame-vV` sur le SHA poussé, puis la GitHub Release et ses quatre assets, seulement après réussite des contrôles ; refuser toute tentative de remplacement d'une version existante. Vérifier que les quatre assets sont téléchargeables et que leurs empreintes recalculées correspondent. Commit ciblé dans `frame`.

### Task 2: Initialiser le catalogue et la formule

**Files:** créer `homebrew-tap/Formula/frame.rb`, `homebrew-tap/README.md`, `homebrew-tap/CONTRIBUTING.md`.

**Interfaces:** consomme le tag, la version, les quatre URL immuables et les SHA-256 validés en Task 1 ; fournit `brew install elydelva/tap/frame`.

- [ ] Créer `Formula/frame.rb` avec `desc`, `homepage`, `license`, `version`, quatre branches `on_macos`/`on_linux` et `on_arm`/`on_intel`, `url` et `sha256` propres à chaque archive, `bin.install "frame"`, puis un bloc `test do` qui compare `--version` à `version.to_s` et exécute `--help`.
- [ ] Remplacer les valeurs d'URL et SHA-256 uniquement avec celles de la release effective ; vérifier chaque archive par `shasum -a 256` avant de valider la formule.
- [ ] Rédiger `README.md` avec le catalogue (`frame`), `brew install elydelva/tap/frame`, `brew upgrade elydelva/tap/frame`, et le lien amont. Rédiger `CONTRIBUTING.md` avec la convention `Formula/<nom>.rb`, URL figée, SHA-256, test de formule et audit ; expliquer la publication automatique depuis `frame/release` et les mises à jour manuelles des autres formules.
- [ ] Vérifier localement `ruby -c Formula/frame.rb`, `brew audit --strict --formula ./Formula/frame.rb`, puis `brew install --formula ./Formula/frame.rb`, `frame --version`, `brew test ./Formula/frame.rb`. Commit ciblé dans `homebrew-tap`.

### Task 3: Vérification continue et mise à disposition du tap

**Files:** créer `homebrew-tap/.github/workflows/ci.yml` ; compléter `README.md` si les commandes finales diffèrent.

**Interfaces:** chaque PR du tap valide sa formule et ses installations ; les utilisateurs installent la formule depuis le dépôt GitHub public.

- [ ] Ajouter une CI sur PR et push qui exécute `ruby -c`, `brew audit --strict --formula` et `brew install`/`brew test` pour les quatre couples OS/architecture annoncés, sur des runners natifs ou une stratégie équivalente dont les limites sont explicites.
- [ ] Vérifier le workflow par PR ou exécution réelle sur les runners ciblés ; conserver la preuve des quatre résultats. Une validation sur le seul Mac local ne vaut que pour son architecture.
- [ ] Après vérification, publier le tap et rendre `elydelva/homebrew-tap` public ; contrôler depuis un contexte non authentifié `brew install elydelva/tap/frame`, `frame --version` et `brew upgrade` lors de la version suivante. Ne documenter la disponibilité publique qu'après ce contrôle.

### Task 4: Mettre à jour et publier automatiquement la formule

**Files:** modifier `frame/.github/workflows/release-cli.yml` ; configurer les règles GitHub de `homebrew-tap/main` et l'auto-fusion.

**Interfaces:** consomme la release CLI et les quatre SHA-256 de Task 1 ; produit une PR unique de `Formula/frame.rb` par version, fusionnée après réussite des contrôles de Task 3.

- [ ] Installer un GitHub App limité à `homebrew-tap` avec `Contents: write` et `Pull requests: write` ; placer son ID et sa clé privée dans les secrets Actions de `frame`. Son jeton d'installation sert uniquement à pousser une branche de mise à jour et à ouvrir/actualiser la PR du tap ; aucun jeton ne va dans le dépôt ou les logs.
- [ ] Après vérification des assets, générer depuis la formule existante les quatre nouvelles URL et empreintes, pousser une branche déterministe `bot/frame-V` dans le tap, puis créer ou actualiser la PR vers `main`. Une nouvelle tentative du même push doit retrouver la même PR sans dupliquer ni remplacer les assets. Le workflow échoue visiblement si la PR ne peut pas être ouverte.
- [ ] Rendre requis les contrôles CI de Task 3 sur `homebrew-tap/main`, activer `allow_auto_merge`, puis demander l'auto-fusion de cette PR. Vérifier qu'une PR verte fusionne et qu'une PR rouge reste ouverte. Ne pas contourner les règles de branche.
- [ ] Vérifier le parcours complet avec une version CLI inédite : push sur `frame/release` → GitHub Release et quatre assets → PR du tap → CI verte → fusion automatique → `brew update` et `brew upgrade elydelva/tap/frame` depuis une installation existante.

## Auto-revue

Le plan couvre la chaîne push `release` → release immuable → empreintes → PR de formule → contrôles → fusion → mise à jour Homebrew. Une version CLI unique est obligatoire à chaque push de publication ; les pushes sans nouvelle version échouent explicitement. Le point le plus incertain est la disponibilité des runners natifs pour les quatre cibles : le choix final des labels et la preuve d'exécution doivent être arrêtés avant de déclarer ces plateformes prises en charge.
