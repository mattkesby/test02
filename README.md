# Attune — Wheel of Emotions

An iPhone app concept: spin a wheel of emotions, tap the feeling that fits,
and get guided from that feeling to the needs beneath it and a way to respond,
using Marshall Rosenberg's Nonviolent Communication (NVC) framework.

## Flow

1. **Wheel** — spin/drag the emotion wheel (6 core emotions, 34 middle
   feelings, 68 outer feelings). Tap an outer feeling, e.g. *Frustrated*.
2. **Needs** — see the needs that may be unmet when that feeling shows up
   (effectiveness, clarity, support, …) and pick the ones that resonate.
3. **Respond** — build an NVC response: Observation → Feeling → Need →
   Request, with a "say it to them" and a "self-empathy" mode.

## Repo contents

- `Attune.xcodeproj` / `Attune/` — the SwiftUI iOS app (iOS 17+, Xcode 16+).
  - `Models/EmotionWheel.swift` — the feeling taxonomy and wheel geometry.
  - `Models/NVC.swift` — needs per core emotion and the response steps,
    including the gratitude variant for met needs (Joy, Love).
  - `Views/WheelScreen.swift` — Canvas-drawn wheel with drag-to-spin and
    tap-to-select.
  - `Views/NeedsView.swift`, `Views/RespondView.swift` — the NVC flow.
- `design/` — working files for the interactive design canvas
  (three iPhone artboards as Design Components, plus `canvas.json` layout).
- `design/gen-wheel.mjs` — generates `design/Main.dc.html`, including the
  wheel SVG geometry and the full feeling taxonomy.

## Building the app

Open `Attune.xcodeproj` in Xcode 16 or later and run the `Attune` scheme on
an iOS 17+ simulator or device. The needs mapping is currently per core
emotion (all Anger-family feelings share one candidate list); per-feeling
tuning is a natural next step.

"Attune" is a placeholder name.
