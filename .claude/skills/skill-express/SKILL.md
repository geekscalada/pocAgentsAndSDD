---
name: skill-express
description: >
  Guía para generar código de ejemplo Express 4.x que implementa endpoints REST
  definidos en una spec OpenAPI. Actívala siempre que el usuario quiera desarrollar
  un backend en Node.js/Express, crear una ruta o router, implementar un endpoint
  REST, estructurar ficheros de una API, o ver cómo Express consume un contrato
  OpenAPI. Úsala también cuando el usuario mencione Express, Node.js o "backend"
  sin más contexto — casi seguro necesita estos patrones. El código es demostrativo
  (datos dummy, sin base de datos real), pensado para ilustrar correctamente los
  contratos y facilitar la integración con el frontend.
---

> **Capa de especialización para `subagent-dev`.**
> Los principios contract-first y clean architecture están definidos en el agente y aplican siempre.
> Esta skill añade únicamente las restricciones y patrones específicos de Express 4.x.

# skill-express — Código de ejemplo Express 4.x desde OpenAPI

El objetivo es generar código Express **claro, didáctico y alineado con el contrato
OpenAPI**. No implementes lógica de negocio ni acceso a base de datos: los datos
son siempre hardcodeados. El valor está en los patrones y en que el shape de las
respuestas coincida exactamente con la spec.

## Antes de escribir una sola línea

Necesitas la spec OpenAPI del endpoint. Sin el contrato no sabes qué paths, qué
parámetros ni qué shape de respuesta generar — cualquier código que escribas sin
ella será incorrecto o inconsistente. Si no la tienes, pídela explícitamente antes
de continuar.

## Estructura de ficheros

Usa siempre esta organización de dos capas:

```
app.js                  ← configuración global: middlewares + montaje de routers
routes/<recurso>.js     ← handlers de cada recurso en su propio fichero
```

Mantener los handlers fuera de `app.js` facilita escalar la API y localizar bugs
rápidamente — aunque el proyecto sea pequeño, adquirir este hábito desde el inicio
evita refactorizaciones costosas.

## `app.js` — punto de entrada

```js
// app.js
// Spec: <nombre-spec>.yaml | Base URL: http://localhost:<PORT>

const express = require('express');
const cors    = require('cors');

const temperatureRouter = require('./routes/temperature');

const app  = express();
const PORT = process.env.PORT || 3000;

// Acepta peticiones solo desde el frontend de desarrollo
app.use(cors({ origin: 'http://localhost:4200' }));

// Permite leer JSON en el body de POST/PUT
app.use(express.json());

// Cada recurso tiene su propio prefijo de ruta
app.use('/temperature', temperatureRouter);

app.listen(PORT, () =>
  console.log(`API disponible en http://localhost:${PORT}`)
);

module.exports = app; // facilita los tests de integración si los hay
```

Exportar `app` es un detalle pequeño pero relevante: si en algún momento se añaden
tests con supertest, no hay que refactorizar.

## `routes/<recurso>.js` — router de recurso

Encapsula todos los handlers del recurso en un `express.Router()`. Usa funciones con
nombre en lugar de lambdas anónimas: los stack traces son mucho más legibles cuando
algo falla.

```js
// routes/temperature.js
// Contrato: GET /temperature/:city?timestamp=<13 dígitos>
//           operationId: getTemperatureByCity

const express = require('express');
const router  = express.Router();

// Datos dummy — claves en minúsculas para búsqueda case-insensitive
const TEMPERATURES = {
  madrid:    { maxTemp: 22.4, minTemp: 10.1 },
  barcelona: { maxTemp: 24.0, minTemp: 13.5 },
  paris:     { maxTemp: 20.2, minTemp: 11.0 },
  london:    { maxTemp: 17.8, minTemp:  9.3 },
};

const TIMESTAMP_RE = /^\d{13}$/;

router.get('/:city', function getTemperatureByCity(req, res) {
  const { city } = req.params;
  const { timestamp } = req.query;

  // 1. Validar parámetros obligatorios antes de cualquier lógica
  if (!timestamp) {
    return res.status(400).json({
      error:   'BAD_REQUEST',
      message: "El query param 'timestamp' es obligatorio.",
    });
  }
  if (!TIMESTAMP_RE.test(timestamp)) {
    return res.status(400).json({
      error:   'BAD_REQUEST',
      message: "El parámetro 'timestamp' debe tener exactamente 13 dígitos.",
    });
  }

  // 2. Buscar en los datos dummy (case-insensitive)
  const data = TEMPERATURES[city.toLowerCase()];
  if (!data) {
    return res.status(404).json({
      error:   'NOT_FOUND',
      message: `No hay datos para la ciudad '${city}'.`,
    });
  }

  // 3. Respuesta 200 con el shape exacto del schema de la spec
  return res.status(200).json({
    city:      city,
    date:      new Date(parseInt(timestamp, 10)).toISOString(),
    maxTemp:   data.maxTemp,
    minTemp:   data.minTemp,
  });
});

module.exports = router;
```

## Patrones clave explicados

### Lectura de parámetros según su tipo

Siempre lee desde el objeto correcto — Express los separa para que no haya
ambigüedad:

| Tipo de parámetro | Objeto Express | Ejemplo en la spec |
|---|---|---|
| Path param (`:city`) | `req.params.city` | `/temperature/{city}` |
| Query param (`?page`) | `req.query.page` | `in: query` |
| Body (POST/PUT) | `req.body.nombre` | `requestBody` |

### Validación temprana con `return`

Valida en las primeras líneas del handler y haz `return` en cada caso de error.
Esto evita el "callback hell" de validaciones anidadas y deja el camino feliz
(happy path) visible al final, sin indentación extra.

### Datos dummy con objeto indexado

Un objeto literal con claves normalizadas a minúsculas es la forma más simple de
simular una "base de datos":

```js
const key    = req.params.city.toLowerCase();
const result = DATA[key]; // undefined si no existe → 404
```

Incluye 3-4 entradas representativas para que el demo sea convincente.

### Shape de respuesta alineado con la spec

Construye el objeto de respuesta usando exactamente los campos del schema `200`:
ni campos extra, ni campos obligatorios omitidos. Así el frontend no recibe
sorpresas cuando integre contra la API real.

## `package.json`

```json
{
  "name": "<nombre-api>",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.18.2"
  }
}
```

## Pasos al aplicar la skill

1. **Lee la spec**: anota paths, métodos HTTP, parámetros y schemas de respuesta
   (200 y errores 4xx).
2. **Identifica los recursos**: cada recurso (path raíz distinto) → un fichero en
   `routes/`.
3. **Diseña los datos dummy**: un objeto por recurso con 3-4 entradas realistas y
   claves en minúsculas.
4. **Implementa cada handler**: valida primero, busca en datos dummy, devuelve el
   shape exacto del 200.
5. **Ensambla `app.js`**: registra middlewares (cors, json) y monta cada router con
   su prefijo.
6. **Verifica coherencia**: el path de `app.use('/x', router)` + el path del router
   deben coincidir con el path de la spec.

## Formato de salida

Devuelve un bloque de código por fichero, usando el nombre del fichero como título.
Comenta el código con referencias a la spec para que sirva de ejemplo didáctico.

**`app.js`**
```js
// código aquí
```

**`routes/<recurso>.js`**
```js
// código aquí
```

**`package.json`**
```json
{ ... }
```

No uses `async/await` salvo que la spec implique operaciones verdaderamente
asíncronas. No añadas autenticación, ORM ni lógica de persistencia.
El objetivo es código de ejemplo correcto, coherente con el contrato y fácil de leer.
