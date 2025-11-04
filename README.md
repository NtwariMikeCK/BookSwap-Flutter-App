# 📚 BookSwap - Textbook Exchange Platform

<div align="center">

![BookSwap Logo](https://img.shields.io/badge/BookSwap-Exchange%20Books-deepviolet?style=for-the-badge&logo=flutter)

**A mobile application that enables students to exchange textbooks seamlessly**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?style=flat&logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 🌟 Overview

**BookSwap** is a mobile application designed specifically for students who want to exchange textbooks with their peers instead of buying new ones. Built with Flutter and Firebase, it provides a seamless, real-time platform for book swapping with integrated chat functionality.

### 💡 The Problem We Solve

- **High textbook costs** burden students financially
- **Unused books** accumulate after semesters end
- **Environmental waste** from disposing of books
- **Lack of trust** in traditional peer-to-peer exchanges

### ✨ Our Solution

BookSwap creates a trusted, user-friendly ecosystem where students can:
- Upload books they no longer need
- Browse available books from other students
- Propose swaps instead of purchases
- Chat securely before finalizing exchanges
- Track swap history and status

---

## 🎯 Features

### 📖 Book Management
- **Upload Books**: Add textbooks with title, author, description, condition, and cover image
- **Browse Catalog**: View all available books in an intuitive grid layout
- **Book Details**: See comprehensive information before proposing a swap
- **Edit/Delete**: Manage your book listings at any time
- **Status Tracking**: Real-time updates on book availability (available, pending, swapped)

### 🔄 Swap System
- **Propose Swaps**: Offer one of your books in exchange for another
- **Incoming Offers**: Review swap requests from other students
- **Accept/Decline**: Control which swaps you want to complete
- **Atomic Transactions**: Both books update status simultaneously to prevent conflicts
- **Swap History**: Track all your past and current swaps

### 💬 Real-Time Chat
- **Auto-Created Chats**: Automatically start conversations when swaps are proposed
- **Message History**: Access complete conversation logs
- **Real-Time Sync**: Instant message delivery using Firestore streams
- **Timestamps**: Know exactly when messages were sent

### 🔐 Authentication & Security
- **Email/Password Auth**: Secure Firebase authentication
- **Email Verification**: Ensure valid user accounts
- **Password Reset**: Easy account recovery
- **Firestore Security Rules**: Database-level access control
- **Privacy Protection**: Only swap participants can chat

### ⚙️ User Settings
- **Profile Management**: Update your display name and photo
- **Notification Preferences**: Control push, email, and in-app notifications
- **Account Settings**: Manage your BookSwap experience

---

## 📱 Screenshots

### Authentication Flow
```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│   Welcome   │ → │   Sign Up   │ → │    Login    │
│   Screen    │   │   Screen    │   │   Screen    │
└─────────────┘   └─────────────┘   └─────────────┘
```

### Main App Screens
```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│   Browse    │  My Books   │    Chats    │  Settings   │
│   Books     │             │             │             │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

---

## 🏗️ Architecture

### Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile UI |
| **State Management** | Riverpod | Reactive state management |
| **Backend** | Firebase | Complete BaaS solution |
| **Authentication** | Firebase Auth | User authentication & authorization |
| **Database** | Cloud Firestore | NoSQL real-time database |
| **Storage** | Firebase Storage | Book cover & profile image storage |
| **Functions** | Cloud Functions | Serverless backend logic |

### Design Patterns

- **Repository Pattern**: Separates data access logic from business logic
- **Provider Architecture**: Clean separation of UI and state
- **Streams**: Real-time data synchronization
- **Atomic Transactions**: Ensures data consistency during swaps

### Database Schema

```
📦 Firestore Collections
├── 👥 users
│   ├── uid (PK)
│   ├── name
│   ├── email
│   └── notificationPreferences
│
├── 📚 books
│   ├── bookId (PK)
│   ├── title
│   ├── author
│   ├── ownerId (FK → users)
│   └── status
│
├── 🔄 swaps
│   ├── swapId (PK)
│   ├── requesterId (FK → users)
│   ├── requesterBookId (FK → books)
│   ├── recipientId (FK → users)
│   ├── recipientBookId (FK → books)
│   └── status
│
├── 💬 chats
│   ├── chatId (PK)
│   ├── participants [userId1, userId2]
│   ├── relatedSwapId (FK → swaps)
│   └── messages (subcollection)
│       ├── messageId (PK)
│       ├── senderId (FK → users)
│       └── text
│
└── 🔔 notifications
    ├── notificationId (PK)
    ├── userId (FK → users)
    └── type
```

### State Flow Diagram

```
┌──────────────┐
│   UI Layer   │
│  (Widgets)   │
└──────┬───────┘
       │ ref.watch()
       ↓
┌──────────────┐
│  Providers   │
│  (Riverpod)  │
└──────┬───────┘
       │
       ↓
┌──────────────┐
│ Repositories │
│ (Bus. Logic) │
└──────┬───────┘
       │
       ↓
┌──────────────┐
│   Firebase   │
│   Services   │
└──────────────┘
```

---

## 🚀 Installation

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode
- Firebase account
- Git

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/bookswap.git
cd bookswap
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Setup

#### 3.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Follow the setup wizard

#### 3.2 Add Android App
```bash
# Download google-services.json
# Place it in: android/app/
```

#### 3.3 Add iOS App
```bash
# Download GoogleService-Info.plist
# Place it in: ios/Runner/
```

#### 3.4 Update Android Configuration

**android/build.gradle**
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

**android/app/build.gradle**
```gradle
apply plugin: 'com.google.gms.google-services'
```

#### 3.5 Enable Firebase Services

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

2. **Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Choose location and security rules mode

3. **Storage**
   - Go to Storage
   - Click "Get started"
   - Set up security rules

### Step 4: Configure Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId);
    }
    
    match /books/{bookId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && 
                    request.resource.data.ownerId == request.auth.uid;
      allow update, delete: if isSignedIn() && 
                             resource.data.ownerId == request.auth.uid;
    }
    
    match /swaps/{swapId} {
      allow read: if isSignedIn() && 
                  (resource.data.requesterId == request.auth.uid || 
                   resource.data.recipientId == request.auth.uid);
      allow create: if isSignedIn();
      allow update: if isSignedIn() && 
                    (resource.data.requesterId == request.auth.uid ||
                     resource.data.recipientId == request.auth.uid);
    }
    
    match /chats/{chatId} {
      allow read, write: if isSignedIn() && 
                         request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if isSignedIn() && 
                           request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
  }
}
```

### Step 5: Configure Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_covers/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   request.resource.size < 5 * 1024 * 1024;
    }
    
    match /profile_pictures/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   request.resource.size < 2 * 1024 * 1024;
    }
  }
}
```

### Step 6: Create Firestore Indexes

Create composite indexes for optimal query performance:

```
Collection: books
Fields: status (Ascending), createdAt (Descending)

