package com.portfolio.auth.config;

import com.portfolio.auth.entity.Role;
import com.portfolio.auth.repository.RoleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {
    
    private final RoleRepository roleRepository;
    
    @Override
    public void run(String... args) {
        if (roleRepository.count() == 0) {
            log.info("Initializing roles...");
            
            Role userRole = Role.builder()
                    .name(Role.RoleType.ROLE_USER)
                    .build();
            
            Role adminRole = Role.builder()
                    .name(Role.RoleType.ROLE_ADMIN)
                    .build();
            
            Role managerRole = Role.builder()
                    .name(Role.RoleType.ROLE_MANAGER)
                    .build();
            
            roleRepository.save(userRole);
            roleRepository.save(adminRole);
            roleRepository.save(managerRole);
            
            log.info("Roles initialized successfully");
        }
    }
}
