---
name: skill-angular
description: >
  Guía para generar código de ejemplo Angular 21 moderno que consuma endpoints REST
  definidos en una spec OpenAPI. Usa esta skill siempre que el usuario quiera
  desarrollar en Angular, crear un componente, servicio o módulo Angular, integrar
  un frontend Angular con una API, o mostrar cómo quedaría código Angular consumiendo
  un endpoint. Actívala también cuando el usuario mencione Angular sin más detalle —
  probablemente necesita esta guía de patrones modernos.
---

# Skill Angular 21 — Generación de Código de Ejemplo

Esta skill guía la generación de código Angular 21 moderno a partir de una spec OpenAPI.
El código producido es **dummy/demostrativo**: ilustra patrones correctos pero no es
un scaffold completo ni código listo para producción.

## Prerrequisito obligatorio

Antes de generar código debes tener la spec OpenAPI del endpoint a consumir.
Si no la tienes, detente y solicítala explícitamente — sin el contrato no puedes
garantizar que los tipos y la URL sean correctos.

## Patrones Angular 21 que debes usar siempre

### Componentes standalone (sin NgModule)
En Angular 21 todos los componentes son standalone por defecto. No generes `NgModule`.

```ts
@Component({
  selector: 'app-ejemplo',
  standalone: true,
  imports: [CommonModule],   // solo lo necesario
  template: `...`
})
export class EjemploComponent { }
```

### Inyección con `inject()` (sin constructor)
Usa siempre `inject()` en lugar de inyección por constructor.

```ts
private readonly http = inject(HttpClient);
private readonly router = inject(Router);
```

### Signals para estado reactivo
Usa `signal()`, `computed()` y `effect()` para gestionar estado local.

```ts
readonly datos = signal<Producto[]>([]);
readonly total = computed(() => this.datos().length);
```

### `input()` y `output()` para comunicación entre componentes
Sustituye `@Input()` y `@Output()` por las funciones de señal.

```ts
readonly productoId = input.required<number>();
readonly seleccionado = output<Producto>();
```

### Nuevo control flow en templates (`@if`, `@for`, `@switch`, `@defer`)
No uses `*ngIf` ni `*ngFor`. Usa la syntaxis de bloque.

```html
@if (cargando()) {
  <p>Cargando...</p>
} @else {
  @for (item of datos(); track item.id) {
    <li>{{ item.nombre }}</li>
  } @empty {
    <li>Sin resultados</li>
  }
}
```

### Carga HTTP con `toSignal` + `HttpClient`
Convierte observables a signals usando `toSignal` de `@angular/core/rxjs-interop`.

```ts
private readonly http = inject(HttpClient);

readonly productos = toSignal(
  this.http.get<Producto[]>('/api/productos'),
  { initialValue: [] }
);
```

Para llamadas bajo demanda (ej. al click de un botón), usa un `signal` de trigger:

```ts
readonly trigger = signal(0);
readonly datos = toSignal(
  toObservable(this.trigger).pipe(
    switchMap(() => this.http.get<Producto[]>('/api/productos'))
  ),
  { initialValue: [] }
);

recargar() { this.trigger.update(v => v + 1); }
```

### Proveedores en `app.config.ts` (sin `AppModule`)

```ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(),
  ]
};
```

## Pasos al aplicar la skill

1. **Leer la spec**: identifica path, método HTTP, parámetros y schema de respuesta.
2. **Definir qué ficheros generar**: como mínimo un `*.component.ts` con su template inline y una interfaz TypeScript del modelo.
3. **Tipar la respuesta**: crea una interfaz que coincida exactamente con el response schema de la spec.
4. **Implementar el componente**: aplica todos los patrones modernos descritos arriba.
5. **Verificar coherencia**: comprueba que la URL, el método HTTP y los tipos coinciden con la spec antes de devolver el código.

## Formato de salida

Devuelve bloques de código con el nombre del fichero como título. El código debe estar
comentado para que sirva como ejemplo explicativo.

**`producto.model.ts`**
```ts
// Interfaz generada desde el schema de la spec
export interface Producto {
  id: number;
  nombre: string;
  precio: number;
}
```

**`productos.component.ts`**
```ts
// código aquí
```

No incluyas imports que no sean estándar de Angular. No generes `NgModule`.
Recuerda: el objetivo es código de ejemplo claro y didáctico, no un proyecto funcional completo.
