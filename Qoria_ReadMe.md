# Qoria iOS — Codebase Architecture & Coding Patterns

This document describes the architecture, coding patterns, and conventions used in the Qoria_iOS (Qoria_App) codebase. Use it as the single source of truth (SSOT) for how the app is structured and how to add or change code.

---

## 1. High-Level Architecture

The app follows **Clean Architecture** with a clear separation of layers and **MVVM** in the presentation layer.

```
┌─────────────────────────────────────────────────────────────────┐
│  Presentation (SwiftUI)                                         │
│  • Views (HomeView, QoriaTabView, FeedPostView, …)              │
│  • ViewModels (HomeViewModel) — @MainActor, ObservableObject   │
└───────────────────────────┬─────────────────────────────────────┘
                            │ uses
┌───────────────────────────▼─────────────────────────────────────┐
│  Domain                                                          │
│  • Protocols (HomeRepository)                                    │
│  • Use Cases (GetHomeDataUseCase) — thin, delegate to repo      │
└───────────────────────────┬─────────────────────────────────────┘
                            │ implemented by
┌───────────────────────────▼─────────────────────────────────────┐
│  Data                                                           │
│  • Repository implementations (HomeRepositoryImpl)               │
│  • Dynamic JSON (JSON / dynamicJSON)                            │
└───────────────────────────┬─────────────────────────────────────┘
                            │ uses
┌───────────────────────────▼─────────────────────────────────────┐
│  Network                                                        │
│  • NetworkCall (protocol NetworkCalling), NetworkManager         │
│  • AuthInterceptor, TokenRefresher, AuthTokenStore, AppUrl       │
│  • NetworkError, NetworkLogger                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Cross-cutting / Shared                                          │
│  • App: AppContainer (DI), Qoria_AppApp, ContentView             │
│  • Colors: AppColor (Color extensions)                           │
│  • Constants + Extensions: Constants, SavedData, ScreenSize,    │
│    Device, Validation                                           │
└─────────────────────────────────────────────────────────────────┘
```

- **Unidirectional flow**: User/UI → ViewModel (intent) → Use Case → Repository → Network. Data flows back: Network → Repository → Use Case → ViewModel (`@Published`) → View.
- **Single source of truth**: ViewModels own screen state; repositories/use cases are the SSOT for domain data.

---

## 2. Folder & Module Structure

Under `Qoria_App/Qoria_App/`:

| Folder | Purpose |
|--------|--------|
| **App** | Entry point (`Qoria_AppApp.swift`), DI container (`AppContainer.swift`), shared `ContentView` placeholder. |
| **Presentation** | UI only. `TabView/` → `QoriaTabView/`, `Home/` (HomeView, HomeViewModel; feed content views: FeedPostView [Teacher], FeedPostViewArtist, FeedPostViewStudent, FeedPostViewTeacherAndArtist; `CompetitionStatusButtonView` + `LearnThisButtonView` as media CTAs; `FeedContentTypeView` [content type badges]; `PremiumCrownTag` [unused]; `PremiumBannerView`, `QoriaAppBarView`). |
| **Domain** | Feature-specific protocols and use cases. No UIKit/SwiftUI. Example: `Home/HomeRepository.swift`, `GetHomeDataUseCase.swift`. |
| **Data** | Implementations of domain protocols and shared data types. Example: `Home/HomeRepositoryImpl.swift`, `DynamicJSON.swift`. |
| **Network** | All HTTP/auth: `NetworkManager`, `NetworkCall` (and `NetworkCalling`), `AppUrl`, `AuthInterceptor`, `TokenRefresher`, `AuthTokenStore`, `NetworkError`, `NetworkLogger`. |
| **Colors** | `AppColor.swift` — `Color` extensions with semantic names (e.g. `Color.Surface.appBar`, `Color.Text.onDark`). |
| **Constants + Extensions** | `Constants`, `SavedData`, `ScreenSize`, `Device`, `Validation` (e.g. `String.isValidEmail`). |
| **Assets.xcassets** | Images (home, appBar, TabIcon, dummyImg, etc.). |

Dependencies point inward: Presentation → Domain → Data → Network. Network and shared code do not depend on Presentation or Domain protocols.

---

## 3. Coding Patterns

### 3.1 Dependency Injection (DI)

- **AppContainer** is the single composition root (singleton: `AppContainer.shared`, `private init()`).
  - Holds lazy instances of repositories and use cases.
  - Exposes factory methods for ViewModels, e.g. `makeHomeViewModel() -> HomeViewModel`.
- **Views** receive ViewModels via initializer (manual DI), e.g. `HomeView(viewModel: HomeViewModel)` with `@StateObject private var viewModel: HomeViewModel` and `_viewModel = StateObject(wrappedValue: viewModel)` in `init`.
- **ViewModels** receive use cases in `init`, e.g. `HomeViewModel(getHomeDataUseCase: GetHomeDataUseCase)`.
- **Repositories** can take a networking dependency with a default: e.g. `HomeRepositoryImpl(networkCall: NetworkCalling = NetworkCall.shared)`.

