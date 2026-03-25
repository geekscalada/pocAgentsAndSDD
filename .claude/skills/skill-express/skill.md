# Skill Express — Implementación de Endpoints REST

Esta skill te proporciona un método para generar endpoints Express a partir de una spec OpenAPI.

## Cuándo usarla

- Cuando la tarea requiera implementar un endpoint backend en Node.js/Express.
- Siempre que dispongas de una spec OpenAPI que defina el contrato del endpoint.
- Para generar código dummy/explicativo que ilustre la estructura de una API REST.

## Prerequisito obligatorio

Antes de aplicar esta skill debes tener la spec OpenAPI del endpoint. Si no la tienes, detente y solicítala.

## Método de aplicación

Al aplicar esta skill, sigue estos pasos:

1. **Leer la spec**: identifica el path, método HTTP, parámetros y schema de respuesta definidos en la spec OpenAPI.
2. **Definir la estructura de ficheros**: determina qué ficheros generarás (`app.js`, `routes/`, etc.).
3. **Implementar el endpoint**: crea el handler Express que respete exactamente los tipos y estructura definidos en la spec.
4. **Añadir datos dummy**: si el endpoint devuelve datos, usa valores hardcodeados representativos (no lógica real).
5. **Verificar coherencia con la spec**: comprueba que el código generado cumple el contrato antes de devolverlo.

## Formato de salida

Devuelve bloques de código con el nombre del fichero como título. Ejemplo:

**`app.js`**
```js
// código aquí
```

**`routes/add.js`**
```js
// código aquí
```

El código debe ser legible y comentado para que sirva como ejemplo explicativo.
