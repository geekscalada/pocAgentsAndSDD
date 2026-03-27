# Response — eval-detalle-pedido (with_skill)

**`pedido.model.ts`**
```ts
export interface LineaPedido {
  productoId: number;
  cantidad: number;
  precio: number;
}

export interface Pedido {
  id: number;
  estado: string;
  total: number;
  lineas: LineaPedido[];
}
```

**`detalle-pedido.component.ts`**
```ts
import { Component, inject, input } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule, CurrencyPipe } from '@angular/common';
import { toSignal, toObservable } from '@angular/core/rxjs-interop';
import { switchMap } from 'rxjs/operators';
import { Pedido } from './pedido.model';

@Component({
  selector: 'app-detalle-pedido',
  standalone: true,
  imports: [CommonModule, CurrencyPipe],
  template: `
    @if (pedido() === undefined) {
      <p class="estado-carga">Cargando pedido...</p>
    } @else {
      <section class="detalle-pedido">
        <h2>Pedido #{{ pedido()!.id }}</h2>
        <dl class="resumen">
          <dt>Estado</dt><dd>{{ pedido()!.estado }}</dd>
          <dt>Total</dt><dd>{{ pedido()!.total | currency:'EUR' }}</dd>
        </dl>
        <h3>Líneas del pedido</h3>
        <table>
          <thead><tr><th>Producto ID</th><th>Cantidad</th><th>Precio</th></tr></thead>
          <tbody>
            @for (linea of pedido()!.lineas; track linea.productoId) {
              <tr>
                <td>{{ linea.productoId }}</td>
                <td>{{ linea.cantidad }}</td>
                <td>{{ linea.precio | currency:'EUR' }}</td>
              </tr>
            } @empty {
              <tr><td colspan="3">Este pedido no tiene líneas.</td></tr>
            }
          </tbody>
        </table>
      </section>
    }
  `,
})
export class DetallePedidoComponent {
  readonly id = input.required<string>();
  private readonly http = inject(HttpClient);

  readonly pedido = toSignal<Pedido>(
    toObservable(this.id).pipe(
      switchMap((id) => this.http.get<Pedido>(`/api/pedidos/${id}`))
    )
  );
}
```

**`app.config.ts`**
```ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes, withComponentInputBinding()),
    provideHttpClient(),
  ],
};
```
