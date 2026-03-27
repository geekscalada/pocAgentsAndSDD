# eval-pedidos — WITH skill

**`package.json`**
```json
{
  "name": "orders-api",
  "version": "1.0.0",
  "description": "Demo Orders API following OpenAPI spec",
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
const cors = require('cors');
const ordersRouter = require('./routes/orders');

const app = express();

app.use(cors({ origin: 'http://localhost:4200' }));
app.use(express.json());

app.use('/orders', ordersRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Orders API running on http://localhost:${PORT}`);
});

module.exports = app;
```

**`routes/orders.js`**
```js
// routes/orders.js
// Contrato: POST /orders  →  operationId: createOrder
// Request body : { customerId: string, items: [{ productId: string, quantity: integer >= 1 }] }
// Response 201 : { orderId: string, status: "pending"|"confirmed", createdAt: date-time }
// Response 400 : { error: string, message: string }

const express = require('express');
const router = express.Router();

router.post('/', function createOrder(req, res) {
  const { customerId, items } = req.body;

  // Validar campo obligatorio: customerId
  if (!customerId) {
    return res.status(400).json({
      error:   'BAD_REQUEST',
      message: "El campo 'customerId' es obligatorio.",
    });
  }

  // Validar campo obligatorio: items (debe ser array no vacío)
  if (!items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({
      error:   'BAD_REQUEST',
      message: "El campo 'items' debe ser un array no vacío.",
    });
  }

  // Validar cada item del array
  for (let i = 0; i < items.length; i++) {
    const item = items[i];

    if (!item.productId) {
      return res.status(400).json({
        error:   'BAD_REQUEST',
        message: `El campo 'productId' es obligatorio en items[${i}].`,
      });
    }

    if (!Number.isInteger(item.quantity) || item.quantity < 1) {
      return res.status(400).json({
        error:   'BAD_REQUEST',
        message: `El campo 'quantity' en items[${i}] debe ser un entero >= 1.`,
      });
    }
  }

  // Respuesta 201 con el shape exacto del schema de la spec
  return res.status(201).json({
    orderId:   `ord-${Date.now()}`,
    status:    'pending',
    createdAt: new Date().toISOString(),
  });
});

module.exports = router;
```
