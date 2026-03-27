# Response — eval-formulario-post (with_skill)

**`producto.model.ts`**
```ts
// Interfaz generada desde el schema de la spec
// POST /productos — body de la petición
export interface CrearProductoDto {
  nombre: string;
  precio: number;
  stock: number;
}

// Respuesta del servidor: producto creado con su id
export interface Producto {
  id: number;
  nombre: string;
  precio: number;
  stock: number;
}
```

**`crear-producto.component.ts`**
```ts
import { Component, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { CrearProductoDto, Producto } from './producto.model';

@Component({
  selector: 'app-crear-producto',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <h2>Crear Producto</h2>
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <label>
        Nombre
        <input type="text" formControlName="nombre" />
      </label>
      <label>
        Precio
        <input type="number" formControlName="precio" />
      </label>
      <label>
        Stock
        <input type="number" formControlName="stock" />
      </label>
      <button type="submit" [disabled]="form.invalid || enviando()">
        @if (enviando()) { Guardando... } @else { Crear producto }
      </button>
    </form>

    @if (productoCreado()) {
      <div class="resultado">
        <p>Producto creado con éxito. ID asignado: <strong>{{ productoCreado()!.id }}</strong></p>
      </div>
    }
    @if (error()) {
      <p class="error">Error al crear el producto: {{ error() }}</p>
    }
  `,
})
export class CrearProductoComponent {
  private readonly http = inject(HttpClient);
  private readonly fb = inject(FormBuilder);

  readonly enviando = signal(false);
  readonly productoCreado = signal<Producto | null>(null);
  readonly error = signal<string | null>(null);

  readonly form = this.fb.group({
    nombre: ['', [Validators.required, Validators.minLength(2)]],
    precio: [null as number | null, [Validators.required, Validators.min(0)]],
    stock:  [null as number | null, [Validators.required, Validators.min(0)]],
  });

  onSubmit(): void {
    if (this.form.invalid) return;
    this.enviando.set(true);
    this.productoCreado.set(null);
    this.error.set(null);

    const body: CrearProductoDto = this.form.getRawValue() as CrearProductoDto;

    this.http.post<Producto>('/api/productos', body).subscribe({
      next: (producto) => {
        this.productoCreado.set(producto);
        this.enviando.set(false);
        this.form.reset();
      },
      error: (err) => {
        this.error.set(err?.message ?? 'Error desconocido');
        this.enviando.set(false);
      },
    });
  }
}
```
