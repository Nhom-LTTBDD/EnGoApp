// ToeicTestSession Entity - Quản lý trạng thái của MỘT PHIÊN THI TOEIC
///
/// ============================================================
/// MỤC ĐÍCH:
/// - Lưu trữ thông tin phiên thi đang diễn ra (real-time)
/// - Quản lý trạng thái: câu hỏi hiện tại, đáp án người dùng, thời gian
/// - Hỗ trợ tính năng tạm dừng/tiếp tục bài thi
/// - Theo dõi tiến độ: số câu đã trả lời, thời gian còn lại
/// - Được quản lý bởi ToeicTestProvider (state management)
///
/// ============================================================
/// FIELD GIẢI THÍCH:
///
/// - testId: String Mã định danh của bài thi (e.g., "test1")
///   Dùng để load câu hỏi từ Firebase Storage
///   Firebase path: toeic_data/{testId}/questions.json
///
/// - testName: String
///   Tên bài thi hiển thị trên UI (e.g., "TOEIC Practice Test 1")
///   Dùng cho header trang test-taking
///

///
/// - userAnswers: Map<int, String>
///   Map từ questionNumber → đáp án người dùng
///   Key: questionNumber (1-200)
///   Value: "A", "B", "C", "D"
///   Ví dụ: {1: "A", 2: "C", 5: "B"}
///   Dùng để:
///     - Lưu đáp án khi user click option
///     - Tính điểm (compare với correctAnswer)
///     - Hiển thị kết quả (toeic_result_page)
///     - Xem lại bài (toeic_review_page)
///
/// - currentQuestionIndex: int
///   Index của câu hỏi hiện tại (0-based)
///   currentQuestionIndex = 0 → Câu 1
///   currentQuestionIndex = 9 → Câu 10
///
/// ============================================================
/// COPYITH METHOD:
///
/// Dùng để tạo bản copy với một số field thay đổi (immutable pattern)
/// Tất cả parameters là optional - chỉ thay đổi cái cần
///
/// Ví dụ:
///   // Update đáp án câu 1
///   session = session.copyWith(
///     userAnswers: {...session.userAnswers, 1: "B"}
///   );
///
///   // Chuyển sang câu tiếp theo
///   session = session.copyWith(
///     currentQuestionIndex: session.currentQuestionIndex + 1
///   );
///
///   // Tạm dừng bài thi
///   session = session.copyWith(isPaused: true);
///
/// ============================================================
/// VÒNG ĐỜI SESSION:
///
/// 1. KHỞI TẠO:
///    - User chọn part → selectedParts = [part1, part2, ...]
///    - Load questions từ Firebase
///    - ToeicTestProvider.startTest() tạo ToeicTestSession
///    - startTime = DateTime.now()
///
/// 2. TRONG QUANH TÍNH:
///    - UI hiển thị câu ở currentQuestionIndex
///    - User click option → session.copyWith(userAnswers: {...})
///    - User click next → session.copyWith(currentQuestionIndex: ...)
///    - Timer hiển thị remainingTime (countdown)
///    - Nếu isPaused=true → không thể interact
///
/// 3. KHI HẾT GIỜ HOẶC SUBMIT:
///    - ToeicTestProvider.finishTestAndGetResults()
///    - Calculate scores từ userAnswers
///    - Save session vào Firestore
///    - Navigate tới toeic_result_page
///
/// ============================================================
/// EXAMPLE DATA:
///
/// {
///   testId: "test1",
///   testName: "TOEIC Practice Test 1",
///   isFullTest: true,
///   selectedParts: [1, 2, 3, 4, 5, 6, 7],
///   timeLimit: 120,  // 2 hours
///   startTime: DateTime.now(),
///   userAnswers: {
///     1: "A",
///     2: "C",
///     3: "B",
///     5: "D",
///     // ... 45 more answers
///   },
///   currentQuestionIndex: 47,  // Đang ở câu 48
///   isPaused: false
/// }
///
/// Instance methods:
/// - totalAnswered: 48
/// - elapsedTime: Duration(minutes: 30)
/// - remainingTime: Duration(minutes: 90)  // 120 - 30 = 90
///
/// TÍCH HỢP VỚI TOEICTEST & TOEICQUESTION:
///
/// ToeicTest (định thông tin bài thi - static)
///   ├─ id, name, partCount, questionCount
///   └─ Loaded một lần khi app start
///
/// ToeicTestSession (trạng thái bài thi - dynamic)
///   ├─ testId (link tới ToeicTest)
///   ├─ startTime, userAnswers, currentQuestionIndex
///   └─ Thay đổi liên tục khi user làm bài
///
/// ToeicQuestion (thông tin từng câu - static)
///   ├─ id, partNumber, questionNumber, correctAnswer
///   └─ Loaded từ Firebase dựa trên selectedParts

