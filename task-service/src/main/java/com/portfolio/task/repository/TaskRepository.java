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
    
    @Query("{ 'userId': ?0, $or: [ { 'title': { $regex: ?1, $options: 'i' } }, { 'description': { $regex: ?1, $options: 'i' } } ] }")
    Page<Task> searchTasks(Long userId, String keyword, Pageable pageable);
    
    List<Task> findByUserIdAndStatusAndDueDateBefore(Long userId, Task.TaskStatus status, LocalDateTime dueDate);
    
    long countByUserIdAndStatus(Long userId, Task.TaskStatus status);
}
