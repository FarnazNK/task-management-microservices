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
