# Card Game – Assignment 2

**Hadar David**

An iOS card battle app built with **Swift** and **UIKit**.  
Two players — you and the PC — compete over **10 rounds**. Each round, both sides reveal a card; the higher card wins the point. Your side (East or West) is determined by your **location** at launch.

---

## Demo Video

---

## App Screens

### 1. Welcome Screen

- **First launch:** enter your name with the **Insert Name** button.
- **Later launches:** your saved name is shown (e.g. `Hi Gabi`) — no name input.
- On **every app open**, the device samples your location once.
- Longitude split point: **34.817549168324334**
  - **East** of the line → you play on the **East** side
  - **West** of the line → you play on the **West** side
- After location is received, the UI updates: your side is highlighted and **START** becomes enabled.
- The game **cannot start** without both a name and a location.
- Supports **portrait** and **landscape**.
- **Dark mode:** earth images switch to night variants; text uses adaptive lighter colors.

### 2. Game Screen

- Two players: **you** and **PC**. Your position (left/right) depends on your East/West side from the welcome screen.
- **No buttons** — the game starts automatically.
- Every **5 seconds** the cards flip:
  - **3 seconds** showing the card faces
  - **2 seconds** showing card backs
  - repeats until 10 rounds are complete
- Each card has a strength value — the higher card wins the round; scores update after each flip.
- **Ties during a round** are ignored (no point awarded).
- After **10 rounds**, the app automatically navigates to the result screen.
- **Final tie:** if scores are equal after 10 rounds, **PC (house) wins**.
- **Lifecycle:** timer and background music pause when the app goes to background, and resume when it returns.

### 3. Result Screen

- Shows the **winner** and **score** (e.g. `Winner: Gabi`, `score: 10`).
- **BACK TO MENU** returns to the welcome screen.
- Dark mode: lighter text colors.
- Confetti and win/lose sounds when appropriate.

---

## Extras (Assignment 2)

- **Dark mode** + **portrait** layout support
- **Flip sounds** on each card transition
- **Win / end-game sounds** on the result screen
- **Background music** during gameplay (stops when leaving the game or when the app backgrounds)

---

## Screenshots

| Welcome (Light) | Welcome (Dark) | Game        | Result      |
| --------------- | -------------- | ----------- | ----------- |
| _add image_     | _add image_    | _add image_ | _add image_ |

---

## Built With

| Technology     | Purpose                              |
| -------------- | ------------------------------------ |
| UIKit          | Screens, layout, navigation          |
| CoreLocation   | East/West side assignment            |
| AVFoundation   | Background music and sound effects   |
| CAEmitterLayer | Confetti animation on player victory |
| UserDefaults   | Persisting player name               |

---

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/hadardv/CardGame.git
   ```
2. Open `CardGame.xcodeproj` in **Xcode**.
3. Select an iPhone simulator (e.g. iPhone 16).
4. Press **⌘R** to build and run.
5. Allow **location** when prompted.

### Simulating location (Simulator)

The simulator does not use your real GPS. Set a test location manually:

**Features → Location → Custom Location…**

| Side | Latitude | Longitude |
| ---- | -------- | --------- |
| East | `32.11`  | `34.82`   |
| West | `32.11`  | `34.80`   |

Relaunch the app after changing location so it is sampled again.

### Dark mode (Simulator)

**Features → Toggle Appearance**, or in the simulated iPhone: **Settings → Display & Brightness → Dark**.

### Reset saved name (first-launch flow)

Delete the app from the simulator, or: **Device → Erase All Content and Settings…**

---

## Project Structure

```
CardGame/
├── WelcomeController.swift   # Name entry, location, START
├── GameController.swift      # 10-round auto-play logic
├── ResultViewController.swift  # Winner screen
├── Ticker.swift                # Repeating timer for card flips
├── Main.storyboard             # UI layout and navigation
└── Assets.xcassets             # Cards, earth images, colors
```

---

## Author

**Hadar David**