Collection: chats
Fields: participants (Array), updatedAt (Descending)

Collection: swaps
Fields: requesterId (Ascending), createdAt (Descending)
Fields: recipientId (Ascending), createdAt (Descending)
```

### Step 7: Run the App

```bash
# Check for issues
flutter doctor

# Run on connected device
flutter run

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
flutter build appbundle    # Android App Bundle
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # UI & Utils
  image_picker: ^1.0.5
  cached_network_image: ^3.3.0
  intl: ^0.18.1
  uuid: ^4.2.1
```

---

## 🎮 Usage Guide

### For Students Looking to Exchange Books

1. **Sign Up / Login**
   - Create an account with your email
   - Verify your email address

2. **Add Your Books**
   - Tap the "+" button in "My Books" tab
   - Fill in book details (title, author, condition, description)
   - Upload a cover photo (optional)

3. **Browse Available Books**
   - Go to "Browse" tab
   - Scroll through available textbooks
   - Tap any book to see full details

4. **Propose a Swap**
   - On a book detail page, tap "Offer a Swap"
   - Select one of your available books to offer
   - Confirm the swap proposal

5. **Manage Swap Offers**
   - Go to "My Books" → Tap swap icon
   - Review incoming offers
   - Accept or decline based on your preference

6. **Chat with Swap Partners**
   - Once a swap is proposed, chat is automatically created
   - Go to "Chats" tab
   - Coordinate exchange details with your swap partner

7. **Complete the Exchange**
   - Meet in person to exchange books
   - Mark swap as completed in the app

---


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 BookSwap Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

**Made with ❤️ by students, for students**

⭐ Star us on GitHub — it helps!

[Report Bug](https://github.com/yourusername/bookswap/issues) • [Request Feature](https://github.com/yourusername/bookswap/issues)
