Write-Host "Creating all project files..." -ForegroundColor Cyan

# Service Registry
Write-Host "Creating Service Registry files..." -ForegroundColor Yellow
New-Item -Path "service-registry\pom.xml" -ItemType File -Force | Out-Null
New-Item -Path "service-registry\Dockerfile" -ItemType File -Force | Out-Null
New-Item -Path "service-registry\src\main\java\com\portfolio\registry\EurekaServerApplication.java" -ItemType File -Force | Out-Null
New-Item -Path "service-registry\src\main\resources\application.yml" -ItemType File -Force | Out-Null

# API Gateway
Write-Host "Creating API Gateway files..." -ForegroundColor Yellow
New-Item -Path "api-gateway\pom.xml" -ItemType File -Force | Out-Null
New-Item -Path "api-gateway\Dockerfile" -ItemType File -Force | Out-Null
New-Item -Path "api-gateway\src\main\java\com\portfolio\gateway\GatewayApplication.java" -ItemType File -Force | Out-Null
New-Item -Path "api-gateway\src\main\java\com\portfolio\gateway\config\GatewayConfig.java" -ItemType File -Force | Out-Null
New-Item -Path "api-gateway\src\main\java\com\portfolio\gateway\filter\JwtAuthenticationFilter.java" -ItemType File -Force | Out-Null
New-Item -Path "api-gateway\src\main\java\com\portfolio\gateway\filter\RateLimitFilter.java" -ItemType File -Force | Out-Null
New-Item -Path "api-gateway\src\main\resources\application.yml" -ItemType File -Force | Out-Null

# Auth Service
Write-Host "Creating Auth Service files..." -ForegroundColor Yellow
New-Item -Path "auth-service\pom.xml" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\Dockerfile" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\AuthServiceApplication.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\entity\User.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\entity\Role.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\repository\UserRepository.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\repository\RoleRepository.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\dto\RegisterRequest.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\dto\LoginRequest.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\dto\JwtResponse.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\service\AuthService.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\controller\AuthController.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\security\JwtTokenProvider.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\config\SecurityConfig.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\config\DataInitializer.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\exception\GlobalExceptionHandler.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\exception\ResourceAlreadyExistsException.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\java\com\portfolio\auth\exception\InvalidCredentialsException.java" -ItemType File -Force | Out-Null
New-Item -Path "auth-service\src\main\resources\application.yml" -ItemType File -Force | Out-Null

# Task Service
Write-Host "Creating Task Service files..." -ForegroundColor Yellow
New-Item -Path "task-service\pom.xml" -ItemType File -Force | Out-Null
New-Item -Path "task-service\Dockerfile" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\TaskServiceApplication.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\entity\Task.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\repository\TaskRepository.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\dto\TaskDTO.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\dto\TaskStatsDTO.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\service\TaskService.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\controller\TaskController.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\mapper\TaskMapper.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\kafka\TaskEventProducer.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\kafka\TaskEvent.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\config\KafkaConfig.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\config\RedisConfig.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\exception\GlobalExceptionHandler.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\exception\ResourceNotFoundException.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\java\com\portfolio\task\exception\UnauthorizedException.java" -ItemType File -Force | Out-Null
New-Item -Path "task-service\src\main\resources\application.yml" -ItemType File -Force | Out-Null

# Notification Service
Write-Host "Creating Notification Service files..." -ForegroundColor Yellow
New-Item -Path "notification-service\pom.xml" -ItemType File -Force | Out-Null
New-Item -Path "notification-service\Dockerfile" -ItemType File -Force | Out-Null
New-Item -Path "notification-service\src\main\java\com\portfolio\notification\NotificationServiceApplication.java" -ItemType File -Force | Out-Null
New-Item -Path "notification-service\src\main\java\com\portfolio\notification\kafka\TaskEventConsumer.java" -ItemType File -Force | Out-Null
New-Item -Path "notification-service\src\main\java\com\portfolio\notification\service\EmailService.java" -ItemType File -Force | Out-Null
New-Item -Path "notification-service\src\main\resources\application.yml" -ItemType File -Force | Out-Null

Write-Host "`nAll files created successfully!" -ForegroundColor Green
Write-Host "Total files created: 50+" -ForegroundColor Cyan
Write-Host "`nNext step: Fill in the code for each file" -ForegroundColor Yellow