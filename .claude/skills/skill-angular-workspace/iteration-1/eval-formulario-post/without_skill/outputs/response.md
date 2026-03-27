# Response — eval-formulario-post (without_skill)

**`producto.model.ts`**
```ts
export interface CrearProductoDto {
  nombre: string;
  precio: number;
  stock: number;
}

export interface Producto {
  id: number;
  nombre: string;
  precio: number;
  stock: number;
}
```

**`producto.service.ts`** (servicio separado — patrón antiguo)
```ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { CrearProductoDto, Producto } from './producto.model';

@Injectable({ providedIn: 'root' })
export class ProductoService {
  private readonly apiUrl = 'http://localhost:3000/productos';

  constructor(private http: HttpClient) {}

  crearProducto(dto: CrearProductoDto): Observable<Producto> {
    return this.http.post<Producto>(this.apiUrl, dto);
  }
}
```

**`crear-producto.component.ts`** (con constructor injection, sin signals)
```ts
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ProductoService } from '../producto.service';
import { Producto } from '../producto.model';

@Component({
  selector: 'app-crear-producto',
  templateUrl: './crear-producto.component.html',
})
export class CrearProductoComponent {
  form: FormGroup;
  productoCreado: Producto | null = null;
  errorMensaje: string | null = null;
  enviando = false;

  constructor(private fb: FormBuilder, private productoService: ProductoService) {
    this.form = this.fb.group({
      nombre: ['', [Validators.required, Validators.minLength(2)]],
      precio: [null, [Validators.required, Validators.min(0)]],
      stock:  [null, [Validators.required, Validators.min(0)]]
    });
  }

  onSubmit(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.enviando = true;
    this.productoService.crearProducto(this.form.value).subscribe({
      next: (producto) => { this.productoCreado = producto; this.enviando = false; this.form.reset(); },
      error: (err) => { this.errorMensaje = 'Error al crear el producto.'; this.enviando = false; }
    });
  }
}
```

**`crear-producto.component.html`** (con *ngIf — patrón antiguo)
```html
<form [formGroup]="form" (ngSubmit)="onSubmit()">
  <input type="text" formControlName="nombre" />
  <span *ngIf="form.get('nombre')?.invalid && form.get('nombre')?.touched">Nombre requerido</span>
  <input type="number" formControlName="precio" />
  <input type="number" formControlName="stock" />
  <button type="submit" [disabled]="enviando">Crear Producto</button>
</form>
<div *ngIf="productoCreado">ID: {{ productoCreado.id }}</div>
<div *ngIf="errorMensaje">{{ errorMensaje }}</div>
```

**`app.module.ts`** (NgModule — patrón antiguo)
```ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { CrearProductoComponent } from './crear-producto/crear-producto.component';

@NgModule({
  declarations: [CrearProductoComponent],
  imports: [BrowserModule, ReactiveFormsModule, HttpClientModule],
  bootstrap: []
})
export class AppModule {}
```
