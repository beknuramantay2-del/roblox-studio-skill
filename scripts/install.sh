#!/usr/bin/env bash
# Ставит скилл roblox-studio во все поддерживаемые клиенты через симлинки.
# Использование:
#   bash scripts/install.sh          # глобально (для всех проектов)
#   bash scripts/install.sh --local  # только в текущую рабочую папку
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_SRC="$REPO_ROOT/skills/roblox-studio"

if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo "error: не нашёл $SKILL_SRC/SKILL.md" >&2
  exit 1
fi

if [ "${1:-}" = "--local" ]; then
  TARGETS=(
    "$PWD/.claude/skills"
    "$PWD/.opencode/skills"
    "$PWD/.agents/skills"
  )
else
  TARGETS=(
    "$HOME/.claude/skills"
    "$HOME/.config/opencode/skills"
    "$HOME/.agents/skills"
  )
fi

for dir in "${TARGETS[@]}"; do
  mkdir -p "$dir"
  link="$dir/roblox-studio"
  rm -rf "$link"
  ln -s "$SKILL_SRC" "$link"
  echo "installed -> $link"
done

echo
echo "Готово. Перезапусти клиента, чтобы он увидел новый скилл."
