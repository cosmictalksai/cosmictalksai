# CosmicTalksAI Onboarding UI Flow

The onboarding flow consists of a single `Scaffold` containing a `PageView` to handle smooth transitions between steps, with a fixed navigation bar at the bottom.

## Step Components

### 🔄 Top: Progress Indicator
- Horizontal progress bar showing current progress (1/5, 2/5, etc.).

### 📖 Step 1: Identity (Name)
- **UI:** Large typography greeting, single high-contrast `TextField`.
- **Validation:** Next button disabled if empty.

### 📅 Step 2: Cosmic Beginning (Date)
- **UI:** Visual Date Picker.
- **Validation:** Next button disabled if no date selected.

### ⏰ Step 3: Precise Moment (Time)
- **UI:** Time Picker + "I don't know my exact time" switch.
- **Behavior:** If switch is ON, Time Picker is dimmed/disabled.

### 📍 Step 4: Earthly Anchor (Place)
- **UI:** Search bar with auto-suggestions.
- **Data:** Selecting a result populates `birthPlace`, `latitude`, and `longitude`.

### 🌌 Step 5: The Analysis (Loading & Submission)
- **UI:** Immersive animation or themed spinner.
- **Text:** "Generating your unique birth chart..."
- **Trigger:** `submit()` is called immediately when this step is reached.
- **Error State:**
  - If `errorMessage` is set, hide spinner and show error text.
  - **Retry Button:** Visible only on error; re-executes `submit()`.

## Navigation Controls
- **Back Button:** Hidden on Step 1.
- **Next Button:** Text changes to "Analyze Chart" on Step 4.
- **Completion:** On success, the app moves to `/home`.