So: **constructor injection** for ViewModels and repositories; **container** only for building the ViewModel graph at the app/tab level.

### 3.2 Presentation (SwiftUI + Combine)

- **Views**: Structs, `View` protocol. Use `// MARK: - State`, `// MARK: - Init`, `// MARK: - Body` (and optional sections) for readability.
- **ViewModels**: `final class`, `ObservableObject`, `@MainActor`. Expose state via `@Published`; no SwiftUI imports in ViewModel except where needed for types. Sections: `// MARK: - Published State`, `// MARK: - Lifecycle`, `// MARK: - Intent`.
- **Data binding**: View uses `.task { viewModel.loadHome() }` for initial load; observes `viewModel.isLoading`, `viewModel.errorMessage`, `viewModel.homeData`. No business logic in the View.
- **Async work**: ViewModels use `Task { await ... }` and cancel previous work when appropriate (e.g. `loadTask?.cancel()` before starting a new load). Errors are mapped to a single `errorMessage: String?` and optionally to `LocalizedError.errorDescription`.
- **Previews**: Use `#Preview { ... }` and construct a minimal graph (e.g. repo → use case → ViewModel → View) for screens that need DI.

### 3.3 Domain Layer

- **Repository protocol**: Abstraction for data access, e.g. `protocol HomeRepository { func fetchHomeData() async throws -> dynamicJSON }`. No mention of HTTP or concrete types from Network.
- **Use case**: Thin struct, holds `repository: HomeRepository`, exposes a single method like `execute() async throws -> dynamicJSON` that delegates to the repository. No UI, no Alamofire.

### 3.4 Data Layer

- **Repository implementation**: `final class`, conforms to domain protocol, uses `NetworkCalling` (or similar) to perform requests and returns domain types (e.g. `dynamicJSON`).
- **Dynamic JSON**: `JSON` enum (from DynamicJSON) with `dynamicMemberLookup`; project alias `dynamicJSON = JSON`. Used for flexible API responses; parsing happens in Data/Network, not in ViewModels.

### 3.5 Network Layer

- **NetworkManager**: Singleton, builds Alamofire `Session` with `AuthInterceptor` and `NetworkLogger` (verbose in DEBUG). Exposes `requestData` and `requestJSON` (returns `JSON`) with `async throws`.
- **NetworkCalling / NetworkCall**: Protocol for API methods; concrete class uses `NetworkManager.shared` and `AppUrl.shared` for URLs. Each method is a single responsibility (e.g. `postLogin`, `getTestTodo`).
- **Auth**: `AuthTokenStore` (UserDefaults) for access/refresh tokens. `AuthInterceptor` adds `Authorization: Bearer` and retries once on 401 via `TokenRefresher`. `TokenRefresher` serializes concurrent refresh calls and notifies waiters.
- **Errors**: `NetworkError` enum with `LocalizedError` (emptyResponse, invalidJSON, unauthorized, httpStatus). Thrown from NetworkManager/TokenRefresher and propagated; can be mapped in ViewModels to user-facing strings.

### 3.6 Naming & Style

- **Types**: PascalCase. Protocols: noun or capability (e.g. `HomeRepository`, `NetworkCalling`). ViewModels: `*ViewModel`; Views: `*View`.
- **Files**: One main type per file; filename matches type (e.g. `HomeViewModel.swift`, `HomeRepository.swift`).
- **Comments**: File header with project name and purpose; `// MARK: -` for sections. Optional one-line comments for non-obvious logic.
- **Singletons**: `static let shared` + `private init()` for services (NetworkManager, NetworkCall, AppUrl, AuthTokenStore, TokenRefresher, AppContainer).

### 3.7 UI / Theming

- **Colors**: Centralized in `AppColor.swift` as `Color` extensions with nested enums: `Surface`, `Text`, `Profile`, `Tag`, `Badge`, `Premium`, `Gradient`. Use these instead of ad-hoc `Color(red:green:blue:)` in views. `Premium.crownTagBackground` is used for the premium crown tag next to user type.
- **Layout**: SwiftUI layout with `VStack`/`HStack`/`ZStack`, `Spacer()`, `frame(maxWidth: .infinity)` where appropriate. Some views use `UIScreen.main.bounds` for full-width images (consider `GeometryReader` for flexibility).
- **Feed media (single vs two items)**: Feed post views (`FeedPostView`, `FeedPostViewArtist`, `FeedPostViewStudent`, `FeedPostViewTeacherAndArtist`) support **single** media (full-width square, current behavior) and **two** media items side-by-side (when API provides 2 items). For two items, they use a **square container** (width = screen width, height = width) with BG `Color.Surface.appBar` (`#17171A`), **2px outer padding**, **2px inner gap**, and **4px corner radius per image**. Each media uses `scaledToFill` + `clipped` so left/right sides may crop to keep height maxed.
- **Shared posts (Student)**: A student can share another user’s post. `FeedPostViewStudentShared` renders an outer student post header + caption, then shows a **shared post preview** inside a bordered container (author header + text + media). The shared preview supports 1 or 2 media items (same container rules) and keeps the volume button on the shared media.
- **Placeholder tabs**: Learn, Post, Discover, Settings use a shared `ContentView(heading:)` with a test “Run Test Call” and optional auto-run; they are not yet feature-specific.

