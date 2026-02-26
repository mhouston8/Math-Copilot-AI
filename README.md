# Math Copilot AI

A Flutter app that photographs math homework and solves it using the OpenAI GPT-4o vision API. Users can have follow-up conversations about the problem to better understand the solution.

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter 3.41.0 | Cross-platform UI framework |
| Dart 3.11.0 | Programming language |
| OpenAI GPT-4o | Image analysis + math tutoring |
| Supabase | Auth, database, image storage |
| RevenueCat | Subscriptions + paywall (planned) |

## Project Structure

```
lib/
├── main.dart                    # App entry point, initializes Supabase
├── config.dart                  # API keys (git-ignored)
├── models/
│   ├── analysis_result.dart     # Data model for AI responses
│   └── chat_message.dart        # Data model for chat messages
├── screens/
│   ├── tab_shell.dart           # Bottom tab bar (Home, Camera, Settings)
│   ├── home_screen.dart         # Welcome / conversation history
│   ├── camera_screen.dart       # Take photo or pick from gallery
│   ├── result_screen.dart       # Photo preview + "Analyze" button
│   ├── chat_screen.dart         # AI chat with follow-up questions
│   └── settings_screen.dart     # App settings
└── services/
    ├── openai_service.dart      # OpenAI API integration
    └── supabase_service.dart    # Supabase auth, DB, and storage
```

## Architecture

MVVM-inspired with a service layer:

- **Screens** — UI widgets (StatelessWidget / StatefulWidget)
- **Models** — Data classes
- **Services** — External API integrations (OpenAI, Supabase, RevenueCat)

Screens call services directly. Services handle all network/database logic.

## App Flow

```
1. User opens app → Tab bar (Home, Camera, Settings)
2. User taps Camera tab → Take photo or pick from gallery
3. Photo taken → Result screen shows preview
4. User taps "Analyze with AI" → Loading spinner
5. AI responds → Chat screen with solution
6. User asks follow-up questions → Multi-turn conversation
7. Conversation auto-saved to Supabase
```

## Database Schema (Supabase)

### conversations
| Column | Type | Description |
|---|---|---|
| id | uuid (PK) | Auto-generated |
| user_id | uuid (FK → auth.users) | Owner of the conversation |
| title | text | Summary of the problem |
| image_url | text | Path to image in Supabase Storage |
| created_at | timestamptz | Auto-generated |

### messages
| Column | Type | Description |
|---|---|---|
| id | uuid (PK) | Auto-generated |
| conversation_id | uuid (FK → conversations) | Parent conversation |
| role | text | "user" or "assistant" |
| content | text | Message text |
| created_at | timestamptz | Auto-generated |

Row Level Security (RLS) is enabled — users can only access their own data.

### Storage
- Bucket: `homework-images`
- Structure: `{user_id}/{filename}.jpg`
- RLS enforced — users can only access their own folder.

## Setup

1. Clone the repo
2. Create `lib/config.dart` with your keys:
   ```dart
   const String openAIApiKey = 'your-openai-key';
   const String supabaseUrl = 'https://your-project.supabase.co';
   const String supabaseAnonKey = 'your-anon-key';
   ```
3. Run `flutter pub get`
4. Run `flutter run`

## Key Concepts (Flutter ↔ SwiftUI)

| Flutter | SwiftUI |
|---|---|
| Widget | View |
| StatelessWidget | View (no @State) |
| StatefulWidget + setState() | View + @State |
| Column / Row | VStack / HStack |
| Navigator.push() | NavigationLink |
| Scaffold | NavigationView |
| NavigationBar | TabView |
| Padding widget | .padding() modifier |
| SizedBox | Spacer with frame |
| Future + async/await | async/await |
| pub (package manager) | SPM / CocoaPods |
