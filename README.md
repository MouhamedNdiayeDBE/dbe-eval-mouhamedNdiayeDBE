# Évaluation DBE — Linux & Git/GitHub

Dépôt de travail individuel pour l'évaluation Linux et Git/GitHub du Département Informatique de l'ISEP Amadou Trawaré.

## Objectif

Analyser un journal d'accès d'API généré en Java, automatiser le rapport avec Bash, surveiller le journal en arrière-plan, puis versionner et intégrer le travail avec Git et GitHub Actions.

## Prérequis

- Linux, WSL ou une VM Linux
- Java 17 ou supérieur
- Git 2.34 ou supérieur
- Bash, awk, sed, grep, find et coreutils
- Compte GitHub avec clé SSH enregistrée pour l'authentification et la signature

## Structure

- `src/GenerateurLogs.java` : génération déterministe des journaux à partir du matricule
- `scripts/analyse.sh` : analyse et production du rapport
- `scripts/surveille.sh` : surveillance périodique et arrêt propre via SIGTERM
- `docs/linux.md` : carnet d'exécution Linux
- `docs/git.md` : carnet d'exécution Git/GitHub
- `docs/preuves/` : traces de session et historiques
- `rapports/` : rapports d'analyse
- `rendus/` : archives de remise

## Exécution rapide

Depuis la racine du dépôt :

```bash
export MATRICULE="VOTRE_MATRICULE"
mkdir -p out logs rapports rendus
javac -encoding UTF-8 -d out src/GenerateurLogs.java
java -cp out GenerateurLogs "$MATRICULE" 2000 > logs/access.log
bash scripts/analyse.sh logs/access.log --top 3
```

Surveillance :

```bash
nohup bash scripts/surveille.sh >/dev/null 2>&1 &
PID=$!
# Pour arrêter proprement :
kill -TERM "$PID"
```

## Intégration continue

Le workflow `.github/workflows/ci.yml` compile le code avec Java 17, génère le journal, exécute l'analyse et publie le rapport comme artefact. Il utilise la variable de dépôt GitHub Actions `MATRICULE`.

## Auteur

Mouhamed Ndiaye — étudiant, Département Informatique, ISEP Amadou Trawaré.

Les fichiers de preuve et les résultats chiffrés doivent correspondre à des exécutions réelles de l'évaluation. Aucune donnée de preuve ne doit être fabriquée.
