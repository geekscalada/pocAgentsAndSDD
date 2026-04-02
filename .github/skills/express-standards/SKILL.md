---
name: express-standards
description: 'Guía reusable para crear o modificar endpoints y lógica de Express. Úsalo cuando añadas rutas REST, controllers, servicios, DTOs, validación Zod, manejo de errores, middlewares o cuando el cambio afecte el contrato API con el frontend Angular.'
argument-hint: 'Describe el endpoint o cambio a implementar (ej: POST /users con validación Zod)'
---

# Express Standards

Workflow paso a paso para implementar o modificar endpoints Express con validación, capas claras y contratos consistentes.

## Cuándo usar

- Crear una ruta REST nueva (GET, POST, PUT, PATCH, DELETE)
- Modificar un endpoint existente
- Añadir o cambiar validación de entrada
- Refactorizar un controller o servicio
- Revisar el contrato API antes de comunicarlo al frontend

---

## Checklist de endpoint

Antes de dar por finalizado cualquier endpoint, verificar:

- [ ] Ruta en kebab-case (`/user-profiles`, no `/userProfiles`)
- [ ] Verbo HTTP correcto para la semántica de la operación
- [ ] DTO de entrada definido y validado con Zod en el middleware
- [ ] DTO de respuesta definido (tipado explícito, sin `any`)
- [ ] Código de estado HTTP correcto (`201` para creación, `200` para lectura/actualización, `204` para borrado sin cuerpo)
- [ ] Errores operacionales manejados con `AppError` (`services/express-api/src/errors/AppError.ts`)
- [ ] Errores de validación devuelven `400` con detalle de campos inválidos
- [ ] No se filtran stack traces ni detalles internos en respuestas de error
- [ ] No hay secretos, contraseñas ni datos sensibles en el cuerpo de respuesta

---

## Procedimiento

### 1. Definir el contrato primero

Antes de escribir lógica, especifica:

```typescript
// DTO de entrada
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
});
type CreateUserDto = z.infer<typeof CreateUserSchema>;

// DTO de respuesta
interface UserResponse {
  id: string;
  email: string;
  name: string;
  createdAt: string;
}
```

Comprueba si ya existe un tipo o schema equivalente antes de crear uno nuevo.

### 2. Validación de entrada

Toda entrada en el borde del sistema (body, params, query) debe validarse con un middleware antes de llegar al controller:

```typescript
// services/express-api/src/middleware/validate.ts
export const validate = (schema: ZodSchema) =>
  (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      return res.status(400).json({
        error: 'Validation failed',
        details: result.error.flatten().fieldErrors,
      });
    }
    req.body = result.data;
    next();
  };
```

Reglas:
- Validar `req.body`, `req.params` y `req.query` por separado
- Nunca confiar en datos no validados dentro del controller
- Usar `safeParse`, no `parse` (evitar excepciones no controladas)

### 3. Estructura de capas

```
router  →  validate middleware  →  controller  →  service  →  repository/DB
```

| Capa | Responsabilidad |
|------|-----------------|
| Router | Definir verbo, ruta y middlewares |
| Controller | Extraer datos de req, llamar servicio, formar respuesta |
| Service | Lógica de negocio, sin conocimiento de req/res |
| Repository | Acceso a datos, sin lógica de negocio |

El controller **no** contiene lógica de negocio. El service **no** importa `Request` ni `Response`.

### 4. Manejo de errores

Usar la clase `AppError` del proyecto y el error handler global registrado en `app.ts`:

```typescript
// services/express-api/src/errors/AppError.ts
export class AppError extends Error {
  constructor(
    public readonly statusCode: number,
    message: string,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

// services/express-api/src/middleware/errorHandler.ts
export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ error: err.message });
  }
  // Error inesperado: no filtrar detalles internos
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
};
```

Reglas:
- `AppError` para errores operacionales conocidos (404, 409, 403…)
- Nunca devolver stack traces al cliente
- Loguear errores inesperados en el servidor antes de responder `500`

### 5. Impacto en consumidores

Si el cambio afecta la firma del endpoint (ruta, método, body, respuesta), evaluar:

- [ ] ¿El frontend Angular consume este endpoint? → actualizar el servicio HTTP Angular
- [ ] ¿Cambia la forma del body de respuesta? → actualizar interfaces en Angular
- [ ] ¿Es un cambio breaking? → coordinar despliegue o versionar la ruta (`/v2/...`)
- [ ] ¿Hay tests de integración existentes para esta ruta? → actualizarlos

Documentar si el cambio es **backward-compatible** o **breaking** antes de la PR.

---

## Criterios de finalización

El endpoint está listo para PR cuando:

1. Checklist de endpoint completo
2. Tests unitarios del service
3. Test de integración de la ruta (al menos happy path + error de validación)
4. Contrato actualizado en Angular si hubo cambios en firma
5. Sin secrets hardcodeados
6. Sin `any` en tipos públicos del contrato
