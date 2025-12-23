# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Core commands

### Dependency management
- Install Flutter dependencies:
  - `flutter pub get`

### Running the app
- Run on a connected device or simulator (auto-detect device):
  - `flutter run`
- Run specifically in Chrome (useful for quick UI iteration):
  - `flutter run -d chrome`

### Linting and static analysis
- Run Dart/Flutter analysis (uses `flutter_lints` via `analysis_options.yaml`):
  - `flutter analyze`

### Code generation
This project uses `riverpod_generator` and `json_serializable`. Any time you change files with `part '*.g.dart';` or Riverpod annotations, regenerate code:
- One-off build:
  - `dart run build_runner build --delete-conflicting-outputs`
- Watch mode (recommended during active feature work):
  - `dart run build_runner watch --delete-conflicting-outputs`

### Tests
There are no repository-specific test helpers configured; use standard Flutter test commands:
- Run all tests:
  - `flutter test`
- Run a single test file (replace with an actual path when tests exist):
  - `flutter test test/path_to_test.dart`

## High-level architecture

### Overview
This is a Flutter application (`pubspec.yaml`) for a digital signature product (Digito). It uses:
- `flutter_riverpod` / `riverpod_annotation` for state management
- `go_router` for navigation
- `json_serializable` for model serialization
- `shared_preferences` and `path_provider` for simple persistence
- `google_generative_ai`, `genui`, and related packages to power AI-assisted flows (sender-side request creation and signer-side assistant).

The main app entry point is `lib/main.dart`, which wires up:
- A top-level `ProviderContainer`
- Global logging and error handling
- The router and theming

### Core layer (`lib/core`)

**1. Providers (`lib/core/providers`)**

These expose app-wide services and state via Riverpod:
- `logger_provider.dart` → provides `LoggerService` (console logger) used for diagnostics throughout the app.
- `error_handler_provider.dart` → wraps `ErrorHandlerService`, which normalizes `Object`/exceptions into the domain-level `AppError` and logs them.
- `auth_provider.dart` → wires `AuthService` using the in-memory/`FlutterSecureStorage`-based `MockAuthService`. Also exposes `currentUser` and `isAuthenticated` as async providers.
- `profile_provider.dart` → derives a `UserProfile` from the authenticated user and exposes mutation methods for contract acceptance and certificate lifecycle.
- `theme_provider.dart` → holds the global `ThemeMode` with `toggle`/`setThemeMode` helpers.

These providers typically wrap service classes under `lib/core/services` and domain models under `lib/domain/models`.

**2. Services (`lib/core/services`)**

- `auth_service.dart` → abstract interface for authentication (login/logout/token management). The concrete implementation in this app is `MockAuthService`.
- `mock_auth_service.dart` → mock user store backed by `FlutterSecureStorage`, with helper login flows (`loginWithCredentials`, `signUp`). Production auth (e.g., `auth0_service.dart`) can be swapped in via `authService` provider.
- `logger_service.dart` → `ConsoleLoggerService` that logs to `dart:developer` in debug mode.
- `error_handler_service.dart` → central place to convert arbitrary errors into `AppError` variants (network/auth/server/unknown) and log them.

**3. Router (`lib/core/router/app_router.dart`)**

Defines all navigation using `GoRouter` exported via `appRouterProvider`. Key routes:
- `/` → `DashboardScreen` (sender dashboard)
  - `/create` → `DocumentSelectScreen` with nested:
    - `/create/recipients` → `RecipientScreen`
    - `/create/editor` → `EditorScreen`
    - `/create/review` → `ReviewScreen`
  - `/create/chat` → `ChatCreationScreen` (AI-driven creation flow)
  - `/history` → `HistoryScreen`
- `/login` → `LoginScreen`
- `/profile` → `ProfileScreen`
- `/sign/:requestId` → `SigningScreen` (signer-side assistant)
- `/share/:requestId` → `ShareLinkView` (shareable view of a request)

`ShareLinkView` fetches the `SignatureRequest` from `requestsProvider`, so changes to how requests are stored or identified should keep this in sync.

**4. Theme and global UI (`lib/core/theme`, `lib/core/widgets`)**

