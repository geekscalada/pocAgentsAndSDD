# Response — eval-lista-productos (without_skill)

**`producto.model.ts`**
```ts
export interface Producto {
  id: number;
  nombre: string;
  precio: number;
}
```

**`productos.service.ts`**
```ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Producto } from './producto.model';

@Injectable({
  providedIn: 'root'
})
export class ProductosService {
  private apiUrl = 'http://localhost:3000/productos';

  constructor(private http: HttpClient) {}

  getProductos(): Observable<Producto[]> {
    return this.http.get<Producto[]>(this.apiUrl);
  }
}
```

**`productos.component.ts`**
```ts
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProductosService } from './productos.service';
import { Producto } from './producto.model';

@Component({
  selector: 'app-productos',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './productos.component.html',
  styleUrls: ['./productos.component.css']
})
export class ProductosComponent implements OnInit {
  productos: Producto[] = [];
  cargando = false;
  error: string | null = null;

  constructor(private productosService: ProductosService) {}

  ngOnInit(): void {
    this.cargarProductos();
  }

  cargarProductos(): void {
    this.cargando = true;
    this.error = null;
    this.productosService.getProductos().subscribe({
      next: (datos) => {
        this.productos = datos;
        this.cargando = false;
      },
      error: (err) => {
        this.error = 'Error al cargar los productos.';
        this.cargando = false;
      }
    });
  }
}
```

**`productos.component.html`**
```html
<div class="productos-container">
  <h2>Lista de Productos</h2>
  <div *ngIf="cargando" class="cargando">Cargando productos...</div>
  <div *ngIf="error" class="error">{{ error }}</div>
  <ul *ngIf="!cargando && !error" class="productos-lista">
    <li *ngFor="let producto of productos" class="producto-item">
      <span class="producto-id">#{{ producto.id }}</span>
      <span class="producto-nombre">{{ producto.nombre }}</span>
      <span class="producto-precio">{{ producto.precio | currency:'EUR' }}</span>
    </li>
  </ul>
  <p *ngIf="!cargando && !error && productos.length === 0" class="sin-productos">
    No hay productos disponibles.
  </p>
</div>
```
