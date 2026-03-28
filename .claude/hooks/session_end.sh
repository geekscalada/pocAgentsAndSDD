#!/usr/bin/env bash
# session_end.sh — Se ejecuta al FINALIZAR la sesión de Claude Code (evento Stop).
# Genera un resumen de cambios y checklist pre-PR.
#
# Contexto disponible:
#   stdin: JSON con { session_id, transcript_path, ... }

set -euo pipefail

INPUT=$(cat)

TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('transcript_path', ''))
" 2>/dev/null || echo "")

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "" >&2
echo "═══════════════════════════════════════════════════════════" >&2
echo "  RESUMEN DE SESIÓN — pocAgentesSubAgentesSDD" >&2
echo "═══════════════════════════════════════════════════════════" >&2
echo "" >&2

# ─────────────────────────────────────────────
# Ficheros modificados en la sesión (git status)
# ─────────────────────────────────────────────
echo "📁 FICHEROS MODIFICADOS:" >&2
if git -C "$REPO_ROOT" status --short 2>/dev/null | head -30; then
  :
else
  echo "  (no se pudo obtener git status)" >&2
fi
echo "" >&2

# ─────────────────────────────────────────────
# Áreas tocadas
# ─────────────────────────────────────────────
CHANGED_FILES=$(git -C "$REPO_ROOT" status --short 2>/dev/null | awk '{print $2}' || echo "")

TOUCHED_ANGULAR=false
TOUCHED_EXPRESS=false
TOUCHED_CDK=false
TOUCHED_CONTRACTS=false

if echo "$CHANGED_FILES" | grep -q "apps/angular-app"; then TOUCHED_ANGULAR=true; fi
if echo "$CHANGED_FILES" | grep -q "services/express-api"; then TOUCHED_EXPRESS=true; fi
if echo "$CHANGED_FILES" | grep -q "infra/cdk"; then TOUCHED_CDK=true; fi
if echo "$CHANGED_FILES" | grep -qiE "(dto|schema|contract)"; then TOUCHED_CONTRACTS=true; fi

echo "🏗️  STACKS AFECTADOS:" >&2
$TOUCHED_ANGULAR && echo "  ✔ Angular (apps/angular-app/)" >&2
$TOUCHED_EXPRESS && echo "  ✔ Express (services/express-api/)" >&2
$TOUCHED_CDK    && echo "  ✔ CDK (infra/cdk/)" >&2
if ! $TOUCHED_ANGULAR && ! $TOUCHED_EXPRESS && ! $TOUCHED_CDK; then
  echo "  (ninguno de los stacks principales)" >&2
fi
echo "" >&2

# ─────────────────────────────────────────────
# Checklist pre-PR
# ─────────────────────────────────────────────
echo "✅ CHECKLIST PRE-PR:" >&2

if $TOUCHED_ANGULAR; then
  echo "  Angular:" >&2
  echo "  [ ] ng lint pasa sin errores" >&2
  echo "  [ ] ng build --configuration production sin errores" >&2
  echo "  [ ] Tests unitarios de componentes/servicios afectados pasan" >&2
fi

if $TOUCHED_EXPRESS; then
  echo "  Express:" >&2
  echo "  [ ] tsc --noEmit sin errores" >&2
  echo "  [ ] npm run lint pasa" >&2
  echo "  [ ] Tests unitarios e integración del área afectada pasan" >&2
fi

if $TOUCHED_CDK; then
  echo "  CDK:" >&2
  echo "  [ ] tsc --noEmit sin errores" >&2
  echo "  [ ] npm test (CDK assertion tests) pasa" >&2
  echo "  [ ] cdk diff revisado antes de hacer deploy" >&2
  echo "  [ ] Plan de rollback documentado si hay recursos con estado" >&2
fi

if $TOUCHED_CONTRACTS; then
  echo "  Contratos de API:" >&2
  echo "  [ ] integration-reviewer verificó coherencia entre capas" >&2
  echo "  [ ] Cambio documentado en PR (breaking o non-breaking)" >&2
fi

echo "" >&2
echo "  General:" >&2
echo "  [ ] No hay secretos hardcodeados" >&2
echo "  [ ] No hay console.log de debugging" >&2
echo "  [ ] Título del PR sigue formato: type(scope): descripción" >&2
echo "  [ ] Tests nuevos escritos para funcionalidad nueva o bugs corregidos" >&2
echo "" >&2

# ─────────────────────────────────────────────
# Riesgos potenciales
# ─────────────────────────────────────────────
echo "⚠️  RIESGOS A VERIFICAR:" >&2

if $TOUCHED_CDK && $TOUCHED_EXPRESS; then
  echo "  → Cambio coordinado CDK + Express: verificar orden de deploy (CDK primero si hay recursos nuevos)" >&2
fi

if $TOUCHED_ANGULAR && $TOUCHED_EXPRESS; then
  echo "  → Cambio coordinado Angular + Express: verificar coherencia de contratos de API" >&2
fi

if $TOUCHED_CDK; then
  echo "  → Revisar RemovalPolicy en recursos con datos antes de deploy a producción" >&2
fi

echo "" >&2
echo "═══════════════════════════════════════════════════════════" >&2

exit 0
