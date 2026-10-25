# CafeStock: Cafe Inventory & Expiration Management

**CS310 Mobile Application Development – Project Step 1 Proposal**

**Sabancı University | Group 28**

**Application name:** CafeStock  
**Group number:** 28  
**Step 1 coordinator:** Eray Bahar  
**GitHub repository:** [CafeStock](https://github.com/elif-piskindemir/Cs310-Cafe-Inventory-Expiration-Management)

**Group members:**
- Umut Akın – 35291
- Eray Bahar – 35573
- Elif Pişkindemir – 34337
- Melis Atalay – 35323

## 1. App Overview

CafeStock is a Flutter mobile application that helps independent cafes track ingredient quantities, expiration dates and storage locations (freezer, refrigerator, shelf) without relying on paper lists or memory. It addresses two everyday problems. Employees lose track of expiration dates, which leads to waste or unsafe products. Cafes also don't know precisely how much stock remains, particularly in frozen storage that is rarely checked.

The intended users are cafe owners and baristas. The app is an internal staff tool with no customer-facing component. Several staff members share one cafe inventory from their own devices, so a delivery recorded by one barista is immediately visible to everyone else.

A key design decision is batch-level tracking. For example, a cafe may have 12 L of milk, of which 5 L expire tomorrow and 7 L next week. CafeStock stores these as two separate batches instead of assigning one expiration date to the whole product.

## 2. Core Features

| Feature | Description |
|---|---|
| Product & inventory management | Add, edit, delete, categorize, search and filter inventory items, including their units and storage locations. |
| Expiration tracking | Track separate product batches with individual quantities and expiration dates; highlight expired and near-expiry batches. |
| Stock operations | Record deliveries, consumption, waste and adjustments while maintaining timestamped transaction histories. Consumption follows First-Expiring, First-Out (FEFO), with manual batch selection available. |
| Low-stock & expiry alerts | Display configurable low-stock warnings and upcoming expiration alerts. |
| Inventory dashboard | Show product counts, low-stock items and expiration summaries. |
| Shared staff access | Authenticate users, provide owner-generated invitation codes, support staff membership, and synchronize inventory across devices. |

**Batch deduction policy:** Consumption automatically deducts from the earliest-expiring non-expired batch, proceeding to later batches when necessary. Staff may manually select another eligible batch. Expired batches are excluded from normal consumption and can be recorded as waste.

**Workspace access:** Owners create café workspaces and generate invitation codes. Employees sign in, enter a code, and request access. The owner approves membership before inventory access is granted. Baristas can view and update inventory and record stock operations, but cannot manage staff, invitations, or café settings. Owners have these additional administrative permissions.

**Optional features:** Local notifications, waste and consumption charts, barcode scanning, and more granular staff permissions.

## 3. Data Requirements

The app requires a database. We will use Firebase Cloud Firestore with Firebase Authentication. No external third-party API is needed.

- **Cafes & members:** cafe name, owner, and the list of staff with their roles.
- **Products:** name, category, unit, storage location, minimum stock threshold.
- **Batches:** product reference, quantity, expiration date, date received.
- **Stock transactions:** type (delivery, consumption, waste, adjustment), product/batch, quantity change, timestamp, and the user who made the change.

A local database such as SQLite would be simpler and would work offline, but it offers no automatic synchronization between devices. Because several staff members must see the same inventory, a cloud database is the better fit. Firestore provides local caching for viewing previously accessed inventory data during connectivity interruptions. Stock modifications requiring transactions will need an active connection to maintain inventory consistency.

## 4. Potential Challenges

- Keeping quantities consistent when multiple employees update the same product at the same time. We plan to use Firestore transactions for this.
- Implementing FEFO batch deduction with manual overrides while maintaining accurate quantities across multiple batches.
- Computing expiration and low-stock warnings reliably and keeping the dashboard updated in real time.
- Implementing secure invitation-based workspace membership and enforcing owner/barista permissions through Firestore Security Rules.
- Designing an interface that lets busy cafe staff record stock changes in a few taps.

## 5. Team Responsibilities

| Member | Step 1 task |
|---|---|
| Umut AKIN | App overview and core features sections |
| Melis ATALAY | Data requirements and potential challenges sections |
| Elif PISKINDEMIR | GitHub repository, README.md, Flutter .gitignore, initial commit, collaborator setup |
| Eray BAHAR | Organizing meetings, compiling the draft, team review, final PDF submission |

### Planned development ownership (will be rebalanced as the project progresses):

| Member | Main area |
|---|---|
| Melis ATALAY | Product catalog, categories, storage locations, batch entry, search and filtering |
| Umut AKIN | Stock operations (delivery, consumption, waste), quantity updates, movement history |
| Elif PISKINDEMIR | Dashboard, expiration and low-stock detection, warnings and summaries |
| Eray BAHAR | Firebase Authentication, cafe workspace and staff joining, settings |

All members write Flutter code, take part in integration and testing, and review the final submission.
