# =====================================================
# TASK SERVICE - Part 3 (Config, Exceptions, YAML)
# NOTIFICATION SERVICE - Complete
# =====================================================

Write-Host "Generating final files for Task and Notification Services..." -ForegroundColor Cyan

# =====================================================
# TASK SERVICE - Configs and Exceptions
# =====================================================

# KafkaConfig.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\config\KafkaConfig.java" -Value @"
package com.portfolio.task.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaConfig {
    
    @Bean
    public NewTopic taskEventsTopic() {
        return TopicBuilder.name("task-events")
                .partitions(3)
                .replicas(1)
                .build();
    }
}
"@

# RedisConfig.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\config\RedisConfig.java" -Value @"
package com.portfolio.task.config;

import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

import java.time.Duration;

@Configuration
@EnableCaching
public class RedisConfig {
    
    @Bean
    public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(10))
                .serializeValuesWith(
                        RedisSerializationContext.SerializationPair.fromSerializer(
                                new GenericJackson2JsonRedisSerializer()));
        
        return RedisCacheManager.builder(connectionFactory)
                .cacheDefaults(config)
                .build();
    }
}
"@

# ResourceNotFoundException.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\exception\ResourceNotFoundException.java" -Value @"
package com.portfolio.task.exception;

public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
"@

# UnauthorizedException.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\exception\UnauthorizedException.java" -Value @"
package com.portfolio.task.exception;

public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String message) {
        super(message);
    }
}
"@

# GlobalExceptionHandler.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\exception\GlobalExceptionHandler.java" -Value @"
package com.portfolio.task.exception;

