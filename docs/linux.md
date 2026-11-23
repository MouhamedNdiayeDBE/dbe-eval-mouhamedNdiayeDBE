# Partie 2 — Linux pratique (25 points)

Les commandes suivent le sujet de l'ISEP. Les résultats de la reproduction technique sont consignés dans docs/preuves/validation_L3.txt, validation_L4.txt, validation_L5.txt et validation-linux.txt.

> Important sur les preuves : les fichiers validation_* sont issus d'une reproduction dans un environnement Linux isolé à partir du générateur et du matricule déjà inscrit dans docs/preuves/.bashrc. Ils vérifient réellement le code, mais ne remplacent pas la session interactive WSL de l'étudiant ni son historique Bash. Les traces personnelles originales doivent être conservées lors de la récupération de cette branche.

## L1 — Environnement et preuves (2 pts)

Le matricule présent dans la configuration consignée est mouhamedNdiayeDBE. Le snapshot docs/preuves/.bashrc contient une affectation sans export. Pour que bash scripts/analyse.sh reçoive la variable, corriger le vrai ~/.bashrc :

~~~bash
export MATRICULE="mouhamedNdiayeDBE"
export HISTTIMEFORMAT="%F %T "
source ~/.bashrc
printf 'MATRICULE=%s\n' "$MATRICULE"
~~~

Création demandée en une seule commande et démarrage de l'enregistrement (depuis le terminal WSL personnel) :

~~~bash
mkdir -p "$HOME/dbe-eval-${MATRICULE}"/{src,scripts,logs,docs/preuves,rapports,rendus} && cd "$HOME/dbe-eval-${MATRICULE}"
script -q --timing=docs/preuves/linux.tm docs/preuves/linux.log
~~~

Dans cette session personnelle, exécuter L2 à L6 puis terminer avec exit.

## L2 — Générer vos données (2 pts)

Le fichier du sujet est présent dans src/GenerateurLogs.java.

~~~bash
mkdir -p out logs
javac -encoding UTF-8 -d out src/*.java
java -cp out GenerateurLogs 2> logs/gen.err
echo "code=$?"
java -cp out GenerateurLogs "$MATRICULE" 2000 > logs/access.log
wc -l logs/access.log
head -n 1 logs/access.log
~~~

Résultats de la reproduction : compilation OK ; lancement sans arguments code=1 ; génération 2000 lignes. Première ligne pour le matricule consigné :

~~~text
10.0.0.11 - - [23/Nov/2026:08:00:02 +0000] "GET /api/etudiants/104 HTTP/1.1" 200 787 28ms
~~~

La sortie complète et l'empreinte du journal sont consignées dans docs/preuves/validation-linux.txt.

## L3 — Analyser le journal en une ligne de commande (10 pts)

Une commande par question, tubes autorisés.

**a.** Nombre de requêtes par code HTTP, du plus fréquent au moins fréquent :

~~~bash
awk '{print $9}' logs/access.log | sort | uniq -c | sort -rn
~~~

Résultat : 200=1632, 401=169, 201=101, 404=43, 400=26, 500=15, 503=14.

**b.** Top 3 des endpoints sans ?page=... :

~~~bash
awk '{print $7}' logs/access.log | sed -E 's/\?.*//' | sort | uniq -c | sort -rn | sed -n '1,3p'
~~~

Résultat : /api/auth/login 362, /api/cours 292, /api/etudiants 284.

**c.** Nombre d'adresses IP distinctes :

~~~bash
awk '{print $1}' logs/access.log | sort -u | wc -l
~~~

Résultat : 61.

**d.** IP qui a le plus d'échecs 401 sur /api/auth/login, avec son nombre d'échecs :

~~~bash
awk '$7=="/api/auth/login" && $9==401 {print $1}' logs/access.log | sort | uniq -c | sort -rn | sed -n '1p'
~~~

Résultat : 113 197.149.97.9.

**e.** Temps de réponse moyen des requêtes 200, avec une décimale :

~~~bash
awk '$9==200 {s+=$11+0; n++} END {if(n) printf "%.1f ms\n",s/n}' logs/access.log
~~~

Résultat : 161.9 ms.

**f.** Ligne complète de la requête la plus lente :

~~~bash
awk '{d=$11; sub(/ms$/,"",d); print d "\t" $0}' logs/access.log | sort -nr | cut -f2- | sed -n '1p'
~~~

Résultat : requête /api/paiements, temps 2940ms (ligne complète dans validation_L3.txt).

