#!/usr/bin/env bash
set -euo pipefail

TOP=3
FICHIER=""

usage() {
    echo "Usage : bash scripts/analyse.sh <fichier.log> [--top N]" >&2
    echo "Exemple : bash scripts/analyse.sh logs/access.log --top 5" >&2
    exit 1
}

verifier() {
    if [ -z "${MATRICULE:-}" ]; then
        echo "Erreur : la variable MATRICULE n'est pas définie" >&2
        exit 1
    fi
    if [ "$#" -ne 1 ] && [ "$#" -ne 3 ]; then
        usage
    fi
    FICHIER="$1"
    if [ "$#" -eq 3 ]; then
        if [ "$2" != "--top" ] || ! [[ "$3" =~ ^[0-9]+$ ]]; then
            usage
        fi
        TOP="$3"
    fi
    if [ ! -e "$FICHIER" ]; then
        echo "Erreur : fichier introuvable : $FICHIER" >&2
        exit 2
    fi
    if [ ! -s "$FICHIER" ]; then
        echo "Erreur : fichier vide : $FICHIER" >&2
        exit 3
    fi
}

entete() {
    echo "=== Rapport d'analyse ==="
    echo "Date      : $(date '+%F %T')"
    echo "Machine   : $(whoami)@$(hostname)"
    echo "Matricule : $MATRICULE"
    echo "Fichier   : $FICHIER"
    echo "SHA256    : $(sha256sum "$FICHIER" | awk '{print $1}')"
}

familles() {
    echo
    echo "--- Requêtes par famille ---"
    for f in 2 3 4 5; do
        n=$(awk -v f="$f" 'int($9/100)==f' "$FICHIER" | wc -l)
        echo "${f}xx : $n"
    done
}

top_endpoints() {
    echo
    echo "--- Top $TOP endpoints ---"
    awk '{print $7}' "$FICHIER" | sed -E 's/\?.*//' | sort | uniq -c | sort -rn | sed -n "1,${TOP}p"
}

ip_suspecte() {
    echo
    echo "--- IP suspecte (plus de 401 sur /api/auth/login) ---"
    awk '$7=="/api/auth/login" && $9==401 {print $1}' "$FICHIER" | sort | uniq -c | sort -rn | sed -n '1p'
}

temps_moyen() {
    echo
    echo "--- Temps de réponse moyen (statut 200) ---"
    awk '$9==200 {s+=$11+0; n++} END {if (n) printf "%.1f ms\n", s/n}' "$FICHIER"
}

par_heure() {
    echo
    echo "--- Requêtes par heure ---"
    awk '{print substr($4,14,2)}' "$FICHIER" | sort | uniq -c
}

main() {
    verifier "$@"
    mkdir -p rapports
    RAPPORT="rapports/rapport_${MATRICULE}_$(date +%Y%m%d_%H%M).txt"
    {
        entete
        familles
        top_endpoints
        ip_suspecte
        temps_moyen
        par_heure
    } > "$RAPPORT"
    echo "Rapport écrit dans $RAPPORT"
}

main "$@"
