@echo off
echo Starting Promo Code Management System...
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

echo Docker is running
echo.

echo Stopping existing containers...
docker-compose down

echo.
echo Building and starting services...
echo This may take a few minutes on first run...
echo.

docker-compose up -d

echo.
echo Waiting for services to be ready...
echo.

echo Waiting for PostgreSQL...
:wait_postgres
docker-compose exec -T postgres pg_isready -U postgres >nul 2>&1
if errorlevel 1 (
    timeout /t 2 /nobreak >nul
    goto wait_postgres
)
echo PostgreSQL is ready

echo Waiting for Keycloak (this may take 60-90 seconds)...
:wait_keycloak
curl -sf http://localhost:8080/health/ready >nul 2>&1
if errorlevel 1 (
    timeout /t 5 /nobreak >nul
    goto wait_keycloak
)
echo Keycloak is ready

echo Waiting for Backend...
:wait_backend
curl -sf http://localhost:8081/actuator/health >nul 2>&1
if errorlevel 1 (
    timeout /t 3 /nobreak >nul
    goto wait_backend
)
echo Backend is ready

echo Waiting for Frontend...
:wait_frontend
curl -sf http://localhost:4200 >nul 2>&1
if errorlevel 1 (
    timeout /t 2 /nobreak >nul
    goto wait_frontend
)
echo Frontend is ready

echo.
echo All services are up and running!
echo.
echo Access URLs:
echo    Frontend:        http://localhost:4200
echo    Backend API:     http://localhost:8081
echo    Swagger UI:      http://localhost:8081/swagger-ui/index.html
echo    Keycloak Admin:  http://localhost:8080 (admin/admin)
echo.
echo Test Users:
echo    Admin (Tenant 1):    admin / admin123
echo    Business (Tenant 1): business / business123
echo    Admin (Tenant 2):    admin2 / admin123
echo.
echo To view logs: docker-compose logs -f
echo To stop:      docker-compose down
echo.
pause