#### 3.7.1 Premium lock overlay (Teacher feed)

- **Premium overlay**: `FeedPostViewTeacher` now supports a premium overlay via `showsPremiumOverlay: Bool`.
- **Usage**: Wrap the normal content in a `ZStack`; when `showsPremiumOverlay == true`, the `PremiumLockedOverlayView` is drawn above the post, and the base content is slightly blurred.
- **Design**: The overlay uses a blurred material (`.ultraThinMaterial`) plus a subtle dark tint so the underlying post remains visible. It shows the `LockForPremium` asset, explanatory copy, and two CTA buttons: “View Post” and “Follow Premium Content”.

### 3.8 Error Handling & Null Safety

- **Errors**: Use `throws` and `do/catch` in async code; map to `LocalizedError` or a single `String?` in the ViewModel. Handle `CancellationError` (e.g. ignore when task is cancelled).
- **Optionals**: Use `if let`, `guard let`, optional chaining; avoid force unwraps. Views use `if let error = viewModel.errorMessage` and `if let data = viewModel.homeData`.

---

## 4. Data Flow Example (Home)

1. **QoriaTabView** creates `HomeViewModel` via `AppContainer.shared.makeHomeViewModel()` and shows `HomeView(viewModel: homeViewModel)`.
2. **HomeView** in `.task` calls `viewModel.loadHome()`.
3. **HomeViewModel.loadHome()** sets `isLoading = true`, `errorMessage = nil`, then `homeData = try await getHomeDataUseCase.execute()`; on failure sets `errorMessage`; in `defer` sets `isLoading = false`.
4. **GetHomeDataUseCase.execute()** calls `repository.fetchHomeData()`.
5. **HomeRepositoryImpl.fetchHomeData()** calls `networkCall.getTestTodo()` and returns the `JSON` (as `dynamicJSON`).
6. Response flows back: ViewModel updates `@Published`; SwiftUI re-renders HomeView (loading, error, or `homeData.description`).

---

## 5. Dependencies (External)

- **Alamofire**: HTTP client, `Session`, `RequestInterceptor`, `EventMonitor`.
- **Kingfisher**, **PhotosPicker**, **WebViewKit**: Referenced in the project (usage can be expanded for images, picker, web content).

---

## 6. Conventions to Follow When Adding Code

- **New feature (e.g. “Learn” screen)**:
  - Add `Domain/Learn/LearnRepository.swift` (protocol) and `GetLearnDataUseCase.swift`.
  - Add `Data/Learn/LearnRepositoryImpl.swift` implementing the protocol and using `NetworkCalling` (extend protocol if needed).
  - Add `Presentation/.../Learn/LearnViewModel.swift` and `LearnView.swift`; in ViewModel use the use case, in View use `@StateObject` and `.task` for initial load.
  - Register in `AppContainer`: e.g. `learnRepo`, `learnUseCase`, `makeLearnViewModel()`.
  - In `QoriaTabView`, inject `LearnViewModel` and show `LearnView(viewModel: learnViewModel)` for the Learn tab.
- **New API endpoint**: Add method to `NetworkCalling` and `NetworkCall`; keep URLs in `AppUrl`. Use `JSON`/`dynamicJSON` for responses unless you introduce a dedicated DTO layer.
- **New UI screen in an existing flow**: Reuse the same ViewModel/use case/repository pattern; keep Views dumb and ViewModels testable.
- **Constants / config**: Prefer `Constants` or `SavedData` (or a dedicated config type) and reuse from one place (SSOT).
- **Colors / assets**: Add to `AppColor` or Assets.xcassets; use semantic names in UI.

---

## 7. Summary

| Aspect | Choice |
|--------|--------|
| **Architecture** | Clean Architecture (Domain / Data / Presentation) + MVVM in UI |
| **UI** | SwiftUI, SwiftUI lifecycle (`@main` App) |
| **State** | Combine in ViewModels (`ObservableObject`, `@Published`) |
| **Async** | async/await, `Task`; cancellation where needed |
| **DI** | AppContainer as composition root; constructor injection for ViewModels and repos |
| **Networking** | Alamofire; protocol `NetworkCalling`; auth via interceptor + token refresh |
| **API data** | Dynamic JSON (`JSON` / `dynamicJSON`) in Data/Network layer |
| **Navigation** | Tab-based; each tab in its own `NavigationStack` |
| **Documentation** | This file (Qoria_ReadMe.md) as SSOT for architecture and patterns |

Keeping these patterns consistent will make the codebase predictable and easier to extend (e.g. new tabs, new APIs, new screens) without changing the overall architecture.