**g.** Nombre de requêtes par heure :

~~~bash
awk '{print substr($4,14,2)}' logs/access.log | sort | uniq -c
~~~

Résultat : 08=564, 09=574, 10=550, 11=312.

**h.** Copier les erreurs 5xx, puis afficher leur nombre :

~~~bash
grep -E 'HTTP/1\.1" 5[0-9]{2} ' logs/access.log > logs/erreurs_5xx.log; wc -l logs/erreurs_5xx.log
~~~

Résultat : 29 logs/erreurs_5xx.log. Le motif inclut HTTP/1.1" afin de ne pas confondre le code HTTP avec le nombre d'octets.

**i.** Copie anonymisée où chaque IP est remplacée :

~~~bash
sed -E 's/^([0-9]{1,3}\.){3}[0-9]{1,3}/x.x.x.x/' logs/access.log > logs/access_anonyme.log
~~~

La première ligne commence bien par x.x.x.x.

**j.** Fichiers .log modifiés il y a moins de 60 minutes et de plus de 1 Ko, avec leur nombre de lignes :

~~~bash
find . -type f -name '*.log' -mmin -60 -size +1k -exec wc -l {} +
~~~

Résultat : 2000 access.log, 29 erreurs_5xx.log, 2000 access_anonyme.log, soit 4029 total. Les dix sorties complètes sont dans docs/preuves/validation_L3.txt.

## L4 — Script d'analyse scripts/analyse.sh (7 pts)

Le script commence par set -euo pipefail, comporte au moins trois fonctions et accepte bash scripts/analyse.sh <fichier.log> [--top N], avec top par défaut égal à 3. Il refuse MATRICULE non défini et génère rapports/rapport_<matricule>_<AAAAMMJJ_HHMM>.txt. Le rapport contient la date, utilisateur@machine, matricule, SHA-256, familles 2xx/3xx/4xx/5xx calculées dans une boucle, top endpoints, IP suspecte et moyenne des 200. Il contient aussi les requêtes par heure pour G5.

Tests exécutés :

~~~bash
bash -n scripts/analyse.sh
bash scripts/analyse.sh logs/access.log --top 3
echo "code=$?"
bash scripts/analyse.sh
echo "code=$?"
bash scripts/analyse.sh logs/absent.log
echo "code=$?"
: > logs/vide.log
bash scripts/analyse.sh logs/vide.log
echo "code=$?"
~~~

Résultats : syntaxe 0 ; cas correct 0 ; sans argument 1 ; fichier absent 2 ; fichier vide 3. Contrôles complémentaires : MATRICULE absent retourne 1 ; --top 5 fonctionne ; --top 0, une valeur non numérique ou une option inconnue sont refusés avec le code 1. Voir docs/preuves/validation_L4.txt.

## L5 — Processus et signaux (3 pts)

scripts/surveille.sh écrit toutes les cinq secondes l'heure et le nombre de lignes dans logs/surveillance.log. Le trap SIGTERM arrête également le processus sleep enfant puis ajoute arrêt propre avant de terminer.

~~~bash
nohup bash scripts/surveille.sh >/dev/null 2>&1 &
PID=$!
pgrep -af '^bash scripts/surveille.sh'
ps -o pid,ppid,stat,etime -p "$PID"
kill -TERM "$PID"
wait "$PID" || true
tail -n 3 logs/surveillance.log
~~~

Dans le test isolé, le processus a été trouvé (PID 1032), ps a affiché PID/PPID/état/durée et le journal a terminé par arrêt propre. Sortie détaillée dans docs/preuves/validation_L5.txt. Rejouer localement pour obtenir le PID et la preuve de la machine personnelle.

## L6 — Clôture et empreinte (1 pt)

Dans la session script personnelle, avant exit :

~~~bash
history > docs/preuves/historique_linux.txt
exit
tar czf "rendus/linux_${MATRICULE}.tar.gz" src scripts docs rapports
sha256sum "rendus/linux_${MATRICULE}.tar.gz"
~~~

L'archive de validation rendus/linux_mouhamedNdiayeDBE.tar.gz est créée et vérifiée. Elle ne contient pas encore les traces personnelles originales linux.log/linux.tm, git.log/git.tm ni historique_linux.txt : voir docs/preuves/ARCHIVE_ETAT.md. Ne pas utiliser son SHA-256 comme empreinte définitive de la remise ; régénérer l'archive après la vraie session WSL.
