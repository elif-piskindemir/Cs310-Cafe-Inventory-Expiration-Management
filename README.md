# CafeStock – Cafe Inventory & Expiration Management

**CS310 – Mobile Application Development**

**Sabancı University | Group 28**

## About the Project

CafeStock is a Flutter-based mobile application designed to help independent cafes manage their inventory, monitor ingredient quantities and track product expiration dates.

Many cafes rely on manual inventory tracking, which can result in inaccurate stock records, expired ingredients and unnecessary food waste. These problems are especially common for products stored in refrigerators, freezers and storage areas.

CafeStock aims to provide a simple and centralized inventory management system that allows cafe owners and baristas to monitor and update inventory from their own devices.

The application is intended exclusively for internal cafe operations and does not include customer-facing features.

A key feature of CafeStock is **batch-level inventory tracking**. For example, a cafe may have 12 liters of milk, with 5 liters expiring tomorrow and 7 liters next week. CafeStock tracks these as separate batches rather than assigning a single expiration date to the entire product.

## Core Features

### 1. Product & Inventory Management

- Add, edit, categorize and remove products.
- Record product names, measurement units (kg, L, pcs) and storage locations.
- Search and filter inventory items.

### 2. Batch-Based Expiration Tracking

- Store multiple batches of the same product.
- Track quantities and expiration dates separately for each batch.
- Highlight products approaching their expiration dates.
- Display expired products separately.

### 3. Stock Operations

- Record incoming deliveries.
- Track ingredient consumption.
- Register waste and manual stock adjustments.
- Automatically update inventory quantities.
- Maintain transaction history with timestamps and responsible users.
- Apply the First-Expiring, First-Out (FEFO) policy with manual batch selection.

**Batch Deduction Policy (FEFO):**

When an ingredient is consumed, CafeStock automatically deducts the required quantity from the earliest-expiring non-expired batch.

If the selected batch does not contain enough stock, the remaining quantity is deducted from the next eligible batch.

Staff members can manually select another eligible batch when necessary.

Expired batches are excluded from normal consumption and can be recorded as waste.

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

- Support user authentication through Firebase Authentication.
- Allow cafe owners to create cafe workspaces.
- Enable owners to generate invitation codes.
- Allow employees to request access using an invitation code.
- Require owner approval before granting workspace access.
- Synchronize inventory information across multiple devices.

**Workspace Access & Permissions:**

Cafe owners create workspaces and generate invitation codes for employees.

Employees sign in, enter an invitation code and submit a membership request. The cafe owner must approve the request before the employee can access the shared inventory.

The application defines two main user roles:

- **Owner:** Can manage inventory, record stock operations, manage staff members, handle invitations and modify cafe settings.
- **Barista:** Can view and update inventory and record stock operations, but cannot manage staff, invitations or cafe settings.

These permissions will be enforced using Firestore Security Rules.

## Optional Features

The following features may be implemented depending on available time and development progress:

- Local device notifications for expiration dates and low stock.
- Waste and consumption statistics with simple charts.
- Barcode scanning for faster product identification.
- More granular staff permissions.


## Data Management

CafeStock will use **Firebase Cloud Firestore** to store and synchronize inventory data across multiple users and devices.

The application will manage the following information:

- **Cafes & Members:** Cafe names, owners, staff members and roles.
- **Products:** Names, categories, measurement units, storage locations and minimum stock thresholds.
- **Batches:** Product references, quantities, expiration dates and received dates.
- **Stock Transactions:** Deliveries, consumption, waste, adjustments, timestamps and responsible users.

A cloud database is required because multiple employees need access to the same inventory.

Firestore provides local caching for viewing previously accessed inventory data during connectivity interruptions. Stock modifications requiring transactions will need an active connection to maintain inventory consistency.

No additional third-party API is planned.

## Technical Challenges

The main anticipated technical challenges include:

1. **Concurrent Inventory Updates:** Maintaining accurate stock quantities when multiple employees update the same product simultaneously. Firestore transactions are planned to address this issue.
2. **FEFO Batch Deduction:** Implementing automatic earliest-expiring-first stock deduction with manual overrides while maintaining accurate quantities across multiple batches.
3. **Real-Time Inventory Monitoring:** Computing expiration and low-stock warnings reliably and keeping the dashboard updated in real time.
4. **Workspace Security:** Implementing secure invitation-based membership and enforcing owner/barista permissions through Firestore Security Rules.
5. **User Interface Design:** Creating an intuitive mobile interface that allows busy cafe employees to record inventory changes in a few taps.

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
| Eray Bahar | Team coordination, proposal compilation, team review and final PDF submission |

### Planned Development Responsibilities

| Member | Main Development Area |
|---|---|
| Melis Atalay | Product catalog, categories, storage locations, batch management, search and filtering |
| Umut Akın | Stock operations, quantity updates and transaction history |
| Elif Pişkindemir | Inventory dashboard, expiration and low-stock detection, warnings and summaries |
| Eray Bahar | Firebase Authentication, cafe workspace and staff joining, settings |

These responsibilities may be adjusted as development progresses.

All team members will participate in Flutter development, integration, testing and project review.

## Development Status

**Current Phase: Project Proposal Finalization & Development Preparation**

The project proposal has been revised to incorporate feedback on batch deduction rules, workspace access and staff permissions.

The application is planned for development using Flutter and Firebase.

Source code, installation instructions and additional documentation will be added as development progresses.

## Repository

[GitHub – CafeStock](https://github.com/elif-piskindemir/Cs310-Cafe-Inventory-Expiration-Management)

---

**Sabancı University – CS310 Mobile Application Development**

**Group 28 | CafeStock**
