# =====================================================
# TASK SERVICE - Part 2 (Service, Controller, Kafka, Config)
# =====================================================

Write-Host "Generating Task Service Part 2..." -ForegroundColor Cyan

# TaskService.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\service\TaskService.java" -Value @"
package com.portfolio.task.service;

import com.portfolio.task.dto.TaskDTO;
import com.portfolio.task.dto.TaskStatsDTO;
import com.portfolio.task.entity.Task;
import com.portfolio.task.exception.ResourceNotFoundException;
import com.portfolio.task.exception.UnauthorizedException;
import com.portfolio.task.kafka.TaskEventProducer;
import com.portfolio.task.mapper.TaskMapper;
import com.portfolio.task.repository.TaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TaskService {
    
    private final TaskRepository taskRepository;
    private final TaskMapper taskMapper;
    private final TaskEventProducer taskEventProducer;
    
    @CacheEvict(value = "tasks", allEntries = true)
    public TaskDTO createTask(TaskDTO taskDTO, Long userId) {
        log.info("Creating task for user: {}", userId);
        
        Task task = taskMapper.toEntity(taskDTO);
        task.setUserId(userId);
        task.setCreatedAt(LocalDateTime.now());
        
        Task savedTask = taskRepository.save(task);
        
        taskEventProducer.sendTaskCreatedEvent(savedTask);
        
        log.info("Task created successfully: {}", savedTask.getId());
        return taskMapper.toDTO(savedTask);
    }
    
    @Cacheable(value = "tasks", key = "#taskId")
    public TaskDTO getTaskById(String taskId, Long userId) {
        log.info("Fetching task: {} for user: {}", taskId, userId);
        
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        
        if (!task.getUserId().equals(userId) && 
            (task.getAssignedToUserId() == null || !task.getAssignedToUserId().equals(userId))) {
            throw new UnauthorizedException("You don't have permission to access this task");
        }
        
        return taskMapper.toDTO(task);
    }
    
    public Page<TaskDTO> getAllTasks(Long userId, int page, int size, String sortBy) {
        log.info("Fetching all tasks for user: {}", userId);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, sortBy));
        Page<Task> tasks = taskRepository.findByUserId(userId, pageable);
        
        return tasks.map(taskMapper::toDTO);
    }
    
    public Page<TaskDTO> getTasksByStatus(Long userId, Task.TaskStatus status, int page, int size) {
        log.info("Fetching tasks by status: {} for user: {}", status, userId);
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Task> tasks = taskRepository.findByUserIdAndStatus(userId, status, pageable);
        
        return tasks.map(taskMapper::toDTO);
    }
    
    public Page<TaskDTO> searchTasks(Long userId, String keyword, int page, int size) {
        log.info("Searching tasks with keyword: {} for user: {}", keyword, userId);
        
        Pageable pageable = PageRequest.of(page, size);
        Page<Task> tasks = taskRepository.searchTasks(userId, keyword, pageable);
        
        return tasks.map(taskMapper::toDTO);
    }
    
    @CacheEvict(value = "tasks", key = "#taskId")
    public TaskDTO updateTask(String taskId, TaskDTO taskDTO, Long userId) {
        log.info("Updating task: {} for user: {}", taskId, userId);
        
        Task existingTask = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        
        if (!existingTask.getUserId().equals(userId)) {
            throw new UnauthorizedException("You don't have permission to update this task");
        }
        
        existingTask.setTitle(taskDTO.getTitle());
        existingTask.setDescription(taskDTO.getDescription());
        existingTask.setStatus(taskDTO.getStatus());
        existingTask.setPriority(taskDTO.getPriority());
        existingTask.setDueDate(taskDTO.getDueDate());
        existingTask.setTags(taskDTO.getTags());
        existingTask.setUpdatedAt(LocalDateTime.now());
        
        if (taskDTO.getStatus() == Task.TaskStatus.COMPLETED && existingTask.getCompletedAt() == null) {
            existingTask.setCompletedAt(LocalDateTime.now());
        }
        
        Task updatedTask = taskRepository.save(existingTask);
        
        taskEventProducer.sendTaskUpdatedEvent(updatedTask);
        
        log.info("Task updated successfully: {}", updatedTask.getId());
        return taskMapper.toDTO(updatedTask);
    }
    
    @CacheEvict(value = "tasks", key = "#taskId")
    public void deleteTask(String taskId, Long userId) {
        log.info("Deleting task: {} for user: {}", taskId, userId);
        
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        
        if (!task.getUserId().equals(userId)) {
            throw new UnauthorizedException("You don't have permission to delete this task");
        }
        
        taskRepository.delete(task);
        
        taskEventProducer.sendTaskDeletedEvent(task);
        
        log.info("Task deleted successfully: {}", taskId);
    }
    
    public TaskStatsDTO getTaskStats(Long userId) {
        log.info("Fetching task statistics for user: {}", userId);
        
        long total = taskRepository.findByUserId(userId, Pageable.unpaged()).getTotalElements();
        long todo = taskRepository.countByUserIdAndStatus(userId, Task.TaskStatus.TODO);
        long inProgress = taskRepository.countByUserIdAndStatus(userId, Task.TaskStatus.IN_PROGRESS);
        long completed = taskRepository.countByUserIdAndStatus(userId, Task.TaskStatus.COMPLETED);
        
        List<Task> overdueTasks = taskRepository.findByUserIdAndStatusAndDueDateBefore(
                userId, Task.TaskStatus.TODO, LocalDateTime.now());
        
        return TaskStatsDTO.builder()
                .totalTasks(total)
                .todoTasks(todo)
                .inProgressTasks(inProgress)
                .completedTasks(completed)
                .overdueTasks(overdueTasks.size())
                .build();
    }
    
    @CacheEvict(value = "tasks", key = "#taskId")
    public TaskDTO addComment(String taskId, Long userId, String username, String content) {
        log.info("Adding comment to task: {}", taskId);
        
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found"));
        
        Task.Comment comment = Task.Comment.builder()
                .id(UUID.randomUUID().toString())
                .userId(userId)
                .username(username)
                .content(content)
                .createdAt(LocalDateTime.now())
                .build();
        
        task.getComments().add(comment);
        Task updatedTask = taskRepository.save(task);
        
        return taskMapper.toDTO(updatedTask);
    }
}
"@

