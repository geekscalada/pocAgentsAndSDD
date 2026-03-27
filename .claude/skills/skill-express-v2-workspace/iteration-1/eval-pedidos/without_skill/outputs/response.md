# eval-pedidos — WITHOUT skill (baseline)

**`app.js`**
```js
// app.js
// Spec: orders-api | Base URL: http://localhost:3000

const express = require('express');
const cors    = require('cors');

const ordersRouter = require('./routes/orders');

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: 'http://localhost:4200' }));
app.use(express.json());

app.use('/orders', ordersRouter);

app.listen(PORT, () =>
  console.log(`API disponible en http://localhost:${PORT}`)
);

module.exports = app;
```

**`routes/orders.js`**
```js
// routes/orders.js
// Contrato: POST /orders  →  operationId: createOrder

const express = require('express');
const router  = express.Router();

let orderCounter = 1;

function generateOrderId() {
  return `ORD-${String(orderCounter++).padStart(4, '0')}`;
}

router.post('/', function createOrder(req, res) {
  const { customerId, items } = req.body;

  if (!customerId) {
    return res.status(400).json({
      error:   'BAD_REQUEST',
      message: "El campo 'customerId' es obligatorio.",
    });
  }

  if (!items) {
    return res.status(400).json({
      error:   'BAD_REQUEST',
      message: "El campo 'items' es obligatorio.",
    });
  }

  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({
      error:   'BAD_REQUEST',
      message: "El campo 'items' debe ser un array no vacío.",
    });
  }

  for (let i = 0; i < items.length; i++) {
    const item = items[i];

    if (!item.productId) {
      return res.status(400).json({
        error:   'BAD_REQUEST',
        message: `El campo 'productId' es obligatorio en items[${i}].`,
      });
    }

    if (item.quantity === undefined || item.quantity === null) {
      return res.status(400).json({
        error:   'BAD_REQUEST',
        message: `El campo 'quantity' es obligatorio en items[${i}].`,
      });
    }

    if (!Number.isInteger(item.quantity) || item.quantity < 1) {
      return res.status(400).json({
        error:   'BAD_REQUEST',
        message: `El campo 'quantity' en items[${i}] debe ser un entero mayor o igual a 1.`,
      });
    }
  }

  const newOrder = {
    orderId:   generateOrderId(),
    status:    'pending',
    createdAt: new Date().toISOString(),
  };

  return res.status(201).json(newOrder);
});

module.exports = router;
```

**`package.json`**
```json
{
  "name": "orders-api",
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
