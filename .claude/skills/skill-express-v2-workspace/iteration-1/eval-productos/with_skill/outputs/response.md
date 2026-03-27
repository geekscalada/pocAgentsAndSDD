# eval-productos — WITH skill

**`package.json`**
```json
{
  "name": "products-api",
  "version": "1.0.0",
  "description": "Demo Products API built with Express 4.x",
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
const productsRouter = require('./routes/products');

const app = express();

app.use(cors({ origin: 'http://localhost:4200' }));
app.use(express.json());

app.use('/products', productsRouter);

app.listen(process.env.PORT || 3000, () =>
  console.log(`Products API disponible en http://localhost:${process.env.PORT || 3000}`)
);

module.exports = app;
```

**`routes/products.js`**
```js
const express = require('express');
const router = express.Router();

const products = [
  { id: '1', name: 'Laptop Pro 15',  price: 1299.99, category: 'electronics' },
  { id: '2', name: 'Wireless Mouse', price:   29.95, category: 'electronics' },
  { id: '3', name: 'Running Shoes',  price:   89.50, category: 'sports'      },
  { id: '4', name: 'Coffee Mug',     price:   14.99, category: 'kitchen'     },
];

// GET /products — query param opcional: category
router.get('/', (req, res) => {
  const { category } = req.query;

  let result = products;
  if (category) {
    result = products.filter(
      (p) => p.category.toLowerCase() === category.toLowerCase()
    );
  }

  res.status(200).json(result);
});

// GET /products/:id
router.get('/:id', (req, res) => {
  const { id } = req.params;

  const product = products.find((p) => p.id === id);

  if (!product) {
    return res.status(404).json({
      error: 'NOT_FOUND',
      message: `No se encontró ningún producto con id '${id}'`,
    });
  }

  res.status(200).json(product);
});

module.exports = router;
```
