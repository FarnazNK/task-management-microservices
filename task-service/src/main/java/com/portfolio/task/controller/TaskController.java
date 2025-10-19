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
