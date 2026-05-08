# Premium Flutter Portfolio Application Plan

This document outlines the product architecture, design system, and technical implementation plan for a production-quality, App Store-ready personal portfolio application. It is designed to highlight your expertise in Flutter, NLP, Frontend Development, and AI.

## User Review Required
> [!IMPORTANT]
> - **State Management**: Proposing **Riverpod** (`hooks_riverpod`) for robust, scalable state management.
> - **Routing**: Proposing **GoRouter** for deep linking and declarative navigation.
> - **AI Integration**: The AI Chatbot is included in the plan. We need to decide on the backend (e.g., Gemini API, Dialogflow, or a local model).

## Open Questions
> [!WARNING]
> 1. **Brand Identity**: Do you have specific brand colors in mind, or should I proceed with the proposed sleek dark/light theme (Indigo/Teal on Deep Blue)?
> 2. **AI Chatbot Backend**: Which LLM API do you prefer for the "Chat with me" feature?
> 3. **Platform Target**: Is this primarily a Mobile App (iOS/Android), or do we need to optimize heavily for Web and Desktop as well? (Web requires specific responsive handling).

---

## 1. Product Architecture

*   **Framework**: Flutter (Latest Stable)
*   **Architecture Pattern**: **Feature-First Clean Architecture**. Divides the app into domain, data, and presentation layers per feature. This is highly scalable and mirrors enterprise-level codebases.
*   **State Management**: **Riverpod**. It is compile-safe, easily testable, doesn't rely on the widget tree, and handles asynchronous data (like fetching Firebase data) beautifully with `AsyncValue`.
*   **Routing**: **GoRouter**. Essential for web compatibility and handling deep links gracefully.
*   **Dependency Injection**: Handled implicitly and cleanly through Riverpod providers.
*   **Data Models**: **Freezed** + **JsonSerializable** for immutable data classes, union types, and robust JSON parsing.

## 2. UX Flow (Recruiter Journey)

The flow is designed to capture attention instantly and guide the user through your value proposition.

1.  **Splash Screen**: 1.5s minimal, elegant logo or name animation.
2.  **Home (Dashboard)**:
    *   *Header*: Striking headline (e.g., "Engineering Intelligence, Designing Experiences").
    *   *Quick Pitch*: 2-3 sentences summarizing your unique blend of Flutter & AI.
    *   *Highlights*: Horizontal scroll of top 2 "Featured Projects" for immediate impact.
    *   *FAB*: A floating action button pulsing subtly, inviting them to "Chat with my AI Assistant."
3.  **About Me & Experience**: An interactive vertical timeline blending your story, roles, and tech used. It shows *impact*, not just job descriptions.
4.  **Skills**: Visual representation categorized by domain (Frontend, AI/NLP, Architecture). Tapping a skill reveals a micro-interaction (e.g., a progress ring or a list of related tools).
5.  **Projects Gallery**: Vertical list of premium cards. Tapping expands to a detailed view with rich media, tech stack chips, and direct links (GitHub, Live App).
6.  **Contact**: Clean form, direct social links, and a prominent **Download CV** button.

## 3. UI Design System

*   **Theme**: Modern Minimalist + Subtle Glassmorphism.
*   **Color Palette (Dark Mode First)**:
    *   *Background*: `#0B0F19` (Deep, rich Blue-Black)
    *   *Surface*: `#1A1F2E` (Elevated cards)
    *   *Primary Accent*: `#6366F1` (Indigo - conveys tech and trust)
    *   *Secondary Accent*: `#14B8A6` (Teal - highlights AI/NLP elements)
    *   *Text*: `#F8FAFC` (Soft white for high readability)
*   **Typography**: `Plus Jakarta Sans` or `Inter`.
    *   Headlines: Bold, tight letter spacing for a punchy look.
    *   Body: Regular/Medium, generous line height (1.5 - 1.6) for readability.
*   **Spacing**: Strict 8pt grid system (8, 16, 24, 32, 48) for perfect rhythm.
*   **Animations (`flutter_animate`)**:
    *   `Hero` transitions for project images when navigating to details.
    *   Staggered `FadeIn` and `SlideUp` for lists as they enter the viewport.

## 4. Folder Structure (Clean Architecture)

