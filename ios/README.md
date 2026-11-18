# Aegis Academic OS for iPhone (SwiftUI, iOS 26)

Part of **Aegis Academic OS**. This folder holds the native iPhone version of the graduation tracker that the web app in the
repository root also implements: commencement countdown, degree audit, courses, honors, and the conferral celebration.

> **Status: design prototype.** This is a native SwiftUI iOS 26 (Liquid Glass) prototype. It has **not yet been built, run or
> tested in Xcode**. It was written on Linux, where every Swift file passed `swiftc -parse` and the model/storage layer passed
> `swiftc -typecheck` and its unit tests (6/6). The SwiftUI views need Apple's SDK, so expect small compile fixes on the first
> Xcode build.

It opens with Tiffany's Liberty University data and is built so any student can set up their own program.
Data stays on the device as JSON in Application Support. There are no accounts and no backend.

> The bundled data is a student-maintained summary, not an official transcript.

The web build is unaffected: Vite only builds from `index.html`/`src/`, and this folder contains no JS/TS.

## Requirements
- macOS with **Xcode 26** or later (the app uses iOS 26 Liquid Glass APIs: `glassEffect`, `GlassEffectContainer`, `.glass` button styles)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Generate the Xcode project and run
The Xcode project isn't checked in; XcodeGen creates it from `project.yml`.

1. `cd ios`
2. `xcodegen generate` (creates `Aegis.xcodeproj` from `project.yml`)
3. `open Aegis.xcodeproj`
4. In **Signing & Capabilities**, pick your Team for the **Aegis** and **AegisWidget** targets. If Xcode flags the App Group
   `group.com.tiffanygreene.aegis`, register it (or change it in both `.entitlements` files and in `Shared/WidgetSnapshot.swift`).
5. Choose an iPhone simulator (iOS 26) and press **Run** (⌘R). Run the tests with ⌘U.

To try the SwiftUI previews, open any file under `Aegis/Features/` and show the canvas (⌥⌘↩). Each screen has previews for
light, dark and large accessibility text sizes.

## App structure
```
project.yml                  XcodeGen spec: app + lock-screen widget + unit tests
Aegis/
  App/                       AegisApp (entry, theme), RootView (loading/onboarding/error/tabs), MainTabView
  Model/                     Codable Program, RequirementCategory, Course, Honor, Milestone, RegaliaItem + derived metrics
  Store/                     ProgramStore (@Observable), ProgramRepository (JSON file I/O)
  Services/                  MotionManager (tilt parallax), NotificationScheduler, CelebrationSound, AppearancePreference
  DesignSystem/              Color roles, spacing, glass card, state views, credit ring
  Features/Onboarding        Welcome ("Use my Liberty data" / "Set up my program"), program setup form
  Features/Countdown         Countdown tab, conferral celebration, celebration shapes and confetti
  Features/Audit             Degree audit list, requirement detail
  Features/Courses           Course list by term and source (swipe to delete + undo), add/edit sheet
  Features/Honors            GPA, Latin honors track, societies, regalia
  Features/Settings          Settings, notification pre-prompt, add society or requirement
  Resources/                 DefaultProgram.json (bundled data), Assets.xcassets (color tokens, app icon slot)
AegisWidget/                 Lock-screen and Home Screen countdown widget (WidgetKit)
Shared/                      WidgetSnapshot (shared through the App Group)
AegisTests/                  Model, countdown, validation and persistence tests
```

## Flow
```
First launch -> Welcome -> [Use my Liberty data] -> Tabs
                       \-> [Set up my program] (sheet) -> Tabs
Tabs: Countdown | Degree Audit | Courses | Honors   (gear button on each opens Settings as a sheet)
Countdown -> tap the card or "Preview Conferral" -> full-screen celebration
Degree Audit -> requirement -> course (edit sheet)
Courses -> + (add sheet) / tap (edit sheet) / swipe (delete, then Undo)
Honors -> society detail
```

## Design tokens
Colors live in `Assets.xcassets` as color sets with light and dark appearances. Dark is the main look, and light is a
version with the same hues adjusted for contrast. The fonts are SF Pro with Dynamic Type text styles. Spacing follows an 8-pt grid (4/8/16/24/32), cards use a 24-pt radius and controls use 14 pt.

