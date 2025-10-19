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
