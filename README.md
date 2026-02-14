# Smart Bin Application
---

## 📚 Additional Documentation

- 📘 [System Design](SYSTEM_DESIGN.md)
- ⚙️ [Installation Guide](INSTALLATION.md)
- 🤝 [Contributing Guidelines](CONTRIBUTING.md)


![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

A mobile application developed using Flutter for intelligent waste classification and tracking.

---

## 📑 Table of Contents
- [Project Overview](#-project-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [System Architecture](#-system-architecture)
- [Use Case Diagram](#-use-case-diagram)
- [Architecture Diagram](#-architecture-diagram)
- [Project Structure](#-project-structure)
- [Installation & Setup](#-installation--setup)
- [Authentication System](#-authentication-system)
- [Database Design](#-database-design)
- [ER Diagram](#-er-diagram)
- [Application Workflow](#-application-workflow)
- [AI Classification](#-ai-classification)
- [Deployment Diagram](#-deployment-diagram)
- [Future Improvements](#-future-improvements)
- [Version](#-version)
- [Developer](#-developer)

---

## 📌 Project Overview

The Smart Bin Application helps users classify waste and track disposal history.  
It integrates Firebase Cloud services and local SQLite storage for hybrid (online/offline) support.

### Main Objectives
- Improve waste classification awareness  
- Provide digital tracking system  
- Demonstrate Flutter + Firebase integration  

---

## 🚀 Features
- 🔐 Authentication (Register/Login/Logout)
- 📷 Waste Scanning
- 🤖 Mock AI Classification
- ☁️ Firestore Cloud Storage
- 💾 SQLite Offline Storage
- 📊 Dashboard Statistics
- 📜 Scan History
- 🗺 Waste Bin Map
- 🔄 Bottom Navigation

---

## 🛠 Tech Stack
- Flutter (Dart)
- Firebase Authentication
- Cloud Firestore
- SQLite
- Mock AI Service
- Google Maps

---

## 🏗 System Architecture

Layered Architecture:
1. UI Layer  
2. Navigation/Controller  
3. Service Layer  
4. Database Layer  

Data Flow:
User → UI → Service → Database → UI

---

## 📋 Use Case Diagram

```
        +------------------+
        |      User        |
        +------------------+
           |   |    |    |
           |   |    |    +--> View Map
           |   |    +--------> View History
           |   +-------------> Scan Waste
           +-----------------> Login/Register
```

---

## 🧱 Architecture Diagram

```
        ┌───────────┐
        │   User    │
        └─────┬─────┘
              │
              ▼
        ┌───────────┐
        │    UI     │
        └─────┬─────┘
              │
              ▼
        ┌───────────┐
        │  Service  │
        └─────┬─────┘
        ┌─────┴─────┐
        ▼           ▼
  ┌─────────┐  ┌─────────┐
  │Firestore│  │ SQLite  │
  └─────────┘  └─────────┘
```

---

## 📂 Project Structure

```bash
lib/
├── main.dart
├── main_navigation.dart
├── navigation_controller.dart
├── screens/
├── services/
└── models/
```

---

## ⚙️ Installation & Setup

```bash
git clone https://github.com/manks0123/flutter_smartbin.git
cd flutter_smartbin
flutter pub get
flutter run
```

Firebase:
- Enable Authentication
- Enable Firestore
- Add google-services.json to android/app/

---

## 🔐 Authentication System
Uses Firebase Authentication (Email/Password).

---

## 📊 Database Design

Cloud Firestore:

users:
- userId
- email

scans:
- scanId
- userId
- wasteType
- timestamp

---

## 🗄 ER Diagram

```
User
-----
userId (PK)
email

Scan
-----
scanId (PK)
userId (FK)
wasteType
timestamp

User (1) -------- (M) Scan
```

---

## 🔄 Application Workflow
1. Login
2. Scan Waste
3. AI Classification
4. Save to DB
5. Update Dashboard

---

## 🤖 AI Classification
Mock AI service used.  
Future: TensorFlow Lite integration.

---

## 🚀 Deployment Diagram

```
[ Android Device ]
        |
        ▼
[ Flutter Application ]
        |
        ▼
[ Firebase Cloud ]
   |            |
Auth        Firestore
```

---

## 📈 Future Improvements
- Real AI model
- Rewards system
- Push notifications
- Admin panel

---

## 🏷 Version
1.0.0 (2026)

---

## 👨‍💻 Developer
Student Project – Information Technology

---

## 📄 License
Educational use only.
