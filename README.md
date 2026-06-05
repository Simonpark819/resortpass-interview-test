# SimonPass

A native iOS implementation of the ResortPass take-home interview test — two interconnected screens backed by live API calls, built from the ground up with SwiftUI and Swift Concurrency.

---

## Running the Project

**Requirements:**
- Xcode 15+
- iOS 16+ simulator or device

**Steps:**
1. Clone the repository
2. Open `SimonPass/SimonPass.xcodeproj`
3. Select a simulator or device and run
4. Run tests with Cmd+U

No API keys or additional setup required.

---

## Architecture

The app uses **MVVM + Coordinator**, built on SwiftUI's `@ObservableObject` model and `NavigationStack`.

```
App
├── AppContainer       — dependency graph, ViewModel factories
├── AppCoordinator     — navigation state, route resolution
├── AppRoute           — type-safe navigation destinations

Core
├── Features
│   ├── Search         — SearchView + SearchViewModel
│   └── HotelList      — HotelListView + HotelListViewModel
├── Models             — Codable value types (Place, Hotel, Currency, ...)
├── Networking         — NetworkService, APIEndpoint
└── Repositories       — SearchRepository, HotelRepository

Components
└── Shared             — SearchBar, HotelCard, RatingView, ErrorStateView, LoadingView

Designs                — Colors, Typography, Spacing, Radius, Icons
Foundations            — Strings, A11y
```

### Why MVVM + Coordinator

MVVM with `ObservableObject` gives a clean, predictable data flow — ViewModels own application state while views emit user intent and render state. `@Published` properties drive SwiftUI updates and keep state changes explicit and traceable.

The Coordinator pattern was a deliberate choice for scalability. Views never push or pop directly — they report events to the coordinator, which decides what happens next and constructs the destination. This keeps every screen independently instantiable and navigation logic centralised in one place, which scales well as the app grows.

### Dependency Injection

Manual constructor injection via `AppContainer`. Long-lived dependencies are created and owned by `AppContainer` and injected downward — no third-party DI framework was introduced. At this scope, a lightweight container keeps the dependency graph explicit and readable without the overhead of a library.

---

## State Management

Each ViewModel exposes a single `ViewState` enum that the view switches over:

```swift
enum ViewState: Equatable {
    case idle / loading / success / empty / error(String)
}
```

State transitions happen only inside the ViewModel. Views are purely declarative — they render what they're given. This makes the data flow predictable and the ViewModels straightforwardly testable by asserting state transitions against a mock repository.

---

## Concurrency

All network work is handled with **async/await and structured concurrency**. The one exception is the search input pipeline, where **Combine is used deliberately**. Combine provides mature, built-in debounce and deduplication operators, making it a natural fit for search input handling.

The boundary is intentional and explicit:
- **Combine** manages the input stream (debounce → deduplication → trigger)
- **async/await** handles everything beyond that boundary (network request → state update)

Cancellation is handled differently per screen:
- **Search:** each keystroke cancels the previous `Task` before starting a new one, preventing stale responses from overwriting newer state
- **Hotel List:** the fetch is `await`-ed directly inside SwiftUI's `.task` modifier, which cancels automatically when the view disappears

---

## Networking

`URLSession` directly, with no third-party library. Given the scope of the current implementation — two endpoints, no authentication, no request queuing — a networking dependency would add overhead without meaningful benefit.

For image loading specifically, **Nuke** would be a strong upgrade path over the current `URLCache` approach at production scale — it handles progressive rendering, memory pressure, and large image set performance more robustly.

### Image Caching

Images are cached using `URLCache` with 50MB memory and 200MB disk capacity. Hotel images are served from S3 with a `max-age=31536000` cache header, so `URLCache` handles cache hits natively without any additional logic. Search API responses are intentionally not cached — the server sets `max-age=0, private` on those endpoints.

---

## Navigation

`AppCoordinator` owns a `NavigationPath` and is injected into the environment. All routes are defined as cases on the `AppRoute` enum, which is `Hashable` and passed to `NavigationStack`'s `navigationDestination` modifier.

Views never reference other views directly — they call coordinator methods (`show`, `pop`, `popToRoot`) or fire callbacks. This keeps every screen independently instantiable and navigation logic in one place.

---

## Design System

All visual tokens are centralised in `Designs/`:

