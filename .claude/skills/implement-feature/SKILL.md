---
name: implement-feature
description: Playbook para implementar una feature nueva. Guía el proceso de análisis, diseño, implementación y verificación de una nueva funcionalidad, coordinando los stacks afectados.
triggers:
  - /implement-feature
---

# Implement Feature

Sigue estos pasos para implementar una feature nueva de forma ordenada y sin sorpresas.

## 1. Análisis antes de escribir código

- **Leer** los archivos relacionados antes de modificar nada.
- **Identificar stacks afectados**: ¿solo Angular? ¿Angular + Express? ¿necesita infra CDK?
- **Detectar contratos existentes**: ¿hay DTOs, endpoints o interfaces que ya existen y se reutilizan?
- **Preguntar si hay ambigüedad**: no asumir requisitos; pedir aclaración al usuario si algo no está claro.

## 2. Diseño del contrato (si afecta a API)

Antes de implementar, documentar el contrato:
```
Endpoint: POST /api/products
Request body: { name: string, price: number, categoryId: string }
Response 201: { id: string, name: string, price: number, ... }
Response 400: { errors: { field: string[] } }
Response 409: { message: string, code: 'CONFLICT' }
```
Mostrar el contrato al usuario antes de continuar si el cambio es relevante.

## 3. Orden de implementación

Si afecta a múltiples stacks, implementar en este orden:

1. **Backend primero** (contrato → service → controller → route → tests).
2. **Frontend después** (modelo → servicio HTTP → componente → tests).
3. **Infra si hace falta** (antes del backend si requiere nuevos recursos).

Si es solo frontend con mocks, empezar por el frontend y dejar el backend para después.

## 4. Checklist de implementación

Por cada capa afectada:

**Backend (Express):**
- [ ] DTO de request y response definidos en `domain/dtos/`.
- [ ] Validación de request en middleware.
- [ ] Lógica en service, no en controller.
- [ ] Error handling con clases de error personalizadas.
- [ ] Test de integración de la ruta.
- [ ] Test unitario del service.

**Frontend (Angular):**
- [ ] Interfaz/modelo del frontend actualizado (no usar DTO backend directamente).
- [ ] Servicio HTTP con tipado explícito.
- [ ] Componente con `ChangeDetectionStrategy.OnPush` si es presentacional.
- [ ] Limpieza de subscripciones.
- [ ] Spec con render + interacción básica.

**Infra (CDK):**
- [ ] Nuevo recurso con naming correcto.
- [ ] `RemovalPolicy.RETAIN` si tiene datos en prod.
- [ ] IAM con mínimo privilegio (`grant*` methods).
- [ ] Tests de assertion para el recurso nuevo.
- [ ] `cdk diff` revisado antes de proponer deploy.

## 5. Verificación final

Antes de dar la feature por completa:
- Los tests pasan.
- No hay `any` nuevo sin justificar.
- No hay secretos hardcodeados.
- Si afecta a contrato de API: `integration-reviewer` verificó coherencia.
- Si afecta a tests: `test-reviewer` confirmó cobertura mínima.
