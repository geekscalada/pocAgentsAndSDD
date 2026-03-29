---
name: deploy-checklist
description: Checklist pre-deploy para validar que todo está en orden antes de un despliegue a staging o producción. Cubre infra CDK, backend Express y frontend Angular.
---

# Deploy Checklist

Checklist a completar antes de cualquier despliegue a staging o producción.

## Regla de oro

**Nunca hacer `cdk deploy` en staging/producción sin revisar este checklist y confirmar con el usuario.**

---

## 1. Cambios de infraestructura (CDK)

- [ ] `cdk diff` ejecutado y revisado en detalle.
- [ ] ¿Algún recurso va a ser **reemplazado** (CloudFormation replace)? → Confirmar con usuario, puede implicar downtime o pérdida de datos.
- [ ] ¿Algún recurso va a ser **eliminado**? → Reverificar `RemovalPolicy`; en prod debe ser `RETAIN` para recursos con datos.
- [ ] ¿Cambian permisos IAM? → Revisar que siguen principio mínimo privilegio.
- [ ] ¿Cambia algún secreto o variable de entorno? → Coordinar rotación si es necesario y verificar que el código los lee correctamente.
- [ ] ¿Hay nuevos recursos que requieren configuración inicial? (tablas con datos semilla, queues con DLQ, etc.)
- [ ] ¿Impacto estimado en coste? (nuevo recurso, cambio de tier, mayor concurrencia)

## 2. Backend (Express / Lambda)

- [ ] Los tests pasan en CI/CD.
- [ ] No hay migraciones de base de datos pendientes sin ejecutar.
- [ ] Si hay migraciones: ¿son reversibles? ¿está documentado el rollback?
- [ ] Todas las variables de entorno requeridas están definidas en el entorno destino.
- [ ] Todos los secretos referenciados existen en Secrets Manager/SSM del entorno destino.
- [ ] Si cambia algún endpoint: ¿el frontend está actualizado o hay compatibilidad hacia atrás?
- [ ] No hay `console.log` de debugging en el código.

## 3. Frontend (Angular)

- [ ] Build de producción completado sin errores (`ng build --configuration production`).
- [ ] No hay errores de TypeScript en build de producción.
- [ ] Las URLs de endpoints apuntan al entorno correcto (no a localhost ni a endpoints de dev).
- [ ] Las variables de entorno Angular (`environment.prod.ts`) están correctas.
- [ ] Assets optimizados: imágenes comprimidas, lazy loading configurado.

## 4. Coherencia entre stacks

- [ ] Si se despliega CDK y Express juntos: verificar orden correcto (CDK primero si hay recursos nuevos que el backend necesita).
- [ ] Si se despliegan cambios de API: frontend y backend alineados en contrato.
- [ ] Los entornos destino (dev/staging/prod) tienen la misma configuración estructural (no datos, sino variables, secrets, recursos).

## 5. Plan de rollback

Para cada stack afectado, documentar:

```
## Plan de rollback — [nombre del deploy]

**CDK:**
- Rollback: cdk deploy con el commit anterior del stack
- Recursos con estado afectados: [lista o "ninguno"]
- Tiempo estimado de rollback: X minutos

**Backend:**
- Rollback: redeployar Lambda/ECS con la imagen anterior
- Migraciones irreversibles: [lista o "ninguna"]

**Frontend:**
- Rollback: redeployar S3/CloudFront con la versión anterior
- Tiempo estimado: < 5 minutos
```

## 6. Go/No-Go

Antes de ejecutar el deploy, confirmar:

- [ ] Todos los checks anteriores completados.
- [ ] El equipo está disponible para monitorizar durante y después del deploy.
- [ ] No es un momento de alto tráfico (si es crítico, preferir hora de baja actividad).
- [ ] Las alarmas de CloudWatch están activas.
- [ ] Confirmación explícita del usuario para proceder.

---

## Después del deploy

- [ ] Verificar logs en CloudWatch: no hay errores inesperados.
- [ ] Smoke test manual del flujo principal.
- [ ] Confirmar que las métricas (latencia, error rate) están en rangos normales.
- [ ] Si es release importante: comunicar al equipo.
