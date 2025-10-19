# =====================================================
# TASK SERVICE & NOTIFICATION SERVICE CODE GENERATOR
# =====================================================

Write-Host "Generating Task Service and Notification Service..." -ForegroundColor Cyan

# =====================================================
# TASK SERVICE - All Files
# =====================================================

Write-Host "`nCreating Task Service files..." -ForegroundColor Yellow

# pom.xml
Set-Content -Path "task-service\pom.xml" -Value @"
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
    <artifactId>task-service</artifactId>
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
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-mongodb</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.kafka</groupId>
            <artifactId>spring-kafka</artifactId>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>2.2.0</version>
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

# TaskServiceApplication.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\TaskServiceApplication.java" -Value @"
package com.portfolio.task;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.data.mongodb.config.EnableMongoAuditing;

@SpringBootApplication
@EnableDiscoveryClient
@EnableMongoAuditing
@EnableCaching
public class TaskServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(TaskServiceApplication.class, args);
    }
}
"@

# Task.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\entity\Task.java" -Value @"
package com.portfolio.task.entity;

import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Document(collection = "tasks")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Task {
    
    @Id
    private String id;
    
    @Indexed
    private Long userId;
    
    private String title;
    
    private String description;
    
    private TaskStatus status;
    
    private Priority priority;
    
    private LocalDateTime dueDate;
    
    @Builder.Default
    private List<String> tags = new ArrayList<>();
    
    @Builder.Default
    private List<Comment> comments = new ArrayList<>();
    
    private Long assignedToUserId;
    
    @CreatedDate
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    private LocalDateTime updatedAt;
    
    private LocalDateTime completedAt;
    
    public enum TaskStatus {
        TODO, IN_PROGRESS, IN_REVIEW, COMPLETED, CANCELLED, ON_HOLD
    }
    
    public enum Priority {
        LOW, MEDIUM, HIGH, URGENT
    }
    
    @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
    public static class Comment {
        private String id;
        private Long userId;
        private String username;
        private String content;
        private LocalDateTime createdAt;
    }
}
"@

# TaskRepository.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\repository\TaskRepository.java" -Value @"
package com.portfolio.task.repository;

import com.portfolio.task.entity.Task;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TaskRepository extends MongoRepository<Task, String> {
    
    Page<Task> findByUserId(Long userId, Pageable pageable);
    
    Page<Task> findByUserIdAndStatus(Long userId, Task.TaskStatus status, Pageable pageable);
    
    @Query("{ 'userId': ?0, `$or: [ { 'title': { `$regex: ?1, `$options: 'i' } }, { 'description': { `$regex: ?1, `$options: 'i' } } ] }")
    Page<Task> searchTasks(Long userId, String keyword, Pageable pageable);
    
    List<Task> findByUserIdAndStatusAndDueDateBefore(Long userId, Task.TaskStatus status, LocalDateTime dueDate);
    
    long countByUserIdAndStatus(Long userId, Task.TaskStatus status);
}
"@

# TaskDTO.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\dto\TaskDTO.java" -Value @"
package com.portfolio.task.dto;

import com.portfolio.task.entity.Task;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TaskDTO {
    
    private String id;
    private Long userId;
    
    @NotBlank(message = "Title is required")
    @Size(max = 200, message = "Title must not exceed 200 characters")
    private String title;
    
    @Size(max = 5000, message = "Description must not exceed 5000 characters")
    private String description;
    
    @NotNull(message = "Status is required")
    private Task.TaskStatus status;
    
    private Task.Priority priority;
    private LocalDateTime dueDate;
    
    @Builder.Default
    private List<String> tags = new ArrayList<>();
    
    private Long assignedToUserId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime completedAt;
}
"@

# TaskStatsDTO.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\dto\TaskStatsDTO.java" -Value @"
package com.portfolio.task.dto;

import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TaskStatsDTO {
    private long totalTasks;
    private long todoTasks;
    private long inProgressTasks;
    private long completedTasks;
    private long overdueTasks;
}
"@

# TaskMapper.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\mapper\TaskMapper.java" -Value @"
package com.portfolio.task.mapper;

import com.portfolio.task.dto.TaskDTO;
import com.portfolio.task.entity.Task;
import org.springframework.stereotype.Component;

@Component
public class TaskMapper {
    
    public TaskDTO toDTO(Task task) {
        if (task == null) return null;
        
        return TaskDTO.builder()
                .id(task.getId())
                .userId(task.getUserId())
                .title(task.getTitle())
                .description(task.getDescription())
                .status(task.getStatus())
                .priority(task.getPriority())
                .dueDate(task.getDueDate())
                .tags(task.getTags())
                .assignedToUserId(task.getAssignedToUserId())
                .createdAt(task.getCreatedAt())
                .updatedAt(task.getUpdatedAt())
                .completedAt(task.getCompletedAt())
                .build();
    }
    
    public Task toEntity(TaskDTO dto) {
        if (dto == null) return null;
        
        return Task.builder()
                .id(dto.getId())
                .userId(dto.getUserId())
                .title(dto.getTitle())
                .description(dto.getDescription())
                .status(dto.getStatus())
                .priority(dto.getPriority())
                .dueDate(dto.getDueDate())
                .tags(dto.getTags())
                .assignedToUserId(dto.getAssignedToUserId())
                .createdAt(dto.getCreatedAt())
                .updatedAt(dto.getUpdatedAt())
                .completedAt(dto.getCompletedAt())
                .build();
    }
}
"@

Write-Host "Task Service entities, DTOs, and mappers created!" -ForegroundColor Green

# Continue with next script part...
Write-Host "`nPart 1 of Task Service complete. Run next script for remaining files..." -ForegroundColor Cyan