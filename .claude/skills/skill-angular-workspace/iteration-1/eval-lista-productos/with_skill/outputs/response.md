# Response — eval-lista-productos (with_skill)

**`producto.model.ts`**
```ts
// Interfaz generada desde el schema de la spec
// Endpoint: GET /productos
// Response schema: array de { id, nombre, precio }
export interface Producto {
  id: number;
  nombre: string;
  precio: number;
}
```

**`productos.component.ts`**
```ts
import { Component, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { toSignal } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { Producto } from './producto.model';

// Componente standalone — no se requiere NgModule (Angular 21)
@Component({
  selector: 'app-productos',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (!productos()) {
      <p>Cargando productos...</p>
    } @else {
      <ul>
        @for (producto of productos(); track producto.id) {
          <li>
            <strong>{{ producto.nombre }}</strong> —
            {{ producto.precio | currency:'EUR' }}
          </li>
        } @empty {
          <li>No hay productos disponibles.</li>
        }
      </ul>
    }
  `,
})
export class ProductosComponent {
  // Inyección con inject() — sin constructor (patrón Angular 21)
  private readonly http = inject(HttpClient);

  // toSignal convierte el observable HTTP a un signal reactivo.
  readonly productos = toSignal<Producto[]>(
    this.http.get<Producto[]>('/api/productos')
  );
}
```

**`app.config.ts`** (extracto)
```ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(),
  ],
};
```
