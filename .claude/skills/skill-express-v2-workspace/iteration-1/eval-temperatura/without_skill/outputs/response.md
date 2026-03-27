# eval-temperatura — WITHOUT skill (baseline)

**`app.js`**
```js
// app.js
// Spec: temperature-api-spec.yaml | Base URL: http://localhost:3000

const express = require('express');
const cors    = require('cors');

const temperatureRouter = require('./routes/temperature');

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: 'http://localhost:4200' }));
app.use(express.json());

app.use('/temperature', temperatureRouter);

app.listen(PORT, () =>
  console.log(`API disponible en http://localhost:${PORT}`)
);

module.exports = app;
```

**`routes/temperature.js`**
```js
// routes/temperature.js
// Contrato: GET /temperature/:city?timestamp=<13 dígitos>
//           operationId: getTemperatureByCity

const express = require('express');
const router  = express.Router();

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

  const data = TEMPERATURES[city.toLowerCase()];
  if (!data) {
    return res.status(404).json({
      error:   'NOT_FOUND',
      message: `No hay datos para la ciudad '${city}'.`,
    });
  }

  return res.status(200).json({
    city:    city,
    date:    new Date(parseInt(timestamp, 10)).toISOString(),
    maxTemp: data.maxTemp,
    minTemp: data.minTemp,
  });
});

module.exports = router;
```

**`package.json`**
```json
{
  "name": "temperature-api",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": { "start": "node app.js" },
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.18.2"
  }
}
```
