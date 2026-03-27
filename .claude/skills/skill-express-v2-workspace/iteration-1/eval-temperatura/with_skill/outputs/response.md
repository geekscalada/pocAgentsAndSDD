# eval-temperatura — WITH skill

**`package.json`**
```json
{
  "name": "temperature-api",
  "version": "1.0.0",
  "description": "Demo Express server for Temperature API",
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

**`app.js`**
```js
const express = require('express');
const cors    = require('cors');

const temperatureRouter = require('./routes/temperature');

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: 'http://localhost:4200' }));
app.use(express.json());

app.use('/temperature', temperatureRouter);

app.listen(PORT, () => console.log(`API disponible en http://localhost:${PORT}`));

module.exports = app;
```

**`routes/temperature.js`**
```js
const express = require('express');
const router  = express.Router();

const temperatureData = {
  madrid:    { city: 'Madrid',    maxTemp: 28.4, minTemp: 14.1 },
  barcelona: { city: 'Barcelona', maxTemp: 25.7, minTemp: 17.3 },
  sevilla:   { city: 'Sevilla',   maxTemp: 35.2, minTemp: 20.8 },
  bilbao:    { city: 'Bilbao',    maxTemp: 19.5, minTemp: 11.0 },
};

router.get('/:city', (req, res) => {
  const { city } = req.params;
  const { timestamp } = req.query;

  if (!timestamp) {
    return res.status(400).json({
      error: 'MISSING_PARAMETER',
      message: 'El parámetro "timestamp" es obligatorio.',
    });
  }

  if (!/^\d{13}$/.test(timestamp)) {
    return res.status(400).json({
      error: 'INVALID_PARAMETER',
      message: 'El parámetro "timestamp" debe ser un número de 13 dígitos (Unix ms).',
    });
  }

  const record = temperatureData[city.toLowerCase()];

  if (!record) {
    return res.status(404).json({
      error: 'NOT_FOUND',
      message: `No se encontraron datos de temperatura para la ciudad "${city}".`,
    });
  }

  const date = new Date(Number(timestamp)).toISOString();

  return res.status(200).json({
    city:    record.city,
    date,
    maxTemp: record.maxTemp,
    minTemp: record.minTemp,
  });
});

module.exports = router;
```
