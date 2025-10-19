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
