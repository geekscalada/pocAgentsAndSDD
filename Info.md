1. Una capa fija de normas, y no metería eso dentro del “dev”

Pondría en CLAUDE.md solo lo que debe aplicar siempre en todo el repo: arquitectura global, naming, reglas de seguridad, convenciones de PR, estrategia de testing, estructura monorepo, política de migraciones, reglas de no romper IaC, etc. Anthropic documenta CLAUDE.md precisamente para instrucciones persistentes de proyecto y además recomienda que sea conciso, porque entra en contexto en cada sesión y consume tokens; también deja claro que se trata como contexto, no como configuración rígida.

Para una app con Angular, Express y CDK, eso significa que CLAUDE.md debe contener la doctrina común y no los detalles finos de cada stack. Por ejemplo: “toda feature que toque API debe revisar contrato frontend/backend”, “todo cambio de infraestructura debe indicar impacto en entornos”, “no cambiar recursos críticos sin plan de rollback”, “los tests mínimos exigidos antes de abrir PR”. Eso encaja con el uso que Anthropic da a CLAUDE.md para coding standards, workflows y arquitectura.

2. El agente principal sería un orquestador de producto/tarea, no un programador gigante

Crearía un agente principal tipo app-orchestrator. Su función no sería implementar código en profundidad, sino:

entender la tarea,
decidir si afecta a Angular, Express, CDK o a varios,
trocearla,
delegar,
recomponer la salida,
y vigilar consistencia transversal.

Esto encaja con la idea de Anthropic de usar subagentes especializados con contexto separado, herramientas y permisos propios.

La regla mental sería: el principal piensa en coordinación; los subagentes piensan en ejecución especializada.

3. Haría 3 subagentes principales por stack, y 2 horizontales

Para tu caso, mi base sería esta:

frontend-angular

Responsable de:

componentes, templates, estilos, estado, rutas, guards, formularios
contratos consumidos desde Express
accesibilidad y UX técnica
tests unitarios/front
backend-express

Responsable de:

rutas, controllers, services, domain/app layers
validación, auth, middlewares, errores
persistencia y contratos API
tests unitarios/integración backend
infra-cdk

Responsable de:

stacks, constructs, permisos IAM, despliegues
networking, recursos cloud, observabilidad, secretos
impacto en coste y seguridad
drift y compatibilidad entre entornos

Y añadiría dos horizontales:

integration-reviewer

Solo revisa coherencia entre capas:

DTOs y schemas
naming de endpoints
impacto de cambios backend en Angular
impacto de cambios de CDK en backend/frontend
test-reviewer

Se centra en:

cobertura mínima razonable
tests que faltan
smoke paths
regresiones probables

Esto sigue mejor la recomendación de Anthropic de que los subagentes sean pequeños y nítidos, no uno enorme tipo “Dev” que hace todo.

4. No haría un “dev” único salvo como rol abstracto

Si quieres conservar la idea de “Dev”, lo dejaría como una etiqueta conceptual, no como subagente real. O sea:

“Dev” = intención general de implementación.
Los agentes reales = frontend-angular, backend-express, infra-cdk.

¿Por qué? Porque si el subagente dev tiene instrucciones generales y luego además carga skills de Angular, Express y CDK, acabas mezclando tres fronteras:

normas globales,
especialización por stack,
workflow operativo.

Eso suele generar ambigüedad de activación. Anthropic basa la invocación de subagentes y skills en sus descripciones y alcance, así que cuanto más solapadas estén sus responsabilidades, peor se comporta la delegación.

5. Las skills las separaría por “stack” y por “workflow”

Aquí es donde tu idea tiene mucho sentido.

No haría solo skills por tecnología. Haría dos familias:

Skills de stack
angular-standards
express-standards
cdk-standards

Estas contienen playbooks concretos:

cómo estructuráis Angular,
cómo modeláis servicios/controladores en Express,
cómo nombráis stacks y constructs en CDK,
anti-patrones de cada stack,
ejemplos buenos/malos.
Skills de workflow
debug-bug
implement-feature
refactor-safe
write-tests
review-pr
api-contract-change
deploy-checklist

Anthropic documenta los skills como extensiones reutilizables que Claude puede cargar cuando son relevantes o invocar directamente, y además soportan ejecución en subagentes y contexto dinámico.

La ventaja de esta separación es muy fuerte:

stack skills = “cómo trabajamos en esta tecnología”
workflow skills = “cómo hacemos este tipo de trabajo”

Eso te evita meter demasiado contenido en el prompt del subagente.

6. Qué skills preloaded pondría en cada subagente

Aquí yo no confiaría totalmente en lazy loading.

Anthropic permite skills y además recomienda mover instrucciones especializadas desde CLAUDE.md a skills para ahorrar contexto; también documenta que los skills pueden ejecutarse dentro de subagentes.

Mi reparto sería:

frontend-angular

Preloaded:

angular-standards
write-tests

On-demand:

debug-bug
refactor-safe
api-contract-change
review-pr
backend-express

Preloaded:

express-standards
write-tests

On-demand:

debug-bug
refactor-safe
api-contract-change
review-pr
infra-cdk

Preloaded:

cdk-standards
deploy-checklist

On-demand:

debug-bug
refactor-safe
review-pr
integration-reviewer

Preloaded:

api-contract-change
review-pr
test-reviewer

Preloaded:

