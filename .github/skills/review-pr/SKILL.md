---
name: review-pr
description: Playbook para revisar un Pull Request. Checklist estructurado de revisión de código en los tres stacks (Angular, Express, CDK), incluyendo coherencia entre capas, calidad, seguridad y tests.
---

# Review PR

Checklist estructurado para revisar un Pull Request en este monorepo.

## Cómo usarlo

Lee los ficheros cambiados, luego pasa por cada sección relevante del checklist. Reporta en formato:
- ✅ OK — cumple
- ⚠️ Sugerencia — mejora opcional
- ❌ Problema — debe corregirse antes de merge

---

## Checklist general (toda PR)

- [ ] El título del PR sigue el formato `type(scope): descripción`.
- [ ] La descripción explica qué cambia y por qué.
- [ ] No hay secretos hardcodeados (API keys, passwords, tokens).
- [ ] No hay `console.log` / `console.error` de debugging (solo logging intencional).
- [ ] No hay código comentado sin justificación.
- [ ] No hay `TODO` de cosas que debían hacerse en este PR.
- [ ] No hay `any` nuevo en TypeScript sin justificación y comentario explicativo.

## Checklist Angular

- [ ] Componentes nuevos tienen spec con tests mínimos.
- [ ] No hay subscripciones sin limpieza (`async pipe` o `takeUntilDestroyed`).
- [ ] No hay lógica de negocio en templates (solo expresiones simples).
- [ ] Los servicios HTTP mapean DTOs a modelos propios.
- [ ] `ChangeDetectionStrategy.OnPush` en componentes presentacionales.
- [ ] Imports de módulos no incluyen módulos enteros innecesarios.
- [ ] Rutas lazy-loaded.

## Checklist Express

- [ ] No hay lógica de negocio en controllers (solo coordinación).
- [ ] No hay acceso directo a DB fuera de repositories.
- [ ] Toda entrada de usuario validada con Zod o class-validator.
- [ ] Los errores usan las clases de error personalizadas.
- [ ] Nuevas rutas tienen test de integración.
- [ ] Nuevos services tienen tests unitarios.
- [ ] DTOs de response definidos en `domain/dtos/`.

## Checklist CDK

- [ ] No hay `RemovalPolicy.DESTROY` en recursos con datos en producción.
- [ ] Secretos referenciados por ARN, no por valor.
- [ ] Permisos IAM usan `grant*` methods o acciones específicas (no `*`).
- [ ] Nuevos recursos tienen tags de entorno.
- [ ] Nuevos stacks tienen tests de assertion mínimos.
- [ ] `cdk diff` revisado y reflejado en la descripción del PR si hay cambios de infra.

## Checklist de coherencia entre capas

- [ ] DTOs de response en Express coinciden con interfaces en Angular.
- [ ] URLs en Angular services coinciden con rutas definidas en Express.
- [ ] Env vars usadas en Express están definidas como output o variable en CDK.
- [ ] Si se añade un recurso CDK nuevo: el backend tiene los permisos IAM para usarlo.
- [ ] Si se cambia un endpoint: el frontend está actualizado en la misma PR (o hay un plan de compatibilidad).

## Checklist de seguridad

- [ ] No hay inyección SQL, XSS o command injection.
- [ ] Toda entrada externa validada en el borde.
- [ ] Los endpoints protegidos tienen middleware de autenticación.
- [ ] Los recursos CDK nuevos no tienen acceso público inadvertido.
- [ ] No se expone información de stack traces en respuestas de producción.

## Formato del informe de revisión

```
## Code Review — PR #[número] — [título]

### Veredicto: [Aprobado / Aprobado con sugerencias / Cambios requeridos]

### Problemas (deben corregirse)
1. [archivo:línea] — [descripción del problema]

### Sugerencias (opcionales)
1. [archivo:línea] — [descripción de la mejora]

### Puntos positivos
- [...]

### Tests
- Cobertura: [suficiente / insuficiente]
- [gaps detectados si los hay]
```
