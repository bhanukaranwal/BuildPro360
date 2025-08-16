# BuildPro360 - Construction Management Platform

![BuildPro360 Logo](docs/images/buildpro360-logo.png)

## Overview

BuildPro360 is a comprehensive construction management platform designed to streamline operations, improve efficiency, and enhance decision-making in construction projects. By integrating asset management, project tracking, maintenance planning, compliance monitoring, IoT integration, and advanced analytics, BuildPro360 provides a 360-degree view of construction operations.

**Version:** 1.0.0  
**Date:** August 16, 2025  
**Developed by:** BuildPro360 Team  
**Last Updated by:** bhanukaranwal

## Table of Contents

- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Technology Stack](#technology-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
- [Microservices](#microservices)
- [Mobile Application](#mobile-application)
- [API Documentation](#api-documentation)
- [Deployment](#deployment)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## Key Features

### Asset Management
- Complete equipment and tool inventory tracking
- Asset utilization monitoring and optimization
- Equipment maintenance scheduling
- Asset location tracking
- Comprehensive asset lifecycle management

### Project Management
- Project planning and scheduling
- Task assignment and tracking
- Resource allocation
- Budget management
- Real-time progress monitoring
- Document management

### Maintenance Management
- Preventive maintenance scheduling
- Corrective maintenance tracking
- Maintenance history logging
- Work order management
- Spare parts inventory

### Compliance & Safety
- Inspection scheduling and reporting
- Safety incident tracking
- Regulatory requirement management
- Certification tracking
- Compliance analytics

### IoT Integration
- Real-time equipment monitoring
- Environmental condition tracking
- Predictive maintenance alerts
- Geofencing and location services
- Remote equipment control

### Analytics & Business Intelligence
- Executive dashboards
- Performance metrics
- Predictive analytics
- Custom report generation
- Data visualization

### Mobile Access
- Field data collection
- Mobile inspections
- Real-time task updates
- Offline capability
- Cross-platform compatibility

## System Architecture

BuildPro360 is built using a modern microservices architecture, allowing for scalability, resilience, and maintainability.

![System Architecture](docs/images/architecture-diagram.png)

### Key Components:

1. **Frontend Layer**
   - Web application (React)
   - Mobile application (Flutter)

2. **API Gateway**
   - Request routing
   - Authentication
   - Rate limiting
   - Load balancing

3. **Microservices**
   - Asset Service
   - Project Service
   - Maintenance Service
   - Compliance Service
   - IoT Integration Service
   - Analytics Service
   - Notification Service
   - User Service

4. **Data Storage**
   - PostgreSQL for relational data
   - MongoDB for document storage
   - InfluxDB for time-series data
   - Redis for caching

5. **Infrastructure**
   - Containerized deployment with Docker
   - Orchestration with Kubernetes
   - CI/CD with GitHub Actions

## Technology Stack

### Backend
- **Languages:** Python, Node.js
- **Frameworks:** FastAPI, Express.js
- **Authentication:** JWT, OAuth 2.0
- **Databases:** PostgreSQL, MongoDB, InfluxDB, Redis
- **Message Brokers:** RabbitMQ, Kafka
- **IoT Protocols:** MQTT, WebSockets

### Frontend (Web)
- **Framework:** React with TypeScript
- **State Management:** Redux
- **UI Components:** Material-UI
- **Data Visualization:** D3.js, Chart.js
- **Maps:** Leaflet, Mapbox

### Mobile
- **Framework:** Flutter
- **State Management:** Bloc pattern
- **Local Storage:** SQLite, Shared Preferences
- **Networking:** Dio
- **UI Components:** Flutter Material Design

### DevOps
- **Containerization:** Docker
- **Orchestration:** Kubernetes
- **CI/CD:** GitHub Actions
- **Monitoring:** Prometheus, Grafana
- **Logging:** ELK Stack (Elasticsearch, Logstash, Kibana)

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Python 3.9+
- Node.js 16+
- Flutter SDK 3.0+
- PostgreSQL 14+
- MongoDB 5.0+
- InfluxDB 2.0+
- Redis 6.0+

### Installation

#### Clone the repository

```bash
git clone https://github.com/buildpro360/buildpro360.git
cd buildpro360