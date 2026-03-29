---
name: write-tests
description: Playbook para escribir tests de calidad. Guía la escritura de tests unitarios, de integración y de snapshot en los tres stacks (Angular, Express, CDK), con patrones concretos y criterios de cobertura mínima.
---

# Write Tests

Guía completa para escribir tests de calidad en los tres stacks del monorepo.

## Principios generales

- **Testear comportamiento, no implementación.** Los tests no deben tener que cambiar cuando el código se refactoriza internamente.
- **Arrange → Act → Assert.** Estructura clara en cada test.
- **Un test, una sola cosa.** Un `it` / `test` verifica un comportamiento específico.
- **Tests que fallan antes del fix.** Si estás arreglando un bug, el test debe fallar primero.
- **Tests deterministas.** No depender de orden, tiempo real o datos externos sin mockear.

---

## Angular — tests de componentes

```typescript
describe('ProductCardComponent', () => {
  let fixture: ComponentFixture<ProductCardComponent>;
  let component: ProductCardComponent;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ProductCardComponent],
      // Solo lo necesario, no AppModule entero
    }).compileComponents();
    fixture = TestBed.createComponent(ProductCardComponent);
    component = fixture.componentInstance;
  });

  it('should render product name', () => {
    // Arrange
    component.product = { id: '1', name: 'Widget', price: 9.99 };
    // Act
    fixture.detectChanges();
    // Assert
    const nameEl = fixture.nativeElement.querySelector('[data-testid="product-name"]');
    expect(nameEl.textContent).toContain('Widget');
  });

  it('should emit addToCart event when button clicked', () => {
    component.product = { id: '1', name: 'Widget', price: 9.99 };
    fixture.detectChanges();
    const emitSpy = spyOn(component.addToCart, 'emit');

    fixture.nativeElement.querySelector('[data-testid="add-to-cart-btn"]').click();

    expect(emitSpy).toHaveBeenCalledWith({ id: '1', name: 'Widget', price: 9.99 });
  });
});
```

## Angular — tests de servicios HTTP

```typescript
describe('ProductsService', () => {
  let service: ProductsService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [ProductsService],
    });
    service = TestBed.inject(ProductsService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => httpMock.verify());  // Verificar que no quedan requests pendientes

  it('should fetch and map products', fakeAsync(() => {
    const mockDtos = [{ id: '1', name: 'Widget', price: 9.99, category: { id: 'c1', name: 'Tools' } }];
    let result: Product[] = [];

    service.getAll().subscribe(products => result = products);
    const req = httpMock.expectOne('/api/products');
    expect(req.request.method).toBe('GET');
    req.flush(mockDtos);

    expect(result).toHaveLength(1);
    expect(result[0].name).toBe('Widget');
  }));
});
```

---

## Express — tests unitarios de services

```typescript
describe('ProductsService', () => {
  let service: ProductsService;
  let mockRepo: jest.Mocked<ProductsRepository>;

  beforeEach(() => {
    mockRepo = {
      findAll: jest.fn(),
      findById: jest.fn(),
      findByName: jest.fn(),
      save: jest.fn(),
    };
    service = new ProductsService(mockRepo);
  });

  describe('create', () => {
    it('should create product when name is unique', async () => {
      mockRepo.findByName.mockResolvedValue(null);
      mockRepo.save.mockResolvedValue({ id: '1', name: 'Widget', price: 9.99 });

      const result = await service.create({ name: 'Widget', price: 9.99, categoryId: 'c1' });

      expect(mockRepo.save).toHaveBeenCalledWith({ name: 'Widget', price: 9.99, categoryId: 'c1' });
      expect(result.id).toBe('1');
    });

    it('should throw ConflictError when name already exists', async () => {
      mockRepo.findByName.mockResolvedValue({ id: '1', name: 'Widget' } as Product);

      await expect(service.create({ name: 'Widget', price: 9.99, categoryId: 'c1' }))
        .rejects.toThrow(ConflictError);
    });
  });
});
```

## Express — tests de integración de rutas

```typescript
describe('Products API', () => {
  let token: string;

  beforeAll(async () => {
    await setupTestDatabase();
    token = generateTestToken({ userId: 'test-user', role: 'admin' });
  });

  afterAll(async () => teardownTestDatabase());

  describe('GET /api/products', () => {
    it('should return 200 with products list', async () => {
      const res = await request(app)
        .get('/api/products')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });

    it('should return 401 without token', async () => {
      const res = await request(app).get('/api/products');
      expect(res.status).toBe(401);
    });
  });

  describe('POST /api/products', () => {
    it('should return 201 with created product', async () => {
      const res = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: 'New Widget', price: 14.99, categoryId: 'valid-cat-id' });

      expect(res.status).toBe(201);
      expect(res.body.name).toBe('New Widget');
    });

    it('should return 400 for invalid body', async () => {
      const res = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${token}`)
        .send({ price: 'not-a-number' });

      expect(res.status).toBe(400);
      expect(res.body.errors).toBeDefined();
    });
  });
});
```

---

## CDK — tests de assertion y snapshot

```typescript
describe('ApiServiceStack', () => {
  let template: Template;

  beforeAll(() => {
    const app = new cdk.App();
    const stack = new ApiServiceStack(app, 'TestApiStack', environments.dev);
    template = Template.fromStack(stack);
  });

  it('should create a Lambda function', () => {
    template.resourceCountIs('AWS::Lambda::Function', 1);
  });

  it('should configure Lambda with correct runtime', () => {
    template.hasResourceProperties('AWS::Lambda::Function', {
      Runtime: 'nodejs20.x',
      MemorySize: 256,
    });
  });

  it('should have DynamoDB table', () => {
    template.hasResourceProperties('AWS::DynamoDB::Table', {
      BillingMode: 'PAY_PER_REQUEST',
    });
  });

  it('should match snapshot', () => {
    expect(template.toJSON()).toMatchSnapshot();
  });
});
```

---

## Cobertura mínima por tipo

| Archivo | Tests mínimos requeridos |
|---------|--------------------------|
| Angular Component nuevo | Render + inputs + 1 interacción |
| Angular Service HTTP | Happy path + error handling |
| Express Service | Happy path + error case por método público |
| Express Route | 200 happy path + 400 validación + 401 auth |
| CDK Stack | Recursos críticos + 1 snapshot |
