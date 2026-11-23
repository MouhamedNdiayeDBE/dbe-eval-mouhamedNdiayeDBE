# Partie 4 — Git et GitHub pratique

Ce guide récapitule les opérations demandées. Les preuves et sorties doivent provenir de l'exécution effective par l'étudiant.

## G1 — Identité et signatures SSH

```bash
git config --global user.name "Mouhamed Ndiaye"
git config --global user.email "ADRESSE_EMAIL_VERIFIEE_GITHUB"
git config --global init.defaultBranch main
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgSign true
ssh-keygen -lf ~/.ssh/id_ed25519.pub
```

Sur GitHub, enregistrer la clé publique correspondante dans Settings → SSH and GPG keys comme **Authentication key** et **Signing key**. Ne jamais publier la clé privée.

## G2–G3 — Dépôt individuel

Le dépôt personnel est privé, sa branche par défaut est `main`, et le collaborateur `pape1283` a le droit `write`.

La variable de dépôt `MATRICULE` doit être créée dans Settings → Secrets and variables → Actions → Variables. Vérifier sa présence sans afficher sa valeur dans les journaux.

```bash
git status
git remote -v
git branch --show-current
git log --oneline --decorate -10
```

Le sujet demande des commits atomiques distincts pour le code Java, les scripts, la documentation et l'archive. Chaque commit personnel et le tag doivent apparaître Verified sur GitHub.

## G4 — Intégration continue

Le workflow est `.github/workflows/ci.yml`. Il doit compiler avec Java 17, générer 2 000 lignes avec la variable `MATRICULE`, exécuter le script d'analyse et publier le rapport en artefact.

Vérification :

```bash
git ls-files .github/workflows
git diff --check
```

Ouvrir une PR vers `main`, attendre un pipeline vert, puis seulement fusionner.

## G5 — Rebase interactif

À réaliser sans réécrire `main` :

```bash
git switch -c feature/heures
# Ajouter la fonctionnalité en trois commits de travail
git rebase -i main
# Remplacer les commits wip par un commit final clair dans l'éditeur
git switch main
git merge --ff-only feature/heures
```

Le résultat attendu sur `main` est un historique linéaire sans messages `wip`.

## G6 — Stash

```bash
# Modifier README.md sans commiter
git stash push -m "readme en cours"
git stash list
# Conserver la sortie réelle dans docs/git.md
# Effectuer G7
git stash pop
```

## G7 — Correctif et cherry-pick

```bash
git switch -c release/1.0 main~1
git switch main
# Corriger le message d'usage, puis :
git add scripts/analyse.sh
git commit -m "Corrige le message d'usage de analyse.sh (exemple --top 5)"
git switch release/1.0
git cherry-pick -x <SHA_DU_CORRECTIF>
```

Remplacer `<SHA_DU_CORRECTIF>` par le SHA effectivement créé.

## G8 — Annulation publiée

Le changement erroné doit être annulé par un commit de revert, sans reset ni push forcé :

```bash
git revert <SHA_DU_COMMIT_ERRONE>
git push origin main
```

## G9 — Tag et Release

```bash
git tag -s v1.0 -m "Version 1.0"
git push origin v1.0
```

Créer ensuite la Release GitHub `v1.0` à partir du tag et joindre l'archive de rendu.

## G10 — Preuves

```bash
git reflog -n 60 > docs/preuves/reflog.txt
history > docs/preuves/historique_git.txt
git add docs && git commit -S -m "Ajoute les preuves de la partie Git"
git push --all
git push --tags
git rev-parse --short HEAD
```

Recopier le SHA court dans la fiche de contrôle.

## État des preuves observé lors de l'audit

Au 23 novembre 2026, le dépôt contient plusieurs commits et le tag `v1.0`, mais les journaux consultés ne prouvent pas l'exécution complète de G5, G6 et G7. Le tag existe mais GitHub le signalait non vérifié (`no_user`). La PR CI #1 a été fusionnée alors que son exécution était en échec. Compléter les preuves uniquement après avoir exécuté réellement les commandes.
