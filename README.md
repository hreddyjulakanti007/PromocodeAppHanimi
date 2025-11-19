# Promo Code Management System

A production-ready multi-tenant promo code management system with complete data isolation, role-based access control, and OAuth2 authentication.

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- Git

### Start the Application

```bash
# Clone the repository
git clone https://github.com/hreddyjulakanti007/PromocodeAppHanimi.git
cd PromocodeAppHanimi

# Start all services
docker-compose up -d

# Wait for services to be ready (~30 seconds)
# Access the application at http://localhost:4200
```

### Test Credentials

| Username | Password | Role | Tenant | Access Level |
|----------|----------|------|--------|-------------|
| admin | admin123 | ADMIN | tenant1 | Full CRUD access |
| business | business123 | BUSINESS | tenant1 | Read-only access |
| admin2 | admin123 | ADMIN | tenant2 | Full CRUD access |
| business2 | business123 | BUSINESS | tenant2 | Read-only access |

### Service URLs
- **Frontend**: http://localhost:4200
- **Backend API**: http://localhost:8081
- **Keycloak**: http://localhost:8090
- **PostgreSQL**: localhost:5432

## 📋 Architecture

### Technology Stack

**Backend**
- Java 21 with Spring Boot 3.5+
- PostgreSQL 16 (multi-tenant with tenant_id column)
- Spring Security with OAuth2/JWT
- Spring Data JPA with Hibernate
- Maven 3.9+

**Frontend**
- Angular 18 (standalone components)
- Angular Material UI
- Keycloak Angular integration
- RxJS for reactive programming
- TypeScript

**Infrastructure**
- Docker & Docker Compose
- Keycloak 22.0 (OAuth2/OIDC provider)
- Nginx (production-ready frontend server)

### Multi-Tenancy Architecture

**Column-based multi-tenancy approach:**
- All tenants share the same database and schema
- Each promo code record has a `tenant_id` column
- Tenant context extracted from JWT token (`tenant_id` claim)
- Automatic tenant filtering via `TenantFilter` interceptor
- Complete data isolation between tenants at application level

### Security Architecture

- **Authentication**: OAuth2/OIDC via Keycloak
- **Authorization**: JWT bearer tokens with role-based claims
- **Role-Based Access Control (RBAC)**:
  - **ADMIN**: Full CRUD operations (create, read, update, delete, filter)
  - **BUSINESS**: Read-only access (read, filter only)
- **Tenant Isolation**: Enforced at application layer via TenantFilter
- **CORS**: Configured for localhost development

## ✨ Features

### Promo Code Management
- ✅ Create, read, update, delete promo codes (ADMIN only)
- ✅ View and filter promo codes (ADMIN and BUSINESS)
- ✅ Fields: code, amount, discount type (percentage/fixed), expiry date, status
- ✅ Status management: ACTIVE, EXPIRED, USED

### Filtering & Reporting
- ✅ Filter by code, status, discount type
- ✅ Date range filtering (valid from/to dates)
- ✅ Tenant-specific views (automatic)
- ✅ Real-time data updates

### Multi-Tenancy Features
- ✅ Complete data isolation per tenant
- ✅ Tenant-aware API endpoints
- ✅ Automatic tenant resolution from JWT claims
- ✅ Multiple users per tenant with different roles

## 🔧 API Endpoints

### Authentication
- **POST** `/realms/promocode/protocol/openid-connect/token` - Get JWT token

### Promo Code Management

| Method | Endpoint | Roles | Description |
|--------|----------|-------|-------------|
| GET | `/api/promo-codes` | ADMIN, BUSINESS | Get all promo codes |
| GET | `/api/promo-codes/{id}` | ADMIN, BUSINESS | Get promo code by ID |
| POST | `/api/promo-codes` | ADMIN | Create promo code |
| PUT | `/api/promo-codes/{id}` | ADMIN | Update promo code |
| DELETE | `/api/promo-codes/{id}` | ADMIN | Delete promo code |
| POST | `/api/promo-codes/filter` | ADMIN, BUSINESS | Filter promo codes |

### Example Request

```bash
# Get access token
curl -X POST http://localhost:8090/realms/promocode/protocol/openid-connect/token \
  -d "client_id=promocode-frontend" \
  -d "username=admin" \
  -d "password=admin123" \
  -d "grant_type=password"

# Create promo code (ADMIN only)
curl -X POST http://localhost:8081/api/promo-codes \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "SUMMER2025",
    "discountType": "PERCENTAGE",
    "discountValue": 20.0,
    "validFrom": "2025-06-01",
    "validTo": "2025-08-31",
    "status": "ACTIVE"
  }'
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=admin
./kc.sh start-dev --http-port=8090
```

