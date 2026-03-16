# Smart Checklist with Auto Total

- **Tech**: Flutter
- **Type**: Mobile App (Android)

## 1) Project Overview

This app is a smart checklist where each item has a price, and totals are calculated automatically.

Each item includes:
- Item name
- Price
- Checkbox status (bought / not bought)

Auto-calculated totals:
- Total planned cost
- Total purchased cost
- Remaining cost

Example use cases:
- Home renovation shopping list
- Grocery planning
- PC build budget
- Event planning
- Wedding preparation

## 2) Core Concept

Example project: **Room Renovation**

Items:
- ☐ Paint - RM120
- ☐ Curtain - RM80
- ☑ Lamp - RM45
- ☐ Carpet - RM150

Summary:
- **Total Planned**: RM395
- **Total Bought**: RM45
- **Remaining**: RM350

## 3) Main Features

### 3.1 Project Management

Users can create multiple checklist projects.

Examples:
- Room Renovation
- Gaming PC Build
- Monthly Groceries
- Wedding Preparation

Project fields:
- `id`
- `title`
- `budget` (optional)
- `created_date`

### 3.2 Item Checklist

Inside each project, users can add items.

Item fields:
- `id`
- `project_id`
- `name`
- `price`
- `is_checked`
- `created_at`

Example items:
- Paint - RM120
- Curtain - RM80
- Lamp - RM45

### 3.3 Auto Price Calculation

The app automatically calculates:
- **Total Planned** = `SUM(all item prices)`
- **Total Bought** = `SUM(price where is_checked = true)`
- **Remaining** = `Total Planned - Total Bought`

### 3.4 Checklist Toggle

Users can mark an item as purchased:
- ☐ Not purchased
- ☑ Purchased

When toggled:
- UI updates
- Totals update automatically

### 3.5 Budget (Optional)

Users may set a budget for each project.

Example:
- Budget: RM500
- Total: RM395
- Remaining Budget: RM105

If total exceeds budget:
- Show warning indicator

## 4) Nice-to-Have Features (Phase 2)

### 4.1 Categories

Example categories:
- Lighting
- Furniture
- Decoration
- Paint

Item structure:
- `category`

### 4.2 Progress Indicator

Example:
- `3 / 10 items purchased`
- Progress bar UI

### 4.3 Sorting

Sort by:
- Price
- Purchased
- Name
- Newest

### 4.4 Search

- Search items within a project

### 4.5 Currency Support

Users can choose:
- RM
- USD
- EUR

## 5) UI Design Structure

### 5.1 Home Screen

Shows all projects.

```text
Projects

Room Renovation
Total: RM395
Items: 8

PC Build
Total: RM4200
Items: 12

+ Create Project
```

### 5.2 Project Detail Screen

Shows checklist and totals.

```text
Room Renovation

☐ Paint                RM120
☐ Curtain              RM80
☑ Lamp                 RM45
☐ Carpet               RM150

----------------------

Total Planned : RM395
Total Bought  : RM45
Remaining     : RM350

+ Add Item
```

### 5.3 Add Item Screen

Form fields:
- Item Name
- Price
- Category (optional)
- Save

## 6) Data Storage

Start with local database.

Recommended Flutter options:
- SQLite
- Hive
- Isar

Best fit for this project: **Isar**

Reasons:
- Fast
- Offline
- Simple queries

## 7) App Architecture

Recommended structure:

```text
lib/
├── models
│   ├── project.dart
│   └── item.dart
├── screens
│   ├── home_screen.dart
│   ├── project_screen.dart
│   └── add_item_screen.dart
├── services
│   └── database_service.dart
├── providers
│   └── project_provider.dart
└── main.dart
```

## 8) State Management

Recommended: **Riverpod**

Reasons:
- Scalable
- Clean architecture
- Reactive updates

## 9) Calculation Logic

```dart
double totalPlanned(List<Item> items) {
  return items.fold(0, (sum, item) => sum + item.price);
}

double totalBought(List<Item> items) {
  return items
      .where((item) => item.isChecked)
      .fold(0, (sum, item) => sum + item.price);
}

double remaining(List<Item> items) {
  return totalPlanned(items) - totalBought(items);
}
```

## 10) Development Phases

### Phase 1 (MVP)

Features:
- Create project
- Add item
- Checkbox toggle
- Price input
- Auto total calculation
- Local storage

Goal:
- Working offline app

### Phase 2

Add:
- Budget feature
- Categories
- Progress bar
- Sorting

### Phase 3

Add:
- Cloud sync
- Multi-device sync
- Export list

## 11) Future Expansion Ideas

Potential upgrades:
- AI shopping suggestion
- Share checklist with family
- Collaboration mode
- Cost history tracking

## 12) Monetization (Optional)

### Free Version

- Unlimited projects
- Local storage

### Premium Version

- Cloud sync
- Collaboration
- Export features

## 13) Estimated Development Time

Solo developer estimate:
- MVP: 1-2 weeks
- Full features: 1-2 months

## 14) UI Framework and Design System

### UI Toolkit

The app uses Flutter for cross-platform mobile development (Android), enabling consistent UI and strong performance.

### Design System

Use `shad_ui_flutter` as the primary UI component library.

Benefits:
- Modern minimalist UI
- Production-ready components
- Consistent design system
- Beautiful default styling

Goal:
- Avoid default Flutter look
- Deliver a clean, professional productivity-app feel

## 15) UI Components from `shad_ui_flutter`

### Buttons

Use for:
- Add Item
- Create Project
- Save actions

```text
[ + Add Item ]
[ Create Project ]
```

### Cards

Use for:
- Project containers
- Item grouping
- Totals section

```text
Room Renovation
---------------
Total Planned : RM395
Items         : 8
```

### Input Fields

Use for:
- Projects
- Checklist items
- Price inputs

```text
Item Name
[ Paint ]

Price
[ RM120 ]
```

### Dialogs / Modals

Use for:
- Adding items
- Editing items
- Delete confirmation

```text
Add Item

Item Name
Price

[ Cancel ]  [ Save ]
```

### Badges

Use to show status:
- ✔ Purchased
- Pending

### Switch / Checkbox

Use to mark purchased items:
- ☐ Paint
- ☑ Lamp

## 16) Additional UI Enhancement Packages

- **Animations**: `flutter_animate`
- **Swipe gestures**: `flutter_slidable`
- **Icons**: `lucide_icons_flutter`
- **Loading effects**: `shimmer`

## 17) UI Philosophy

Design principles:
- Minimalism
- Clean spacing
- Readable typography
- Soft colors
- Smooth animations

Primary UI goal:
- Clarity and usability over complexity

## 18) Example Screen Layout

### Project List Screen

```text
Projects

Room Renovation
Total: RM395

Gaming PC Build
Total: RM4200

+ Create Project
```

### Project Detail Screen

```text
Room Renovation

☐ Paint              RM120
☐ Curtain            RM80
☑ Lamp               RM45
☐ Carpet             RM150

------------

Total Planned : RM395
Total Bought  : RM45
Remaining     : RM350

+ Add Item
```
