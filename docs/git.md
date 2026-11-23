# Partie 4 — Git/GitHub pratique individuelle (25 points)

Cette partie note les opérations Git réelles et leur historique, pas uniquement l'état final des fichiers. Dépôt : MouhamedNdiayeDBE/dbe-eval-mouhamedNdiayeDBE.

## G1 — Configuration et signature (2 pts)

À exécuter sur le poste personnel :

~~~bash
git config --global user.name "Mouhamed Ndiaye"
git config --global user.email "EMAIL_VERIFIE_DANS_GITHUB"
git config --global init.defaultBranch main
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgSign true
ssh-keygen -lf ~/.ssh/id_ed25519.pub
~~~

Sur GitHub, dans Settings → SSH and GPG keys, la clé publique exacte doit être ajoutée comme Authentication key et Signing key. Ne jamais copier la clé privée dans le dépôt.

**État observé :** plusieurs commits personnels et le tag v1.0 portent une signature SSH, mais GitHub répond verified=false, raison no_user. Les commits initiaux dc4821e, 4d4cc05, c76632b et 4ba3b52 sont non signés. Les signatures web-flow sont vérifiées. La configuration de signature n'est donc pas validée sur le compte GitHub.

## G2 — Initialiser le dépôt (2 pts)

Le dépôt distant est privé, main est la branche par défaut et .gitignore contient :

~~~gitignore
out/
*.class
logs/
~~~

Les commits initiaux visibles comprennent le code Java (dc4821e), les scripts (4d4cc05), la documentation (c76632b) et les preuves/compléments (4ba3b52). L'archive de rendu n'était pas dans ce dernier commit lors de l'audit initial ; une archive de validation a été ajoutée dans la branche de correction.

Vérifications locales :

~~~bash
git status --short
git log --oneline --decorate --all
git check-ignore out/GenerateurLogs.class logs/access.log
~~~

## G3 — Publier (2 pts)

**État vérifié :** dépôt privé ; branche par défaut main ; collaborateur pape1283 avec permission write.

La variable de dépôt MATRICULE doit être vérifiée dans Settings → Secrets and variables → Actions → Variables. Le connecteur ne donne pas accès à la liste des variables Actions ; la valeur utilisée dans docs/preuves/.bashrc est mouhamedNdiayeDBE. Ne pas transformer cette variable en secret si le workflow utilise vars.MATRICULE.

## G4 — Intégration continue (4 pts)

Le workflow actif est .github/workflows/ci.yml. Il se trouve au bon emplacement. Le doublon dans .github/workflow/ci.yml a été supprimé dans la PR #2. Le run 45204763558 (tentative 2) a passé toutes les étapes et publié l'artefact rapport-analyse.

La PR #1, la PR #2 et la PR #3 sont fusionnées dans main. La PR #2 a été intégrée par 84512b4 et la PR #3 par 7c3fbce. Le premier run de main après la PR #3, 45204763558, n'a pas obtenu de runner (runner_id=0). La tentative 2 du même run a ensuite réussi le 23 novembre 2026 : runner_id=1000002832, 10 étapes exécutées, toutes avec conclusion success. Le job a vérifié la variable MATRICULE, Bash, Java 17, 2 000 lignes, le rapport, le rejet de --top 0, l'arrêt SIGTERM et l'upload de l'artefact. G4 est donc validé par ce run vert.

Sur le poste, vérifier que Actions est activé et que la variable MATRICULE est définie. Puis ouvrir la PR vers main, attendre un pipeline vert et seulement ensuite fusionner. Le rapport d'artefact doit correspondre au rapport local.

## G5 — Fonctionnalité, réécriture d'historique et rebase (5 pts)

La fonction par_heure est présente dans scripts/analyse.sh et le commit cb9c6b3 l'a ajoutée. Cependant, l'historique actuel contient wip 1 (9b71b7a) et wip 2 (bef5ad7) directement dans l'ascendance de main. L'audit n'a pas trouvé de branche feature/heures ni de preuve d'un git rebase -i main. Le résultat fonctionnel est présent, mais la procédure n'est pas démontrée et main conserve les messages WIP.

La procédure correcte, à réaliser avant intégration :

~~~bash
git switch main
git pull --ff-only origin main
git switch -c feature/heures
# Modifier analyse.sh en trois étapes et créer les commits demandés.
git add scripts/analyse.sh && git commit -S -m "wip 1"
# Deuxième modification :
git add scripts/analyse.sh && git commit -S -m "wip 2"
# Troisième modification :
git add scripts/analyse.sh && git commit -S -m "wip 3"
git rebase -i main
# Garder le premier commit en pick, passer les deux suivants en squash.
# Message final : Ajoute le regroupement des requêtes par heure.
git switch main
git merge --ff-only feature/heures
git log --oneline --decorate -10
~~~

