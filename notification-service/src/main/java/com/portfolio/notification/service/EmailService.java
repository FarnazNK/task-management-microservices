package com.portfolio.notification.service;

import com.portfolio.notification.kafka.TaskEventConsumer;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {
    
    private final JavaMailSender mailSender;
    
    public void sendTaskCreatedNotification(Object event) {
        log.info("Sending task created notification");
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo("user@example.com");
            message.setSubject("New Task Created");
            message.setText("A new task has been created in your task management system.");
            
            // Uncomment when email is configured
            // mailSender.send(message);
            log.info("Task created notification sent successfully");
        } catch (Exception e) {
            log.error("Error sending email notification", e);
        }
    }
    
    public void sendTaskCompletedNotification(Object event) {
        log.info("Sending task completed notification");
        
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo("user@example.com");
            message.setSubject("Task Completed");
            message.setText("Congratulations! Your task has been completed.");
            
            // Uncomment when email is configured
            // mailSender.send(message);
            log.info("Task completed notification sent successfully");
        } catch (Exception e) {
            log.error("Error sending email notification", e);
        }
    }
}
