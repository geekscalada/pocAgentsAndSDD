---
name: sync-contracts
description: Revisa si un cambio en frontend y backend ha dejado contratos inconsistentes y propone una sincronización mínima.
agent: app-orchestrator
argument-hint: describe el endpoint o la feature afectada
---

# For adademic purpose only section
- usa argument-hint para orientar al usuario;
- usa ${input:...} para los datos realmente importantes;


Review the current change with a focus on frontend/backend contract consistency.

Tasks:

1. Identify the affected API contract.
2. Compare backend producer and frontend consumer expectations.
3. Detect mismatches in:
   - request payload
   - response payload
   - optional vs required fields
   - error handling
4. Propose the smallest coordinated change set.
5. Summarize:
   - what is inconsistent
   - what should change in Angular
   - what should change in Express
   - any deployment or config impact

Be concise and prioritize backward compatibility when possible.
