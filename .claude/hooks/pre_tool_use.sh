#!/usr/bin/env bash
# pre_tool_use.sh — Se ejecuta ANTES de cada llamada a herramienta.
# Recibe JSON con la información del tool por stdin.
# Salir con código no-cero BLOQUEA la acción.
# Salir con código 0 PERMITE la acción.
#
# Contexto disponible:
#   stdin: JSON con { tool_name, tool_input, session_id, ... }

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")

# ─────────────────────────────────────────────
# REGLA 1: Bloquear comandos destructivos en Bash
# ─────────────────────────────────────────────
if [ "$TOOL_NAME" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

  # Bloquear rm -rf sin /tmp o node_modules
  if echo "$COMMAND" | grep -qE 'rm\s+-rf?\s+/' && ! echo "$COMMAND" | grep -qE '(node_modules|\.next|dist|build|tmp|temp)'; then
    echo "⛔ BLOQUEADO: 'rm -rf' sobre una ruta raíz detectado. Confirma manualmente si es intencional." >&2
    exit 1
  fi

  # Bloquear git push --force a main/master
  if echo "$COMMAND" | grep -qE 'git push.*(--force|-f).*(main|master)'; then
    echo "⛔ BLOQUEADO: force push a main/master no permitido." >&2
    exit 1
  fi

  # Bloquear git reset --hard sin confirmación explícita
  if echo "$COMMAND" | grep -qE 'git reset --hard'; then
    echo "⚠️  ADVERTENCIA: 'git reset --hard' puede perder cambios. Si es intencional, inclúyela como confirmación explícita en tu mensaje." >&2
    # Solo advertir, no bloquear
  fi

  # Bloquear cdk deploy en producción sin marca explícita
  if echo "$COMMAND" | grep -qE 'cdk deploy' && echo "$COMMAND" | grep -qiE '(prod|production)'; then
    echo "⛔ BLOQUEADO: 'cdk deploy' en producción requiere confirmación explícita del usuario." >&2
    echo "   Ejecuta 'cdk diff' primero y pide al usuario que apruebe explícitamente el deploy." >&2
    exit 1
  fi

  # Advertir sobre migraciones
  if echo "$COMMAND" | grep -qiE '(migrate|migration|db:push|prisma migrate|knex migrate|sequelize db:migrate)'; then
    echo "⚠️  ADVERTENCIA: comando de migración detectado." >&2
    echo "   Asegúrate de que el plan de rollback está documentado antes de continuar." >&2
    # Solo advertir, no bloquear
  fi
fi

# ─────────────────────────────────────────────
# REGLA 2: Detectar posibles secretos en Write/Edit
# ─────────────────────────────────────────────
if [ "$TOOL_NAME" = "Write" ] || [ "$TOOL_NAME" = "Edit" ]; then
  CONTENT=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
inp = d.get('tool_input', {})
print(inp.get('content', '') + ' ' + inp.get('new_string', ''))
" 2>/dev/null || echo "")

  # Patrones comunes de secretos hardcodeados
  if echo "$CONTENT" | grep -qiE '(password|secret|api_key|apikey|token|private_key)\s*[=:]\s*["\x27][A-Za-z0-9+/]{16,}'; then
    echo "⚠️  ADVERTENCIA: posible secreto hardcodeado detectado en el contenido a escribir." >&2
    echo "   Usa variables de entorno o AWS Secrets Manager en su lugar." >&2
    # Solo advertir, no bloquear (puede ser un falso positivo en tests)
  fi
fi

exit 0