**4. Import Keycloak Realm**

- Access Keycloak admin console: http://localhost:8090
- Login with `admin` / `admin`
- Click "Create Realm" → "Browse" → Select `keycloak/realm-export.json`

## 🛠️ Development Setup

### Local Development (Without Docker)

**Prerequisites:**
- Java 21 JDK
- Node.js 20+
- Maven 3.9+
- PostgreSQL 16

**Backend Development**

```bash
cd backend

# Install dependencies and build
mvn clean install

# Run locally
mvn spring-boot:run

# Run tests
mvn test

# Package
mvn clean package -DskipTests
```

**Frontend Development**

```bash
cd frontend

# Install dependencies
npm install

# Start dev server (runs on http://localhost:4200)
npm start

# Build for production
npm run build

# Run tests
ng test
npm test
```

**Environment Configuration** (`src/environments/environment.ts`):
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8081/api',
  keycloak: {
    url: 'http://localhost:8090',
    realm: 'promocode',
    clientId: 'promocode-frontend'
  }
};
```

## API Documentation

### Authentication

All API endpoints require a valid JWT token in the Authorization header:

```bash
Authorization: Bearer <jwt-token>
X-Tenant-ID: <tenant-id>
```

### Endpoints

| Method | Endpoint | Description | Required Role |
|--------|----------|-------------|---------------|
| POST | `/api/promo-codes` | Create promo code | ADMIN |
| GET | `/api/promo-codes` | Get all promo codes | ADMIN, BUSINESS |
| GET | `/api/promo-codes/{id}` | Get promo code by ID | ADMIN, BUSINESS |
| PUT | `/api/promo-codes/{id}` | Update promo code | ADMIN |
| DELETE | `/api/promo-codes/{id}` | Delete promo code | ADMIN |
| POST | `/api/promo-codes/filter` | Filter promo codes | ADMIN, BUSINESS |

### Examples

**Create Promo Code**
```bash
curl -X POST http://localhost:8081/api/promo-codes \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "X-Tenant-ID: tenant1" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "SUMMER2024",
    "amount": 20.00,
    "discountType": "PERCENTAGE",
    "expiryDate": "2024-12-31T23:59:59",
    "usageLimit": 100,
    "status": "ACTIVE"
  }'
```

## 📊 Database Schema

### Promo Codes Table

```sql
CREATE TABLE promo_codes (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(255) NOT NULL,
    discount_type VARCHAR(50) NOT NULL,
    discount_value DECIMAL(19,2) NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(code, tenant_id)
);

CREATE INDEX idx_promo_codes_tenant ON promo_codes(tenant_id);
CREATE INDEX idx_promo_codes_status ON promo_codes(status);
CREATE INDEX idx_promo_codes_code ON promo_codes(code);
```

### Multi-Tenant Data Isolation

- Each promo code has a `tenant_id` column
- Queries automatically filtered by tenant context
- Unique constraint on `(code, tenant_id)` allows same code across tenants
- Indexes on `tenant_id` for performance

## 🔐 Security Configuration

### JWT Token Structure

```json
{
  "exp": 1732099999,
  "iat": 1732096399,
  "sub": "user-uuid",
  "preferred_username": "admin",
  "email": "admin@example.com",
  "tenant_id": "tenant1",
  "realm_access": {
    "roles": ["ADMIN"]
  }
}
```

### Tenant Resolution Flow

1. User authenticates via Keycloak
2. JWT token includes `tenant_id` claim
3. `TenantFilter` extracts `tenant_id` from token
4. Tenant context stored in `ThreadLocal`
5. All database queries automatically include tenant filter
6. Response sent to client

### CORS Configuration

Configured in `SecurityConfig.java`:
```java
configuration.setAllowedOrigins(List.of("http://localhost:4200"));
configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
configuration.setAllowedHeaders(List.of("*"));
configuration.setAllowCredentials(true);
```

## 📁 Project Structure

```
PromocodeAppHanimi/
├── backend/
│   ├── src/main/java/com/promocode/management/
│   │   ├── config/
│   │   │   ├── SecurityConfig.java        # OAuth2, JWT & CORS
│   │   │   ├── TenantContext.java         # ThreadLocal tenant storage
│   │   │   ├── TenantFilter.java          # Tenant extraction from JWT
│   │   │   └── TenantIdentifierResolver.java
│   │   ├── controller/
│   │   │   └── PromoCodeController.java   # REST API endpoints
│   │   ├── dto/
│   │   │   ├── PromoCodeDTO.java
│   │   │   └── PromoCodeFilterDTO.java
│   │   ├── exception/
│   │   │   ├── GlobalExceptionHandler.java
│   │   │   └── ResourceNotFoundException.java
│   │   │   └── GlobalExceptionHandler.java # Centralized error handling
│   │   ├── model/
│   │   │   └── PromoCode.java             # JPA entity
│   │   ├── repository/
│   │   │   └── PromoCodeRepository.java   # Data access layer
│   │   └── service/
│   │       ├── PromoCodeService.java      # Business logic interface
│   │       └── PromoCodeServiceImpl.java  # Implementation
│   ├── src/main/resources/
│   │   └── application.yml                # Spring configuration
│   ├── Dockerfile                         # Multi-stage Docker build
│   └── pom.xml                            # Maven dependencies
│   │   ├── model/
│   │   │   ├── PromoCode.java
│   │   │   ├── DiscountType.java
│   │   │   └── PromoCodeStatus.java
│   │   ├── repository/
│   │   │   └── PromoCodeRepository.java    # JPA repository
│   │   ├── service/
│   │   │   └── PromoCodeService.java       # Business logic
│   │   └── PromoCodeManagementApplication.java
│   ├── src/main/resources/
│   │   ├── application.yml                  # Main config
│   │   └── application-prod.yml             # Production config
│   ├── Dockerfile                           # Multi-stage build
│   └── pom.xml                              # Maven dependencies
├── frontend/
│   ├── src/app/
│   │   ├── core/
│   │   │   ├── guards/auth.guard.ts         # Route protection
│   │   │   ├── interceptors/auth.interceptor.ts
│   │   │   ├── models/promo-code.model.ts
│   │   │   └── services/promo-code.service.ts
│   │   ├── features/promo-codes/
│   │   │   ├── promo-code-list/             # List & filter
│   │   │   └── promo-code-form/             # Create/Edit
│   │   ├── app.component.ts
│   │   ├── app.config.ts                    # Keycloak init
│   │   └── app.routes.ts
│   ├── Dockerfile                           # Multi-stage build
│   ├── nginx.conf                           # Production config
│   └── package.json
├── keycloak/
│   └── realm-export.json                    # Pre-configured realm with 4 users
├── docker-compose.yml                       # Orchestration (4 services)
├── init-db.sql                              # Database schema
└── README.md

