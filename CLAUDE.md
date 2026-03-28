# CLAUDE.md — pocAgentesSubAgentesSDD

## Arquitectura del repositorio

Monorepo con tres stacks:
- `apps/angular-app/` — frontend Angular
- `services/express-api/` — backend Express/Node
- `infra/cdk/` — infraestructura AWS CDK

## Procesado de tareas

Siempre que recibas cualquier tipo de tarea, busca si hace matching con alguno de los subagentes definidos en `.claude/agents/` y si es así, delega la tarea a ese subagente.

Para tareas que afecten a múltiples stacks, usa **app-orchestrator** para coordinar.

## Reglas transversales obligatorias

**Contratos API:**
- Toda feature que toque la API (Express) exige revisar el contrato con el frontend (Angular).
- Ningún cambio de schema/DTO se hace sin actualizar ambos lados.

**Infraestructura:**
- Todo cambio en `infra/cdk/` debe indicar impacto en cada entorno (dev/staging/prod).
- No modificar recursos críticos (RDS, IAM roles de producción, VPCs) sin plan de rollback explícito.
- Los cambios destructivos en CDK requieren aprobación manual antes de ejecutar `cdk deploy`.

**Migraciones:**
- Las migraciones de base de datos son irreversibles por defecto; documentar rollback siempre.
- No ejecutar migraciones automáticamente en producción.

**Testing mínimo antes de PR:**
- Frontend: tests unitarios de componentes nuevos o modificados.
- Backend: tests unitarios de servicios y tests de integración de rutas nuevas.
- Infra: `cdk diff` revisado y documentado.

**Seguridad:**
- No hardcodear secretos, API keys ni credenciales en ningún archivo.
- Todo acceso IAM sigue principio de mínimo privilegio.
- Validar y sanitizar toda entrada en el borde del sistema (Express middlewares).

**Convenciones de PR:**
- Título: `type(scope): descripción` — tipos: feat, fix, refactor, test, infra, docs.
- Descripción incluye: qué cambia, por qué, impacto en otros stacks si aplica.
- PRs que tocan API o infra requieren revisión de integration-reviewer.

**Naming:**
- Angular: componentes en PascalCase, archivos en kebab-case.
- Express: rutas en kebab-case, servicios/controllers en camelCase.
- CDK: stacks en PascalCase con sufijo `Stack`, constructs en PascalCase.
