# EnGo App

**Nhóm 5**

## Cây thư mục (chính)

```
en_go_app/
├── android/                     # Android project
├── ios/                         # iOS project
├── linux/                       # Linux desktop support
├── macos/                       # macOS desktop support
├── windows/                     # Windows desktop support
├── web/                         # Web assets
├── assets/                      # Ảnh, icon, fonts
├── build/                       # Build outputs
├── test/                        # Unit/widget tests
├── lib/                         # Source chính của Flutter app
│   ├── main.dart                # Entrypoint
│   ├── core/                    # Constants, utils, theme, error
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_assets.dart
│   │   │   └── firebase_collections.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   ├── logger.dart
│   │   │   └── helpers.dart
│   │   ├── error/
│   │   │   ├── failure.dart
│   │   │   ├── exceptions.dart
│   │   │   └── firebase_error_mapper.dart
│   │   └── theme/
│   │       ├── light_theme.dart
│   │       ├── dark_theme.dart
│   │       └── theme_provider.dart
│   ├── data/                    # Models, datasources, repositories
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── vocabulary_model.dart
│   │   │   ├── grammar_model.dart
│   │   │   ├── lesson_model.dart
│   │   │   ├── test_model.dart
│   │   │   └── progress_model.dart
│   │   ├── repositories/
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── vocabulary_repository_impl.dart
│   │   │   ├── grammar_repository_impl.dart
│   │   │   ├── lesson_repository_impl.dart
│   │   │   └── test_repository_impl.dart
│   │   └── datasources/
│   │       ├── local/
│   │       │   ├── local_cache.dart
│   │       │   └── local_db_service.dart
│   │       └── remote/
│   │           └── firebase/
│   │               ├── firebase_auth_service.dart
│   │               ├── firestore_service.dart
│   │               ├── firebase_storage_service.dart
│   │               └── firebase_messaging_service.dart
│   ├── domain/                  # Entities, usecases, interfaces
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   ├── vocabulary.dart
│   │   │   ├── grammar.dart
│   │   │   ├── lesson.dart
│   │   │   ├── test.dart
│   │   │   └── progress.dart
│   │   ├── usecases/
│   │   │   ├── auth/
│   │   │   │   ├── login.dart
│   │   │   │   ├── register.dart
│   │   │   │   └── logout.dart
│   │   │   ├── vocabulary/
│   │   │   │   ├── get_all_words.dart
│   │   │   │   ├── add_word.dart
│   │   │   │   └── delete_word.dart
│   │   │   ├── grammar/
│   │   │   │   └── get_all_grammar.dart
│   │   │   └── progress/
│   │   │       └── update_progress.dart
│   │   └── repository_interfaces/
│   │       ├── auth_repository.dart
│   │       ├── vocabulary_repository.dart
│   │       ├── grammar_repository.dart
│   │       ├── lesson_repository.dart
│   │       └── test_repository.dart
│   ├── presentation/            # UI: pages, widgets, providers
│   │   ├── pages/
│   │   │   ├── welcome/
│   │   │   ├── auth/
│   │   │   ├── vocabulary/
│   │   │   ├── grammar/
│   │   │   ├── flashcard/
│   │   │   ├── quiz/
│   │   │   ├── test/
│   │   │   └── profile/
│   │   ├── widgets/
│   │   │   ├── app_button.dart
│   │   │   ├── app_input_field.dart
│   │   │   ├── navbar_bottom.dart
│   │   │   ├── app_header.dart
│   │   │   ├── lesson_card.dart
│   │   │   └── app_modal.dart
│   │   └── providers_or_blocs/
│   │       ├── auth_bloc.dart
│   │       ├── vocabulary_bloc.dart
│   │       ├── grammar_bloc.dart
│   │       ├── flashcard_bloc.dart
│   │       └── progress_bloc.dart
│   ├── routes/
│   │   └── app_routes.dart
│   └── firebase/
│       ├── firebase_options.dart       # auto-generated
│       ├── firebase_initializer.dart   # init firebase
│       └── firebase_di.dart            # dependency injection
├── .vscode/                      # VSCode configs (launch, settings)
└── README.md
```
