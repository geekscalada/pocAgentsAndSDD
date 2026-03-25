# Skill Angular — Generación de Módulos y Servicios

Esta skill te proporciona un método para generar módulos y servicios Angular a partir de una spec OpenAPI.

## Cuándo usarla

- Cuando la tarea requiera crear un módulo o servicio Angular que consuma una API REST.
- Siempre que dispongas de una spec OpenAPI que defina el contrato del endpoint a consumir.
- Para generar código dummy/explicativo que ilustre la estructura de integración frontend-backend.

## Prerequisito obligatorio

Antes de aplicar esta skill debes tener la spec OpenAPI del endpoint que el servicio Angular va a consumir. Si no la tienes, detente y solicítala.

## Contexto importante

El código generado es a nivel de módulo/servicio dummy: no asumas que existe un scaffold Angular completo. Genera solo los ficheros relevantes para ilustrar el patrón de integración.

## Método de aplicación

Al aplicar esta skill, sigue estos pasos:

1. **Leer la spec**: identifica la URL, método HTTP y el schema de respuesta que consumirá el servicio.
2. **Definir la estructura de ficheros**: como mínimo, un `*.service.ts` y un `*.module.ts` dummy.
3. **Implementar el servicio**: usa `HttpClient` para llamar al endpoint con los parámetros definidos en la spec.
4. **Tipar la respuesta**: crea una interfaz TypeScript que coincida con el response schema de la spec.
5. **Verificar coherencia con la spec**: comprueba que el servicio generado respeta el contrato antes de devolverlo.

## Formato de salida

Devuelve bloques de código con el nombre del fichero como título. Ejemplo:

**`add.service.ts`**
```ts
// código aquí
```

**`add.module.ts`**
```ts
// código aquí
```

El código debe ser legible y comentado para que sirva como ejemplo explicativo. No incluyas imports de módulos que no sean `HttpClientModule` u otros estándar de Angular.