class ToeicTestSession {
  final String testId;
  final String testName;
  final bool isFullTest;
  final List<int> selectedParts;
  final int? timeLimit; // minutes, null = no limit
  final DateTime startTime;
  final Map<int, String> userAnswers; // questionNumber -> answer
  final int currentQuestionIndex;
  final bool isPaused;

  /// Constructor để tạo ToeicTestSession instance
  /// - userAnswers: Map đáp án người dùng
  ///   - Default: {} (empty, chưa trả lời câu nào)
  ///
  /// - currentQuestionIndex: Index câu hỏi hiện tại (0-based)
  ///   - Default: 0 (câu 1)
  ///   - Range: 0 đến (totalQuestions - 1)
  ///   );
  const ToeicTestSession({
    required this.testId,
    required this.testName,
    required this.isFullTest,
    required this.selectedParts,
    this.timeLimit,
    required this.startTime,
    this.userAnswers = const {},
    this.currentQuestionIndex = 0,
    this.isPaused = false,
  });

  /// CopyWith method - Tạo bản copy của session với một số field thay đổi
  ///
  /// Dùng Immutable Pattern - Không thay đổi object hiện tại, trả về object mới
  /// Tất cả parameters là optional - chỉ thay đổi cái cần thay đổi
  ///
  /// Ví dụ sử dụng:
  ///
  /// 1. Lưu đáp án câu hỏi:
  ///    session = session.copyWith(
  ///      userAnswers: {...session.userAnswers, 1: "B"}
  ///    );
  ///
  /// 2. Chuyển sang câu hỏi tiếp theo:
  ///    session = session.copyWith(
  ///      currentQuestionIndex: session.currentQuestionIndex + 1
  ///    );
  ///
  /// 3. Quay lại câu hỏi trước đó:
  ///    session = session.copyWith(
  ///      currentQuestionIndex: session.currentQuestionIndex - 1
  ///    );
  ///
  /// 6. Cập nhật nhiều field cùng lúc:
  ///    session = session.copyWith(
  ///      userAnswers: {...session.userAnswers, 10: "A"},
  ///      currentQuestionIndex: 10,
  ///    );
  ToeicTestSession copyWith({
    String? testId,
    String? testName,
    bool? isFullTest,
    List<int>? selectedParts,
    int? timeLimit,
    DateTime? startTime,
    Map<int, String>? userAnswers,
    int? currentQuestionIndex,
    bool? isPaused,
  }) {
    return ToeicTestSession(
      testId: testId ?? this.testId,
      testName: testName ?? this.testName,
      isFullTest: isFullTest ?? this.isFullTest,
      selectedParts: selectedParts ?? this.selectedParts,
      timeLimit: timeLimit ?? this.timeLimit,
      startTime: startTime ?? this.startTime,
      userAnswers: userAnswers ?? this.userAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  /// Getter - Tổng số câu đã trả lời
  ///
  /// Trả về: userAnswers.length
  int get totalAnswered => userAnswers.length;

  /// Getter - Thời gian đã sử dụng kể từ khi bắt đầu
  ///
  /// Trả về: Duration = DateTime.now() - startTime
  /// Dùng để:
  /// - Tính remainingTime
  /// - Lưu thông tin session vào Firestore
  /// - Hiển thị thời gian đã dùng (nếu cần)
  ///
  /// Ví dụ:
  ///   final session = ToeicTestSession(startTime: DateTime.now());
  ///   // ... sau 30 phút
  ///   final elapsed = session.elapsedTime;
  ///   print(elapsed.inMinutes);  // Output: 30
  Duration get elapsedTime => DateTime.now().difference(startTime);

  /// Getter - Thời gian còn lại cho bài thi
  ///
  /// Trả về:
  /// - Duration: Thời gian còn lại nếu có timeLimit
  /// - Duration.zero: Nếu hết giờ (không âm)
  /// - null: Nếu không giới hạn thời gian (timeLimit = null)
  ///
  /// Logic:
  ///   if timeLimit == null
  ///     → return null (không giới hạn)
  ///   else
  ///     remaining = Duration(minutes: timeLimit) - elapsedTime
  ///     return max(remaining, Duration.zero)  // Không âm
  ///
  /// Dùng để:
  /// - Hiển thị countdown timer trên UI
  /// - Auto-submit bài thi khi remainingTime = 0
  /// - Cảnh báo user khi thời gian sắp hết
  Duration? get remainingTime {
    if (timeLimit == null) return null;
    final limit = Duration(minutes: timeLimit!);
    final remaining = limit - elapsedTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
