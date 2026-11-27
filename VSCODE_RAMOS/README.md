# PlatePrep 🥗🍳
> **Plan, Prep, and Eat Smart**  
> A student-friendly meal planner and kitchen assistant built with **Flutter** and **Firebase** (Firebase Auth and Cloud Firestore).

---

## 📱 App Overview

PlatePrep is designed for students and busy cooks to seamlessly organize weekly meals, generate smart shopping checklists automatically from planned recipes, and manage cooking preparation with preset timers and congratulations alerts.

### 🎨 Design & Visual System
- **Color Palette:**
  - **Sage Green (Primary):** `#4A7C59` — Fresh, healthy, grounding
  - **Warm Orange (Accent):** `#E87A5D` — Energetic, appetizing highlights
  - **Off-White (Background):** `#F9F9F6` — Clean, modern canvas
  - **Dark Slate (Text):** `#2C3E50` — Crisp, legible typography
- **Corner Radius:** 16px modern rounded card UI
- **Typography:** Plus Jakarta Sans clean modern sans-serif

---

## ✨ Features & Screen Specifications

### 1. Authentication Screen
- **Logo & Branding:** Custom chef icon with PlatePrep title and tagline (*"Plan, Prep, and Eat Smart"*).
- **Form Validation:** Student email verification and secure password requirements.
- **Dynamic Mode Toggle:** Instant switch between **Sign In** and **Create Account** (with full name and daily calorie target).
- **Firebase Auth Integration:** Directly calls `signInWithEmailAndPassword` and `createUserWithEmailAndPassword`.
- Creates and synchronizes user documents in Cloud Firestore upon registration.

### 2. Dashboard Screen
- **Header:** Displays current formatted date (`EEEE, MMMM d`) and personalized greeting (*"Welcome back, Chef!"*).
- **Overview Widget:**
  - Summary of today's scheduled meals (Breakfast, Lunch, Dinner, Snacks).
  - Daily Prep Progress Bar calculating prepped vs. target meals (e.g., *"2 of 3 meals prepped today"*).
  - Calorie estimation synced to daily target (e.g., *1330 / 2000 kcal*).
- **Quick Action Banner:** One-tap *"Add Today's Meal"* shortcut.
- **Kitchen Shortcuts:** Fast navigation cards into Grocery Lists and Countdown Timers.

### 3. Meal & Recipe Manager Screen
- **Real-Time Synchronized Stream:** Live Firestore `StreamBuilder` scoped to logged-in `userId`.
- **Category Filter Chips:** `All`, `Breakfast`, `Lunch`, `Dinner`, `Snacks`.
- **Interactive Meal Cards:**
  - Category badge, prep time badge (e.g., *"25 min"*), title, and ingredient previews.
  - Interactive **Prepped Checkbox** with tactile toggle.
  - Swipe-to-delete dismissal and 3-dots Edit/Delete menu.
- **Floating Add Button (+):** Bottom sheet modal capturing title, category, prep time, ingredients (comma-separated), and scheduled date picker.

### 4. Grocery List & Cooking Timer Screen (Special Feature)
- **Dual Tab Interface:** Toggle seamlessly between shopping lists and cooking timers.
- **Section A: Auto-Generated Grocery List:**
  - **"Generate from Meals" Button:** Scans planned meals, extracts ingredients, cleans duplicates, and categorizes into `Produce`, `Dairy`, and `Pantry`.
  - **Interactive Checklist:** Strikethrough effect on purchased items.
  - Manual item additions and *"Clear Purchased"* utility.
- **Section B: Interactive Cooking Prep Timer:**
  - Circular countdown visualizer with animated progress arc.
  - **Preset Buttons:** Quick 10m, 15m, 25m, 45m, and 60m chips + custom minute dialog.
  - **Controls:** Start, Pause, and Reset.
  - **Congratulatory Completion Modal:** Triggers haptic feedback and alert sound when countdown ends (*"Ding! Prep Complete!"*).

### 5. Chef Profile & Settings
- Displays authenticated name and email.
- Editable daily calorie target synced to Firestore.
- Firebase Auth status and one-tap sign out.

---

## 🗄️ Database Schema (Cloud Firestore)

