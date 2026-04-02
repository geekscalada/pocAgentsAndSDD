---
name: angular-standards
description: "Guía reusable para implementar cambios en Angular. Úsala para: crear componentes, servicios, formularios reactivos, rutas, guards, interceptors o consumir endpoints. Incluye checklist de feature, orden de trabajo recomendado, antipatrones y criterios de done. Activa cuando implementes features Angular, revises código frontend, o necesites recordar las convenciones del proyecto."
argument-hint: "Describe la feature o cambio Angular que vas a implementar"
---

# For adademic purpose only section

Cuando el proyecto es grande y crece podemos partir esta skill en:
 angular-forms, angular-routing-guards, angular-state-management, angular-component-patterns, angular-testing, angular-performance o angular-design-system.


# Angular Standards

Guía de implementación para el frontend Angular de este monorepo (`apps/angular-app/`).

## Cuándo cargar esta skill

- Antes de crear un componente, servicio, guard, interceptor o formulario nuevo.
- Cuando vayas a consumir un endpoint de la API Express.
- Cuando revises o refactorices código Angular existente.
- Cuando el agente `angular-implementer` lo indique explícitamente.

---

## Orden de trabajo recomendado

Sigue este orden para cualquier feature Angular, de mayor a menor riesgo de iterar al final:

1. **Confirma el contrato API** — Verifica que el endpoint que vas a consumir ya existe en Express. No inventes payloads. Si el endpoint no existe, para y señala la dependencia.
2. **Busca patrones existentes** — Explora `apps/angular-app/` antes de escribir nada. Si hay un componente o servicio similar, extiéndelo.
3. **Define el modelo/tipo** — Crea o reutiliza la interfaz TypeScript que representa el dato. Un tipo por concepto, en el fichero del servicio o en `models/`.
4. **Crea o actualiza el servicio** — El servicio hace la llamada HTTP y expone Observables. Nada de lógica de presentación en el servicio.
5. **Crea el componente** — Solo lógica de presentación y manejo de eventos. Delega al servicio para datos.
6. **Registra la ruta** — Si el componente necesita ruta, añádela en el módulo de rutas correspondiente.
7. **Añade guard o interceptor** si la ruta requiere autenticación o el servicio necesita cabeceras.
8. **Escribe los tests** — Un spec por componente/servicio. Sigue los patrones existentes en `apps/angular-app/`.
9. **Comprueba la checklist de done** (ver abajo) antes de dar por terminado.

---

## Checklist de feature Angular

### Estructura y naming

- [ ] Componentes en PascalCase: `UserListComponent`
- [ ] Ficheros en kebab-case: `user-list.component.ts`, `user-list.component.html`, `user-list.component.spec.ts`
- [ ] Servicios con sufijo `Service`: `UserService`
- [ ] Guards con sufijo `Guard`: `AuthGuard`
- [ ] Interceptors con sufijo `Interceptor`: `AuthInterceptor`
- [ ] Módulos con sufijo `Module`: `UsersModule`
- [ ] Cada pieza en su carpeta feature: `users/`, `auth/`, `shared/`

### Servicios HTTP

- [ ] El servicio inyecta `HttpClient`
- [ ] Las URLs se construyen con las constantes de `environment.ts` / `environment.prod.ts`. Nunca hardcodeadas.
- [ ] Los métodos devuelven `Observable<T>`, no promesas, salvo caso excepcional justificado.
- [ ] El tipo de respuesta está tipado explícitamente (no `any`).
- [ ] Los errores se propagan con `catchError` o se manejan en el componente con `error` en `subscribe`.

### Formularios reactivos

- [ ] Se usa `ReactiveFormsModule`, no `FormsModule` para formularios complejos.
- [ ] `FormGroup` y `FormControl` definidos en el componente, no en la plantilla.
- [ ] Validadores estándar de Angular cuando sea posible; validadores custom como funciones puras.
- [ ] El submit está deshabilitado mientras `form.invalid`.
- [ ] Los mensajes de error se muestran condicionalmente con `*ngIf` o `@if` sobre `control.errors`.

### Rutas y guards

- [ ] Las rutas lazy-load los módulos feature con `loadChildren` o `loadComponent` (standalone).
- [ ] Los guards implementan `CanActivate` (o la función equivalente en Angular 17+).
- [ ] No hay lógica de negocio dentro de los guards; delegan a servicios.

### Estado y async

