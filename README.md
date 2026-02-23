# YKS Master Tablet 🎓📱

> [!IMPORTANT]
> **LEGAL NOTICE & PRIVACY**
> This repository is publicly available for **portfolio demonstration and interview review purposes only**.
> All rights reserved. Reproduction, distribution, modification, or usage of this source code for commercial or non-commercial purposes without explicit written permission from the author is **strictly prohibited**.
> Certain sensitive configuration files (Firebase, API Keys) have been excluded for security reasons.

A professional YKS (Higher Education Institutions Exam) preparation application designed specifically for iPad and Android Tablets (Landscape Mode).

## 🚀 Overview

YKS Master is a comprehensive exam solving and productivity suite for students. It features a custom drawing engine with smart shape recognition, persistent exam progress, and advanced analytic tools like the "Mistake Notebook".

## ✨ Key Features

- **Smart Exam Engine**: Full-screen exam solving with integrated persistent scratchpad.
- **Draw & Hold (Shape Snapping)**: Intelligent algorithm (Douglas-Peucker) that converts hand-drawn rough sketches into perfect geometric shapes.
- **Mistake Notebook (Yanlış Defteri)**: Automatically tracks incorrect answers and provides a focused interface for re-attempting failed questions.
- **Daily Analysis**: Intelligent notification system that reminds users of pending reviews.
- **Landscape Optimization**: Custom UI layout designed strictly for tablet experiences.

## 🛠️ Technical Stack

- **Framework**: Flutter
- **Architecture**: Clean Architecture (Data, Domain, Presentation layers)
- **State Management**: Flutter Riverpod
- **Dependency Injection**: get_it
- **Persistence**: SharedPreferences & Disk IO for stroke data
- **Backend**: Firebase (Auth & Firestore) - *Disconnected in this demo version*

## 📁 Repository Structure

- `lib/core`: Foundation, constants, and global utilities (including the Shape Recognizer).
- `lib/data`: Repository implementations and data sources.
- `lib/domain`: Business logic, entities, and repository interfaces.
- `lib/presentation`: Custom widgets, Riverpod providers, and Tablet-optimized UI pages.

---
Developed by **[Adınız Soyadınız]**. 🦾
