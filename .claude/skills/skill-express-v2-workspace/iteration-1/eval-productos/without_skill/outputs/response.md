# eval-productos — WITHOUT skill (baseline)

**`app.js`**
```js
// app.js
// Spec: products-api.yaml | Base URL: http://localhost:3000

const express = require('express');
const cors    = require('cors');

const productsRouter = require('./routes/products');

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: 'http://localhost:4200' }));
app.use(express.json());

app.use('/products', productsRouter);

app.listen(PORT, () =>
  console.log(`API disponible en http://localhost:${PORT}`)
);

module.exports = app;
```

**`routes/products.js`**
```js
// routes/products.js
// Contrato:
//   GET /products?category=<string>  →  operationId: listProducts
//   GET /products/:id                →  operationId: getProductById

const express = require('express');
const router  = express.Router();

const PRODUCTS = [
  { id: '1', name: 'Laptop Pro 15',       price: 1299.99, category: 'electronics' },
  { id: '2', name: 'Wireless Mouse',      price:   29.99, category: 'electronics' },
  { id: '3', name: 'Mechanical Keyboard', price:   89.99, category: 'electronics' },
  { id: '4', name: 'Desk Chair',          price:  249.99, category: 'furniture'   },
  { id: '5', name: 'Standing Desk',       price:  499.99, category: 'furniture'   },
  { id: '6', name: 'Coffee Mug',          price:   12.99, category: 'kitchen'     },
  { id: '7', name: 'French Press',        price:   34.99, category: 'kitchen'     },
];

router.get('/', function listProducts(req, res) {
  const { category } = req.query;

  if (category) {
    const filtered = PRODUCTS.filter(
      p => p.category.toLowerCase() === category.toLowerCase()
    );
    return res.status(200).json(filtered);
  }

  return res.status(200).json(PRODUCTS);
});

router.get('/:id', function getProductById(req, res) {
  const { id } = req.params;

  const product = PRODUCTS.find(p => p.id === id);

  if (!product) {
    return res.status(404).json({
      error:   'NOT_FOUND',
      message: `El producto con id '${id}' no existe.`,
    });
  }

  return res.status(200).json(product);
});

module.exports = router;
```

**`package.json`**
```json
{
  "name": "products-api",
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
