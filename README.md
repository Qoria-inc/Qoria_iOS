# Qoria_iOS

Qoria iOS app — SwiftUI-based, Clean Architecture with unidirectional data flow.

---

## Codebase Overview

| Layer / Area | Location | Purpose |
|-------------|----------|---------|
| **App** | `Qoria_App/App/` | Entry point, DI container, root `WindowGroup` |
| **Presentation** | `Qoria_App/Presentation/` | SwiftUI views, ViewModels, tab navigation |
| **Domain** | `Qoria_App/Domain/` | Use cases, repository protocols (business rules) |
| **Data** | `Qoria_App/Data/` | Repository implementations, dynamic JSON model |
| **Network** | `Qoria_App/Network/` | API client, auth, token refresh, URLs, errors |
| **Constants + Extensions** | `Qoria_App/Constants + Extensions/` | Constants, validation, screen/device helpers |
| **Colors** | `Qoria_App/Colors/` | App color system (`AppColor.swift`) |

---

## Architecture

- **Pattern:** Clean Architecture–style layering with **MVVM** in the UI.
- **Data flow:** Unidirectional — View → ViewModel → UseCase → Repository → Network. State is owned by ViewModels and published to Views.
- **Dependency injection:** Centralized in `AppContainer` (singleton). Repositories and use cases are created there; ViewModels are built via factory methods (e.g. `makeHomeViewModel()`).
- **Single source of truth (SSOT):** Feed data lives in `HomeViewModel` (`items`, `homeData`, `hasNextPage`). No duplicate feed state across screens.

### Layer Responsibilities

1. **Presentation (SwiftUI + ViewModels)**  
   - Views: `HomeView`, `QoriaTabView`, feed post views, app bar, banners.  
   - ViewModels: `@MainActor`, `ObservableObject`, `@Published` state; call use cases and update UI state.

2. **Domain**  
   - **Use cases:** e.g. `GetHomeDataUseCase` — one clear action (`execute(page:pageSize:)`).  
   - **Repository protocols:** e.g. `HomeRepository` — abstract contract for data (no network detail).

3. **Data**  
   - **Repository implementations:** e.g. `HomeRepositoryImpl` — use `NetworkManager` / `AppUrl` to fetch; return domain-friendly type (`dynamicJSON`).  
   - **Models:** `DynamicJSON.swift` — typealias for `JSON` (dynamic, type-safe JSON with `@dynamicMemberLookup`).

4. **Network**  
   - **NetworkManager:** Alamofire `Session` with `AuthInterceptor` and optional `NetworkLogger`; `requestData` / `requestJSON` with timeout and encoding by method.  
   - **Auth:** `AuthTokenStore` (UserDefaults), `AuthInterceptor` (Bearer + 401 retry), `TokenRefresher` (single-flight refresh, then retry or clear).  
   - **API surface:** `NetworkCall` conforms to `NetworkCalling`; login and other endpoints go through here.  
   - **Config:** `AppUrl` — base URL (staging/production), path helpers.  
   - **Errors:** `NetworkError` with `LocalizedError` for user-facing messages.

---

## Networking

- **Library:** Alamofire.  
- **Session:** One shared `NetworkManager.shared` session with:  
  - **AuthInterceptor:** Adds `Authorization: Bearer <accessToken>`; skips header for refresh URL; on 401 retries once after refresh (or clears tokens and does not retry).  
  - **NetworkLogger:** DEBUG = verbose (cURL + body), else basic (method + URL + status).  
- **Token refresh:** `TokenRefresher` uses a lock and waiters so concurrent 401s trigger a single refresh; supports both `{ result, data: { access, refresh } }` and flat `{ access, refresh }` response shapes.  
- **Storage:** `AuthTokenStore` (UserDefaults) for `access` and `refresh`; clear on refresh failure.  
- **API calls:**  
  - High-level: `NetworkCall` (e.g. `loginWithEmail()`).  
  - Data flow: ViewModel → UseCase → Repository → `NetworkManager.requestJSON` / `requestData` → Alamofire.  
