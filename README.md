# Homebrew tap

Catalogue Homebrew des outils d'elydelva.

| Formule | Outil |
| --- | --- |
| `frame` | [CLI de gestion de projets Git](https://github.com/elydelva/frame) |

## Installer Frame

```sh
brew install elydelva/tap/frame
frame --version
```

Pour recevoir les nouvelles versions publiées dans le tap :

```sh
brew update
brew upgrade elydelva/tap/frame
```

Les archives autonomes couvrent macOS et Linux sur arm64 et x86_64. La formule
référence une release GitHub précise et contrôle chaque archive par SHA-256.

Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour ajouter une formule ou modifier
`frame`.