- `app_theme.dart` → central Material 3 theme definition (light/dark) with brand colors, typography (Inter via `google_fonts`), button and input styles.
- `error_boundary.dart` / `GlobalErrorHandler` → wraps the app widget tree and integrates `ErrorHandlerService` with a UI-level `ErrorDialog` to show user-facing error messages and optional recovery actions.

### Domain layer (`lib/domain`)

Pure data and domain logic — no Flutter/UI-specific dependencies except for `Offset` in `PlacedField`:

- `app_error.dart` → polymorphic error type with categories (network, auth, server, validation, unknown) and recovery actions; used throughout error handling flows.
- `auth_user.dart` → authenticated user representation.
- `user_profile.dart` → extended profile model with role, account status, contract flags, certificate info, and helper getters (`isAdmin`, `canCreateCertificate`, `missingPrerequisites`, etc.).
- `signature_request.dart` → main aggregate for a signature workflow:
  - `RequestStatus` (draft/sent/completed/declined)
  - `SignatureRequestType` (selfSign/oneOnOne/multiParty)
  - recipients (`Recipient`), field placements (`PlacedField`)
  - persistence-related fields (`filePath`, `fileBytes`, `signUrl`)
- `recipient.dart` → single recipient (name/email/role) used by sender flows.
- `placed_field.dart` → logical representation of a field placed on a document page, including `FieldType` and `Offset` with custom JSON conversion.

Many of these models are `json_serializable` and have corresponding `*.g.dart` files generated by `build_runner`.

### Feature layer (`lib/features`)

Features are organized by role and concern, typically with `data`, `domain`, `providers`, and `presentation` subfolders.

#### Sender flows (`lib/features/sender`)

**Persistence and state**
- `data/requests_repository.dart` → persistence of `SignatureRequest` objects into `SharedPreferences` as a JSON list. It is intentionally forgiving: malformed entries are skipped rather than failing the entire load.
- `providers/requests_provider.dart` → main orchestrator for sender-side signature requests.
  - `requestsRepositoryProvider` → exposes `RequestsRepository`.
  - `Requests` notifier → async list of all `SignatureRequest`s with `addOrUpdate` and `delete` methods; ensures optimistic in-memory updates in addition to persistence.
  - `ActiveDraft` notifier → central source of truth for the currently edited `SignatureRequest` (including quick actions). It:
    - Initializes new drafts for self-sign/1-on-1/multi-party flows.
    - Manages file upload and persistence, including copying files into an app-specific directory on non-web platforms and handling transient `fileBytes` for web.
    - Updates recipients and fields while keeping `updatedAt` in sync.
    - `markAsSent` generates a mock signing URL and persists the request as `RequestStatus.sent`.
  - `TransientFile` and `_transientFiles` map → hold in-memory PDF bytes between sessions whenever serialization strips them out.

**Screens and flows**
Key presentation components (UI and flow logic live together):

- `presentation/dashboard_screen.dart` → main sender dashboard.
  - Displays quick-action cards for creating self-sign, 1-on-1, and multi-party requests by calling the relevant `ActiveDraft` initializers and routing to `/create`.
  - Shows recent activity using `requestsProvider` with status chips and appropriate navigation depending on `RequestStatus`.
  - Header menu integrates theme toggling and auth state (`isAuthenticatedProvider`, `authServiceProvider`).

- `presentation/document_select_screen.dart` (not fully inspected, but participates in `/create` flow) → first step in the standard wizard, likely chooses a PDF via `file_picker` and feeds it into `ActiveDraft.updateFile`.

- `presentation/recipient_screen.dart` → second step in the wizard.
  - Manages an internal list of `TextEditingController`s for names/emails, syncing changes back to `ActiveDraft.updateRecipients`.
  - Encodes flow-specific constraints (self-sign requires exactly 1 signer; 1-on-1 requires exactly 2; multi-party allows variable count with min 2) and enforces them before moving to `EditorScreen`.
  - Can auto-populate the first recipient from `currentUser` when "I am one of the signers" is checked.