- **Error handling:** Thrown as `NetworkError`; in ViewModels caught and mapped to `errorMessage` (e.g. `LocalizedError.errorDescription`).

---

## Coding Patterns

- **Async/await:** All network and use-case calls are `async throws`; ViewModels use `Task` and `@MainActor` for UI updates.  
- **Cancellation:** `HomeViewModel` cancels previous `loadTask` on new `loadHome()`; respects `CancellationError` in catch.  
- **Pagination:** Home feed uses `page` and `page_size`; `loadNextPageIfNeeded(currentIndex:)` triggers when near the end of the list; `hasNextPage` from `pagination.has_next`.  
- **SwiftUI:** `@StateObject` for ViewModels created outside the view (e.g. in tab); `@Published` for state; no business logic in views — views only bind to ViewModel and call intents.  
- **Conventions:**  
  - `final class` for singletons and injectable types.  
  - Protocol for network API (`NetworkCalling`) and repository (`HomeRepository`) for testability.  
  - Centralized URLs and constants (`AppUrl`, `Constants`, `SavedData`).  
  - Colors and surfaces in `AppColor` for consistency.  
- **Feed post mapping:** Home maps API `user_type`, `teachable`, `student_type`, `post_type` to enums (`UserCategory`, `proUserFeed`, `nonProUserFeed`, `feedPostType`) and picks the correct feed view (Teacher, Artist, Student, etc.).

---

## Key Files Quick Reference

| File | Role |
|------|------|
| `Qoria_AppApp.swift` | `@main`, `URLCache` setup, root `QoriaTabView`, dark/light from `AppStorage` |
| `AppContainer.swift` | DI: `HomeRepository` → `GetHomeDataUseCase` → `makeHomeViewModel()` |
| `NetworkManager.swift` | Alamofire session, `requestData` / `requestJSON`, validation, `NetworkError` |
| `AuthInterceptor.swift` | Bearer header, 401 retry with `TokenRefresher` |
| `TokenRefresher.swift` | Single-flight refresh, lock + waiters, token persistence |
| `AuthTokenStore.swift` | UserDefaults access/refresh tokens, `clear()` |
| `AppUrl.swift` | Base URL + paths (login, refresh, feed, privacy, terms) |
| `HomeRepository.swift` | Protocol `fetchHomeData(page:pageSize:)` |
| `HomeRepositoryImpl.swift` | Implements with `NetworkManager` + `AppUrl.homeFeedURL()` |
| `GetHomeDataUseCase.swift` | Delegates to `HomeRepository`, returns `dynamicJSON` |
| `HomeViewModel.swift` | Load/refresh/pagination, error state, hardcoded login bridge |
| `HomeView.swift` | Feed list, post type mapping, banner, loading/error UI |
| `DynamicJSON.swift` | `JSON` type + `dynamicJSON` alias for flexible API models |

---

## UI behavior (Teacher feed)

- **Premium blur overlay:** When `showsPremiumOverlay` is true, the blur overlay (`PremiumLockedOverlayView`) is shown over the media with **width = main screen width** (explicit `UIScreen.main.bounds.width`).
- **Share + Save when blurred:** When the blur overlay is visible, the **Share** and **Save** buttons in the actions row are **hidden**; Like and Comment remain visible.

## Current Limitations / Notes

- Login is hardcoded in `HomeViewModel.performHardcodedLogin()` and triggered from `QoriaTabView.task`; no login screen yet.  
- Some tabs (Learn, Post, Discover, Settings) still use placeholder `ContentView` or a single view.  
- Feed uses dynamic `dynamicJSON` (no strong DTOs) for flexibility; type safety is at access time via `.string`, `.int`, `.array`, etc.

---

## Running the Project

1. Open `Qoria_App/Qoria_App.xcodeproj` in Xcode.  
2. Select target and run on simulator or device.  
3. App starts on Home tab; hardcoded login runs once, then feed loads from staging API.
