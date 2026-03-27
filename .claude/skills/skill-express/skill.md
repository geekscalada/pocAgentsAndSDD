---
name: skill-express
description: >
  Guía para generar código de ejemplo Express 4.x que implemente endpoints REST
  definidos en una spec OpenAPI. Usa esta skill siempre que el usuario quiera
  desarrollar backend en Node.js/Express, crear una ruta o router Express,
  implementar un endpoint REST, organizar la estructura de ficheros de una API,
  o mostrar cómo quedaría código Express consumiendo un contrato OpenAPI.
  Actívala también cuando el usuario mencione Express, Node.js o backend sin más
  detalle — probablemente necesita esta guía de patrones recomendados.
---

# Skill Express 4.x — Generación de Código de Ejemplo

Esta skill guía la generación de código Express con CommonJS a partir de una spec
OpenAPI. El código producido es **dummy/demostrativo**: ilustra patrones correctos
pero no contiene lógica de negocio real ni acceso a base de datos.

## Prerrequisito obligatorio

Antes de generar código debes tener la spec OpenAPI del endpoint a implementar.
Si no la tienes, detente y solicítala explícitamente — sin el contrato no puedes
garantizar que los paths, parámetros y shapes de respuesta sean correctos.

## Patrones Express 4.x que debes usar siempre

### Estructura de ficheros

Organiza siempre el proyecto en dos capas:

```
app.js               ← punto de entrada: middlewares globales + montaje de routers
routes/<recurso>.js  ← router con los handlers del recurso
```

Nunca pongas los handlers directamente en `app.js`.

### Punto de entrada `app.js`

```js
// app.js — <Nombre de la API>
// Spec: <nombre-spec>.yaml | Servidor: http://localhost:<PORT>

const express = require('express');
const cors    = require('cors');

const ejemploRouter = require('./routes/ejemplo');

const app  = express();
const PORT = 3000;

// CORS — permite únicamente el origen del frontend
app.use(cors({ origin: 'http://localhost:4200' }));

// Parseo de JSON (para POST/PUT con body)
app.use(express.json());

// Montaje de rutas
app.use('/ejemplo', ejemploRouter);

app.listen(PORT, () => {
  console.log(`API escuchando en http://localhost:${PORT}`);
});

module.exports = app; // exportar facilita los tests
```

### Router de recurso con `express.Router()`

Cada recurso tiene su propio fichero de rutas. Define los handlers con funciones
nombradas para que los stack traces sean legibles.

```js
// routes/ejemplo.js
// Contrato: GET /ejemplo/:id  →  operationId: getEjemploById

const express = require('express');
const router  = express.Router();

router.get('/:id', (req, res) => {
  // ... handler aquí
});

module.exports = router;
```

### Lectura de parámetros

Lee siempre desde los objetos correctos según la spec:

```js
// Parámetro de path  →  req.params
const id = req.params.id;

// Parámetro de query →  req.query
const { page, size } = req.query;

// Body de POST/PUT   →  req.body  (requiere express.json())
const { nombre, precio } = req.body;
```

### Validación de entrada antes de procesar

Valida los parámetros obligatorios nada más entrar en el handler. Usa el shape
de `ErrorResponse` definido en la spec para las respuestas de error.

```js
// Ejemplo: validar parámetro timestamp de 13 dígitos
const TIMESTAMP_RE = /^\d{13}$/;

if (!timestamp) {
  return res.status(400).json({
    error:   'BAD_REQUEST',
    message: "El parámetro 'timestamp' es obligatorio."
  });
}
if (!TIMESTAMP_RE.test(timestamp)) {
  return res.status(400).json({
    error:   'BAD_REQUEST',
    message: "El parámetro 'timestamp' debe tener exactamente 13 dígitos."
  });
}
```

### Datos dummy hardcodeados

Para simular un backend sin base de datos, define un objeto literal con datos
representativos. Normaliza siempre las claves de búsqueda (p. ej. `toLowerCase()`)
para que la comparación sea case-insensitive.

```js
// Datos dummy — claves siempre en minúsculas
const ejemplos = {
  madrid: { maxTemp: 22.4, minTemp: 10.1 },
  paris:  { maxTemp: 20.2, minTemp: 11.0 }
};

const key    = req.params.city.toLowerCase();
const result = ejemplos[key];

if (!result) {
  return res.status(404).json({
    error:   'NOT_FOUND',
    message: `El recurso '${req.params.city}' no existe.`
  });
}
```

### Respuesta 200 alineada con la spec

Construye el objeto de respuesta usando exactamente los campos y tipos del schema
`200` definido en la spec. No añadas campos extra ni omitas ninguno obligatorio.

```js
return res.status(200).json({
  city:    req.params.city,
  date:    new Date(parseInt(timestamp, 10)).toISOString(),
  maxTemp: result.maxTemp,
  minTemp: result.minTemp
});
```

### `package.json` mínimo

```json
{
  "name": "<nombre-api>",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": { "start": "node app.js" },
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.18.2"
  }
}
```

## Pasos al aplicar la skill

1. **Leer la spec**: identifica paths, métodos HTTP, parámetros (path/query/body) y
   schemas de respuesta (200, 4xx).
2. **Definir la estructura de ficheros**: siempre `app.js` + `routes/<recurso>.js`.
3. **Tipar los datos**: si hay schemas complejos, define un comentario JSDoc o un
   objeto de ejemplo que documente los campos esperados.
4. **Implementar el handler**: valida parámetros, busca en los datos dummy, construye
   la respuesta con el shape exacto del schema 200.
5. **Verificar coherencia**: antes de devolver el código, comprueba que el path
   montado en `app.use` + el path del router coinciden con la spec, y que todos los
   campos obligatorios están presentes en la respuesta.

## Formato de salida

Devuelve bloques de código con el nombre del fichero como título. El código debe
estar comentado para que sirva como ejemplo explicativo y haga referencia a la spec.

**`app.js`**
```js
// código aquí
```

**`routes/ejemplo.js`**
```js
// código aquí
```

**`package.json`**
```json
// contenido aquí
```

No añadas lógica de base de datos ni autenticación. No uses `async/await` a menos
que la spec implique operaciones asíncronas reales.
Recuerda: el objetivo es código de ejemplo claro, coherente con el contrato y didáctico.
