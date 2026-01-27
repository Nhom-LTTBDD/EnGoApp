# TOEIC Test System - Architecture & Guide

**Tài liệu này tổng hợp toàn bộ file TOEIC và flow hoạt động của hệ thống bài thi TOEIC**

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [File List (14 files)](#file-list)
3. [Layer Breakdown](#layer-breakdown)
4. [Complete Flow](#complete-flow)
5. [Data Structure](#data-structure)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER (UI)                      │
├─────────────────────────────────────────────────────────────────┤
│  Pages:                          Widgets:                       │
│  • toeic_page                   • toeic_quiz_summary_widget     │
│  • toeic_detail_page            • toeic_question_display_widget │
│  • toeic_test_taking_page       •  shared_audio_player_widget   │
│  • toeic_result_page                                            │
│  • toeic_review_page            Providers:                      │
│                                 • toeic_test_provider           │
├─────────────────────────────────────────────────────────────────┤
│                      DATA LAYER (Services)                      │
├─────────────────────────────────────────────────────────────────┤
│  • toeic_sample_data.dart (Data Source)                         │
│  • toeic_json_service.dart (JSON Service)                       │
│  • FirebaseStorageService (Firebase)                            │
├─────────────────────────────────────────────────────────────────┤
│                    DOMAIN LAYER (Entities)                      │
├─────────────────────────────────────────────────────────────────┤
│  • toeic_test.dart (Model bài thi)                              │
│  • toeic_question.dart (Model câu hỏi)                          │
│  • toeic_test_session.dart (Model phiên thi)                    │
├─────────────────────────────────────────────────────────────────┤
│                    UTILITIES                                    │
├─────────────────────────────────────────────────────────────────┤
│  • toeic_score_calculator.dart (Tính điểm)                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## File List (14 Files)

### DOMAIN LAYER - Entities (3 files)

#### 1. `toeic_test.dart`

- **📍 Đường dẫn:** `lib/domain/entities/toeic_test.dart`
- **Chức năng:** Model đại diện cho một **bài thi TOEIC**
- **Thông tin:**
  - id, name, description
  - totalQuestions, listeningQuestions, readingQuestions
  - duration, createdAt, updatedAt
  - isActive, year
- **Dùng để:** Lưu thông tin bài thi (Test 1, Test 2, ...)
- **Size:** 96 dòng

#### 2. `toeic_question.dart`

- **📍 Đường dẫn:** `lib/domain/entities/toeic_question.dart`
- **Chức năng:** Model đại diện cho một **câu hỏi TOEIC**
- **Thông tin:**
  - id, testId, partNumber, questionNumber
  - questionType (single, group, image)
  - questionText, imageUrl, imageUrls
  - audioUrl, options[A,B,C,D]
  - correctAnswer, explanation, transcript
  - groupId, passageText, order
- **Dùng để:** Lưu dữ liệu từng câu hỏi (Q1, Q2, ..., Q200)
- **Size:** 66 dòng

#### 3. `toeic_test_session.dart`

- ** Đường dẫn:** `lib/domain/entities/toeic_test_session.dart`
- **Chức năng:** Model đại diện cho một **phiên thi đang diễn ra**
- **Thông tin:**
  - testId, testName, isFullTest, selectedParts
  - timeLimit (phút), startTime
  - userAnswers {questionNumber → answer}
  - currentQuestionIndex, isPaused
  - elapsedTime, remainingTime
  - totalAnswered
- **Dùng để:** Lưu trạng thái khi user đang làm bài
- **Size:** 61 dòng

---

### DATA LAYER - Data Sources & Services (2 files)

#### 4. `toeic_sample_data.dart`

- ** Đường dẫn:** `lib/data/datasources/toeic_sample_data.dart`
- **Chức năng:** **Data Source** cung cấp dữ liệu bài thi
- **Methods:**
  - `getAllTests()` → Lấy tất cả bài thi
  - `getTest(testId)` → Lấy 1 bài thi
  - `getQuestionsByPart(partNumber)` → Lấy câu hỏi theo part
- **Dùng để:** Cầu nối giữa UI → Firebase
- **Size:** ?

#### 5. `toeic_json_service.dart`

- ** Đường dẫn:** `lib/data/services/toeic_json_service.dart`
- **Chức năng:** **JSON Service** xử lý JSON từ Firebase
- **Methods:**
  - `loadTest(testId)` → Load bài thi từ Firebase
  - `loadQuestionsByPart(testId, partNumber)` → Load câu theo part
  - `_loadQuestionsFromFirebaseStorage()` → Load từ storage
  - `_parseQuestions(questionsData)` → Parse JSON thành objects
- **Dùng để:** Parse JSON từ Firebase Storage thành Dart objects
- **Firebase Path:** `gs://bucket/toeic_data/test_1_2026/questions.json`
- **Size:** 162 dòng

---

### PRESENTATION LAYER - Pages (5 files)

#### 6. `toeic_page.dart`

- ** Đường dẫn:** `lib/presentation/pages/test/toeic_page.dart`
- **Chức năng:** **Trang danh sách bài thi TOEIC**
- **Tính năng:**
  - Hiển thị tất cả bài thi (Test 1, Test 2, ...)
  - Search, filter bài thi
  - Nút "Làm bài" → dẫn tới toeic_detail_page
  - Pull-to-refresh để tải bài thi mới
- **Output:** Danh sách bài thi dạng card
- **Size:** ?

#### 7. `toeic_detail_page.dart`

- ** Đường dẫn:** `lib/presentation/pages/test/toeic_detail_page.dart`
- **Chức năng:** **Trang chi tiết bài thi** - chọn Part
- **Tính năng:**
  - Hiển thị thông tin bài thi chi tiết
  - Cho phép chọn Part (Part 1, 2, 3, 4, 5, 6, 7)
  - Nút "Bắt đầu thi" → toeic_test_taking_page
  - Lựa chọn: Full test hoặc practice mode
- **Output:** Chi tiết bài thi + chọn part
- **Size:** ?

#### 8. `toeic_test_taking_page.dart`

- ** Đường dẫn:** `lib/presentation/pages/test/toeic_test_taking_page.dart`
- **Chức năng:** **Trang làm bài thi** - CHÍNH của hệ thống
- **Tính năng:**
  - Load câu hỏi từ Firebase
  - Hiển thị câu hỏi + audio + hình ảnh + options
  - Cho phép chọn A, B, C, D
  - Đếm ngược thời gian (nếu có giới hạn)
  - Lưới 9 cột hiển thị tất cả câu (ToeicQuizSummaryWidget)
  - Nút Previous/Next để chuyển câu
  - Nút Translate helper
  - Nút Submit Finish → toeic_result_page
  - Auto-play audio cho câu đầu + các câu kế tiếp
  - Xử lý single questions (Part 1,2,5) vs group questions (Part 3,4,6,7)
- **Dùng:** ToeicTestProvider, ToeicQuestionDisplayWidget, ToeicQuizSummaryWidget
- **Size:** 1039 dòng
- **Key Methods:**
  - `_loadTest()` → Load questions từ Firebase
  - `_buildHeader()` → Timer + Finish button
  - `_buildOptions()` → Hiển thị options
  - `_buildNavigationButtons()` → Previous/Next/Translate
  - `_showFinishConfirmation()` → Xác nhận submit

#### 9. `toeic_result_page.dart`

- ** Đường dẫn:** `lib/presentation/pages/test/toeic_result_page.dart`
- **Chức năng:** **Trang kết quả bài thi**
- **Tính năng:**
  - Hiển thị điểm (Listening, Reading, Tổng)
  - Hiển thị số câu đúng/sai/chưa làm
  - Hiển thị score level (Expert, Advanced, ...)
  - Nút "Xem lại" → toeic_review_page
  - Lưu kết quả vào Firestore (TestHistory)
  - Hiển thị chart/stats (optional)
- **Output:** Bảng điểm và kết quả chi tiết
- **Size:** 444 dòng
- **Key Methods:**
  - `_saveTestHistory()` → Lưu vào Firestore
  - `_buildScoreCard()` → Hiển thị điểm

#### 10. `toeic_review_page.dart`

- ** Đường dẫn:** `lib/presentation/pages/test/toeic/toeic_review_page.dart`
- **Chức năng:** **Trang xem lại bài làm**
- **Tính năng:**
  - Hiển thị từng câu hỏi khi xem lại
  - Hiển thị đáp án user + đáp án đúng
  - Màu xanh = câu đúng, màu đỏ = câu sai
  - Phát audio để xem lại
  - Xem giải thích (explanation)
  - Xem transcript audio
  - Nút Previous/Next để xem câu khác
  - Hiển thị hình ảnh từ Firebase
- **Dùng:** SharedAudioPlayerWidget, FirebaseStorageService
- **Size:** 731 dòng
- **Key Methods:**
  - `_buildAudioButton()` → Phát audio
  - `_buildImages()` → Hiển thị hình
  - `_buildTranscript()` → Hiển thị transcript
  - `_buildAnswerSection()` → Hiển thị đáp án + giải thích
  - `_buildOption()` → Hiển thị từng option

---

### PRESENTATION LAYER - Widgets (3 files)

#### 11. `toeic_quiz_summary_widget.dart`

- ** Đường dẫn:** `lib/presentation/widgets/test/toeic_quiz_summary_widget.dart`
- **Chức náng:** **Lưới 9 cột câu hỏi** (ở dưới trang test_taking)
- **Tính năng:**
  - Hiển thị tất cả câu hỏi dạng grid 9 cột
  - Màu xanh (primaryColor) = câu hiện tại
  - Màu xám (disabledColor) = đã trả lời
  - Màu trắng (surface) = chưa trả lời
  - Bấm ô để nhảy đến câu đó ngay
  - Tap các ô → goToQuestion() trong provider
- **Dùng:** ToeicTestProvider
- **Size:** 140 dòng
- **Ví dụ:** 100 câu → 12 dòng × 9 cột

#### 12. `toeic_question_display_widget.dart`

- ** Đường dẫn:** `lib/presentation/widgets/test/toeic_question_display_widget.dart` (không chính xác, phải là `lib/presentation/widgets/toeic/toeic_question_display_widget.dart`)
- **Chức năng:** **Widget hiển thị câu hỏi**
- **Tính năng:**
  - Tự động phân biệt single question vs group question
  - Dùng callback để tương tác với parent
  - Hiển thị audio + hình + câu hỏi + options
  - Hỗ trợ Part 1-7 với logic khác nhau
  - Auto-select hình ảnh khi là group question
- **Callbacks:**
  - `buildOptions()` → Hiển thị A,B,C,D options
  - `buildSimpleOptions()` → Chỉ A,B,C (Part 2)
  - `buildNavigationButtons()` → Previous/Next buttons
  - `buildAudioPlayer()` → Phát audio
  - `buildImageContainer()` → Hiển thị hình
- **Size:** 254 dòng
- **Flow:**
  - Part 1,2,5 → Single question hiển thị
  - Part 3,4,6,7 → Group question hiển thị

#### 13. `shared_audio_player_widget.dart`

- ** Đường dẫn:** `lib/presentation/widgets/toeic/shared_audio_player_widget.dart`
- **Chức năng:** **Widget phát audio chung** (dùng ở test_taking + review)
- **Tính năng:**
  - Play/Pause button
  - Progress bar (0.0 - 1.0)
  - Cập nhật progress mỗi 100ms (từ audioplayers package)
  - Cache Firebase URL
  - Hai chế độ:
    - Provider mode: Dùng ToeicTestProvider
    - Standalone mode: AudioPlayer riêng
  - Xử lý nhiều loại URL:
    - firebase_audio: → Resolve Firebase
    - assets/ → AssetSource
    - http/https → UrlSource
  - Error handling
- **Dùng:** audioplayers package (v6.0.0)
- **Size:** 304 dòng
- **Logic Progress Bar:**
  - value = audioPosition / totalDuration
  - onPositionChanged event mỗi 100ms
  - LinearProgressIndicator render lại
  - Màu xám (nền) → chưa phát
  - Màu xanh (tiến độ) → đã phát

---

### STATE MANAGEMENT - Provider (1 file)

#### 14. `toeic_test_provider.dart`

- ** Đường dẫn:** `lib/presentation/providers/toeic_test_provider.dart`
- **Chức năng:** **Provider/State Manager** quản lý toàn bộ phiên thi
- **State:**
  - `_session` → ToeicTestSession hiện tại
  - `_questions` → List<ToeicQuestion>
  - `_audioPlayer` → AudioPlayer instance
  - `_isAudioPlaying` → Trạng thái phát
  - `_audioDuration` → Tổng thời gian audio
  - `_audioPosition` → Vị trí hiện tại
  - `_timer` → Timer countdown
- **Methods:**
  - `startTest()` → Khởi động bài thi + auto-play Q1
  - `selectAnswer(questionNumber, answer)` → Lưu đáp án
  - `nextQuestion()` → Câu tiếp theo + auto-play
  - `previousQuestion()` → Câu trước
  - `goToQuestion(index)` → Nhảy tới câu cụ thể
  - `playAudio(url)` → Phát audio
  - `pauseAudio()` / `resumeAudio()` / `stopAudio()` → Điều khiển audio
  - `finishTestAndGetResults()` → Tính điểm
  - `finishTest()` → Kết thúc bài thi
  - `_startTimer()` → Bắt đầu đếm ngược
  - `_initAudioPlayer()` → Khởi tạo audio player
- **Events nghe từ AudioPlayer:**
  - `onDurationChanged` → Cập nhật tổng thời gian
  - `onPositionChanged` → Cập nhật vị trí (100ms/lần)
  - `onPlayerStateChanged` → Cập nhật trạng thái play/pause
  - `onPlayerComplete` → Audio phát xong
- **Size:** 375 dòng

---

### UTILITIES (1 file)

#### 15. `toeic_score_calculator.dart`

- ** Đường dẫn:** `lib/core/utils/toeic_score_calculator.dart`
- **Chức năng:** **Tính điểm TOEIC** theo công thức chuẩn
- **Methods:**
  - `calculateListeningScore(correct, total)` → Listening 5-495
    - 97/100 = 495 (max)
    - Công thức: 5 + (correct/97) × 490
  - `calculateReadingScore(correct, total)` → Reading 5-495
    - 100/100 = 495 (max)
    - Công thức: 5 + (correct/100) × 490
  - `calculateTotalScore(listeningScore, readingScore)` → Tổng 10-990
  - `getScoreLevel(totalScore)` → String level
    - ≥860 → "Expert"
    - ≥730 → "Advanced"
    - ≥470 → "Intermediate"
    - ≥220 → "Elementary"
    - <220 → "Beginner"
  - `getScoreColor(totalScore)` → Màu hex
- **Size:** 67 dòng
- **Logic:**
  - 197/200 correct (97L + 100R) = 990 ✅
  - 0/200 correct = 10 (5+5)

---

## Complete Flow - Quy trình hoàn chỉnh

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TOEIC TEST FLOW                              │
└─────────────────────────────────────────────────────────────────────┘

STEP 1: TỰA CHỌN BÀI THI
┌──────────────────────────────────────────────────┐
│ toeic_page.dart                                  │
│ - Hiển thị danh sách bài thi                     │
│ - Load từ Firebase via FirebaseStorageService    │
│ - User bấy chọn 1 bài thi                        │
└──────────────────────────────────────────────────┘
                     ↓ (Bấm "Làm bài")

STEP 2: CHỈ ĐỊNH PART & CHẾ ĐỘ
┌──────────────────────────────────────────────────┐
│ toeic_detail_page.dart                           │
│ - Hiển thị thông tin bài thi chi tiết            │
│ - User chọn Part (1,2,3,4,5,6,7)               │
│ - User chọn Full test hay Practice mode          │
│ - Lựa chọn time limit (nếu muốn)               │
└──────────────────────────────────────────────────┘
                     ↓ (Bấm "Bắt đầu thi")

STEP 3: LOAD QUESTIONS & INIT SESSION
┌──────────────────────────────────────────────────┐
│ toeic_test_taking_page._loadTest()              │
│                                                  │
│ 1. Gọi ToeicSampleData.getQuestionsByPart()    │
│    ↓                                             │
│ 2. ToeicJsonService.loadTest()                 │
│    ↓                                             │
│ 3. FirebaseStorageService.loadJsonData()       │
│    ├→ Get URL: toeic_data/test_1_2026/q.json  │
│    ├→ Download JSON từ Firebase                │
│    └→ Parse thành ToeicQuestion objects        │
│    ↓                                             │
│ 4. Trả về List<ToeicQuestion>                  │
│    ↓                                             │
│ 5. ToeicTestProvider.startTest()               │
│    ├→ Tạo ToeicTestSession mới                │
│    ├→ Init AudioPlayer                        │
│    ├→ Bắt đầu Timer (nếu có time limit)      │
│    └→ Auto-play audio câu đầu tiên ⭐         │
│                                                  │
│ Result: Session sẵn sàng, Q1 displayed         │
└──────────────────────────────────────────────────┘
                     ↓

STEP 4: DISPLAY QUESTION
┌──────────────────────────────────────────────────┐
│ toeic_test_taking_page.build()                  │
│                                                  │
│ ┌──────────────────────────────────────┐        │
│ │ Header (Time, Finish Button)        │ ← Timer│
│ ├──────────────────────────────────────┤        │
│ │ ToeicQuestionDisplayWidget           │        │
│ │ ├─ Audio: SharedAudioPlayerWidget   │ ← Play │
│ │ ├─ Image (nếu có)                  │        │
│ │ ├─ Question Text                   │        │
│ │ └─ Options (A,B,C,D)               │        │
│ ├──────────────────────────────────────┤        │
│ │ Navigation Buttons                  │ ← Prev │
│ │ [Translate] [<] [>]                │   Next  │
│ ├──────────────────────────────────────┤        │
│ │ ToeicQuizSummaryWidget (Grid 9 col) │ ← Tap  │
│ │ [1][2][3][4][5][6][7][8][9]       │   jump  │
│ │ [10]...                            │   to Q  │
│ └──────────────────────────────────────┘        │
│                                                  │
│ Audio auto-play Q1 ✅                          │
└──────────────────────────────────────────────────┘
                     ↓ (User chọn A,B,C,D)

STEP 5: SELECT ANSWER
┌──────────────────────────────────────────────────┐
│ User bấm option (e.g., "B")                     │
│         ↓                                        │
│ _buildOptions() callback gọi                    │
│         ↓                                        │
│ provider.selectAnswer(Q1, "B")                  │
│         ↓                                        │
│ ToeicTestProvider:                              │
│  - Lưu: userAnswers[1] = "B"                   │
│  - notifyListeners() → UI rebuild              │
│  - CircleAvatar change to primaryColor ✅       │
│                                                  │
│ Result: Câu 1 được lưu là "B"                 │
└──────────────────────────────────────────────────┘
                     ↓ (User bấm Next)

STEP 6: NEXT QUESTION
┌──────────────────────────────────────────────────┐
│ User bấm nút "Next" (hay grid column)           │
│         ↓                                        │
│ provider.nextQuestion()                         │
│         ↓                                        │
│ ToeicTestProvider:                              │
│  - currentIndex++                              │
│  - Auto-play audio Q2 (nếu listening) ⭐      │
│  - notifyListeners()                           │
│         ↓                                        │
│ UI rebuild → Display Q2                        │
│                                                  │
│ Loop back to STEP 4                            │
└──────────────────────────────────────────────────┘
    (Repeat: Q3 → Q4 → ... → Q200)
                     ↓

STEP 7: SUBMIT TEST / FINISH
┌──────────────────────────────────────────────────┐
│ User bấm "Finish" button                        │
│         ↓                                        │
│ Show confirmation dialog:                       │
│ "Bạn có X câu chưa trả lời. OK?"              │
│         ↓                                        │
│ User confirm: "SUBMIT"                         │
│         ↓                                        │
│ provider.finishTestAndGetResults()              │
│         ↓                                        │
│ ToeicTestProvider:                              │
│  - Separate listening (P1-4) vs reading (P5-7)│
│  - Count: correct, wrong, unanswered          │
│  - Call ToeicScoreCalculator:                 │
│    * listeningScore (5-495, need 97/100)     │
│    * readingScore (5-495, need 100/100)      │
│    * totalScore (10-990)                      │
│  - Return result map                          │
│  - stopAudio()                                 │
│         ↓                                        │
│ Result: {                                       │
│   listeningScore: 245                          │
│   readingScore: 230                            │
│   totalScore: 475                              │
│   listeningCorrect: 97                         │
│   readingCorrect: 100                          │
│   ...                                           │
│ }                                               │
└──────────────────────────────────────────────────┘
                     ↓

STEP 8: SHOW RESULTS
┌──────────────────────────────────────────────────┐
│ toeic_result_page.dart                          │
│                                                  │
│ ┌──────────────────────────────────────┐        │
│ │ Kết quả - Test 1                    │        │
│ ├──────────────────────────────────────┤        │
│ │ Listening: 245/495 🎵                │        │
│ │ Reading:   230/495 📖                │        │
│ │ ────────────────────────             │        │
│ │ Tổng: 475/990 (ADVANCED) ✅         │        │
│ │                                      │        │
│ │ Đúng: 95/100 ✓                       │        │
│ │ Sai: 5/100   ✗                       │        │
│ │                                      │        │
│ │ [Xem lại]  [Thoát]  [Lưu]          │        │
│ └──────────────────────────────────────┘        │
│                                                  │
│ Actions:                                        │
│ 1. _saveTestHistory() → Firestore              │
│    Store: userId, testId, score, date, etc.   │
│ 2. Show stats & comparison                     │
└──────────────────────────────────────────────────┘
        ↓ (User bấm "Xem lại")

STEP 9: REVIEW TEST (Optional)
┌──────────────────────────────────────────────────┐
│ toeic_review_page.dart                          │
│                                                  │
│ ┌──────────────────────────────────────┐        │
│ │ Xem lại bài làm - Q1                 │        │
│ ├──────────────────────────────────────┤        │
│ │ Câu 1 - Part 1                       │        │
│ │ 🔊 [Play Audio] ████░░░░░           │        │
│ │ [Hình ảnh]                           │        │
│ │ A. ○ (Câu trả lời A)                │        │
│ │ B. ● (Câu trả lời B) - YOUR ANSWER │ ← Chọn │
│ │ C. ○ (Câu trả lời C)                │ ← Đúng │
│ │ D. ○ (Câu trả lời D)                │        │
│ │                                      │        │
│ │ Giải thích:                          │        │
│ │ The correct answer is C because...  │        │
│ │                                      │        │
│ │ Transcript:                          │        │
│ │ "Example audio transcript..."        │        │
│ ├──────────────────────────────────────┤        │
│ │ [<] Q1/100 [>]                       │        │
│ └──────────────────────────────────────┘        │
│                                                  │
│ Actions:                                        │
│ - Phát lại audio từng câu                      │
│ - Xem giải thích chi tiết                      │
│ - Xem transcript                               │
│ - Điều hướng Previous/Next                     │
└──────────────────────────────────────────────────┘
                     ↓

STEP 10: FINISH
User thoát về toeic_page hoặc home page
Provider.finishTest() → clear session
Session kết thúc ✅

┌─────────────────────────────────────────────────────────────────────┐
│                      END OF FLOW                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Structure

### JSON Structure từ Firebase Storage

```json
{
  "test1": {
    "id": "test1",
    "name": "TOEIC Test 1 - 2026",
    "description": "Full TOEIC test with 200 questions",
    "totalQuestions": 200,
    "listeningQuestions": 100,
    "readingQuestions": 100,
    "duration": 120,
    "createdAt": "2026-01-01T00:00:00Z",
    "updatedAt": "2026-01-27T12:00:00Z",
    "isActive": true,
    "year": 2026,
    "parts": {
      "1": {
        "questions": [
          {
            "id": "q1",
            "testId": "test1",
            "partNumber": 1,
            "questionNumber": 1,
            "questionType": "single",
            "questionText": null,
            "imageUrl": "firebase_image:part1_q1.jpg",
            "imageUrls": null,
            "audioUrl": "firebase_audio:part1_q1.mp3",
            "options": [
              "The woman is carrying a tray of food.",
              "The woman is tying up her hair.",
              "The woman is removing her hat.",
              "The woman is opening a door."
            ],
            "correctAnswer": "A",
            "explanation": "Looking at the image, the woman is clearly holding a tray with food items on it.",
            "transcript": "Image shows a woman holding a tray of food.",
            "order": 1,
            "groupId": null,
            "passageText": null
          }
          // ... more questions
        ]
      },
      "2": { ... },
      "3": { ... },
      // ... parts 4-7
    }
  },
  "test2": { ... },
  // ... more tests
}
```

### ToeicTestSession State

```dart
ToeicTestSession {
  testId: "test1"
  testName: "TOEIC Test 1"
  isFullTest: true
  selectedParts: [1, 2, 3, 4, 5, 6, 7]
  timeLimit: 120 // 2 hours
  startTime: 2026-01-27T14:30:00
  userAnswers: {
    1: "A",
    2: "B",
    3: "C",
    4: "D",
    5: "A",
    // ... up to 200
  }
  currentQuestionIndex: 4 // Showing Q5
  isPaused: false

  // Computed properties
  elapsedTime: Duration(minutes: 15, seconds: 23)
  remainingTime: Duration(hours: 1, minutes: 44, seconds: 37)
  totalAnswered: 95 // 95 câu đã trả lời
}
```

### Audio Player Flow

```
Audio URL: "firebase_audio:part1_q1.mp3"
       ↓
SharedAudioPlayerWidget._loadAudioUrl()
       ↓
Check cache: _audioUrlCache["firebase_audio:part1_q1.mp3"]
       ├─ MISS → Resolve Firebase
       │  ↓
       │  FirebaseStorageService.resolveFirebaseUrl()
       │  ↓
       │  "https://firebasestorage.googleapis.com/v0/b/...?alt=media&token=xyz"
       │  ↓
       │  Save to cache: _audioUrlCache["firebase_audio:part1_q1.mp3"] = URL
       │
       └─ HIT → Use cached URL
              ↓
Play UrlSource(cachedUrl)
       ↓
onDurationChanged → totalDuration = 45 seconds
       ↓
onPositionChanged (every 100ms) → currentPosition = 0→45s
       ↓
LinearProgressIndicator value = currentPosition / totalDuration
       ├─ 0s: value = 0/45 = 0.0 (0%)
       ├─ 15s: value = 15/45 = 0.33 (33%)
       ├─ 30s: value = 30/45 = 0.67 (67%)
       └─ 45s: value = 45/45 = 1.0 (100%)
       ↓
UI re-render → Progress bar moves ✅
```

---

## 🎯 Key Statistics

| Metric                   | Value                                    |
| ------------------------ | ---------------------------------------- |
| **Total TOEIC Files**    | 14 files                                 |
| **Largest File**         | toeic_test_taking_page.dart (1039 lines) |
| **Total Lines (approx)** | ~4,000+ lines                            |
| **Firebase Questions**   | 200 per test                             |
| **Total Listening Qs**   | 100 (Part 1-4)                           |
| **Total Reading Qs**     | 100 (Part 5-7)                           |
| **Min Score**            | 10 (5+5)                                 |
| **Max Score**            | 990 (495+495)                            |
| **Listening Threshold**  | 97/100 = 495                             |
| **Reading Threshold**    | 100/100 = 495                            |
| **Question Grid**        | 9 columns                                |

---

## ✅ Important Notes

1. **Audio Auto-play:**
   - Q1 tự phát khi vào bài thi
   - Các Q tiếp theo tự phát khi nhấn Next (Practice mode only)
   - Full test mode không auto-play
   - Chỉ listening questions (Part 1-4) mới auto-play

2. **Question Types:**
   - **Part 1,2,5:** Single questions (mỗi câu độc lập)
   - **Part 3,4,6,7:** Group questions (nhiều câu cùng 1 audio/passage)

3. **Score Calculation:**
   - Listening & Reading tính riêng
   - Áp dụng formula khác nhau (listening cần 97/100, reading cần 100/100)
   - Tổng score = Listening + Reading
   - Min: 10, Max: 990

4. **Firebase Storage:**
   - Bucket: `gs://engoapp-91373.firebasestorage.app`
   - Path: `toeic_data/test_1_2026/questions.json`
   - Cache URL để tránh resolve lại

5. **State Management:**
   - Provider: ToeicTestProvider quản lý toàn bộ state
   - Session: Lưu trạng thái phiên thi
   - Cleanup: finishTest() xoá session + stop audio

---

## 🔗 Related Services

- **FirebaseStorageService:** Lấy JSON từ Firebase Storage
- **FirebaseFirestoreService:** Lưu test history
- **FirebaseAuthService:** Xác thực user
- **AudioPlayers Package:** Phát audio (v6.0.0)

---

## 📝 Last Updated

**Date:** January 27, 2026  
**Updated by:** Development Team  
**Version:** 1.0

---

**End of Document**