- **Colors** — semantic tokens with light/dark mode support via asset catalog color sets. Text colors use system semantic colors (`Color(.label)`) to inherit platform accessibility defaults
- **Typography** — `Font.system(size:weight:)` throughout, which supports Dynamic Type scaling automatically
- **Spacing** — numeric naming (`spacing4`, `spacing8`, `spacing16`) so the value is always unambiguous at the call site
- **Radius, Icons** — centralised to prevent raw literals from scattering across the codebase

User-facing strings live in `Foundations/Strings.swift` and accessibility metadata in `Foundations/A11y.swift`, kept separate because display copy and accessibility labels serve different audiences and evolve independently.

---

## Accessibility

Both screens implement:
- Meaningful `.accessibilityLabel` and `.accessibilityHint` on all interactive elements
- Decorative images and icons marked `.accessibilityHidden(true)`
- `HotelCard` info block collapsed into a single VoiceOver element with a composed label covering name, rating, reviews, location, and price
- Place rows use `Button` (not `onTapGesture`) for correct button trait, keyboard navigation, and Switch Control support
- Rows with no coordinates are `.disabled` with a distinct hint explaining unavailability

---

## Design Assumptions and Decisions

The provided Figma design was used as the visual reference. A few gaps required judgment calls:

**Custom navigation bar on the Hotel List screen**

SwiftUI's default `NavigationBar` fades the title and status bar content as the user scrolls up. The design clearly shows a persistent, fully-visible navigation bar with content scrolling beneath it. To achieve this, the system bar is hidden (`.navigationBarHidden(true)`) and a custom bar is rendered as part of the view hierarchy, keeping it outside the scroll context entirely.

**Place rows with no coordinates**

The autocomplete API returns some results (typically broader geographic regions) with `null` latitude and longitude. These cannot be used to fetch hotels. Rather than silently dropping them from the list, they are rendered at reduced opacity and disabled — visible to the user but clearly non-interactive. This felt more honest than hiding them.

**Hotel rating source**

The API returns both `rating` and `avg_rating`. `rating` was used as it was consistently populated in observed responses and matched the displayed values in the design.

**Currency display**

Prices are displayed using the currency symbol returned in the API response envelope. No locale-based conversion is applied — the assumption is that the API already returns pricing in the appropriate currency for the user's context.

---

## Testing

Unit tests cover:

- `SearchViewModel` — state transitions, debounce deduplication, retry, clear
- `HotelListViewModel` — fetch success/empty/error, retry
- `Place.hasValidCoordinates` — all nil and zero coordinate combinations
- `APIEndpoint.makeURLRequest()` — URL construction, query parameters, POST body encoding
- `NetworkService` — success decoding, HTTP error codes, invalid response, malformed JSON, and `userMessage` mapping per error case. Tested via a `URLProtocol` stub injected through the `URLSession` initialiser — no real network required

Repositories are not tested directly — they are single-line passthroughs with no logic of their own.

UI tests are not included. Accessibility correctness is verified by implementation rather than automated assertion — the correctness of `A11y` labels and VoiceOver behaviour is best evaluated with the Accessibility Inspector or manual testing with VoiceOver enabled.

### A note on `@MainActor` in test classes

All test classes are marked `@MainActor`. This is intentional, not a workaround. `ObservableObject` ViewModels publish state changes on the main thread, and model types like `Place` are used throughout main-actor-bound contexts. Marking test classes `@MainActor` ensures tests run in the same execution context as production code, making assertions against `@Published` properties safe and the concurrency model consistent. In Swift 6 strict mode this would be enforced as an error — annotating explicitly here is the forward-compatible approach.

---

## Known Limitations and Future Improvements

- **Environment configuration** — the app targets a single base URL (`staging-app.resortpass.com`). In a production setup this would be split across environment configurations (dev, staging, prod) using Xcode build schemes and `.xcconfig` files to inject the appropriate base URL at build time. This was intentionally omitted since only one endpoint was provided for the test.

- **Pagination** — the hotel list fetches 30 results and stops. Infinite scroll with offset-based pagination would be the natural next step
- **Favourite functionality** — the heart button on hotel cards is present in the design and wired up as a no-op. A real implementation would require a persistence layer (SwiftData or a remote favourites API)
- **Image loading** — `URLCache` works well for this scope but a dedicated library like Nuke would handle memory pressure, cancellation on scroll, and progressive rendering more robustly at scale
