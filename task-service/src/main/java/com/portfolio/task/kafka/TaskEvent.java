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
