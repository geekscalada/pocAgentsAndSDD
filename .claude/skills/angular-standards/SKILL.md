---
name: angular-standards
description: Playbook de estándares Angular para este monorepo. Invócalo con /angular-standards para obtener las convenciones, estructura, patrones y anti-patrones del frontend Angular del proyecto.
triggers:
  - /angular-standards
---

# Angular Standards — pocAgentesSubAgentesSDD

Playbook completo de cómo trabajamos con Angular en este monorepo.

## Estructura de ficheros

```
apps/angular-app/src/
  app/
    core/               → servicios singleton, guards globales, interceptors
      services/
      guards/
      interceptors/
    shared/             → componentes, pipes y directivas reutilizables
      components/
      pipes/
      directives/
    features/           → un módulo por funcionalidad de producto
      feature-name/
        components/     → componentes presentacionales de la feature
        containers/     → componentes contenedor con lógica
        services/       → servicios locales de la feature
        models/         → interfaces y tipos
        feature-routing.module.ts
        feature.module.ts
    app-routing.module.ts
    app.module.ts
```

## Componentes

**Naming:** `kebab-case` en ficheros, `PascalCase` en clase.
```typescript
// product-card.component.ts
@Component({
  selector: 'app-product-card',
  templateUrl: './product-card.component.html',
  styleUrls: ['./product-card.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush  // por defecto en presentacionales
})
export class ProductCardComponent { ... }
```

**Presentacional (dumb):** recibe `@Input()`, emite `@Output()`, sin lógica de negocio.
**Contenedor (smart):** inyecta servicios, gestiona estado, pasa datos a presentacionales.

**Límite de tamaño:** si un componente supera 300 líneas, descomponerlo.

## Estado

- **Local de componente:** propiedades, `signal()` (Angular 17+), o BehaviorSubject local.
- **Compartido entre rutas:** servicio inyectado en root o NgRx si el estado es complejo.
- **Regla inmutabilidad:** no mutar objetos/arrays; siempre spread `{...obj, campo: valor}`.

## Servicios HTTP

```typescript
// core/services/products.service.ts
@Injectable({ providedIn: 'root' })
export class ProductsService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/api/products';

  getAll(): Observable<Product[]> {
    return this.http.get<ProductDto[]>(this.baseUrl).pipe(
      map(dtos => dtos.map(mapProductDtoToModel))  // mapear en el servicio
    );
  }
}
```
- Siempre tipado explícito, nunca `any`.
- El mapeo DTO → modelo ocurre en el servicio, no en el componente.
- Los modelos del frontend son interfaces propias, no los DTOs del backend directamente.

## Formularios reactivos

```typescript
this.form = this.fb.group({
  email: ['', [Validators.required, Validators.email]],
  password: ['', [Validators.required, Validators.minLength(8)]]
});
```
- Validadores en el modelo TypeScript, no en el HTML.
- Errores mostrados condicionalmente desde el template accediendo a `form.get('campo')?.errors`.

## Subscripciones

Siempre limpiar para evitar memory leaks:
```typescript
// Opción recomendada Angular 16+
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

this.service.data$.pipe(
  takeUntilDestroyed()
).subscribe(data => this.data = data);

// O usar async pipe en template (automático)
<div *ngFor="let item of items$ | async">
```

## Rutas (lazy loading)

```typescript
// app-routing.module.ts
{
  path: 'products',
  loadChildren: () => import('./features/products/products.module').then(m => m.ProductsModule)
}
```

## Guards funcionales (Angular 15+)

```typescript
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  return authService.isAuthenticated() ? true : router.createUrlTree(['/login']);
};
```

## Anti-patrones

| Anti-patrón | Solución |
|-------------|----------|
| `any` en TypeScript | Interfaz o type explícito |
| `subscribe()` sin limpieza | `async pipe` o `takeUntilDestroyed()` |
| Lógica en template `(click)="a && b ? c() : d()"` | Mover a método del componente |
| Servicio compartido mutado directamente | Observable/signal + nuevas referencias |
| Importar `AppModule` completo en tests | `TestBed` con imports mínimos |
| `ChangeDetectionStrategy.Default` en todos los componentes | `OnPush` en presentacionales |

## Testing

- `describe('ComponentName', () => { ... })` con `beforeEach` configurando `TestBed`.
- Mocks de servicios: `jasmine.createSpyObj` o `jest.mock`.
- Verificar: render inicial, cambios de input, emisión de outputs, interacción usuario.
- No testear detalles de implementación interna, testear comportamiento visible.
