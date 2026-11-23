#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_LOG="${1:-$ROOT_DIR/logs/access.log}"
OUTPUT_LOG="${2:-$ROOT_DIR/logs/surveillance.log}"

if [[ ! -f "$SOURCE_LOG" ]]; then
    printf 'Erreur : journal introuvable : %s\n' "$SOURCE_LOG" >&2
    exit 2
fi

mkdir -p "$(dirname -- "$OUTPUT_LOG")"

arret_propre() {
    printf '[%s] arrêt propre\n' "$(date '+%F %T')" >> "$OUTPUT_LOG"
    exit 0
}

trap arret_propre TERM

while :; do
    nombre_lignes="$(wc -l < "$SOURCE_LOG")"
    printf '[%s] %s lignes dans %s\n' \
        "$(date '+%F %T')" "$nombre_lignes" "$SOURCE_LOG" >> "$OUTPUT_LOG"
    sleep 5
done