| Role | Dark | Light | Used for |
|---|---|---|---|
| AppBackground | `#071936` | `#F2F7FC` | screen backdrop (plus a soft glow gradient) |
| Surface | `#102546` | `#FFFFFF` | list rows |
| SurfaceElevated | `#0A254E` | `#E3EEF9` | skeletons, raised fills |
| AccentColor (tint) | `#00F5FF` | `#006D80` | primary accent, buttons, progress |
| AccentGlow | `#00E5FF` @ 35% | `#006D80` @ 18% | glows and shadows |
| OnAccent | `#071936` | `#FFFFFF` | text on accent fills |
| Sky | `#4EA8DE` | `#1F6A9E` | secondary accent (active credits) |
| SkySoft | `#9FCBED` | `#3D6E96` | tertiary details |
| TextPrimary | `#E0F7FF` | `#071936` | body text |
| TextSecondary | `#9FCBED` | `#3A5578` | captions, secondary text |
| Hairline | `#8CBEEB` @ 18% | `#0A254E` @ 14% | ring track, separators |
| Liberty | `#B72025` | `#B72025` | fill, used only for the conferral seal |
| LibertyText | `#FF7A7E` | `#B72025` | red text (errors, destructive actions) |

WCAG contrast checks (AA needs 4.5:1 for body text):
- Dark: accent on background is 12.9:1, accent on surface 11.3:1, text 15.8:1, secondary text on surface 8.9:1, sky on surface 5.8:1, navy on cyan 12.9:1, LibertyText on surface 6.1:1.
- Light: accent `#006D80` on white is 6.0:1 and 5.6:1 on the background. Raw `#00F5FF` on white is only 1.35:1, so it is never used in light mode. Sky on white is 5.8:1, secondary text 7.6:1, Liberty red on white 6.5:1.
- White on a Liberty red fill is 6.5:1. Raw `#B72025` on navy is only 2.7:1, so red text in dark mode uses `#FF7A7E`.

## Motion, sound and accessibility
- **Liquid Glass**: the tab bar and toolbars get it from the system. Cards, buttons, banners and the celebration seal use `glassEffect`/`GlassEffectContainer`.
- **Tilt**: `MotionManager` reads CoreMotion device attitude at 30 Hz, smooths it, and drives a small parallax offset and a specular highlight on glass cards and the cap. It stops when the app goes to the background or Reduce Motion is on. No motion permission is needed.
- **Conferral celebration**: the tassel swings from right to left (light haptic), credits count up to the requirement, the cap is tossed, two glasses clink with a sparkle, confetti falls, and a success haptic and an optional chime play. Then the "Degree Conferred" seal appears in Liberty red and VoiceOver announces it. With **Reduce Motion** on, the final scene appears at once with no movement or confetti. The chime uses the ambient audio session, so the silent switch mutes it, and the speaker button turns it off.
- The countdown updates every second. With Reduce Motion on it updates once a minute and hides the seconds.
- Every screen has a loading skeleton, an empty state with an action, and an error state with Retry. A save-failure banner with Retry appears on each tab. Icon buttons have VoiceOver labels and grouped rows, touch targets are at least 44 pt, and layouts switch to stacked versions at accessibility text sizes.
- **Appearance**: Settings has System / Light / Dark options (`preferredColorScheme`). The celebration always uses the dark palette.
- **Reminders**: Settings has an opt-in toggle. A pre-prompt explains the reminders before iOS asks for permission, and if permission is denied there's a button to open iOS Settings. Reminders are local notifications 100, 30, 7 and 1 day before commencement at 9 AM in the commencement time zone.

## Data model
`Program` is one Codable value (see `Aegis/Model/AcademicModels.swift`). To give another student a starting file, replace
`Resources/DefaultProgram.json` or use **Set up my program**.

The bundled data comes from her Liberty degree audit (Nov 11, 2026) and unofficial transcript. No student ID is stored.
Credit terms follow the audit's credit tracker:
- **Earned**: every completed transcript credit (34 institutional + 60 transfer = 94).
- **Applied**: completed credits the audit counts plus in-progress credits (70 + 24 = 94 of 121). `nonApplicableCredits` (24)
  is the extra transfer elective credit the audit doesn't count. This value is inferred from the audit's group totals.
- **In progress**: Fall 2026 (CJUS 410, GOVT 302 = 6) + Spring 2027 (6 courses = 18) = 24.
- **Still needed**: the 9 courses the audit lists (27 credits).
- Course credits are decimals, so transfer hours such as 4.5 stay exact.
