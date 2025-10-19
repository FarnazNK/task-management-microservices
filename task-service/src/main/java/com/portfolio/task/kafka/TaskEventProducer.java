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
