# EnGo app
## Nhóm 5 
## Thành viên:

## Cây thư mục:
lib/
│
├── core/
│   ├── constants/
│   │    ├── app_colors.dart         # Khai báo màu dùng trong toàn app
│   │    ├── app_text_styles.dart    # Quy định font, size, weight
│   │    ├── app_spacing.dart        # Padding, margin, radius
│   │    ├── app_assets.dart         # Link icon, hình ảnh
│   │    └── api_endpoints.dart      # Khai báo endpoint API (nếu dùng)
│   │
│   ├── utils/
│   │    ├── validators.dart         # Validate email, password...
│   │    ├── formatters.dart         # Format ngày, số, thời gian
│   │    ├── logger.dart             # Ghi log debug
│   │    └── helpers.dart            # Hàm hỗ trợ nhỏ khác
│   │
│   ├── error/
│   │    ├── failure.dart            # Định nghĩa lỗi chung
│   │    ├── exceptions.dart         # Exception từ datasource
│   │    └── error_mapper.dart       # Map exception → failure
│   │
│   └── theme/
│        ├── light_theme.dart        # Theme sáng (màu, text, widget style)
│        ├── dark_theme.dart         # Theme tối
│        └── theme_provider.dart     # Provider/BLoC quản lý theme
│
├── data/
│   ├── models/
│   │    ├── user_model.dart         # Model User (từ JSON)
│   │    ├── vocabulary_model.dart   # Model từ vựng
│   │    ├── lesson_model.dart       # Model bài học
│   │    ├── test_model.dart         # Model bài thi
│   │    └── grammar_model.dart      # Model ngữ pháp
│   │
│   ├── repositories/
│   │    ├── user_repository_impl.dart        # Implement interface domain
│   │    ├── vocabulary_repository_impl.dart
│   │    ├── lesson_repository_impl.dart
│   │    └── test_repository_impl.dart
│   │
│   └── datasources/
│        ├── local/
│        │    ├── local_db_service.dart       # SQLite/hive
│        │    └── local_cache.dart            # SharedPreferences
│        │
│        └── remote/
│             ├── api_service.dart            # HTTP, Dio
│             └── firebase_service.dart       # Firebase (nếu dùng)
│
├── domain/
│   ├── entities/
│   │    ├── user.dart                # Entity thuần
│   │    ├── vocabulary.dart
│   │    ├── lesson.dart
│   │    └── test.dart
│   │
│   ├── usecases/
│   │    ├── get_all_words.dart       # Mỗi usecase = 1 chức năng
│   │    ├── add_word.dart
│   │    ├── get_lessons.dart
│   │    ├── login.dart
│   │    └── get_tests.dart
│   │
│   └── repository_interfaces/
│        ├── vocabulary_repository.dart
│        ├── user_repository.dart
│        ├── lesson_repository.dart
│        └── test_repository.dart
│
├── presentation/
│   ├── pages/
│   │    ├── welcome/
│   │    │     └── welcome_page.dart
│   │    ├── auth/
│   │    │     ├── login_page.dart
│   │    │     ├── register_page.dart
│   │    │     └── forgot_password_page.dart
│   │    ├── vocabulary/
│   │    │     ├── vocabulary_page.dart
│   │    │     └── vocabulary_detail_page.dart
│   │    ├── flashcard/
│   │    │     ├── flashcard_page.dart
│   │    │     └── flashcard_review_page.dart
│   │    ├── quiz/
│   │    │     └── quiz_page.dart
│   │    ├── test/
│   │    │     ├── toeic_test_page.dart
│   │    │     └── ielts_test_page.dart
│   │    ├── grammar/
│   │    │     └── grammar_page.dart
│   │    └── profile/
│   │          └── profile_page.dart
│   │
│   ├── widgets/
│   │    ├── app_button.dart          # Primary, secondary, disabled
│   │    ├── app_input_field.dart
│   │    ├── navbar_bottom.dart
│   │    ├── app_header.dart
│   │    ├── lesson_card.dart
│   │    ├── vocabulary_card.dart
│   │    ├── app_modal.dart
│   │    └── app_progress_bar.dart
│   │
│   └── providers_or_blocs/
│        ├── auth_provider.dart / auth_bloc.dart
│        ├── vocabulary_provider.dart
│        ├── flashcard_provider.dart
│        ├── quiz_provider.dart
│        └── test_provider.dart
│
├── routes/
│   └── app_routes.dart               # Khai báo các route trong app
│
└── main.dart                         # File chạy chính