## 🔧 Troubleshooting

### Common Issues

**1. "business2" user not found**
```bash
# Solution: Remove volumes and restart fresh
docker-compose down -v
docker-compose up -d
```

**2. Backend returns 403 Forbidden for BUSINESS user on /filter**
```bash
# Fixed in SecurityConfig.java
# Ensure this line exists:
.requestMatchers(HttpMethod.POST, "/api/promo-codes/filter").hasAnyRole("ADMIN", "BUSINESS")
```

**3. Angular errors: "Cannot find module '@angular/core'"**
```bash
cd frontend
npm install
# In VS Code: Ctrl+Shift+P -> "TypeScript: Restart TS Server"
```

**4. Backend can't connect to Keycloak**
```bash
# Check docker-compose.yml has correct network setup
# Backend needs to use host.docker.internal for JWT validation
# Or ensure keycloak is in same Docker network
```

**5. Port Already in Use**
```bash
# Windows: Find and kill process
netstat -ano | findstr :8081
taskkill /PID <PID> /F

# Or change port in docker-compose.yml
```

**6. Database connection failed**
```bash
# Check PostgreSQL is healthy
docker ps
# Should show: (healthy) for promocode-postgres

# Check logs
docker logs promocode-postgres
```

### Clean Reset

```bash
# Stop everything and remove all data
docker-compose down -v

# Remove old images (optional)
docker rmi promocodeapphanimi-backend promocodeapphanimi-frontend

# Fresh start
docker-compose up -d --build
docker exec -it promocode-postgres psql -U postgres -d promocode_db


### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker logs -f promocode-backend
docker logs -f promocode-keycloak
docker logs -f promocode-frontend
docker logs -f promocode-postgres
```

## 🧪 Testing Guide

### Manual Testing Scenarios

**1. Multi-Tenancy Verification**
1. Login as `admin` (tenant1) → Create promo "SUMMER2025"
2. Logout → Login as `admin2` (tenant2) → Create promo "WINTER2025"  
3. Logout → Login as `admin` again
4. ✅ Should only see "SUMMER2025", not "WINTER2025"

**2. Role-Based Access Control**
1. Login as `business` (BUSINESS role, tenant1)
2. ✅ Can view promo codes
3. ✅ Can filter promo codes  
4. ❌ Cannot see "Add Promo Code" button
5. Logout → Login as `admin` (ADMIN role, tenant1)
6. ✅ Can create, edit, delete promo codes