- `presentation/editor_screen.dart` → field placement UI on top of a PDF (or placeholder if real PDF rendering is unavailable).
  - Uses `flutter_pdfview` for native platforms and a faux preview for web.
  - Provides drag-and-drop tools for `FieldType`s (`signature`, `initials`, `date`, `text`) and overlays existing `PlacedField`s from `ActiveDraft`.
  - Updates field positions and deletions live via `ActiveDraft.updateFields`.

- `presentation/review_screen.dart` and `presentation/history_screen.dart` (not inspected here but referenced by the router) are the final steps and history view for requests, consuming the same `Requests`/`ActiveDraft` state.

- `presentation/chat_creation/...` → AI-assisted sender flow backed by GenUI and Gemini.
  - `chat_creation_screen.dart`:
    - Configures a `GoogleGenerativeAiContentGenerator` with a system prompt focused on building signature requests via GenUI components.
    - Uses `senderCatalog` (in a sibling file) and `A2uiMessageProcessor` to render interactive UI surfaces (request type selector, file selector, recipient form, draft summary) as chat bubbles.
    - Tracks conversation state in `_bubbles`, with each bubble either text or a `GenUiSurface` instance.
    - Shows a status bar summarizing the currently active `SignatureRequest` (title and recipients), derived from `activeDraftProvider`.
  - `chat_tools.dart` → defines Gemini `FunctionDeclaration`s for file picking, adding recipients, placing fields, and moving to review. These are intended to be used by the LLM to manipulate the draft.

This means there are two complementary creation paths for a `SignatureRequest`:
1. Traditional multi-screen wizard (`/create` + nested routes) using hand-built UI.
2. Conversational GenUI-driven flow (`/create/chat`) that still ultimately drives `ActiveDraft` and `Requests`.

#### Signer flows (`lib/features/signer`)

- `presentation/signing_catalog.dart` → GenUI catalog describing widgets used in the signer assistant:
  - `signingRequest` cards (title, recipients, status)
  - `documentPreview` widget
  - `signaturePad` widget that emits `UserActionEvent`s when a mock signature is captured

- `presentation/signing_screen.dart` → signer-facing chat interface.
  - Configures a `GoogleGenerativeAiContentGenerator` with a system instruction targeted at guiding a user through signing.
  - Uses the `signingCatalog` and `A2uiMessageProcessor` to present interactive surfaces like signing requests and signature pads.
  - Manages a list of `ChatBubbleModel`s representing user and assistant messages; each assistant bubble may contain both text and a `GenUiSurface`.

#### Auth & Profile (`lib/features/auth`, `lib/features/profile`)

- `auth/presentation/login_screen.dart` (not fully inspected) will use `MockAuthService` via `authServiceProvider` for sign-in, including demo accounts defined in `MockAuthService._users`.
- `profile/presentation/profile_screen.dart` (not inspected) displays and manipulates `ProfileState` from `profile_provider.dart`, including contract and certificate actions.

### Application entry (`lib/main.dart`)

- Creates a `ProviderContainer`, retrieves the global `LoggerService`, and installs global error hooks:
  - `FlutterError.onError` for framework-level errors
  - `PlatformDispatcher.instance.onError` for uncaught async errors

- Wraps `MaterialApp.router` in `GlobalErrorHandler` so all uncaught widget-level exceptions can be normalized to `AppError` and shown via `ErrorDialog`.
- Binds theme and router to `appRouterProvider` and `appThemeModeProvider` respectively.

### When modifying or extending the app

- Any new app-wide services should have:
  - A concrete implementation under `lib/core/services`
  - A Riverpod provider under `lib/core/providers`
  - Domain models (if needed) under `lib/domain/models` with `json_serializable` support when persistence/serialization is required.

- For sender workflows, prefer integrating with the existing `SignatureRequest` + `Requests` + `ActiveDraft` abstraction instead of creating parallel state. This ensures:
  - History, dashboard, and sharing routes stay consistent
  - Both the wizard and GenUI flows can interoperate on the same data model.

- When introducing new GenUI surfaces or Gemini tools, follow the existing patterns:
  - Add catalog items to `sender_catalog.dart` or `signing_catalog.dart`.
  - Extend `chat_tools.dart` or similar tooling declarations.
  - Ensure the system prompt describes when and how the tool/surface should be used relative to the rest of the flow.
