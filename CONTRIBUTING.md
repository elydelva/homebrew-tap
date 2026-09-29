# Maintenir le catalogue

Chaque outil possède une formule `Formula/<nom>.rb` avec une URL de release
immuable, un SHA-256 et un bloc `test do`. Vérifier une modification avec :

```sh
ruby -c Formula/<nom>.rb
brew tap elydelva/tap "$(pwd)"
brew audit --strict --formula elydelva/tap/<nom>
brew install --formula elydelva/tap/<nom>
brew test elydelva/tap/<nom>
```

Pour `frame`, chaque push sur la branche `release` de
[`elydelva/frame`](https://github.com/elydelva/frame) publie une nouvelle
version et ouvre une PR de mise à jour de `Formula/frame.rb`. Le numéro dans
`apps/cli/package.json` et `apps/cli/src/cli.ts` doit augmenter à chaque push.
Le tag et les archives existants ne sont jamais remplacés. Les contrôles de la
PR doivent réussir avant sa fusion automatique. Une fusion sur `main` rend la
nouvelle formule disponible via `brew update`.

Pour les autres formules, ouvrir une PR qui met à jour la version, les URL et
les SHA-256 ensemble. Le workflow CI vérifie les plateformes déclarées.
