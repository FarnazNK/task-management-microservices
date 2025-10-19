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
