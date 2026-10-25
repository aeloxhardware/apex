#!/usr/bin/env bash
# Recopie le moteur et l'interface dans apex, à partir de leurs dépôts d'origine.
#
#   integration/sync.sh [référence-moteur] [référence-interface]
#
# Références par défaut : origin/main. Les dépôts sont lus dans des dossiers voisins
# (APEX_ENGINE_DIR, défaut ../apex-engine ; APEX_UI_DIR, défaut ../apex-ui).
# Seuls les fichiers suivis par git sont copiés (git archive), moins les exclusions de
# integration/exclude-*.txt. Les dossiers slicer-engine/ et slicer-ux/ sont effacés puis
# recréés : ne jamais y modifier de fichier à la main (integration/RULES.md, §1).
set -euo pipefail

APEX_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE_DIR="${APEX_ENGINE_DIR:-$APEX_DIR/../apex-engine}"
UI_DIR="${APEX_UI_DIR:-$APEX_DIR/../apex-ui}"
ENGINE_REF="${1:-origin/main}"
UI_REF="${2:-origin/main}"

copy() {  # copy <dépôt source> <référence> <dossier cible> <fichier d'exclusions>
  local src="$1" ref="$2" dest="$APEX_DIR/$3" exclude="$APEX_DIR/integration/$4"
  git -C "$src" rev-parse --verify --quiet "$ref^{commit}" >/dev/null \
    || { echo "Référence introuvable : $ref dans $src" >&2; exit 1; }
  rm -rf "$dest"
  mkdir -p "$dest"
  git -C "$src" archive --format=tar "$ref" \
    | tar -x -C "$dest" --anchored --wildcards \
        --exclude-from=<(grep -v '^\s*\(#\|$\)' "$exclude")
}

copy "$ENGINE_DIR" "$ENGINE_REF" slicer-engine exclude-engine.txt
copy "$UI_DIR" "$UI_REF" slicer-ux exclude-ux.txt

source_entry() {  # source_entry <dépôt source> <référence>
  local src="$1" ref="$2"
  printf '{"repository": "%s", "commit": "%s", "date": "%s"}' \
    "$(git -C "$src" remote get-url origin | sed 's#^https://github.com/##; s#\.git$##')" \
    "$(git -C "$src" rev-parse "$ref^{commit}")" \
    "$(git -C "$src" log -1 --format=%cI "$ref")"
}

{
  echo '{'
  echo "  \"slicer-engine\": $(source_entry "$ENGINE_DIR" "$ENGINE_REF"),"
  echo "  \"slicer-ux\": $(source_entry "$UI_DIR" "$UI_REF")"
  echo '}'
} > "$APEX_DIR/integration/sources.json"

cat "$APEX_DIR/integration/sources.json"
