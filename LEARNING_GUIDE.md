# 🎓 Learning Guide: Promo Code Management System

**Welcome!** This guide will help you understand the project from scratch, even if you're completely new to these technologies.

---

## 📚 Table of Contents

1. [What is This Project?](#what-is-this-project)
2. [Understanding the Big Picture](#understanding-the-big-picture)
3. [Step-by-Step Learning Path](#step-by-step-learning-path)
4. [Hands-On Exercises](#hands-on-exercises)
5. [Common Questions](#common-questions)

---

## What is This Project?

### In Simple Terms
Imagine you own multiple online stores (like Store A and Store B). Each store wants to create discount codes for their customers. This project is a system that:

- ✅ Lets Store A create discount codes (like "SUMMER25" for 25% off)
- ✅ Lets Store B create their own codes (like "WINTER30" for 30% off)
- ✅ Makes sure Store A can't see Store B's codes (and vice versa) - **Multi-tenancy**
- ✅ Has different permission levels: managers can create/edit codes, regular employees can only view them

### Real-World Example
```
Store A (tenant1):
- Manager (admin): Can create "BLACKFRIDAY50" discount code
- Employee (business): Can only view the codes

Store B (tenant2):
- Manager (admin2): Can create "NEWYEAR40" discount code
- Employee (business2): Can only view the codes

Important: Store A never sees Store B's codes!
```

---

## Understanding the Big Picture

### The 4 Parts of This System

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR COMPUTER                         │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Frontend   │  │   Backend    │  │  Database    │ │
│  │  (Angular)   │  │  (Java API)  │  │ (PostgreSQL) │ │
│  │              │  │              │  │              │ │
│  │ What you see │→│ Business     │→│ Stores       │ │
│  │ in browser   │  │ logic        │  │ data         │ │
│  │              │←│              │←│              │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│         ↕                                                │
│  ┌──────────────┐                                       │
│  │   Keycloak   │                                       │
│  │   (Login)    │                                       │
│  │              │                                       │
│  │ Handles who  │                                       │
│  │ you are      │                                       │
│  └──────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

### What Each Part Does

#### 1. **Frontend (Angular)** - Port 4200
**What it is:** The website you see in your browser  
**What it does:** 
- Shows login screen
- Displays promo codes in a table
- Provides forms to create/edit promo codes
- Pretty buttons and colors!

**Files to explore:**
- `frontend/src/app/features/promo-codes/promo-code-list/` - The list page
- `frontend/src/app/features/promo-codes/promo-code-form/` - The create/edit form

#### 2. **Backend (Java/Spring Boot)** - Port 8081
**What it is:** The "brain" of the application  
**What it does:**
- Receives requests from the frontend ("create a new code!")
- Checks permissions ("are you an admin?")
- Talks to the database ("save this code")
- Returns results ("here's your list of codes")

**Key files:**
- `backend/src/main/java/com/promocode/management/controller/PromoCodeController.java` - Handles web requests
- `backend/src/main/java/com/promocode/management/service/PromoCodeService.java` - Business logic
- `backend/src/main/java/com/promocode/management/config/TenantFilter.java` - **IMPORTANT:** Makes multi-tenancy work!

#### 3. **Database (PostgreSQL)** - Port 5432
**What it is:** Where all data is stored  
**What it does:**
- Saves promo codes
- Remembers which codes belong to which store (tenant)

**Table structure:**
```sql
promo_codes table:
├── id (unique number)
├── code (like "SUMMER25")
├── discount_value (like 25.00)
├── tenant_id (like "tenant1" or "tenant2") ← KEY for multi-tenancy!
├── status (ACTIVE, EXPIRED, etc.)
└── ...more fields
```

#### 4. **Keycloak** - Port 8090
**What it is:** The security guard  
**What it does:**
- Verifies username/password
- Creates a special ticket (JWT token) that says:
  - Who you are (username: "admin")
  - What you can do (role: "ADMIN")
  - Which store you belong to (tenant: "tenant1")

---

## Step-by-Step Learning Path

### 🎯 Day 1: Run the Project (30 minutes)

**Goal:** See it working!

**Steps:**
```bash
# 1. Start everything
docker-compose up -d

# 2. Wait 30 seconds, then open browser to:
http://localhost:4200
```

**Try this:**
1. Click "Login with Keycloak"
2. Username: `admin`, Password: `admin123`
3. You should see a list of promo codes!

**What just happened?**
- Frontend showed you a login button
- You clicked it → went to Keycloak (port 8090)
- Keycloak verified your password
- Keycloak gave you a "ticket" (JWT token)
- Frontend used the ticket to ask Backend for promo codes
- Backend checked your ticket, asked Database for codes
- Database returned codes for "tenant1" only
- You see the list!

### 🎯 Day 2: Understand Multi-Tenancy (45 minutes)

**Goal:** See how data is isolated between tenants

**Exercise:**
1. Login as `admin` (tenant1)
   - Create a promo code: "ADMIN1SPECIAL"
   - Write down: How many codes do you see?

2. Logout → Login as `admin2` (tenant2)
   - Create a promo code: "ADMIN2SPECIAL"
   - Write down: How many codes do you see?
   - **Question:** Can you see "ADMIN1SPECIAL"? (Answer: NO!)

3. Logout → Login as `admin` again
   - **Question:** Can you see "ADMIN2SPECIAL"? (Answer: NO!)

**Why?**
Open this file and look: `backend/src/main/java/com/promocode/management/config/TenantFilter.java`

This filter:
```java
// 1. Extracts tenant_id from your JWT token
String tenantId = jwt.getClaim("tenant_id");  // e.g., "tenant1"

// 2. Stores it in ThreadLocal
TenantContext.setTenantId(tenantId);

// 3. Every database query automatically adds:
// WHERE tenant_id = 'tenant1'
```

### 🎯 Day 3: Understand Role-Based Access (45 minutes)

**Goal:** See how ADMIN vs BUSINESS roles work

**Exercise:**
1. Login as `business` (BUSINESS role, tenant1)
   - Can you see the "Add Promo Code" button? (Answer: NO!)
   - Can you view existing codes? (Answer: YES!)
   - Try to create a code via browser dev tools → You'll get 403 Forbidden

2. Login as `admin` (ADMIN role, tenant1)
   - Can you see the "Add Promo Code" button? (Answer: YES!)
   - Create a code successfully

**Why?**
Open: `backend/src/main/java/com/promocode/management/config/SecurityConfig.java`

```java
// This line controls who can do what:
.requestMatchers(HttpMethod.POST, "/api/promo-codes").hasRole("ADMIN")
// Only ADMIN can POST (create) promo codes

.requestMatchers(HttpMethod.GET, "/api/promo-codes/**").hasAnyRole("ADMIN", "BUSINESS")  
// Both ADMIN and BUSINESS can GET (view) promo codes
```

### 🎯 Day 4: Explore the Backend API (1 hour)

**Goal:** Understand how the backend works

**Files to read (in order):**

1. **`PromoCodeController.java`** (10 min)
   - This is the "front door" for web requests
   - Look for `@GetMapping`, `@PostMapping`, etc.
   - Each method handles one type of request

2. **`PromoCodeService.java`** (15 min)
   - This is the "business logic"
   - Contains the actual code to create/update/delete codes

3. **`PromoCodeRepository.java`** (5 min)
   - This talks to the database
   - Uses JPA (Java Persistence API) - it's like magic SQL!

**Exercise: Follow a Request**
When you click "Create Promo Code" in the browser:

```
1. Browser sends: POST http://localhost:8081/api/promo-codes
   Body: { code: "TEST", discountValue: 10, ... }

2. PromoCodeController receives it:
   @PostMapping
   public ResponseEntity<PromoCodeDTO> createPromoCode(@RequestBody PromoCodeDTO dto)

3. Controller calls Service:
   promoCodeService.createPromoCode(dto)

4. Service calls Repository:
   promoCodeRepository.save(promoCode)

5. Repository saves to database:
   INSERT INTO promo_codes (code, discount_value, tenant_id, ...) VALUES (...)

6. Response flows back to browser!
```

### 🎯 Day 5: Explore the Frontend (1 hour)

**Goal:** Understand how Angular works

**Files to read:**

1. **`promo-code-list.component.ts`** (15 min)
   - Fetches promo codes when page loads
   - Displays them in a table
   - Handles delete button clicks

2. **`promo-code-form.component.ts`** (15 min)
   - Handles the create/edit form
   - Validates input (required fields, dates, etc.)
   - Sends data to backend

3. **`promo-code.service.ts`** (15 min)
   - Makes HTTP calls to backend
   - Uses `HttpClient` from Angular

**Exercise: Trace a Create Operation**
```typescript
// 1. User fills form and clicks "Save"
onSubmit() {
  // 2. Form component calls service
  this.promoCodeService.createPromoCode(this.formData)
    .subscribe(response => {
      // 4. Success! Show message
      this.snackBar.open('Promo code created!');
    });
}

// 3. Service makes HTTP POST
createPromoCode(promoCode: PromoCode) {
  return this.http.post('http://localhost:8081/api/promo-codes', promoCode);
}
```

---

## Hands-On Exercises

### Exercise 1: Add a New Field (Beginner)
**Goal:** Add "description" field to promo codes

**Steps:**
1. Add column to database (in `init-db.sql`)
2. Add field to Java model (`PromoCode.java`)
3. Add field to DTO (`PromoCodeDTO.java`)
4. Add field to TypeScript model (`promo-code.model.ts`)
5. Add input field to Angular form
6. Test: Create a promo code with a description!

### Exercise 2: Add a Report Feature (Intermediate)
**Goal:** Show statistics: "Total active codes: 5"

**Steps:**
1. Backend: Add method to `PromoCodeRepository`:
   ```java
   @Query("SELECT COUNT(p) FROM PromoCode p WHERE p.status = 'ACTIVE'")
   long countActiveCodes();
   ```
2. Backend: Add endpoint to `PromoCodeController`
3. Frontend: Create a dashboard component
4. Frontend: Call the new endpoint and display stats

### Exercise 3: Create Tenant Management (Advanced)
**Goal:** Add a page to view all tenants

**Steps:**
1. Create `Tenant` entity in backend
2. Create `TenantController` with CRUD operations
3. Create Angular component for tenant list
4. Add admin-only route protection

---

## Common Questions

### Q: What is a JWT token?
**A:** It's like a digital badge that says:
- Who you are (your username)
- What you can do (your roles)
- Which tenant you belong to

When you login, Keycloak creates this badge. Every time your browser talks to the backend, it shows this badge.

### Q: What is multi-tenancy?
**A:** It's like having multiple apartments in one building. Each tenant (Store A, Store B) has their own space, and they can't see into each other's apartments. This app stores everyone's data in one database but keeps it separated using `tenant_id`.

### Q: Why use Docker?
**A:** Instead of installing Java, PostgreSQL, Node.js, Keycloak separately, Docker packages everything together. One command (`docker-compose up`) starts all 4 services!

### Q: What is Spring Boot?
**A:** It's a Java framework that makes it easy to build web APIs. Instead of writing lots of configuration, Spring Boot has smart defaults. You just write your business logic!

### Q: What is Angular?
**A:** It's a JavaScript framework for building web apps. It helps you organize your code into components (like LEGO blocks). Each component has:
- HTML (structure)
- CSS (styling)  
- TypeScript (logic)

### Q: How does authentication work?
```
1. You enter username/password
2. Browser sends it to Keycloak
3. Keycloak checks database → Valid!
4. Keycloak creates JWT token (the badge)
5. Browser stores the token
6. Every API request includes: "Authorization: Bearer <token>"
7. Backend verifies token before processing request
```

---

## Next Steps

After completing this guide:

1. **Read the main README.md** - Now it will make more sense!
2. **Try the exercises** - Best way to learn is by doing
3. **Modify something small** - Change a button color, add a field
4. **Ask questions** - Use the TODO list as your checklist

---

## Debugging Tips

**Backend not working?**
```bash
docker logs promocode-backend
# Look for "Started PromoCodeManagementApplication"
```

**Frontend not loading?**
```bash
docker logs promocode-frontend
# Check if Nginx started successfully
```

**Can't login?**
```bash
docker logs promocode-keycloak
# Look for "Keycloak started"
```

**Database issues?**
```bash
docker exec -it promocode-postgres psql -U postgres -d promocode_db
\dt  # List tables
SELECT * FROM promo_codes;  # View data
```

---

## Resources for Further Learning

**Java & Spring Boot:**
- Spring Boot Official Docs: https://spring.io/projects/spring-boot
- Baeldung (great tutorials): https://www.baeldung.com/spring-boot

**Angular:**
- Angular Official Docs: https://angular.io/docs
- Angular University: https://angular-university.io/

**Docker:**
- Docker Getting Started: https://docs.docker.com/get-started/

**Keycloak:**
- Keycloak Docs: https://www.keycloak.org/documentation

---

**Remember:** Everyone starts as a beginner! Take it one step at a time. Run the app first, then explore each part slowly. Good luck! 🚀
