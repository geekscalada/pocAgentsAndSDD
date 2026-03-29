---
name: cdk-standards
description: Playbook de estándares AWS CDK para este monorepo. Invócalo con /cdk-standards para obtener las convenciones de naming, estructura de stacks, patrones IAM, gestión de secretos y anti-patrones de infraestructura del proyecto.
---

# CDK Standards — pocAgentesSubAgentesSDD

Playbook completo de cómo trabajamos con AWS CDK en este monorepo.

## Estructura

```
infra/cdk/
  bin/
    app.ts              → entry point: instancia stacks por entorno
  lib/
    stacks/
      api-service.stack.ts
      frontend.stack.ts
      data.stack.ts
      observability.stack.ts
    constructs/         → constructs reutilizables (L3)
      api-lambda.construct.ts
      secure-bucket.construct.ts
  config/
    environments.ts     → configuración por entorno (dev/staging/prod)
    constants.ts        → valores compartidos entre stacks
  test/
    stacks/             → tests de snapshot y assertion por stack
```

## Naming

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Stack class | `PascalCaseStack` | `ApiServiceStack` |
| Construct class | `PascalCase` | `ApiLambda`, `UserTable` |
| Construct ID (CDK) | `PascalCase`, estable y descriptivo | `UsersTable`, `ApiHandler` |
| Recurso AWS | `{env}-{project}-{recurso}` | `prod-myapp-users-table` |
| SSM Parameter | `/{env}/{service}/{param}` | `/prod/api/database-url` |
| Secret | `{env}/{service}/{secret}` | `prod/api/jwt-secret` |

**Regla crítica de IDs:** los construction IDs deben ser estables entre deploys. Cambiar un ID provoca destroy + recreate del recurso (crítico en recursos con estado).

## Configuración por entorno

```typescript
// config/environments.ts
export type Environment = 'dev' | 'staging' | 'prod';

export interface EnvironmentConfig {
  env: Environment;
  account: string;
  region: string;
  domainName?: string;
  lambdaMemory: number;
  dbInstanceClass: ec2.InstanceClass;
  removalPolicy: cdk.RemovalPolicy;
  deletionProtection: boolean;
}

export const environments: Record<Environment, EnvironmentConfig> = {
  dev: {
    env: 'dev',
    lambdaMemory: 256,
    removalPolicy: cdk.RemovalPolicy.DESTROY,
    deletionProtection: false,
    // ...
  },
  prod: {
    env: 'prod',
    lambdaMemory: 1024,
    removalPolicy: cdk.RemovalPolicy.RETAIN,   // SIEMPRE RETAIN en prod con datos
    deletionProtection: true,
    // ...
  }
};
```

## IAM — mínimo privilegio

```typescript
// ✅ Correcto: grant específico
table.grantReadWriteData(lambdaFunction);
bucket.grantRead(lambdaFunction);

// ✅ Correcto: política específica cuando no hay grant helper
lambdaFunction.addToRolePolicy(new iam.PolicyStatement({
  actions: ['ses:SendEmail'],
  resources: [`arn:aws:ses:${this.region}:${this.account}:identity/${senderEmail}`],
}));

// ❌ Incorrecto: demasiado permisivo
new iam.PolicyStatement({ actions: ['*'], resources: ['*'] });
```

## Secretos y configuración

```typescript
// Secreto en Secrets Manager
const dbSecret = new secretsmanager.Secret(this, 'DbSecret', {
  secretName: `${env}/api/db-credentials`,
  generateSecretString: {
    secretStringTemplate: JSON.stringify({ username: 'admin' }),
    generateStringKey: 'password',
    excludeCharacters: '/@"',
  },
});

// Inyectar en Lambda (sin exposer valor en CloudFormation)
const fn = new lambda.Function(this, 'ApiHandler', {
  environment: {
    DB_SECRET_ARN: dbSecret.secretArn,   // ARN, no el valor
  }
});
dbSecret.grantRead(fn);

// En el código Express/Lambda: leer en runtime, no en deploy
const secret = await secretsClient.getSecretValue({ SecretId: process.env.DB_SECRET_ARN });
```

**Nunca:**
- `secretValue.toString()` o `secretValue.unsafeUnwrap()` en código CDK (expone en template de CloudFormation).
- Variables de entorno Lambda con valores de secretos directamente.

## Cross-stack references

```typescript
// Stack A: exportar
new cdk.CfnOutput(this, 'TableArn', {
  value: this.table.tableArn,
  exportName: `${env}-myapp-users-table-arn`,
});

// Stack B: importar
const tableArn = cdk.Fn.importValue(`${env}-myapp-users-table-arn`);
```

O mejor: pasar referencias directamente si los stacks se instancian juntos en `bin/app.ts`.

## Tagging obligatorio

```typescript
// bin/app.ts — aplicar a toda la app
cdk.Tags.of(app).add('Project', 'myapp');
cdk.Tags.of(app).add('Environment', env);
cdk.Tags.of(app).add('ManagedBy', 'cdk');
```

## Tests CDK

```typescript
// test/stacks/api-service.stack.test.ts
describe('ApiServiceStack', () => {
  let template: Template;

  beforeAll(() => {
    const app = new cdk.App();
    const stack = new ApiServiceStack(app, 'TestStack', environments.dev);
    template = Template.fromStack(stack);
  });

  it('should create Lambda with minimum memory 256', () => {
    template.hasResourceProperties('AWS::Lambda::Function', {
      MemorySize: 256,
    });
  });

  it('should not have wildcard IAM permissions', () => {
    // Verificar que no hay * en actions
    template.allResourcesProperties('AWS::IAM::Policy', (props) => {
      props.PolicyDocument.Statement.forEach((stmt: any) => {
        expect(stmt.Action).not.toContain('*');
      });
    });
  });
});
```

## Anti-patrones

| Anti-patrón | Solución |
|-------------|----------|
| `RemovalPolicy.DESTROY` en prod con datos | `RETAIN` en prod; `DESTROY` solo en dev |
| Secreto en `environment` directo | ARN en env + `grantRead` + leer en runtime |
| ARNs hardcodeados entre stacks | `CfnOutput`/import o referencias directas |
| IDs de construcción cambiados sin plan | Planificar replace/migrate antes |
| Stack sin tags | Tags obligatorios en `bin/app.ts` |
| `cdk deploy` sin revisar `cdk diff` | Siempre `cdk diff` antes de deploy |