### Collection: `users`
```json
{
  "userId": "string (Firebase Auth UID)",
  "name": "Alex Morgan",
  "email": "alex@student.edu",
  "calorieTarget": 2000
}
```

### Collection: `meals`
```json
{
  "mealId": "string (document id)",
  "userId": "string (Firebase Auth UID)",
  "title": "Garlic Butter Chicken & Rice",
  "category": "Lunch",
  "ingredients": ["Chicken breast", "Rice", "Garlic", "Butter", "Soy sauce"],
  "prepTimeMinutes": 25,
  "scheduledDate": "Timestamp",
  "isPrepped": false
}
```

### Collection: `groceryItems`
```json
{
  "itemId": "string (document id)",
  "userId": "string (Firebase Auth UID)",
  "name": "Avocado",
  "category": "Produce",
  "isBought": false
}
```

---

## 📁 Project Structure

```
plateprep/
├── lib/
│   ├── main.dart                      # App entry point, Firebase init & AuthStateWrapper
│   ├── firebase_options.dart          # Multiplatform Firebase options
│   ├── constants/
│   │   ├── app_colors.dart            # Sage Green, Warm Orange, Off-White, Dark Slate
│   │   └── app_theme.dart             # ThemeData with 16px corner radii & typography
│   ├── models/
│   │   ├── user_model.dart            # User schema
│   │   ├── meal_model.dart            # Meal schema
│   │   └── grocery_item_model.dart    # Grocery schema
│   ├── services/
│   │   ├── auth_service.dart          # Firebase Auth service
│   │   └── firestore_service.dart     # Cloud Firestore real-time queries & CRUD
│   ├── utils/
│   │   ├── ingredient_categorizer.dart # Smart classifier (Produce/Dairy/Pantry)
│   │   ├── date_formatter.dart        # Date & timer string formatters
│   │   └── ui_feedback.dart           # Standardized snackbars & haptics
│   ├── widgets/
│   │   ├── custom_button.dart         # Styled button variants
│   │   ├── custom_text_field.dart     # Custom input field
│   │   ├── meal_card.dart             # 16px radius card with prepped toggle
│   │   ├── grocery_item_tile.dart     # Interactive strikethrough tile
│   │   ├── calorie_progress_card.dart # Daily progress bar
│   │   ├── congratulations_dialog.dart# Timer completion celebratory modal
│   │   └── empty_state.dart           # Stylized placeholders
│   └── screens/
│       ├── auth/
│       │   └── auth_screen.dart       # Sign In & Account Creation
│       ├── main_navigation_screen.dart# Bottom nav bar container
│       ├── dashboard/
│       │   └── dashboard_screen.dart  # Overview, progress & today's meals
│       ├── meals/
│       │   ├── meal_manager_screen.dart# Filter chips & meals list
│       │   └── add_edit_meal_sheet.dart# Add/Edit meal modal sheet
│       ├── grocery_timer/
│       │   ├── grocery_timer_screen.dart# Tabbed wrapper
│       │   ├── grocery_section.dart     # Auto-generated grocery list
│       │   └── cooking_timer_section.dart# Interactive countdown timer
│       └── profile/
│           └── profile_screen.dart    # Calorie goal & sign out
├── web_preview/
│   └── index.html                     # Instant interactive web simulation
├── android/                           # Native Android configuration
├── ios/                               # Native iOS configuration
├── web/                               # Flutter Web bootstrap
├── test/
│   └── widget_test.dart               # Unit tests for models and logic
├── pubspec.yaml                       # Dependencies
└── FIREBASE_SETUP.md                  # Firebase configuration guide & security rules
```

---

## 🚀 How to Run

### Option 1: Instant Interactive Web Prototype (No SDK Required)
You can immediately preview and test the complete PlatePrep mobile experience directly in your browser:
1. Open the file `web_preview/index.html` in Google Chrome or Microsoft Edge.
2. Experience all screens: Sign In/Register, Today's Prep Progress, Filtered Meal CRUD, Auto Grocery Generation, and the Countdown Prep Timer with congratulations modal!

### Option 2: Running with Flutter
Once Flutter SDK is available on your machine:
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit tests
flutter test

# 3. Launch on Chrome (Web)
flutter run -d chrome

# 4. Launch on Android Emulator or Device
flutter run -d android
```

