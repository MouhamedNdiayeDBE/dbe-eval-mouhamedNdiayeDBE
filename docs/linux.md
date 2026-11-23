# Partie 2 — Linux pratique

Ce fichier sert de carnet d'exécution. Les résultats doivent être copiés depuis la session réelle ; aucune sortie n'est inventée dans ce document.

## L1 — Environnement et preuves

Depuis le terminal Linux :

```bash
export MATRICULE="VOTRE_MATRICULE"
mkdir -p "$HOME/dbe-eval-${MATRICULE}"/{src,scripts,logs,docs/preuves,rapports,rendus}
cd "$HOME/dbe-eval-${MATRICULE}"
printf '\nexport MATRICULE=%q\nexport HISTTIMEFORMAT="%%F %%T "\n' "$MATRICULE" >> "$HOME/.bashrc"
source "$HOME/.bashrc"
printf 'MATRICULE=%s\n' "$MATRICULE"
script -q --timing=docs/preuves/linux.tm docs/preuves/linux.log
```

Résultat observé à recopier : matricule affiché, chemin du projet et confirmation du démarrage de `script`.

## L2 — Générateur Java

```bash
mkdir -p out logs
javac -encoding UTF-8 -d out src/GenerateurLogs.java
java -cp out GenerateurLogs 2> logs/gen.err
printf 'code retour : %s\n' "$?"
java -cp out GenerateurLogs "$MATRICULE" 2000 > logs/access.log
wc -l logs/access.log
head -n 1 logs/access.log
```

Résultats à recopier : code de retour du lancement sans arguments, nombre réel de lignes et première ligne réelle du journal.

## L3 — Analyse en une commande

Depuis la racine du projet :

1. Codes HTTP par fréquence :
   `awk '{print $9}' logs/access.log | sort | uniq -c | sort -rn`
2. Trois endpoints les plus appelés, sans query string :
   `awk '{print $7}' logs/access.log | sed -E 's/\?.*//' | sort | uniq -c | sort -rn | head -n 3`
3. Nombre d'IP distinctes :
   `awk '{print $1}' logs/access.log | sort -u | wc -l`
4. IP ayant le plus de 401 sur le login :
   `awk '$7=="/api/auth/login" && $9==401 {print $1}' logs/access.log | sort | uniq -c | sort -rn | head -n 1`
5. Moyenne des temps de réponse en 200 :
   `awk '$9==200 {s+=$11+0; n++} END {if(n) printf "%.1f ms\n",s/n}' logs/access.log`
6. Requête la plus lente :
   `awk '{d=$11; sub(/ms$/,"",d); print d "\t" $0}' logs/access.log | sort -nr | cut -f2- | head -n 1`
7. Nombre de requêtes par heure :
   `awk '{print substr($4,14,2)}' logs/access.log | sort | uniq -c`
8. Extraire les 5xx :
   `grep -E ' 5[0-9]{2} ' logs/access.log > logs/erreurs_5xx.log && wc -l logs/erreurs_5xx.log`
9. Anonymiser les IP :
   `sed -E 's/^([0-9]{1,3}\.){3}[0-9]{1,3}/x.x.x.x/' logs/access.log > logs/access_anonyme.log`
10. Journaux modifiés depuis moins de 60 minutes et dépassant 1 Ko :
    `find . -type f -name '*.log' -mmin -60 -size +1k -exec wc -l {} +`

Copier les commandes et leurs sorties réelles ici pendant la séance ; ne pas remplacer les résultats par des valeurs d'exemple.

## L4 — Script d'analyse

Le script attendu est `scripts/analyse.sh`. Contrôles locaux :

```bash
bash -n scripts/analyse.sh
export MATRICULE
bash scripts/analyse.sh logs/access.log --top 3
bash scripts/analyse.sh
echo "code=$?"
bash scripts/analyse.sh logs/absent.log
echo "code=$?"
: > logs/vide.log
bash scripts/analyse.sh logs/vide.log
echo "code=$?"
```

Codes exigés par le sujet : arguments incorrects = 1 ; fichier absent = 2 ; fichier vide = 3. Le rapport doit contenir SHA-256, familles HTTP, top endpoints, IP suspecte, moyenne des 200 et requêtes par heure.

## L5 — Processus et signaux

```bash
bash -n scripts/surveille.sh
nohup bash scripts/surveille.sh > /dev/null 2>&1 &
PID=$!
sleep 1
pgrep -af 'scripts/surveille.sh'
ps -o pid,ppid,stat,etime -p "$PID"
kill -TERM "$PID"
wait "$PID" || true
tail -n 3 logs/surveillance.log
```

La dernière ligne doit contenir `arrêt propre`. Conserver la sortie réelle dans la preuve de session.

## L6 — Clôture

À exécuter dans la session enregistrée avant `exit` :

```bash
history > docs/preuves/historique_linux.txt
exit
tar czf "rendus/linux_${MATRICULE}.tar.gz" src scripts docs rapports
sha256sum "rendus/linux_${MATRICULE}.tar.gz"
```

Noter les 16 premiers caractères de l'empreinte sur la fiche de contrôle. Ne plus modifier l'archive après calcul de son empreinte.