```text
lib/
├── core/                   # App-wide configurations and utilities
│   ├── theme/              # Colors, fonts, AppTheme config
│   ├── router/             # GoRouter configuration
│   ├── constants/          # Strings, assets paths, dimensions
│   ├── errors/             # Custom exceptions, failure classes
│   └── utils/              # Helper functions (e.g., responsive builder)
├── features/               # Feature-first modules
│   ├── home/
│   │   ├── domain/         # Entities, repository interfaces
│   │   ├── data/           # Repositories impl, remote/local data sources
│   │   └── presentation/   # Pages, widgets, Riverpod controllers
│   ├── projects/           # (Same domain/data/presentation structure)
│   ├── experience/
│   └── chat_bot/           # AI Chatbot integration
├── shared/                 # Reusable UI components across features
│   ├── widgets/            # PrimaryButton, GlassCard, CustomTextField
│   └── animations/         # Page transitions, micro-animations
└── main.dart               # App entry point
```

## 5. Step-by-Step Flutter Implementation

1.  **Setup & Configuration**: Initialize app, configure `pubspec.yaml` with core dependencies (`flutter_riverpod`, `go_router`, `freezed`, `flutter_animate`, `google_fonts`, `url_launcher`).
2.  **Core Layer Foundation**: Define the `AppTheme` (Dark/Light mode), `app_router.dart`, and asset paths.
3.  **Shared Widgets & Design System**: Build the visual building blocks (`PrimaryButton`, `GlassCard`, typography widgets) so UI development is fast and consistent.
4.  **Domain & Data Layer**: Define `Project`, `Skill`, and `Experience` models using `freezed`. Create a mock data source initially to perfect the UI, preparing for a Firebase swap later.
5.  **Feature Navigation**: Implement the main navigation shell (e.g., a custom bottom nav bar or side rail for desktop).
6.  **Feature Implementation**: Build out Home, Projects, and Experience views with staggered entry animations.
7.  **AI Chatbot Integration**: Build the chat UI and connect it to the chosen LLM backend.
8.  **Polish & Performance**: Add micro-interactions (hover states, tap ripples), verify responsiveness across screen sizes, and audit performance.

## 6. Reusable Widgets Design

*   `GlassCard`: A container utilizing `BackdropFilter` for a premium frosted-glass effect. Used for project and skill cards.
*   `AnimatedTechChip`: A pill-shaped chip displaying a technology (e.g., "Flutter"). On tap/hover, it subtly glows or scales up.
*   `PrimaryButton`: A rounded button with an subtle gradient background and a built-in loading state indicator.
*   `SectionHeader`: Standardized typography widget for titles like "Featured Projects", ensuring consistency.
*   `ProjectCard`: A composite widget combining `GlassCard`, image caching (`cached_network_image`), `AnimatedTechChip`s, and a clean text layout.

## 7. Performance Optimization Tips

*   **`const` Constructors**: Liberally use `const` widgets to bypass unnecessary UI rebuilding during animations or state changes.
*   **Lazy Loading**: Always use `ListView.builder` or `GridView.builder` to ensure only visible items are rendered.
*   **Asset Optimization**: Use WebP or heavily compressed JPEGs. Use `cached_network_image` for remote assets to prevent redundant network requests.
*   **Provider Scoping**: Riverpod excels here. We will use `ref.select()` or watch granular providers in specific widgets to avoid rebuilding entire pages when only one data point changes.
*   **`RepaintBoundary`**: Wrap complex static UI elements or intensive animations in `RepaintBoundary` to isolate render cycles.

## 8. Future Improvements (To make it World-Class)

*   **Headless CMS**: Migrate from hardcoded/Firebase data to a modern CMS like Sanity.io. This allows you to update your portfolio content (new projects, new skills) instantly without releasing app updates.
*   **Interactive 3D or Rive Animations**: Embed a small interactive 3D model or a complex Rive animation in the hero section for a massive "wow" factor.
*   **RAG-Powered AI**: Enhance the chatbot using Retrieval-Augmented Generation (RAG). Feed it your actual resume, GitHub commit history, and blog posts so it answers deeply technical questions about your work style accurately.
*   **Analytics Integration**: Add Mixpanel or Firebase Analytics to track user behavior (e.g., which projects get the most clicks, how long recruiters spend on the experience section).
