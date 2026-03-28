---
name: api-contract-change
description: Playbook para gestionar cambios en el contrato de la API entre Express y Angular. Úsalo cuando cambies endpoints, DTOs, métodos HTTP, códigos de respuesta o cualquier parte del contrato público entre frontend y backend.
triggers:
  - /api-contract-change
---

# API Contract Change

Proceso para gestionar cambios en el contrato de la API de forma correcta y sin romper nada.

## Clasificación del cambio

**Non-breaking (seguro de hacer):**
- Añadir campos opcionales a un response DTO.
- Añadir un endpoint nuevo.
- Añadir parámetros query opcionales.
- Añadir nuevos códigos de respuesta para casos de error nuevos.

**Breaking (requiere coordinación):**
- Eliminar un campo de un response DTO.
- Renombrar un campo en request o response.
- Cambiar el tipo de un campo.
- Cambiar el método HTTP de un endpoint existente.
- Cambiar la URL de un endpoint.
- Eliminar un endpoint.
- Cambiar el código HTTP de una respuesta existente.

## Proceso para cambios breaking

### 1. Documentar el contrato actual y el nuevo

```
ANTES:
GET /api/products/:id
Response: { id: string, productName: string, unitPrice: number }

DESPUÉS:
GET /api/products/:id
Response: { id: string, name: string, price: number, category: { id: string, name: string } }

Cambios breaking:
- `productName` → `name` (rename)
- `unitPrice` → `price` (rename)
- Añadido: `category` (non-breaking)
```

### 2. Decidir estrategia

**Opción A — Deploy simultáneo** (si frontend y backend se despliegan juntos):
1. Cambiar backend.
2. Cambiar frontend en la misma PR/deploy.
3. Desplegar juntos.

**Opción B — Deprecación progresiva** (si se despliegan independientemente):
1. Backend añade campos nuevos manteniendo los viejos.
2. Frontend migra a campos nuevos.
3. Backend elimina campos viejos en siguiente ciclo.

### 3. Checklist de implementación

**Backend (Express):**
- [ ] Actualizar DTO en `domain/dtos/`.
- [ ] Actualizar el mapper DTO → response en el service.
- [ ] Si cambió validación: actualizar schema Zod del request.
- [ ] Actualizar tests de integración de la ruta.
- [ ] Actualizar tests unitarios del service si probaban el mapping.
- [ ] Documentar el cambio en el CHANGELOG o en el PR.

**Frontend (Angular):**
- [ ] Actualizar la interfaz/modelo en `domain/` o `models/`.
- [ ] Actualizar el mapeo en el servicio HTTP.
- [ ] Buscar todos los componentes/templates que usan los campos cambiados.
- [ ] Actualizar templates, bindings y accesos a los campos.
- [ ] Actualizar los specs del servicio.
- [ ] Verificar que no quedan referencias al campo/endpoint antiguo.

### 4. Verificación

Ejecutar `integration-reviewer` sobre los cambios para verificar:
- Que no quedan referencias al contrato antiguo en el frontend.
- Que los DTOs del backend coinciden con las interfaces del frontend.
- Que los tests de integración del backend reflejan el nuevo contrato.

## Plantilla de documentación de cambio de contrato

Para incluir en el PR:

```markdown
## Cambio de contrato API

**Endpoint afectado:** `GET /api/products/:id`
**Tipo:** Breaking change

**Contrato anterior:**
{ id: string, productName: string, unitPrice: number }

**Contrato nuevo:**
{ id: string, name: string, price: number, category: { id: string, name: string } }

**Campos eliminados/renombrados:**
- `productName` renombrado a `name`
- `unitPrice` renombrado a `price`

**Campos añadidos:**
- `category: { id, name }` (nuevo)

**Impacto en frontend:**
- Actualizado `ProductService.getById()` y modelo `Product`
- Actualizados `ProductDetailComponent` y `ProductCardComponent`

**Tests actualizados:**
- `products.routes.spec.ts` — respuesta del endpoint
- `products.service.spec.ts` — Angular, mapeo de DTO
```
