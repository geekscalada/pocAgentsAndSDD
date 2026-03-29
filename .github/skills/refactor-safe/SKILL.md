---
name: refactor-safe
description: Playbook para refactorizar código de forma segura. Guía el proceso de refactoring incremental, manteniendo el comportamiento existente, con tests como red de seguridad, sin mezclar refactor con cambios funcionales.
---

# Refactor Safe

Proceso para refactorizar código sin romper nada y sin introducir cambios funcionales.

## Regla fundamental

**Un refactor NO cambia el comportamiento observable.** Si el refactor también cambia funcionalidad, son dos cambios separados que van en dos commits distintos.

## 1. Antes de refactorizar

- Confirmar que los tests actuales pasan (si no pasan, no refactorices).
- Entender completamente qué hace el código que vas a refactorizar.
- Identificar todos los puntos que lo usan (imports, referencias, llamadas).
- Definir claramente el objetivo: ¿qué mejora el refactor? (legibilidad, separación de responsabilidades, rendimiento, etc.)

## 2. Tipos de refactor y su riesgo

| Tipo | Riesgo | Estrategia |
|------|--------|-----------|
| Rename (variable, método, clase) | Bajo | Rename global + verificar todos los usos |
| Extract method/function | Bajo | Extraer + llamar desde el lugar original |
| Move file/module | Medio | Mover + actualizar todos los imports + barrel exports |
| Cambiar interfaz pública | Alto | Deprecar primero si hay callers externos; migrar en dos fases |
| Cambiar estructura de datos | Alto | Migración explícita; no cambiar y asumir |

## 3. Hacerlo incremental

Refactorizar en pasos pequeños, cada uno con los tests pasando:

1. Hacer un cambio atómico.
2. Verificar que los tests pasan.
3. Hacer el siguiente cambio.

No hacer 10 cambios a la vez y luego verificar; si algo falla, no sabrás qué lo causó.

## 4. Checklist por stack

**Angular:**
- [ ] Si se renombra un componente/selector, actualizar todos los templates que lo usan.
- [ ] Si se extrae un servicio, actualizar los providers/injection tokens.
- [ ] Si se mueve un módulo, actualizar el `app-routing.module.ts` y los imports.
- [ ] Los specs del componente/servicio refactorizado siguen pasando sin modificarlos (si los tests necesitan cambiar mucho, el refactor cambió la interfaz pública).

**Express:**
- [ ] Si se extrae un service o repository, actualizar el punto de inyección/instanciación.
- [ ] Si se renombra un método de service usado en controller, actualizar el controller.
- [ ] Los tests de integración de rutas siguen pasando sin cambios.
- [ ] Los tests unitarios de services solo necesitan cambios mínimos de renaming.

**CDK:**
- [ ] Refactorizar CDK es de alto riesgo: cambiar IDs de construcción provoca replace de recursos.
- [ ] Si hay que cambiar IDs, planificar con `cdk diff` y confirmar con el usuario antes.
- [ ] Extraer constructs reutilizables manteniendo los mismos IDs lógicos.

## 5. Lo que NO es un refactor seguro

- Cambiar el comportamiento de una función aunque "mejore" la lógica.
- Cambiar DTOs o interfaces de API (eso es un cambio de contrato).
- Cambiar las RemovalPolicy o configuración de recursos CDK.
- Eliminar código que "parece no usarse" sin verificar que no hay referencias (buscar globalmente antes).

## 6. Verificación final

- Todos los tests pasan.
- No hay `git diff` en tests salvo renaming trivial.
- Si se movieron archivos: todos los imports actualizados, no hay referencias rotas.
- El comportamiento observable es idéntico al anterior.