- [ ] Se usa `AsyncPipe` en la plantilla cuando sea posible (`observable$ | async`).
- [ ] No se llama a `.subscribe()` en el `ngOnInit` sin gestionar la desuscripción (`takeUntilDestroyed`, `DestroyRef`, o `Subject` + `takeUntil`).
- [ ] No se almacena estado mutable en el componente si ya existe en un servicio o store.

### Tests

- [ ] Existe `*.spec.ts` para cada componente y servicio creado o modificado.
- [ ] El test del servicio usa `HttpClientTestingModule` y `HttpTestingController`.
- [ ] El test del componente usa `TestBed.configureTestingModule` con los providers mínimos necesarios.
- [ ] Se testean al menos: renderizado inicial, emisión de eventos clave y manejo de error del servicio.
- [ ] Los tests pasan con `ng test` antes de hacer PR.

---

## Qué revisar antes de dar por terminado

Antes de marcar la tarea como done o abrir PR, verifica:

1. **Ningún `any` sin justificar** — revisa el diff en busca de `any` explícito.
2. **Sin URLs hardcodeadas** — busca `http://` o `localhost` en el código nuevo.
3. **Sin `console.log` olvidados** — limpia logs de depuración.
4. **Contrato API no roto** — si cambiaste el tipo de Request/Response, confirma con Express.
5. **Tests ejecutados** — `ng test --watch=false` sin errores.
6. **Sin imports innecesarios** — elimina imports no usados del módulo y del componente.
7. **Módulo actualizado** — el componente está declarado (o importado si es standalone) en el módulo correcto.
8. **Ruta registrada** — si es una página nueva, la ruta existe y el guard correcto la protege.

---

## Antipatrones a evitar

| Antipatrón | Por qué evitarlo | Alternativa |
|---|---|---|
| Lógica de negocio en el componente | Rompe la separación de responsabilidades, dificulta tests | Mover al servicio correspondiente |
| `any` como tipo de respuesta HTTP | Oculta errores en tiempo de compilación | Definir interfaz TypeScript explícita |
| `subscribe` sin desuscripción | Memory leak en componentes que se destruyen y recrean | `takeUntilDestroyed` o `AsyncPipe` |
| URL hardcodeada en el servicio | Imposible cambiar entre entornos | Usar `environment.apiUrl` |
| Importar `HttpClientModule` en cada feature | Genera múltiples instancias del cliente | Importar solo en `AppModule` o `provideHttpClient()` en bootstrap |
| Componente con más de ~300 LOC | Difícil de testear y mantener | Extraer subcomponentes o lógica al servicio |
| Formulario con `FormsModule` (two-way binding) en formulario complejo | Difícil de validar y testear | `ReactiveFormsModule` + `FormGroup` |
| Guard con lógica de negocio interna | No testeable, no reutilizable | Delegar a `AuthService` u otro servicio |
| Llamada HTTP directa en el componente | Duplica código, imposible mockear en tests | Siempre a través del servicio |
| Importar módulos standalone en `declarations` | Error de compilación | Usar `imports: []` para standalone |

---

## Referencia de estructura de ficheros

```
apps/angular-app/src/
├── app/
│   ├── core/                  # Servicios singleton, interceptors, guards globales
│   │   ├── auth/
│   │   │   ├── auth.guard.ts
│   │   │   ├── auth.interceptor.ts
│   │   │   └── auth.service.ts
│   │   └── core.module.ts
│   ├── features/              # Módulos feature con lazy load
│   │   └── <feature>/
│   │       ├── <feature>.module.ts
│   │       ├── <feature>-routing.module.ts
│   │       ├── components/
│   │       │   └── <name>/
│   │       │       ├── <name>.component.ts
│   │       │       ├── <name>.component.html
│   │       │       ├── <name>.component.scss
│   │       │       └── <name>.component.spec.ts
│   │       └── services/
│   │           ├── <feature>.service.ts
│   │           └── <feature>.service.spec.ts
│   └── shared/                # Componentes, pipes y directivas reutilizables
├── environments/
│   ├── environment.ts
│   └── environment.prod.ts
└── main.ts
```

---

## Dependencias entre capas

- Esta skill cubre solo `apps/angular-app/`.
- Si necesitas un endpoint nuevo o modificado en Express, usa el agente `express-implementer` antes de continuar.
- Si el cambio afecta contrato API (método, ruta, DTO), notifica al agente `integration-reviewer`.
- Para cambios full-stack coordina con `app-orchestrator`.
