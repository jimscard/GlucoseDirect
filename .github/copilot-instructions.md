# GlucoseDirect Copilot Instructions

## Build, test, and lint commands

- List available schemes and targets: `xcodebuild -list -project GlucoseDirect.xcodeproj`
- Build the main app scheme: `xcodebuild -project GlucoseDirect.xcodeproj -scheme GlucoseDirectApp -destination 'generic/platform=iOS Simulator' build`
- Build the widget extension scheme: `xcodebuild -project GlucoseDirect.xcodeproj -scheme GlucoseDirectWidget -destination 'generic/platform=iOS Simulator' build`
- Lint changed files with Trunk: `trunk check`
- Lint the whole repository: `trunk check --all`
- `GlucoseDirect.xcodeproj` currently defines no XCTest target, so there is no project-native full-suite or single-test command yet.

## High-level architecture

- This is an iOS SwiftUI app for Libre glucose sensor workflows, with a separate widget extension target. The main app lives under `App/`, shared domain and infrastructure code lives under `Library/`, and widget code lives under `Widgets/`.
- `App/App.swift` creates one `DirectStore`, dispatches `.startup` during app initialization, and composes the middleware stack. `App/Views/ContentView.swift` exposes the store through a tab-based UI (`Overview`, `Lists`, conditional `Calibrations`, and `Settings`).
- State management is Redux-like, not MVVM: `Library/Extensions/State.swift` defines the generic `Store`/`Middleware` primitives, `Library/DirectAction.swift` is the action surface, and `Library/DirectReducer.swift` performs synchronous state mutation. Side effects belong in middleware under `App/Modules/**`.
- `App/AppState.swift` is the concrete `DirectState`. It initializes settings and "latest" values from `UserDefaults`, persists most preferences back through `didSet`, and leaves historical collections to the GRDB-backed `DataStore`.
- Historical glucose, blood glucose, insulin delivery, and sensor error data is stored in SQLite through GRDB (`App/Modules/DataStore/**`). Each store middleware owns table creation, migrations, insert/delete behavior, reload actions, and derived queries such as glucose statistics.
- Sensor integrations are centered in `App/Modules/SensorConnector/**`. Concrete connection implementations publish updates through `PassthroughSubject<DirectAction, DirectError>`, and `sensorConnectorMiddelware` turns raw sensor readings into calibrated, filtered `SensorGlucose`/`SensorError` actions.
- External integrations are also middleware-driven: Nightscout upload, app-group sharing for FreeAPS-style consumers, notifications, Apple exports, Bellman alarms, screen lock control, widget/live activity updates, and debug utilities all react to the shared action stream instead of being called directly from views.
- Widgets read shared app-group state from `UserDefaults.shared` rather than the GRDB database, so app changes that should appear in widgets usually also need shared-default updates and/or widget reloads.

## Key conventions

- Route behavior changes through `DirectAction` -> `directReducer` -> middleware. Avoid calling service objects directly from SwiftUI views when the behavior should participate in app-wide state flow.
- When adding a persisted setting, wire it in both `App/AppState.swift` and `Library/Extensions/UserDefaults.swift`. Those two files define the defaults, persistence keys, and write-back behavior.
- New sensor or transmitter backends should implement `SensorConnectionProtocol`, use the `sendUpdate(...)` helpers from `Library/Content/SensorConnection.swift`, and be registered in `createAppStore()` / `createSimulatorAppStore()` in `App/App.swift`.
- Keep simulator support intact. The simulator store intentionally uses the `virtual` connection path instead of NFC/Bluetooth hardware integrations.
- Use `LocalizedString(...)` for strings that need localization support. Many domain enums and UI labels already depend on that helper rather than `NSLocalizedString` calls scattered through the app.
- Check `Library/DirectConfig.swift` before changing feature visibility or defaults. Several capabilities are centrally gated there and the views assume those flags when deciding what to render.
- If a persistence change touches glucose history, prefer extending the relevant GRDB store module and migration logic instead of adding standalone SQL in unrelated files.