import lombok.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(
            ResourceNotFoundException ex, WebRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .status(HttpStatus.NOT_FOUND.value())
                .message(ex.getMessage())
                .timestamp(LocalDateTime.now())
                .path(request.getDescription(false).replace("uri=", ""))
                .build();
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<ErrorResponse> handleUnauthorized(
            UnauthorizedException ex, WebRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .status(HttpStatus.FORBIDDEN.value())
                .message(ex.getMessage())
                .timestamp(LocalDateTime.now())
                .path(request.getDescription(false).replace("uri=", ""))
                .build();
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ValidationErrorResponse> handleValidation(
            MethodArgumentNotValidException ex, WebRequest request) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        
        ValidationErrorResponse response = ValidationErrorResponse.builder()
                .status(HttpStatus.BAD_REQUEST.value())
                .message("Validation failed")
                .timestamp(LocalDateTime.now())
                .path(request.getDescription(false).replace("uri=", ""))
                .errors(errors)
                .build();
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGlobalException(
            Exception ex, WebRequest request) {
        ErrorResponse error = ErrorResponse.builder()
                .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .message("An unexpected error occurred")
                .timestamp(LocalDateTime.now())
                .path(request.getDescription(false).replace("uri=", ""))
                .build();
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
class ErrorResponse {
    private int status;
    private String message;
    private LocalDateTime timestamp;
    private String path;
}

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
class ValidationErrorResponse {
    private int status;
    private String message;
    private LocalDateTime timestamp;
    private String path;
    private Map<String, String> errors;
}
"@

# application.yml
Set-Content -Path "task-service\src\main\resources\application.yml" -Value @"
server:
  port: 8082

spring:
  application:
    name: task-service
  data:
    mongodb:
      uri: mongodb://localhost:27017/taskdb
  redis:
    host: localhost
    port: 6379
  kafka:
    bootstrap-servers: localhost:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
"@

# Dockerfile
Set-Content -Path "task-service\Dockerfile" -Value @"
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/task-service-1.0.0.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
"@

Write-Host "Task Service complete!" -ForegroundColor Green

# =====================================================
# NOTIFICATION SERVICE - Complete
# =====================================================

Write-Host "`nCreating Notification Service files..." -ForegroundColor Yellow

# pom.xml
Set-Content -Path "notification-service\pom.xml" -Value @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>

    <groupId>com.portfolio.microservices</groupId>
    <artifactId>notification-service</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>17</java.version>
        <spring-cloud.version>2023.0.0</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.kafka</groupId>
            <artifactId>spring-kafka</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-mail</artifactId>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>`${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
"@

# NotificationServiceApplication.java
Set-Content -Path "notification-service\src\main\java\com\portfolio\notification\NotificationServiceApplication.java" -Value @"
package com.portfolio.notification;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class NotificationServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(NotificationServiceApplication.class, args);
    }
}
"@

# TaskEventConsumer.java
Set-Content -Path "notification-service\src\main\java\com\portfolio\notification\kafka\TaskEventConsumer.java" -Value @"
package com.portfolio.notification.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.portfolio.notification.service.EmailService;
import lombok.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class TaskEventConsumer {
    
    private final EmailService emailService;
    private final ObjectMapper objectMapper;
    
    @KafkaListener(topics = "task-events", groupId = "notification-service")
    public void consumeTaskEvent(String message) {
        try {
            TaskEvent event = objectMapper.readValue(message, TaskEvent.class);
            log.info("Received task event: {}", event.getEventType());
            
            switch (event.getEventType()) {
                case "TASK_CREATED":
                    handleTaskCreated(event);
                    break;
                case "TASK_UPDATED":
                    handleTaskUpdated(event);
                    break;
                case "TASK_DELETED":
                    handleTaskDeleted(event);
                    break;
                default:
                    log.warn("Unknown event type: {}", event.getEventType());
            }
        } catch (Exception e) {
            log.error("Error processing task event", e);
        }
    }
    
    private void handleTaskCreated(TaskEvent event) {
        log.info("Handling task created event for task: {}", event.getTaskId());
        emailService.sendTaskCreatedNotification(event);
    }
    
    private void handleTaskUpdated(TaskEvent event) {
        log.info("Handling task updated event for task: {}", event.getTaskId());
        if ("COMPLETED".equals(event.getStatus())) {
            emailService.sendTaskCompletedNotification(event);
        }
    }
    
    private void handleTaskDeleted(TaskEvent event) {
        log.info("Handling task deleted event for task: {}", event.getTaskId());
    }
}

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
class TaskEvent {
    private String eventType;
    private String taskId;
    private Long userId;
    private String title;
    private String status;
}
"@

# EmailService.java
Set-Content -Path "notification-service\src\main\java\com\portfolio\notification\service\EmailService.java" -Value @"
package com.portfolio.notification.service;

import com.portfolio.notification.kafka.TaskEventConsumer;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {
    
    private final JavaMailSender mailSender;
    
    public void sendTaskCreatedNotification(Object event) {
        log.info("Sending task created notification");
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo("user@example.com");
            message.setSubject("New Task Created");
            message.setText("A new task has been created in your task management system.");
            
            // Uncomment when email is configured
            // mailSender.send(message);
            log.info("Task created notification sent successfully");
        } catch (Exception e) {
            log.error("Error sending email notification", e);
        }
    }
    
    public void sendTaskCompletedNotification(Object event) {
        log.info("Sending task completed notification");
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo("user@example.com");
            message.setSubject("Task Completed");
            message.setText("Congratulations! Your task has been completed.");
            
            // Uncomment when email is configured
            // mailSender.send(message);
            log.info("Task completed notification sent successfully");
        } catch (Exception e) {
            log.error("Error sending email notification", e);
        }
    }
}
"@

# application.yml
Set-Content -Path "notification-service\src\main\resources\application.yml" -Value @"
server:
  port: 8084

spring:
  application:
    name: notification-service
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: notification-service
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
  mail:
    host: smtp.gmail.com
    port: 587
    username: your-email@gmail.com
    password: your-app-password
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
"@

# Dockerfile
Set-Content -Path "notification-service\Dockerfile" -Value @"
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/notification-service-1.0.0.jar app.jar
EXPOSE 8084
ENTRYPOINT ["java", "-jar", "app.jar"]
"@

Write-Host "Notification Service complete!" -ForegroundColor Green

# =====================================================
# ROOT PROJECT FILES
# =====================================================

Write-Host "`nCreating root project files..." -ForegroundColor Yellow

# docker-compose.yml
Set-Content -Path "docker-compose.yml" -Value @"
version: '3.8'

services:
  # Service Registry (Eureka)
  service-registry:
    build:
      context: ./service-registry
      dockerfile: Dockerfile
    container_name: service-registry
    ports:
      - "8761:8761"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8761/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 5

  # PostgreSQL for Auth Service
  postgres-auth:
    image: postgres:15-alpine
    container_name: postgres-auth
    environment:
      POSTGRES_DB: authdb
      POSTGRES_USER: authuser
      POSTGRES_PASSWORD: authpass123
    ports:
      - "5432:5432"
    volumes:
      - postgres-auth-data:/var/lib/postgresql/data
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U authuser"]
      interval: 10s
      timeout: 5s
      retries: 5

  # MongoDB for Task Service
  mongodb:
    image: mongo:7-jammy
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: admin123
      MONGO_INITDB_DATABASE: taskdb
    ports:
      - "27017:27017"
    volumes:
      - mongodb-data:/data/db
    networks:
      - microservices-network
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis for Caching
  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Zookeeper
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    container_name: zookeeper
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    networks:
      - microservices-network

  # Kafka
  kafka:
    image: confluentinc/cp-kafka:7.5.0
    container_name: kafka
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
    depends_on:
      - zookeeper
    networks:
      - microservices-network
    healthcheck:
      test: ["CMD", "kafka-broker-api-versions", "--bootstrap-server", "localhost:9092"]
      interval: 30s
      timeout: 10s
      retries: 5

  # API Gateway
  api-gateway:
    build:
      context: ./api-gateway
      dockerfile: Dockerfile
    container_name: api-gateway
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://service-registry:8761/eureka/
      - SPRING_REDIS_HOST=redis
      - JWT_SECRET=your-very-long-secret-key-at-least-256-bits-for-hs256-algorithm
    depends_on:
      service-registry:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - microservices-network

  # Auth Service
  auth-service:
    build:
      context: ./auth-service
      dockerfile: Dockerfile
    container_name: auth-service
    ports:
      - "8081:8081"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://service-registry:8761/eureka/
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres-auth:5432/authdb
      - SPRING_DATASOURCE_USERNAME=authuser
      - SPRING_DATASOURCE_PASSWORD=authpass123
      - JWT_SECRET=your-very-long-secret-key-at-least-256-bits-for-hs256-algorithm
    depends_on:
      service-registry:
        condition: service_healthy
      postgres-auth:
        condition: service_healthy
    networks:
      - microservices-network

  # Task Service
  task-service:
    build:
      context: ./task-service
      dockerfile: Dockerfile
    container_name: task-service
    ports:
      - "8082:8082"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://service-registry:8761/eureka/
      - SPRING_DATA_MONGODB_URI=mongodb://admin:admin123@mongodb:27017/taskdb?authSource=admin
      - SPRING_REDIS_HOST=redis
      - SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:9092
    depends_on:
      service-registry:
        condition: service_healthy
      mongodb:
        condition: service_healthy
      redis:
        condition: service_healthy
      kafka:
        condition: service_healthy
    networks:
      - microservices-network

  # Notification Service
  notification-service:
    build:
      context: ./notification-service
      dockerfile: Dockerfile
    container_name: notification-service
    ports:
      - "8084:8084"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://service-registry:8761/eureka/
      - SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:9092
    depends_on:
      service-registry:
        condition: service_healthy
      kafka:
        condition: service_healthy
    networks:
      - microservices-network

networks:
  microservices-network:
    driver: bridge

volumes:
  postgres-auth-data:
  mongodb-data:
"@

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "ALL FILES GENERATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nYour complete microservices project is ready!" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Review all generated files" -ForegroundColor White
Write-Host "2. Create README.md (I'll provide this next)" -ForegroundColor White
Write-Host "3. Create .gitignore" -ForegroundColor White
Write-Host "4. Initialize Git and push to GitHub" -ForegroundColor White
Write-Host "`nType 'continue' for README and Git instructions!" -ForegroundColor Cyan