# TaskController.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\controller\TaskController.java" -Value @"
package com.portfolio.task.controller;

import com.portfolio.task.dto.TaskDTO;
import com.portfolio.task.dto.TaskStatsDTO;
import com.portfolio.task.entity.Task;
import com.portfolio.task.service.TaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/tasks")
@RequiredArgsConstructor
@Tag(name = "Tasks", description = "Task management endpoints")
public class TaskController {
    
    private final TaskService taskService;
    
    @PostMapping
    @Operation(summary = "Create new task")
    public ResponseEntity<TaskDTO> createTask(
            @Valid @RequestBody TaskDTO taskDTO,
            @RequestHeader("X-User-Id") Long userId) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(taskService.createTask(taskDTO, userId));
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get task by ID")
    public ResponseEntity<TaskDTO> getTaskById(
            @PathVariable String id,
            @RequestHeader("X-User-Id") Long userId) {
        return ResponseEntity.ok(taskService.getTaskById(id, userId));
    }
    
    @GetMapping
    @Operation(summary = "Get all tasks")
    public ResponseEntity<Page<TaskDTO>> getAllTasks(
            @RequestHeader("X-User-Id") Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy) {
        return ResponseEntity.ok(taskService.getAllTasks(userId, page, size, sortBy));
    }
    
    @GetMapping("/status/{status}")
    @Operation(summary = "Get tasks by status")
    public ResponseEntity<Page<TaskDTO>> getTasksByStatus(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Task.TaskStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(taskService.getTasksByStatus(userId, status, page, size));
    }
    