**3. CRUD Operations (as ADMIN)**
1. **Create**: Click "Add Promo Code" → Fill form → Save
2. **Read**: View list of promo codes
3. **Update**: Click edit icon → Modify → Save
4. **Delete**: Click delete icon → Confirm
5. **Filter**: Use filter form → Apply filters

**4. Cross-Tenant Isolation**
1. Login as `business` (tenant1)
2. Note the promo codes visible
3. Logout → Login as `business2` (tenant2)
4. ✅ Should see completely different promo codes
5. ✅ No overlap between tenant1 and tenant2 data

### API Testing with cURL

```bash
# Get access token
TOKEN=$(curl -s -X POST http://localhost:8090/realms/promocode/protocol/openid-connect/token \
  -d "client_id=promocode-frontend" \
  -d "username=admin" \
  -d "password=admin123" \
  -d "grant_type=password" | jq -r '.access_token')

# Create promo code
curl -X POST http://localhost:8081/api/promo-codes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "SPRING2025",
    "discountType": "PERCENTAGE",
    "discountValue": 25.0,
    "validFrom": "2025-03-01",
    "validTo": "2025-05-31",
    "status": "ACTIVE"
  }'

# Get all promo codes
curl -X GET http://localhost:8081/api/promo-codes \
  -H "Authorization: Bearer $TOKEN"

# Filter promo codes
curl -X POST http://localhost:8081/api/promo-codes/filter \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "ACTIVE"}'
```

```bash
cd backend
mvn test

# Run specific test
mvn test -Dtest=PromoCodeServiceTest

# Generate coverage report
mvn test jacoco:report
```

### 5. Frontend Unit Tests

```bash
cd frontend
npm test

# Run specific test
npm test -- --include='**/promo-code.service.spec.ts'


## 🚀 Production Deployment

### Production Checklist

- [ ] Change Keycloak admin password
- [ ] Use managed PostgreSQL (AWS RDS, Azure Database)
- [ ] Enable SSL/TLS for all services
- [ ] Update CORS origins (remove localhost)
- [ ] Use environment variables for secrets
- [ ] Enable logging and monitoring (ELK stack, Datadog)
- [ ] Configure database backups
- [ ] Set up CI/CD pipeline
- [ ] Configure rate limiting
- [ ] Add health checks and readiness probes

### Docker Registry Push

```bash
# Build with version tags
docker build -t promocode-backend:1.0.0 backend/
docker build -t promocode-frontend:1.0.0 frontend/

# Tag for registry
docker tag promocode-backend:1.0.0 your-registry/promocode-backend:1.0.0
docker tag promocode-frontend:1.0.0 your-registry/promocode-frontend:1.0.0

# Push
docker push your-registry/promocode-backend:1.0.0
docker push your-registry/promocode-frontend:1.0.0
```

### Environment Variables (Production)

Create `.env` file for docker-compose:
```env
DB_HOST=your-prod-db-host
DB_PASSWORD=secure_password
KEYCLOAK_URL=https://keycloak.yourdomain.com
BACKEND_URL=https://api.yourdomain.com
FRONTEND_URL=https://app.yourdomain.com
```

## 📝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -m 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Spring Boot team for the excellent framework
- Angular team for the modern frontend framework
- Keycloak team for the authentication solution
- PostgreSQL team for the robust database

## 📞 Support

For issues or questions:
- Check [Troubleshooting](#-troubleshooting) section
- Review container logs: `docker-compose logs`
- Open an issue on GitHub

---

## ✨ Key Features Summary

✅ **Multi-Tenant SaaS Architecture** - Complete data isolation per tenant  
✅ **OAuth2/OIDC Authentication** - Secure authentication via Keycloak  
✅ **Role-Based Access Control** - ADMIN (full access) vs BUSINESS (read-only)  
✅ **RESTful API** - Complete CRUD + filtering operations  
✅ **Modern UI** - Angular 18 with Material Design  
✅ **Docker-Ready** - One command deployment  
✅ **Production-Ready** - Multi-stage builds, health checks, CORS  
✅ **Secure** - JWT validation, tenant isolation, HTTPS-ready  

## 🏗️ Technical Architecture Highlights

- **Backend**: Java 21 + Spring Boot 3.5 + Spring Security
- **Frontend**: Angular 18 (Standalone) + Angular Material
- **Auth**: Keycloak 22.0 with custom JWT claims
- **Database**: PostgreSQL 16 with tenant_id column isolation
- **Deployment**: Docker Compose with 4 services orchestration
- **Security**: JWT bearer tokens + role-based authorization
- **Multi-Tenancy**: Column-based with automatic filtering via TenantFilter

---

**Built with ❤️ using Java 21, Spring Boot 3.5+, Angular 18, PostgreSQL 16, and Keycloak 22.0**
