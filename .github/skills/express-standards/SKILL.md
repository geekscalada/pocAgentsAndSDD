---
name: express-standards
description: >
  Playbook de estándares Express/Node para este monorepo. USA ESTE SKILL para cualquier tarea de desarrollo o mantenimiento con express. También cuando se modifiquen endpoints existentes, se añadan nuevos recursos REST, se refactorice la capa de acceso a datos o se corrija un bug en el backend.
  NO usar para tareas exclusivas de Angular o CDK.
---

# Express Standards — pocAgentesSubAgentesSDD

Playbook completo de cómo trabajamos con Express/Node en este monorepo.

## Estructura de capas

```
services/express-api/src/
  routes/           → definición de rutas, uso de controllers, middleware de ruta
  controllers/      → recibe req/res, delega a services, devuelve respuesta HTTP
  services/         → lógica de negocio, orquestación entre repositories/externos
  domain/
    entities/       → clases/interfaces de dominio
    dtos/           → Data Transfer Objects (request y response)
    errors/         → clases de error personalizadas
  middlewares/      → auth, validación, error handling global, logging, cors
  repositories/     → acceso a datos (abstracción sobre ORM/DB cliente)
  config/           → variables de entorno validadas, inicialización de app
  utils/            → funciones puras de utilidad sin side-effects
```

## Routes

Solo enrutado y composición de middlewares. Sin lógica:
```typescript
// routes/products.routes.ts
router.get('/', authenticate, productsController.getAll);
router.post('/', authenticate, validate(CreateProductDto), productsController.create);
router.get('/:id', authenticate, productsController.getById);
```

## Controllers

Sin lógica de negocio. Reciben, delegan, responden:
```typescript
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  getAll = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const products = await this.productsService.findAll();
      res.status(200).json(products);
    } catch (error) {
      next(error);
    }
  };
}
```

## Services

Agnósticos a Express (sin `req`/`res`). Toda la lógica aquí:
```typescript
export class ProductsService {
  constructor(private readonly productsRepository: ProductsRepository) {}

  async findAll(): Promise<ProductResponseDto[]> {
    const products = await this.productsRepository.findAll();
    return products.map(toResponseDto);
  }

  async create(dto: CreateProductDto): Promise<ProductResponseDto> {
    const existing = await this.productsRepository.findByName(dto.name);
    if (existing) throw new ConflictError(`Product '${dto.name}' already exists`);
    const product = await this.productsRepository.save(dto);
    return toResponseDto(product);
  }
}
```

## DTOs

Contratos explícitos en `domain/dtos/`. Los de response son contrato público con frontend:
```typescript
// domain/dtos/product.dto.ts
export interface CreateProductDto {
  name: string;
  price: number;
  categoryId: string;
}

export interface ProductResponseDto {
  id: string;
  name: string;
  price: number;
  category: { id: string; name: string };
  createdAt: string;  // ISO 8601
}
```

## Validación (Zod)

En middleware, antes de que llegue al controller:
```typescript
// middlewares/validate.ts
export const validate = (schema: ZodSchema) => (req: Request, res: Response, next: NextFunction) => {
  const result = schema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({ errors: result.error.flatten().fieldErrors });
  }
  req.body = result.data;
  next();
};
```

## Error handling global

```typescript
// middlewares/error-handler.ts
export const errorHandler = (err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ message: err.message, code: err.code });
  }
  // No filtrar stack en producción
  const message = process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message;
  res.status(500).json({ message });
};
```

## Errores personalizados

```typescript
// domain/errors/app.error.ts
export class AppError extends Error {
  constructor(public message: string, public statusCode: number, public code: string) {
    super(message);
  }
}
export class NotFoundError extends AppError {
  constructor(resource: string) { super(`${resource} not found`, 404, 'NOT_FOUND'); }
}
export class ConflictError extends AppError {
  constructor(message: string) { super(message, 409, 'CONFLICT'); }
}
```

## Variables de entorno

Validar y tipar al arrancar:
```typescript
// config/env.ts
import { z } from 'zod';
const envSchema = z.object({
  PORT: z.string().default('3000'),
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32),
});
export const env = envSchema.parse(process.env);
```

## Anti-patrones

| Anti-patrón | Solución |
|-------------|----------|
| Lógica de negocio en controller | Moverla al service |
| `any` en TypeScript | DTOs e interfaces explícitas |
| Acceso directo a DB desde controller | Repository pattern |
| Secretos hardcodeados | `process.env` validado con Zod |
| Catch de errores sin relanзar o loggear | Middleware de error global + logging |
| Respuestas inconsistentes entre endpoints | Formato estándar `{ data/errors/message }` |

## Testing

**Unitario (services):**
```typescript
describe('ProductsService', () => {
  let service: ProductsService;
  let mockRepo: jest.Mocked<ProductsRepository>;

  beforeEach(() => {
    mockRepo = { findAll: jest.fn(), save: jest.fn(), ... };
    service = new ProductsService(mockRepo);
  });

  it('should throw ConflictError when product name exists', async () => {
    mockRepo.findByName.mockResolvedValue({ id: '1', name: 'test' } as Product);
    await expect(service.create({ name: 'test', price: 10, categoryId: 'cat1' }))
      .rejects.toThrow(ConflictError);
  });
});
```

**Integración (rutas con supertest):**
```typescript
describe('GET /api/products', () => {
  it('should return 200 with list of products', async () => {
    const res = await request(app).get('/api/products').set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});
```

## Marca de trazabilidad

Cuando apliques este skill, **debes** añadir el siguiente comentario en la primera línea de `src/index.js` (o `src/index.ts`):

```javascript
// @skill:express-standards applied
```

Esto permite verificar con un simple grep que el skill fue seguido:
```bash
grep -r '@skill:express-standards' services/express-api/src/index.*
```

Si el comentario no está presente, se considera que el skill **no fue aplicado**.