    @GetMapping("/search")
    @Operation(summary = "Search tasks")
    public ResponseEntity<Page<TaskDTO>> searchTasks(
            @RequestHeader("X-User-Id") Long userId,
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(taskService.searchTasks(userId, keyword, page, size));
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update task")
    public ResponseEntity<TaskDTO> updateTask(
            @PathVariable String id,
            @Valid @RequestBody TaskDTO taskDTO,
            @RequestHeader("X-User-Id") Long userId) {
        return ResponseEntity.ok(taskService.updateTask(id, taskDTO, userId));
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete task")
    public ResponseEntity<Void> deleteTask(
            @PathVariable String id,
            @RequestHeader("X-User-Id") Long userId) {
        taskService.deleteTask(id, userId);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/stats")
    @Operation(summary = "Get task statistics")
    public ResponseEntity<TaskStatsDTO> getTaskStats(
            @RequestHeader("X-User-Id") Long userId) {
        return ResponseEntity.ok(taskService.getTaskStats(userId));
    }
    
    @PostMapping("/{id}/comments")
    @Operation(summary = "Add comment to task")
    public ResponseEntity<TaskDTO> addComment(
            @PathVariable String id,
            @RequestHeader("X-User-Id") Long userId,
            @RequestHeader("X-User-Username") String username,
            @RequestParam String content) {
        return ResponseEntity.ok(taskService.addComment(id, userId, username, content));
    }
}
"@

# TaskEvent.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\kafka\TaskEvent.java" -Value @"
package com.portfolio.task.kafka;

import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class TaskEvent {
    private String eventType;
    private String taskId;
    private Long userId;
    private String title;
    private String status;
}
"@

# TaskEventProducer.java
Set-Content -Path "task-service\src\main\java\com\portfolio\task\kafka\TaskEventProducer.java" -Value @"
package com.portfolio.task.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.portfolio.task.entity.Task;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class TaskEventProducer {
    
    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;
    
    private static final String TASK_EVENTS_TOPIC = "task-events";
    
    public void sendTaskCreatedEvent(Task task) {
        try {
            TaskEvent event = TaskEvent.builder()
                    .eventType("TASK_CREATED")
                    .taskId(task.getId())
                    .userId(task.getUserId())
                    .title(task.getTitle())
                    .status(task.getStatus().name())
                    .build();
            
            String message = objectMapper.writeValueAsString(event);
            kafkaTemplate.send(TASK_EVENTS_TOPIC, task.getId(), message);
            
            log.info("Task created event sent: {}", task.getId());
        } catch (Exception e) {
            log.error("Error sending task created event", e);
        }
    }
    
    public void sendTaskUpdatedEvent(Task task) {
        try {
            TaskEvent event = TaskEvent.builder()
                    .eventType("TASK_UPDATED")
                    .taskId(task.getId())
                    .userId(task.getUserId())
                    .title(task.getTitle())
                    .status(task.getStatus().name())
                    .build();
            
            String message = objectMapper.writeValueAsString(event);
            kafkaTemplate.send(TASK_EVENTS_TOPIC, task.getId(), message);
            
            log.info("Task updated event sent: {}", task.getId());
        } catch (Exception e) {
            log.error("Error sending task updated event", e);
        }
    }
    
    public void sendTaskDeletedEvent(Task task) {
        try {
            TaskEvent event = TaskEvent.builder()
                    .eventType("TASK_DELETED")
                    .taskId(task.getId())
                    .userId(task.getUserId())
                    .title(task.getTitle())
                    .build();
            
            String message = objectMapper.writeValueAsString(event);
            kafkaTemplate.send(TASK_EVENTS_TOPIC, task.getId(), message);
            
            log.info("Task deleted event sent: {}", task.getId());
        } catch (Exception e) {
            log.error("Error sending task deleted event", e);
        }
    }
}
"@

Write-Host "Task Service controllers and Kafka complete!" -ForegroundColor Green
Write-Host "`nRun next script for configs and exceptions..." -ForegroundColor Cyan