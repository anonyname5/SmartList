# SmartList Development TODO

Project: Smart Checklist with Auto Total  
Platform: Android (Flutter)  
Status: Milestones 0-5 mostly implemented, QA in progress

---

## Milestone 0 - Project Setup

- [x] Create Flutter project (Android target)
- [ ] Configure app name, app icon, package ID, min SDK, versioning
  - [ ] App name
  - [x] App icon (`tool.png`)
  - [ ] Package ID
  - [ ] Min SDK
  - [ ] Versioning
- [x] Set up folder structure:
  - [x] `lib/models`
  - [x] `lib/screens`
  - [x] `lib/services`
  - [x] `lib/providers`
  - [x] `lib/widgets`
- [x] Add dependencies:
  - [x] `flutter_riverpod`
  - [x] `isar`
  - [x] `isar_flutter_libs`
  - [x] `path_provider`
  - [x] `intl`
  - [x] `shad_ui_flutter`
  - [x] `lucide_icons_flutter`
  - [x] `flutter_animate`
  - [x] `flutter_slidable`
  - [x] `shimmer`
- [x] Configure Isar code generation (`build_runner`)
- [ ] Verify app runs on Android emulator/device

## Milestone 1 - Domain Models

- [x] Implement `Project` model:
  - [x] `id`
  - [x] `title`
  - [x] `budget` (optional)
  - [x] `createdDate`
- [x] Implement `Item` model:
  - [x] `id`
  - [x] `projectId`
  - [x] `name`
  - [x] `price`
  - [x] `isChecked`
  - [x] `createdAt`
  - [x] `category` (optional, future-ready)
- [x] Add validation rules:
  - [x] Non-empty project title
  - [x] Non-empty item name
  - [x] Non-negative price
- [x] Add constants/utilities:
  - [x] Default currency `RM`
  - [x] Currency formatting helper

## Milestone 2 - Local Storage (Isar)

- [x] Create `DatabaseService`:
  - [x] Open Isar instance
  - [x] Register schemas
  - [x] Close/cleanup safely
- [x] Create `ProjectRepository`:
  - [x] Create project
  - [x] Read all projects
  - [x] Update project
  - [x] Delete project
- [x] Create `ItemRepository`:
  - [x] Add item
  - [x] Read items by `projectId`
  - [x] Update item
  - [x] Delete item
- [x] Ensure write operations are transactional
- [ ] (Optional) Add dev seed data helper

## Milestone 3 - State Management (Riverpod)

- [x] Add DB initialization provider
- [x] Add project list provider:
  - [x] Load projects
  - [x] Create project
  - [x] Delete project
- [x] Add item list provider (by project):
  - [x] Load items
  - [x] Add item
  - [x] Toggle `isChecked`
  - [x] Delete item
- [x] Add derived totals providers:
  - [x] `totalPlanned`
  - [x] `totalBought`
  - [x] `remaining`
- [ ] Add loading/error/empty states in providers

## Milestone 4 - Core Screens

- [x] Build `HomeScreen`:
  - [x] Display all projects
  - [x] Show project total + item count
  - [x] Add "Create Project" CTA
- [x] Build "Create Project" flow:
  - [x] Title input (required)
  - [x] Budget input (optional)
  - [x] Save action + validation
- [x] Build `ProjectDetailScreen`:
  - [x] Show project title and optional budget
  - [x] Show item checklist
  - [x] Show totals panel (planned/bought/remaining)
  - [x] Add "Add Item" CTA
- [x] Build "Add Item" flow:
  - [x] Item name (required)
  - [x] Price (required)
  - [x] Category (optional)
  - [x] Save action + validation
- [x] Implement item interactions:
  - [x] Checkbox toggle
  - [x] Delete item (basic)
  - [x] Swipe-to-delete (optional if time allows)

## Milestone 5 - Business Logic

- [x] Implement calculation utility:
  - [x] `totalPlanned(items)`
  - [x] `totalBought(items)`
  - [x] `remaining(items)`
- [x] Ensure totals update instantly after:
  - [x] Add item
  - [x] Toggle item
  - [x] Delete item
- [x] Implement budget warning indicator if exceeded
- [x] Standardize money formatting in all screens
- [x] Handle decimal precision safely

## Milestone 6 - UX Polish (MVP-safe)

- [x] Empty state for no projects
- [x] Empty state for no items
- [x] Inline validation messages for form errors
- [x] Delete confirmation dialog
- [x] Add light animations (`flutter_animate`)
- [x] Keep visual consistency with `shad_ui_flutter`

## Milestone 7 - Testing

- [ ] Unit tests:
  - [x] Calculation functions
  - [ ] Validation rules
- [ ] Repository tests:
  - [ ] Project CRUD
  - [ ] Item CRUD
- [ ] Widget tests:
  - [ ] Create project flow
  - [ ] Add item flow
  - [ ] Toggle updates totals
- [ ] Manual QA checklist:
  - [ ] Data persists after app restart
  - [ ] No crash in core user flow
  - [ ] Totals remain correct after multiple edits

## Milestone 8 - MVP Definition of Done

- [ ] User can create multiple projects
- [ ] User can add/check/uncheck/delete items
- [ ] Totals are always correct and reactive
- [ ] Data is fully offline-persistent
- [ ] Core flows are stable on Android
- [ ] UI is clean and readable

---

## Post-MVP Backlog (Phase 2+)

- [x] Categories UI + filtering
- [x] Search items in project
- [x] Sorting (price/purchased/name/newest)
- [ ] Progress bar (`x / y`)
- [ ] Multi-currency support
- [ ] Cloud sync
- [ ] Multi-device sync
- [ ] Export/share list

---

## Current Sprint (Suggested)

- [ ] M0: Setup completed (pending emulator/device run check)
- [x] M1: Models completed
- [x] M2: Isar storage completed (project update flow done)
- [x] M3: Riverpod state completed
- [x] M4: Core screens completed
- [x] M5: Logic + budget warning completed (decimal precision hardening done)
- [x] M6: Polish completed
- [ ] M7: Tests completed
- [ ] MVP ready for first release
