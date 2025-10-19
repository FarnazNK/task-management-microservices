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
