# Response — eval-detalle-pedido (without_skill)

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
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { ActivatedRoute } from '@angular/router';
import { toSignal, toObservable } from '@angular/core/rxjs-interop';
import { switchMap, map } from 'rxjs/operators';
import { EMPTY } from 'rxjs';
import { Pedido } from './pedido.model';

@Component({
  selector: 'app-detalle-pedido',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (pedido() === null) {
      <p>Cargando pedido...</p>
    } @else if (pedido() === undefined) {
      <p>No se pudo cargar el pedido.</p>
    } @else {
      <div class="pedido-detalle">
        <h2>Pedido #{{ pedido()!.id }}</h2>
        <dl>
          <dt>Estado</dt><dd>{{ pedido()!.estado }}</dd>
          <dt>Total</dt><dd>{{ pedido()!.total | currency:'EUR' }}</dd>
        </dl>
        <h3>Líneas del pedido</h3>
        @for (linea of pedido()!.lineas; track linea.productoId) {
          <tr>
            <td>{{ linea.productoId }}</td>
            <td>{{ linea.cantidad }}</td>
            <td>{{ linea.precio | currency:'EUR' }}</td>
          </tr>
        } @empty {
          <p>Este pedido no tiene líneas.</p>
        }
      </div>
    }
  `,
})
export class DetallePedidoComponent {
  private readonly http = inject(HttpClient);
  private readonly route = inject(ActivatedRoute);

  private readonly pedidoId = toSignal(
    this.route.paramMap.pipe(map(params => params.get('id')))
  );

  readonly pedido = toSignal(
    toObservable(this.pedidoId).pipe(
      switchMap(id => id ? this.http.get<Pedido>(`/api/pedidos/${id}`) : EMPTY)
    ),
    { initialValue: null }
  );
}
```
