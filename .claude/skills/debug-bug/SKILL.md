---
name: debug-bug
description: Playbook para diagnosticar y corregir bugs. Guía el proceso de reproducción, análisis de causa raíz, corrección mínima y verificación, evitando cambios innecesarios mientras se arregla el problema.
triggers:
  - /debug-bug
---

# Debug Bug

Sigue este proceso para diagnosticar y corregir un bug de forma sistemática.

## 1. Entender el bug antes de tocar código

- **Reproducir**: ¿en qué condición ocurre? ¿siempre o intermitentemente?
- **Síntomas vs causa**: el error visible (síntoma) puede no ser donde está el bug (causa).
- **Scope**: ¿afecta a frontend, backend, infra o a varios?
- **Cuándo empezó**: ¿hay un commit o deploy reciente que lo introdujo?

## 2. Hipótesis antes de leer código

Antes de lanzarse a leer ficheros, formular hipótesis:
1. ¿Qué podría causar este comportamiento?
2. ¿Qué archivos/módulos están implicados?
3. ¿Qué datos o estado pueden estar mal?

## 3. Exploración dirigida

- Leer los archivos más probables primero, no todo el codebase.
- Buscar el flujo de datos: ¿de dónde viene el dato erróneo? ¿dónde se transforma?
- Revisar los límites del sistema: validaciones de entrada, mapeos de DTOs, transformaciones.

## 4. Localizar la causa raíz

No corrijas el síntoma; encuentra la causa raíz:
- ¿Es un bug de lógica (condición incorrecta, cálculo erróneo)?
- ¿Es un bug de datos (valor null/undefined inesperado, tipo incorrecto)?
- ¿Es un bug de estado (race condition, estado compartido mutado)?
- ¿Es un bug de contrato (frontend espera un campo que backend no devuelve)?
- ¿Es un bug de configuración (env var faltante, recurso CDK mal configurado)?

## 5. Corrección mínima

- Corregir solo lo necesario para arreglar el bug.
- No refactorizar código colateral mientras se arregla el bug.
- Si ves deuda técnica mientras investigas, anotarla en un comentario `// TODO:` sin tocarla ahora.

## 6. Verificación

- Escribir o actualizar el test que reproduce el bug (test primero si es posible).
- Verificar que el test falla antes de la corrección y pasa después.
- Verificar que los tests existentes siguen pasando.
- Si el bug era un error de contrato, llamar a `integration-reviewer` para verificar coherencia.

## 7. Documentar si es no obvio

Si la causa raíz fue sutil o inesperada, añadir un comentario breve en el código:
```typescript
// Bug fix: el campo `price` puede ser null si el producto es un bundle.
// La API devuelve null en ese caso; el frontend lo trata como 0.
const displayPrice = product.price ?? 0;
```
