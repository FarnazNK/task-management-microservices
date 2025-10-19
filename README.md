\# 🚀 Task Management Microservices Platform



A \*\*production-ready enterprise microservices architecture\*\* built with Spring Boot, demonstrating advanced backend engineering patterns, distributed systems, and cloud-native practices.



\[!\[Java](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)

\[!\[Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen.svg)](https://spring.io/projects/spring-boot)

\[!\[Docker](https://img.shields.io/badge/Docker-Enabled-blue.svg)](https://www.docker.com/)

\[!\[Microservices](https://img.shields.io/badge/Architecture-Microservices-purple.svg)](https://microservices.io/)



---



\## 📋 Table of Contents

\- \[Architecture Overview](#-architecture-overview)

\- \[Key Features](#-key-features)

\- \[Tech Stack](#-tech-stack)

\- \[Project Structure](#-project-structure)

\- \[Getting Started](#-getting-started)

\- \[API Documentation](#-api-documentation)

\- \[Design Patterns](#-design-patterns)

\- \[Security](#-security)



---



\## 🏗️ Architecture Overview

```

&nbsp;                                   ┌─────────────────┐

&nbsp;                                   │   API Gateway   │

&nbsp;                                   │    (Port 8080)  │

&nbsp;                                   └────────┬────────┘

&nbsp;                                            │

&nbsp;                       ┌────────────────────┼────────────────────┐

&nbsp;                       │                    │                    │

&nbsp;                  ┌────▼─────┐       ┌─────▼─────┐       ┌─────▼──────┐

&nbsp;                  │   Auth   │       │   Task    │       │Notification│

&nbsp;                  │ Service  │       │  Service  │       │  Service   │

&nbsp;                  │  :8081   │       │  :8082    │       │   :8084    │

&nbsp;                  └────┬─────┘       └─────┬─────┘       └─────┬──────┘

&nbsp;                       │                   │                    │

&nbsp;                  ┌────▼─────┐       ┌─────▼─────┐       ┌─────▼──────┐

&nbsp;                  │PostgreSQL│       │  MongoDB  │       │   Kafka    │

&nbsp;                  └──────────┘       └─────┬─────┘       └────────────┘

&nbsp;                                            │

&nbsp;                                      ┌─────▼─────┐

&nbsp;                                      │   Redis   │

&nbsp;                                      └───────────┘



&nbsp;                  ┌─────────────────────────────────────┐

&nbsp;                  │    Service Registry (Eureka)        │

&nbsp;                  │          Port 8761                  │

&nbsp;                  └─────────────────────────────────────┘

```



---



\## ✨ Key Features



\### Enterprise Patterns

\- ✅ \*\*Microservices Architecture\*\* - Independently deployable services

\- ✅ \*\*API Gateway Pattern\*\* - Centralized routing and authentication

\- ✅ \*\*Service Discovery\*\* - Dynamic service registration with Eureka

\- ✅ \*\*Event-Driven Architecture\*\* - Kafka for async communication

\- ✅ \*\*Database Per Service\*\* - Polyglot persistence (PostgreSQL + MongoDB)

\- ✅ \*\*CQRS Pattern\*\* - Separated read/write operations



\### Security

\- ✅ \*\*JWT Authentication\*\* - Stateless token-based auth

\- ✅ \*\*Role-Based Access Control (RBAC)\*\* - Granular permissions

\- ✅ \*\*Password Encryption\*\* - BCrypt hashing

\- ✅ \*\*API Rate Limiting\*\* - Redis-backed throttling



\### Performance \& Scalability

\- ✅ \*\*Distributed Caching\*\* - Redis for improved response times

\- ✅ \*\*Database Indexing\*\* - Optimized queries

\- ✅ \*\*Pagination\*\* - Efficient large dataset handling

\- ✅ \*\*Async Processing\*\* - Non-blocking operations with Kafka



\### Code Quality

\- ✅ \*\*Clean Architecture\*\* - Layered design (Controller → Service → Repository)

\- ✅ \*\*DTO Pattern\*\* - Data transfer objects for API contracts

\- ✅ \*\*Global Exception Handling\*\* - Custom error responses

\- ✅ \*\*Input Validation\*\* - Bean validation with custom validators

\- ✅ \*\*API Documentation\*\* - OpenAPI/Swagger integration



---



\## 🛠️ Tech Stack



\### Core Technologies

\- \*\*Java 17\*\* - Programming language

\- \*\*Spring Boot 3.2\*\* - Framework

\- \*\*Spring Cloud 2023.0\*\* - Microservices toolkit

\- \*\*Spring Security\*\* - Authentication \& authorization

\- \*\*Spring Data JPA\*\* - PostgreSQL integration

\- \*\*Spring Data MongoDB\*\* - MongoDB integration



\### Infrastructure

\- \*\*Netflix Eureka\*\* - Service registry \& discovery

\- \*\*Spring Cloud Gateway\*\* - API Gateway \& routing

\- \*\*PostgreSQL\*\* - Relational database (Auth Service)

\- \*\*MongoDB\*\* - NoSQL database (Task Service)

\- \*\*Redis\*\* - Distributed caching \& rate limiting

\- \*\*Apache Kafka\*\* - Message broker for events

\- \*\*Docker\*\* - Containerization



\### Libraries

\- \*\*Lombok\*\* - Boilerplate reduction

\- \*\*JJWT 0.12.3\*\* - JWT token generation/validation

\- \*\*Springdoc OpenAPI\*\* - API documentation

\- \*\*Maven\*\* - Dependency management



---



\## 📁 Project Structure

```

task-management-platform/

│

├── service-registry/              # Eureka Server (Port 8761)

├── api-gateway/                   # API Gateway (Port 8080)

├── auth-service/                  # Authentication Service (Port 8081)

├── task-service/                  # Task Management Service (Port 8082)

├── notification-service/          # Notification Service (Port 8084)

├── docker-compose.yml             # Docker orchestration

└── README.md

```



---



\## 🚀 Getting Started



\### Prerequisites

```bash

\- Java 17 or higher

\- Maven 3.6+

\- Docker \& Docker Compose

```



\### Quick Start with Docker



1\. \*\*Clone the repository\*\*

```bash

git clone https://github.com/FarnazNK/task-management-microservices.git

cd task-management-microservices

```



2\. \*\*Build all services\*\*

```bash

\# Build each service

cd service-registry \&\& mvn clean package -DskipTests \&\& cd ..

cd api-gateway \&\& mvn clean package -DskipTests \&\& cd ..

cd auth-service \&\& mvn clean package -DskipTests \&\& cd ..

cd task-service \&\& mvn clean package -DskipTests \&\& cd ..

cd notification-service \&\& mvn clean package -DskipTests \&\& cd ..

```



3\. \*\*Start all services with Docker Compose\*\*

```bash

docker-compose up -d

```



4\. \*\*Access the services\*\*

\- API Gateway: http://localhost:8080

\- Eureka Dashboard: http://localhost:8761

\- Swagger UI (Auth): http://localhost:8081/swagger-ui.html

\- Swagger UI (Task): http://localhost:8082/swagger-ui.html



---



\## 📝 API Documentation



\### Authentication Endpoints



\#### Register User

```http

POST http://localhost:8080/api/auth/register

Content-Type: application/json



{

&nbsp; "username": "johndoe",

&nbsp; "email": "john@example.com",

&nbsp; "password": "SecurePass123!"

}

```



\#### Login

```http

POST http://localhost:8080/api/auth/login

Content-Type: application/json



{

&nbsp; "username": "johndoe",

&nbsp; "password": "SecurePass123!"

}

```



\### Task Endpoints (Requires Authentication)



\#### Create Task

```http

POST http://localhost:8080/api/tasks

Authorization: Bearer {token}

Content-Type: application/json



{

&nbsp; "title": "Complete project documentation",

&nbsp; "description": "Write comprehensive README",

&nbsp; "status": "TODO",

&nbsp; "priority": "HIGH",

&nbsp; "dueDate": "2025-10-25T23:59:59"

}

```



\#### Get All Tasks

```http

GET http://localhost:8080/api/tasks?page=0\&size=10

Authorization: Bearer {token}

```



\#### Get Task Statistics

```http

GET http://localhost:8080/api/tasks/stats

Authorization: Bearer {token}

```



---



\## 🎨 Design Patterns Implemented



1\. \*\*Microservices Pattern\*\* - Independent deployable services

2\. \*\*API Gateway Pattern\*\* - Single entry point

3\. \*\*Service Registry Pattern\*\* - Dynamic service discovery

4\. \*\*Database Per Service\*\* - Polyglot persistence

5\. \*\*Event-Driven Architecture\*\* - Async communication with Kafka

6\. \*\*CQRS\*\* - Command Query Responsibility Segregation

7\. \*\*Repository Pattern\*\* - Data access abstraction

8\. \*\*DTO Pattern\*\* - Data transfer objects



---



\## 🔒 Security



\### Authentication Flow

1\. User sends credentials to `/api/auth/login`

2\. Auth Service validates and generates JWT

3\. Client stores JWT and includes in Authorization header

4\. API Gateway validates JWT before routing

5\. User context propagated via custom headers



\### Security Features

\- Password hashing with BCrypt

\- JWT expiration (24 hours)

\- Role-based access control

\- API rate limiting (100 requests/minute)

\- CORS configuration

\- Input validation



---



\## 📊 Service Communication



\- \*\*Synchronous\*\*: REST APIs via API Gateway

\- \*\*Asynchronous\*\*: Event-driven with Apache Kafka

\- \*\*Service Discovery\*\*: Netflix Eureka

\- \*\*Load Balancing\*\*: Spring Cloud LoadBalancer

\- \*\*Caching\*\*: Redis for distributed caching



---



\## 🧪 Running Locally (Without Docker)



1\. \*\*Start Infrastructure\*\*

```bash

\# PostgreSQL

docker run -d --name postgres-auth -e POSTGRES\_DB=authdb -e POSTGRES\_USER=authuser -e POSTGRES\_PASSWORD=authpass123 -p 5432:5432 postgres:15-alpine



\# MongoDB

docker run -d --name mongodb -e MONGO\_INITDB\_ROOT\_USERNAME=admin -e MONGO\_INITDB\_ROOT\_PASSWORD=admin123 -p 27017:27017 mongo:7-jammy



\# Redis

docker run -d --name redis -p 6379:6379 redis:7-alpine



\# Kafka \& Zookeeper

docker run -d --name zookeeper -e ZOOKEEPER\_CLIENT\_PORT=2181 -p 2181:2181 confluentinc/cp-zookeeper:7.5.0

docker run -d --name kafka -e KAFKA\_ZOOKEEPER\_CONNECT=localhost:2181 -e KAFKA\_ADVERTISED\_LISTENERS=PLAINTEXT://localhost:9092 -p 9092:9092 confluentinc/cp-kafka:7.5.0

```



2\. \*\*Start Services\*\*

```bash

\# Start in order

cd service-registry \&\& mvn spring-boot:run

cd api-gateway \&\& mvn spring-boot:run

cd auth-service \&\& mvn spring-boot:run

cd task-service \&\& mvn spring-boot:run

cd notification-service \&\& mvn spring-boot:run

```



---



\## 📈 Monitoring



\- \*\*Eureka Dashboard\*\*: http://localhost:8761

\- \*\*Spring Boot Actuator\*\*: `/actuator/health` endpoints

\- \*\*Logs\*\*: Structured logging with SLF4J



---



\## 🤝 Contributing



This is a portfolio project showcasing enterprise microservices architecture.



---



\## 📄 License



MIT License



---



\## 👤 Author



\*\*Farnaz NK\*\*

\- GitHub: \[@FarnazNK](https://github.com/FarnazNK)

\- LinkedIn: \[Your LinkedIn Profile](https://linkedin.com/in/yourprofile)



---



\## 🙏 Acknowledgments



\- Spring Framework Team

\- Netflix OSS

\- Apache Kafka Community



---



⭐ \*\*If this project helps you, please give it a star!\*\*

