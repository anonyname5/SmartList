# SmartList Development TODO

Project: Smart Checklist with Auto Total  
Platform: Android (Flutter)  
Status: Planning complete, implementation pending

---

## Milestone 0 - Project Setup

- [ ] Create Flutter project (Android target)
- [ ] Configure app name, package ID, min SDK, versioning
- [ ] Set up folder structure:
  - [ ] `lib/models`
  - [ ] `lib/screens`
  - [ ] `lib/services`
  - [ ] `lib/providers`
  - [ ] `lib/widgets`
- [ ] Add dependencies:
  - [ ] `flutter_riverpod`
  - [ ] `isar`
  - [ ] `isar_flutter_libs`
  - [ ] `path_provider`
  - [ ] `intl`
  - [ ] `shad_ui_flutter`
  - [ ] `lucide_icons_flutter`
  - [ ] `flutter_animate`
  - [ ] `flutter_slidable`
  - [ ] `shimmer`
- [ ] Configure Isar code generation (`build_runner`)
- [ ] Verify app runs on Android emulator/device

## Milestone 1 - Domain Models

- [ ] Implement `Project` model:
  - [ ] `id`
  - [ ] `title`
  - [ ] `budget` (optional)
  - [ ] `createdDate`
- [ ] Implement `Item` model:
  - [ ] `id`
  - [ ] `projectId`
  - [ ] `name`
  - [ ] `price`
  - [ ] `isChecked`
  - [ ] `createdAt`
  - [ ] `category` (optional, future-ready)
- [ ] Add validation rules:
  - [ ] Non-empty project title
  - [ ] Non-empty item name
  - [ ] Non-negative price
- [ ] Add constants/utilities:
  - [ ] Default currency `RM`
  - [ ] Currency formatting helper

## Milestone 2 - Local Storage (Isar)

- [ ] Create `DatabaseService`:
  - [ ] Open Isar instance
  - [ ] Register schemas
  - [ ] Close/cleanup safely
- [ ] Create `ProjectRepository`:
  - [ ] Create project
  - [ ] Read all projects
  - [ ] Update project
  - [ ] Delete project
- [ ] Create `ItemRepository`:
  - [ ] Add item
  - [ ] Read items by `projectId`
  - [ ] Update item
  - [ ] Delete item
- [ ] Ensure write operations are transactional
- [ ] (Optional) Add dev seed data helper

## Milestone 3 - State Management (Riverpod)

- [ ] Add DB initialization provider
- [ ] Add project list provider:
  - [ ] Load projects
  - [ ] Create project
  - [ ] Delete project
- [ ] Add item list provider (by project):
  - [ ] Load items
  - [ ] Add item
  - [ ] Toggle `isChecked`
  - [ ] Delete item
- [ ] Add derived totals providers:
  - [ ] `totalPlanned`
  - [ ] `totalBought`
  - [ ] `remaining`
- [ ] Add loading/error/empty states in providers

## Milestone 4 - Core Screens

- [ ] Build `HomeScreen`:
  - [ ] Display all projects
  - [ ] Show project total + item count
  - [ ] Add "Create Project" CTA
- [ ] Build "Create Project" flow:
  - [ ] Title input (required)
  - [ ] Budget input (optional)
  - [ ] Save action + validation
- [ ] Build `ProjectDetailScreen`:
  - [ ] Show project title and optional budget
  - [ ] Show item checklist
  - [ ] Show totals panel (planned/bought/remaining)
  - [ ] Add "Add Item" CTA
- [ ] Build "Add Item" flow:
  - [ ] Item name (required)
  - [ ] Price (required)
  - [ ] Category (optional)
  - [ ] Save action + validation
- [ ] Implement item interactions:
  - [ ] Checkbox toggle
  - [ ] Delete item (basic)
  - [ ] Swipe-to-delete (optional if time allows)

## Milestone 5 - Business Logic

- [ ] Implement calculation utility:
  - [ ] `totalPlanned(items)`
  - [ ] `totalBought(items)`
  - [ ] `remaining(items)`
- [ ] Ensure totals update instantly after:
  - [ ] Add item
  - [ ] Toggle item
  - [ ] Delete item
- [ ] Implement budget warning indicator if exceeded
- [ ] Standardize money formatting in all screens
- [ ] Handle decimal precision safely

## Milestone 6 - UX Polish (MVP-safe)

- [ ] Empty state for no projects
- [ ] Empty state for no items
- [ ] Inline validation messages for form errors
- [ ] Delete confirmation dialog
- [ ] Add light animations (`flutter_animate`)
- [ ] Keep visual consistency with `shad_ui_flutter`

## Milestone 7 - Testing

- [ ] Unit tests:
  - [ ] Calculation functions
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

- [ ] Categories UI + filtering
- [ ] Search items in project
- [ ] Sorting (price/purchased/name/newest)
- [ ] Progress bar (`x / y`)
- [ ] Multi-currency support
- [ ] Cloud sync
- [ ] Multi-device sync
- [ ] Export/share list

---

## Current Sprint (Suggested)

- [ ] M0: Setup completed
- [ ] M1: Models completed
- [ ] M2: Isar storage completed
- [ ] M3: Riverpod state completed
- [ ] M4: Core screens completed
- [ ] M5: Logic + budget warning completed
- [ ] M6: Polish completed
- [ ] M7: Tests completed
- [ ] MVP ready for first release
