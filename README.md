# CafeStock – Cafe Inventory & Expiration Management
**CS310 – Mobile Application Development**
**Sabancı University | Group 28**

## About the Project

CafeStock is a Flutter-based mobile application designed to help independent cafes manage their inventory, monitor ingredient quantities and track product expiration dates.

Many cafes rely on manual inventory tracking, which can result in inaccurate stock records, expired ingredients and unnecessary food waste. These problems are especially common for products stored in refrigerators, freezers and storage areas.

CafeStock aims to provide a simple and centralized inventory management system that allows cafe owners and baristas to monitor and update inventory from their own devices.

The application is intended exclusively for internal cafe operations and does not include customer-facing features.

## Core Features

### 1. Product & Inventory Management
- Add, edit, categorize and remove products.
- Record product names, measurement units (kg, L, pcs), and storage locations.
- Search and filter inventory items.

### 2. Batch-Based Expiration Tracking
- Store multiple batches of the same product.
- Track quantities and expiration dates separately for each batch.
- Highlight products approaching their expiration dates.
- Display expired products separately.

For example, a cafe may have 12 liters of milk with 5 liters expiring tomorrow and 7 liters next week. CafeStock will track these as separate batches.

### 3. Stock Operations
- Record incoming deliveries.
- Track ingredient consumption.
- Register waste and manual stock adjustments.
- Automatically update inventory quantities.
- Maintain transaction history with timestamps and responsible users.

### 4. Low-Stock & Expiration Alerts
- Define minimum stock thresholds for individual products.
- Display in-app warnings for low-stock items.
- Highlight products approaching expiration.

### 5. Inventory Dashboard
- Display the total number of products.
- Show low-stock items.
- Highlight expired products.
- Summarize products approaching their expiration dates.

### 6. Shared Staff Access
- Support user accounts with Firebase Authentication.
- Allow cafe owners to create cafe workspaces.
- Enable employees to join their cafe workspace.
- Synchronize inventory information across multiple devices.

## Optional Features

The following features may be implemented depending on available time and development progress:

- Local device notifications for expiration dates and low stock.
- Separate owner and barista permissions.
- Waste and consumption statistics with charts.
- Barcode scanning for faster product identification.

## Technology Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform mobile application development |
| Dart | Programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud database and inventory synchronization |
| Git & GitHub | Version control and team collaboration |

## Data Management

CafeStock will use **Firebase Cloud Firestore** to store and synchronize inventory data across multiple users and devices.

The application will manage the following information:

- **Cafes & Members:** Cafe names, owners, staff members and roles.
- **Products:** Names, categories, measurement units, storage locations and minimum stock thresholds.
- **Batches:** Product references, quantities, expiration dates and received dates.
- **Stock Transactions:** Deliveries, consumption, waste, adjustments, timestamps and responsible users.

Firestore's offline caching capabilities will support temporary connectivity interruptions, with synchronization when connectivity is restored.

No additional third-party API is planned.

## Technical Challenges

The main anticipated challenges include:

1. Maintaining inventory consistency when multiple employees update stock simultaneously.
2. Managing multiple product batches with different expiration dates.
3. Applying an earliest-expiring-first approach when deducting stock.
4. Keeping dashboard information and inventory alerts updated in real time.
5. Managing offline synchronization without losing or duplicating transactions.
6. Implementing Firestore security rules to prevent unauthorized access to another cafe's data.
7. Creating an intuitive mobile interface for efficient daily use.

## Team Members

**Sabancı University – CS310, Group 28**

| Name | Student ID |
|---|---|
| Umut Akın | 35291 |
| Eray Bahar | 35573 |
| Elif Pişkindemir | 34337 |
| Melis Atalay | 35323 |

**Step 1 Coordinator:** Eray Bahar

## Team Responsibilities

### Step 1 – Project Proposal & GitHub Setup

| Member | Responsibility |
|---|---|
| Umut Akın | App overview and core features |
| Melis Atalay | Data requirements and potential challenges |
| Elif Pişkindemir | GitHub repository, README.md, Flutter .gitignore, initial commit and collaborator setup |
| Eray Bahar | Team coordination, proposal compilation, team review, TA communication and final PDF submission |

### Planned Development Responsibilities

| Member | Main Development Area |
|---|---|
| Melis Atalay | Product catalog, categories, storage locations, batch management, search and filtering |
| Umut Akın | Stock operations, quantity updates and transaction history |
| Elif Pişkindemir | Inventory dashboard, expiration and low-stock detection, warnings and summaries |
| Eray Bahar | Firebase Authentication, cafe workspaces, staff management, settings and Firestore security rules |

These responsibilities may be adjusted as development progresses.

All team members will participate in Flutter development, integration, testing and project review.

## Development Status

**Current Phase: Step 1 – Project Proposal & Repository Setup**

The project is currently in its initial planning stage. Application implementation has not yet begun.

Source code, installation instructions and additional documentation will be added as development progresses.

## Repository

[GitHub – CafeStock](https://github.com/elif-piskindemir/Cs31-Caf-Inventory-Expiration-Management)

---

**Sabancı University – CS310 Mobile Application Development**

**Group 28 | CafeStock**