Le README demandé par le sujet est maintenant présent sur main sous README.md depuis le merge de la PR #2. Ne pas faire de push --force sur main. Les WIP déjà publiés sur main ne sont pas supprimés dans cette correction afin de préserver l'historique distant. Le résultat de G5 reste donc incomplet : la procédure de rebase interactif et l'historique final sans WIP ne sont pas démontrés.

## G6 — Mettre un travail de côté (2 pts)

L'audit de docs/preuves/git.log n'a pas retrouvé git stash push, git stash list ni git stash pop. Exécuter la séquence dans le dépôt local et coller la vraie sortie dans docs/git.md :

~~~bash
# Modifier README.md sans commiter.
git stash push -m "readme en cours"
git stash list
# Effectuer G7.
git stash pop
git status --short
~~~

Ne pas inventer une sortie de stash : elle dépend du contenu réel du worktree.

## G7 — Correctif et cherry-pick (2 pts)

Le commit de correction du message d'usage existe sur main : fce7935 (exemple --top 5). La branche distante release/1.0 a été créée à partir de cb9c6b3, parent de fce7935. Elle pointe sur 37bc3f5, commit dont l'arbre correspond au correctif et dont le message contient le trailer (cherry picked from commit fce7935...). Ce commit équivalent a été construit via l'API GitHub, pas par l'exécution de la commande dans le terminal WSL ; la preuve interactive de git cherry-pick -x reste donc à réaliser localement.

Pour contrôler le résultat distant :

~~~bash
git fetch origin
git switch -c release/1.0 --track origin/release/1.0
git show -1 --format=fuller
~~~

Le trailer de cherry-pick est présent dans le message du commit. La procédure de commande demandée par le sujet doit encore être enregistrée dans la session personnelle si l'enseignant exige la preuve de l'exécution de git cherry-pick -x.

## G8 — Annuler un commit publié (2 pts)

Cette étape est démontrée : le commit 7b26e58 (Change le top par défaut) a été annulé par e38f3f8 (Revert "Change le top par défaut"). Le revert conserve l'historique et rétablit le top par défaut à 3. Les deux commits sont visibles sur main.

## G9 — Version signée (2 pts)

Le tag signé v1.0 existe. Son objet contient une signature SSH, mais GitHub indique verified=false, raison no_user. Enregistrer la clé publique comme Signing key sur GitHub, puis revérifier le tag :

~~~bash
git tag -v v1.0
git push origin v1.0
~~~

Créer ensuite sur GitHub une Release v1.0 à partir de ce tag et joindre rendus/linux_${MATRICULE}.tar.gz. La création de la Release avec pièce jointe n'est pas disponible via la connexion GitHub utilisée pour cette correction ; elle reste à effectuer dans l'interface GitHub.

## G10 — Preuves (2 pts)

Les enregistrements docs/preuves/git.log et git.tm existent, mais reflog.txt et historique_git.txt ne sont pas présents. Les reflogs sont locaux et ne sont pas disponibles à travers le dépôt distant. Sur le PC, à la fin de la session enregistrée :

~~~bash
git reflog -n 60 > docs/preuves/reflog.txt
history > docs/preuves/historique_git.txt
exit
git add docs && git commit -S -m "Ajoute les preuves de la partie Git"
git push --all
git push --tags
git rev-parse --short HEAD
~~~

Recopier le SHA court sur la fiche de contrôle. Ne jamais fabriquer reflog.txt à partir de git log : ce ne sont pas les mêmes informations.

## État au 23 novembre 2026 — après le run CI vert

| Exigence | État vérifié |
|---|---|
| Dépôt privé, main, collaborateur pape1283 | OK |
| .gitignore, code Java, scripts | OK |
| README complet et documentation | présents sur main après les PR #2 et #3 |
| Workflow CI au bon emplacement | validé : run 45204763558, tentative 2, 10 étapes sur 10 réussies |
| par_heure dans le rapport | OK |
| Rebase interactif des 3 WIP sur feature/heures | non démontré ; deux WIP déjà sur main |
| Stash / stash pop | non démontré |
| Branche release/1.0 et commit avec trailer cherry-pick | résultat distant présent (37bc3f5), commande locale non démontrée |
| Revert de G8 | OK |
| Tag signé v1.0 | présent, signature non vérifiée par GitHub (no_user) |
| Release GitHub avec archive | absente ; création manuelle restante |
| Reflog et historique Bash exportés | absents |

La branche de correction ne réécrit pas main et ne prétend pas effectuer les opérations qui exigent le shell personnel, la clé SSH privée ou les droits de création de Release de l'étudiant.