write-tests
review-pr

La idea es: lo que el agente usa casi siempre va preloaded; lo que solo aparece en ciertos casos se deja on-demand. Eso reduce latencia mental y a la vez evita inflar todos los contextos. Está muy alineado con la recomendación de Anthropic de mover detalle especializado a skills y gestionar activamente el coste/contexto.

7. El flujo de trabajo real lo diseñaría así
Caso A: feature solo Angular

El orquestador detecta que el cambio es local al front y delega a frontend-angular.
Si hay cambio de mocks o contrato, llama después a integration-reviewer.

Caso B: feature Angular + Express
Orquestador descompone tarea.
backend-express propone o implementa contrato.
frontend-angular adapta consumo.
integration-reviewer comprueba encaje.
test-reviewer valida tests mínimos.
Caso C: feature que necesita infraestructura
infra-cdk define recursos/permisos/env vars/secrets.
backend-express adapta backend a esos recursos.
frontend-angular solo si hay impacto visible.
integration-reviewer revisa coherencia extremo a extremo.

Este patrón encaja mejor con los workflows prácticos que Anthropic documenta para explorar código, depurar, refactorizar, testear y preparar cambios reales, en vez de dejar todo a un solo agente difuso.

8. Hooks: aquí pondría el enforcement de verdad

Esto es muy importante.

No usaría prompts para imponer cosas que realmente quieres garantizar. Ahí usaría hooks. Anthropic define hooks como comandos shell, endpoints HTTP o prompts que se ejecutan automáticamente en puntos concretos del ciclo de vida de Claude Code.

Para tu app pondría hooks como estos:

PreToolUse

Antes de editar o ejecutar ciertos comandos:

bloquear cambios en cdk/production sin una marca explícita
impedir rm -rf, deploys o cambios masivos destructivos
exigir confirmación o etiqueta de tarea para tocar migraciones
PostToolUse

Tras editar:

lanzar lint del área afectada
lanzar typecheck
ejecutar tests rápidos del paquete tocado
validar formato
SubagentStart / TaskCreated
loggear qué subagente intervino
anotar la razón de delegación
limitar ciertos subagentes a ciertas carpetas
SessionEnd
generar resumen de cambios
listar riesgos pendientes
checklist antes de PR

Con esto, la parte “política y calidad” deja de depender solo de que el modelo se acuerde.

9. Cómo lo llevaría a repositorio

Yo lo estructuraría más o menos así:

repo/
├─ CLAUDE.md
├─ .claude/
│  ├─ agents/
│  │  ├─ app-orchestrator.md
│  │  ├─ frontend-angular.md
│  │  ├─ backend-express.md
│  │  ├─ infra-cdk.md
│  │  ├─ integration-reviewer.md
│  │  └─ test-reviewer.md
│  ├─ skills/
│  │  ├─ angular-standards/
│  │  │  └─ SKILL.md
│  │  ├─ express-standards/
│  │  │  └─ SKILL.md
│  │  ├─ cdk-standards/
│  │  │  └─ SKILL.md
│  │  ├─ implement-feature/
│  │  │  └─ SKILL.md
│  │  ├─ debug-bug/
│  │  │  └─ SKILL.md
│  │  ├─ refactor-safe/
│  │  │  └─ SKILL.md
│  │  ├─ write-tests/
│  │  │  └─ SKILL.md
│  │  ├─ api-contract-change/
│  │  │  └─ SKILL.md
│  │  ├─ review-pr/
│  │  │  └─ SKILL.md
│  │  └─ deploy-checklist/
│  │     └─ SKILL.md
│  └─ hooks/
│     ├─ pre_tool_use.sh
│     ├─ post_tool_use.sh
│     └─ session_end.sh
├─ apps/
│  └─ angular-app/
├─ services/
│  └─ express-api/
└─ infra/
   └─ cdk/
10. Cómo escribiría las responsabilidades

La regla sería esta:

CLAUDE.md: principios permanentes.
subagent: quién se encarga de qué.
skill: cómo se ejecuta un trabajo o cómo se trabaja en una tecnología.
hook: qué se comprueba o bloquea automáticamente.

Si mezclas esos cuatro niveles, el sistema se vuelve borroso.

11. Lo que evitaría

Evitaría tres cosas:

Un dev único

Porque termina absorbiendo Angular, Express, CDK, testing, revisión y deployment a la vez.

Skills demasiado grandes

Por ejemplo una sola skill fullstack-dev-rules con 500 líneas. Anthropic recomienda concisión y mover detalle especializado de forma selectiva para no inflar el contexto.

Demasiada delegación en cascada

Si una tarea es pequeña, que el orquestador no monte una coreografía de cinco agentes. Los subagentes ayudan, pero también añaden coste y contexto separado. Anthropic documenta explícitamente el coste/token management y el uso prudente de subagentes y skills.

12. Mi versión corta para tu caso

Si tuviera que empezar mañana, empezaría con esto y no más:

CLAUDE.md
app-orchestrator
frontend-angular
backend-express
infra-cdk
integration-reviewer

Skills iniciales:

angular-standards
express-standards
cdk-standards
implement-feature
debug-bug
write-tests
api-contract-change

Hooks iniciales:

lint/typecheck/test rápido tras edición
bloqueo de cambios peligrosos en CDK
resumen final de sesión

Eso ya te da una arquitectura seria sin pasarte de complejidad.