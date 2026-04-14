# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ArcanaWatch is a custom luxury-style analog watch face for Apple Watch (watchOS 11.0+), with dauphine hands, subdials, and real-time data displays.

## Build Commands

This project uses **XcodeGen** to generate the Xcode project from `ArcanaWatch/project.yml`.

```bash
# Generate Xcode project (run from ArcanaWatch/ directory)
cd ArcanaWatch && xcodegen

# Build for simulator
xcodebuild -scheme ArcanaWatch \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 - 45mm' \
  build

# Build for device
xcodebuild -scheme ArcanaWatch \
  -destination generic/platform=watchOS \
  build
```

The `ArcanaWatch.xcodeproj` is generated — do not edit it directly; edit `project.yml` instead.

## Architecture

```
ArcanaWatchFaceView (root, TimelineView driver)
├── BezelView               — polished silver ring
├── DialView                — Canvas-rendered: sunburst, ticks, indices, Roman numerals
├── HandsView               — hour & minute dauphine hands (Canvas + DauphineHandShape)
├── SecondsSubdialView      — small seconds at 6 o'clock
├── DateSubdialView         — date window at 3 o'clock
├── BatterySubdialView      — battery arc gauge at 9 o'clock
└── CenterPinView           — center jewel
```

**Update driver**: A single `TimelineView(.periodic(from: .now, by: 1))` in `ArcanaWatchFaceView` drives the entire face. There are no separate `Timer` objects.

**Data models** (`@StateObject` / `@ObservedObject`):
- `BatteryModel` — polls `WKInterfaceDevice.current().batteryLevel` every 60s
- `HealthKitModel` — anchored HealthKit query for heart rate (infrastructure present, not yet displayed)

**Subdial pattern**: `SubdialView` is a generic `@ViewBuilder` container (circle frame + tick marks). Specialized subdials (`SecondsSubdialView`, `DateSubdialView`, `BatterySubdialView`) compose content inside it.

## Design System

All proportions are expressed as ratios to watch diameter and centralized in `WatchConstants` (`Utilities/Constants.swift`). **Always use these constants rather than hardcoded values.**

Key ratios:
- Dial: 92% of diameter; bezel width: 2.5%
- Subdials: 24% diameter, offset 26% from center
- Hour hand: 30% length, 3.2% base width
- Minute hand: 42% length, 2.4% base width

Hand angles are pure functions in `AngleCalculations` (`Utilities/AngleCalculations.swift`) — both hands move continuously (not snapping per second/minute).

## Key Patterns

- **Canvas rendering** is used for expensive geometry (dial, hands) — prefer `Canvas` over layered `Shape` views for performance-critical drawing.
- **`GeometryReader`** at the root provides `watchDiameter`; all child views receive it as a parameter for responsive scaling.
- **`allowsHitTesting(false)`** is set on static decorative layers.
- **Colors**: defined in `WatchConstants` — `dialBlack` (rgb 0.04), `silver`/`silverLight`/`silverDark` metallic scale, `tickGray`, `dateWhite`. Roman numeral font is Georgia.
