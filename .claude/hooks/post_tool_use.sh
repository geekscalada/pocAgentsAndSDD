#!/usr/bin/env bash
# post_tool_use.sh — Se ejecuta DESPUÉS de cada llamada a herramienta.
# Recibe JSON con la información del tool y su resultado por stdin.
# La salida de este script es informativa; el código de salida no bloquea nada.
#
# Contexto disponible:
#   stdin: JSON con { tool_name, tool_input, tool_response, session_id, ... }

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")

# Solo actuar en Write, Edit, Bash
if [ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

# Obtener ruta del fichero afectado
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
inp = d.get('tool_input', {})
print(inp.get('file_path', inp.get('notebook_path', '')))
" 2>/dev/null || echo "")

# ─────────────────────────────────────────────
# Determinar área y sugerir comandos de validación
# ─────────────────────────────────────────────

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

suggest_validation() {
  local area="$1"
  local cmd="$2"
  local hint="$3"
  echo "💡 [post-edit] Área: ${area} — Recomendado: ${hint}" >&2
  echo "   Comando: ${cmd}" >&2
}

if [ -n "$FILE_PATH" ]; then
  case "$FILE_PATH" in
    *apps/angular-app/*)
      if echo "$FILE_PATH" | grep -qE '\.ts$'; then
        suggest_validation "Angular" \
          "cd ${REPO_ROOT}/apps/angular-app && npx ng lint --fix && npx tsc --noEmit" \
          "ng lint + typecheck"
      fi
      if echo "$FILE_PATH" | grep -qE '\.spec\.ts$'; then
        suggest_validation "Angular Tests" \
          "cd ${REPO_ROOT}/apps/angular-app && npx ng test --watch=false --browsers=ChromeHeadless" \
          "ng test"
      fi
      ;;
    *services/express-api/*)
      if echo "$FILE_PATH" | grep -qE '\.ts$'; then
        suggest_validation "Express" \
          "cd ${REPO_ROOT}/services/express-api && npx tsc --noEmit && npm run lint" \
          "typecheck + lint"
      fi
      if echo "$FILE_PATH" | grep -qE '(\.spec\.ts|\.test\.ts)$'; then
        suggest_validation "Express Tests" \
          "cd ${REPO_ROOT}/services/express-api && npm test" \
          "npm test"
      fi
      ;;
    *infra/cdk/*)
      if echo "$FILE_PATH" | grep -qE '\.ts$'; then
        suggest_validation "CDK" \
          "cd ${REPO_ROOT}/infra/cdk && npx tsc --noEmit && npm run lint" \
          "typecheck + lint"
      fi
      if echo "$FILE_PATH" | grep -qE '(\.spec\.ts|\.test\.ts)$'; then
        suggest_validation "CDK Tests" \
          "cd ${REPO_ROOT}/infra/cdk && npm test" \
          "npm test"
      fi
      # Si se editó un stack, recordar cdk diff
      if echo "$FILE_PATH" | grep -qE 'lib/stacks/'; then
        echo "💡 [post-edit] CDK Stack modificado — ejecuta 'cdk diff' antes de hacer deploy." >&2
      fi
      ;;
  esac
fi

# ─────────────────────────────────────────────
# Si se editó un fichero de DTOs/contratos, sugerir integration-reviewer
# ─────────────────────────────────────────────
if echo "$FILE_PATH" | grep -qiE '(dto|schema|contract|interface)'; then
  echo "💡 [post-edit] Se detectó cambio en DTO/contrato." >&2
  echo "   Considera invocar el agente 'integration-reviewer' para verificar coherencia." >&2
fi

exit 0
