// lib/domain/entities/toeic_question.dart

/// ToeicQuestion Entity - Model đại diện cho MỘT CÂU HỎI TOEIC
///
/// ============================================================
/// MỤC ĐÍCH:
/// - Lưu trữ thông tin của một câu hỏi TOEIC
/// - Được load từ Firebase Storage (toeic_data/test_1_2026/questions.json)
/// - Dùng để display câu hỏi trên UI (test_taking_page, review_page)
/// - Lưu trữ: câu hỏi, audio, hình ảnh, options, đáp án đúng, giải thích
///
/// ============================================================
/// FIELD GIẢI THÍCH:
///
/// - id: String
///   Mã định danh duy nhất của câu hỏi (e.g., "q1", "q2")
///   Fallback: "q${questionNumber}" nếu JSON không có id
///
/// - testId: String
///   Mã của bài thi mà câu hỏi thuộc về (e.g., "test1")
///
/// - partNumber: int
///   Số part của câu hỏi (1-7)
///   Part 1: Photo description (4 options)
///   Part 2: Question-response (3 options)
///   Part 3: Conversation (4 options per question, multiple questions)
///   Part 4: Short talk (4 options per question, multiple questions)
///   Part 5: Incomplete sentence (4 options)
///   Part 6: Text completion (4 options per question, single passage)
///   Part 7: Reading comprehension (4 options per question)
///
/// - questionNumber: int
///   Số thứ tự câu hỏi trong toàn bộ bài thi (1-200)
///   Dùng để lưu user answers: userAnswers[questionNumber] = "A"
///
/// - questionType: String
///   Loại câu hỏi ('single', 'group', 'image', 'multiple-choice')
///   - 'single': Câu hỏi độc lập (Part 1, 2, 5)
///   - 'group': Nhóm câu hỏi cùng 1 audio/passage (Part 3, 4, 6, 7)
///   - 'image': Có hình ảnh đính kèm (Part 1, Part 3)
///
/// - questionText: String? (nullable)
///   Nội dung câu hỏi (e.g., "What is the woman doing?")
///   null cho Part 1 (chỉ có hình)
///
/// - imageUrl: String? (nullable)
///   URL hình ảnh đơn lẻ (firebase_image:part1_q1.jpg)
///   Dùng cho Part 1, một số câu Part 3
///
/// - imageUrls: List<String>? (nullable)
///   Danh sách URL hình ảnh (cho group questions)
///   Dùng khi 1 group có multiple images
///
/// - audioUrl: String? (nullable)
///   URL file audio (firebase_audio:part1_q1.mp3)
///   Dùng cho Part 1-4 (listening)
///   null cho Part 5-7 (reading)
///
/// - options: List<String>
///   Danh sách 4 (hoặc 3) đáp án
///   [0] = A, [1] = B, [2] = C, [3] = D
///   Part 2: Chỉ có 3 options [A, B, C]
///   Part 1,3,4,5,6,7: Có 4 options [A, B, C, D]
///
/// - correctAnswer: String
///   Đáp án đúng ("A", "B", "C", hoặc "D")
///   Dùng để tính điểm: userAnswer == correctAnswer ? correct : wrong
///
/// - explanation: String? (nullable)
///   Giải thích chi tiết câu trả lời
///   Hiển thị khi user xem lại bài làm (toeic_review_page)
///
/// - transcript: String? (nullable)
///   Nội dung lời thoại audio (transcript)
///   Dùng cho Part 1-4 (listening)
///   Hiển thị khi user xem lại bài làm
///
/// - order: int
///   Thứ tự hiển thị câu hỏi trong group
///   Fallback: questionNumber nếu JSON không có order
///   Dùng để sắp xếp khi có group questions
///
/// - groupId: String? (nullable)
///   Mã nhóm câu hỏi (cho Part 3, 4, 6, 7)
///   Ví dụ: Part 3 có 2 nhóm, mỗi nhóm có 3 câu
///   Group 1: "group_3_1" → Q12, Q13, Q14
///   Group 2: "group_3_2" → Q15, Q16, Q17
///   null cho Part 1, 2, 5 (single questions)
///   ToeicQuestionDisplayWidget dùng groupId để phân biệt loại câu
///
/// - passageText: String? (nullable)
///   Nội dung passage (đoạn văn)
///   Dùng cho Part 6, 7 (reading comprehension)
///   null cho Part 1-5
///
/// ============================================================
/// QUESTION TYPE MAPPING:
///
/// Part 1 (Q1-10):     Photo description
///   - single, image
///   - Mỗi câu 1 hình + audio + 4 options
///   - No questionText, no groupId
///
/// Part 2 (Q11-40):    Question-response
///   - single, multiple-choice
///   - Mỗi câu 1 audio (câu hỏi) + 3 options (câu trả lời)
///   - No images, no questionText
///
/// Part 3 (Q41-70):    Conversation
///   - group, image
///   - Mỗi nhóm 1 audio (hội thoại) + 3 câu hỏi
///   - Mỗi câu hỏi có 4 options
///   - groupId: "group_3_1", "group_3_2", ...
///
/// Part 4 (Q71-100):   Short talk
///   - group, multiple-choice
///   - Mỗi nhóm 1 audio (bài nói) + 3 câu hỏi
///   - Mỗi câu hỏi có 4 options
///   - groupId: "group_4_1", "group_4_2", ...
///
/// Part 5 (Q101-130):  Incomplete sentence
///   - single, multiple-choice
///   - Mỗi câu questionText + 4 options
///   - No audio, no images
///
/// Part 6 (Q131-146):  Text completion
///   - group, multiple-choice
///   - Mỗi nhóm 1 passage + 4 câu hỏi
///   - passageText chứa nội dung passage
///   - groupId: "group_6_1", "group_6_2", ...
///
/// Part 7 (Q147-200):  Reading comprehension
///   - group, multiple-choice
///   - Mỗi nhóm 1 passage (dài) + nhiều câu hỏi
///   - passageText chứa nội dung passage
///   - groupId: "group_7_1", "group_7_2", ...
///
/// ============================================================
/// CÁCH SỬ DỤNG:
///
/// 1. Parse từ JSON (Firebase):
///    final json = {...};
///    final question = ToeicQuestion.fromJson(json);
///
/// 2. Hiển thị câu hỏi:
///    if (question.partNumber <= 4) {
///      // Listening: Play audio, show image
///      playAudio(question.audioUrl);
///    } else {
///      // Reading: Show text/passage
///    }
///
/// 3. Kiểm tra loại câu:
///    if (question.groupId != null) {
///      // Group question (Part 3, 4, 6, 7)
///      // Display nhiều câu từ cùng 1 group
///    } else {
///      // Single question (Part 1, 2, 5)
///      // Display câu này độc lập
///    }
///
/// 4. Lưu đáp án:
///    userAnswers[question.questionNumber] = "B";
///
/// 5. Kiểm tra đúng/sai:
///    bool isCorrect = userAnswer == question.correctAnswer;
///
/// 6. Xem lại bài:
///    showExplanation(question.explanation);
///    showTranscript(question.transcript);
///
/// ============================================================
/// EXAMPLE DATA (Part 1):
///
/// {
///   "id": "q1",
///   "testId": "test1",
///   "partNumber": 1,
///   "questionNumber": 1,
///   "questionType": "image",
///   "questionText": null,
///   "imageUrl": "firebase_image:part1_q1.jpg",
///   "imageUrls": null,
///   "audioUrl": "firebase_audio:part1_q1.mp3",
///   "options": [
///     "The woman is carrying a tray of food.",
///     "The woman is tying up her hair.",
///     "The woman is removing her hat.",
///     "The woman is opening a door."
///   ],
///   "correctAnswer": "A",
///   "explanation": "Looking at the image, the woman is clearly holding a tray with food items on it.",
///   "transcript": "Image shows a woman holding a tray of food.",
///   "order": 1,
///   "groupId": null,
///   "passageText": null
/// }
///
/// EXAMPLE DATA (Part 3):
///
/// {
///   "id": "q41",
///   "testId": "test1",
///   "partNumber": 3,
///   "questionNumber": 41,
///   "questionType": "group",
///   "questionText": "What is the conversation about?",
///   "imageUrl": null,
///   "imageUrls": null,
///   "audioUrl": "firebase_audio:part3_group1.mp3",
///   "options": [
///     "A booking confirmation",
///     "A complaint about service",
///     "A hotel recommendation",
///     "A travel plan"
///   ],
///   "correctAnswer": "A",
///   "explanation": "The caller is confirming a hotel booking.",
///   "transcript": "Caller: I'm calling to confirm my booking for tomorrow...",
///   "order": 1,
///   "groupId": "group_3_1",
///   "passageText": null
/// }
///
/// EXAMPLE DATA (Part 7):
///
/// {
///   "id": "q147",
///   "testId": "test1",
///   "partNumber": 7,
///   "questionNumber": 147,
///   "questionType": "group",
///   "questionText": "What is the purpose of this email?",
///   "imageUrl": null,
///   "imageUrls": null,
///   "audioUrl": null,
///   "options": [
///     "To request a refund",
///     "To provide feedback",
///     "To place an order",
///     "To cancel a subscription"
///   ],
///   "correctAnswer": "B",
///   "explanation": "The email sender is providing feedback on their experience.",
///   "transcript": null,
///   "order": 1,
///   "groupId": "group_7_1",
///   "passageText": "Dear Customer Service Team,..."
/// }
///
/// ============================================================

class ToeicQuestion {
  final String id;
  final String testId;
  final int partNumber;
  final int questionNumber;
  final String questionType; // 'single', 'group', 'image'
  final String? questionText;
  final String? imageUrl;
  final List<String>? imageUrls; // For multiple images in a group
  final String? audioUrl;
  final List<String> options; // A, B, C, D
  final String correctAnswer;
  final String? explanation;
  final String? transcript; // Audio transcript
  final int order;

  final String? groupId;
  final String? passageText;

  /// Constructor để tạo ToeicQuestion instance
  ///
  /// Require:
  /// - id: Mã định danh duy nhất
  /// - testId: Mã bài thi
  /// - partNumber: Số part (1-7)
  /// - questionNumber: Số thứ tự câu (1-200)
  /// - questionType: Loại câu ('single', 'group', 'image', 'multiple-choice')
  /// - options: Danh sách 3-4 options
  /// - correctAnswer: Đáp án đúng ("A", "B", "C", "D")
  /// - order: Thứ tự hiển thị
  ///
  /// Optional (nullable):
  /// - questionText: Nội dung câu hỏi (null cho Part 1)
  /// - imageUrl: URL hình ảnh đơn (Part 1, Part 3)
  /// - imageUrls: Danh sách URLs hình ảnh (group images)
  /// - audioUrl: URL file audio (Part 1-4)
  /// - explanation: Giải thích đáp án
  /// - transcript: Transcript audio
  /// - groupId: Mã nhóm câu hỏi (Part 3,4,6,7)
  /// - passageText: Nội dung passage (Part 6, 7)
  const ToeicQuestion({
    required this.id,
    required this.testId,
    required this.partNumber,
    required this.questionNumber,
    required this.questionType,
    this.questionText,
    this.imageUrl,
    this.imageUrls,
    this.audioUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.transcript,
    required this.order,
    this.groupId,
    this.passageText,
  });

  /// Factory method để parse ToeicQuestion từ JSON
  ///
  /// JSON được load từ Firebase Storage: toeic_data/test_1_2026/questions.json
  /// Structure của JSON phải có:
  ///   - id: Mã câu hỏi
  ///   - testId: Mã bài thi
  ///   - partNumber: Số part (1-7)
  ///   - questionNumber: Số thứ tự câu (1-200)
  ///   - questionType: Loại câu
  ///   - options: Danh sách options (3 hoặc 4)
  ///   - correctAnswer: Đáp án đúng
  ///   - order: Thứ tự hiển thị
  ///
  /// Optional fields trong JSON:
  ///   - questionText: Nội dung câu hỏi
  ///   - imageUrl: URL hình ảnh đơn
  ///   - imageUrls: List URLs hình ảnh (group)
  ///   - audioUrl: URL file audio
  ///   - explanation: Giải thích
  ///   - transcript: Transcript audio
  ///   - groupId: Mã nhóm (Part 3,4,6,7)
  ///   - passageText: Nội dung passage (Part 6,7)
  ///
  /// Fallback logic:
  ///   - id: Nếu không có trong JSON → fallback "q${questionNumber}"
  ///   - order: Nếu không có trong JSON → fallback questionNumber
  ///
  /// Ví dụ:
  ///   final json = {
  ///     "id": "q1",
  ///     "testId": "test1",
  ///     "partNumber": 1,
  ///     "questionNumber": 1,
  ///     "questionType": "image",
  ///     "options": ["A", "B", "C", "D"],
  ///     "correctAnswer": "A",
  ///     "order": 1,
  ///     "audioUrl": "firebase_audio:part1_q1.mp3",
  ///     "imageUrl": "firebase_image:part1_q1.jpg"
  ///   };
  ///   final question = ToeicQuestion.fromJson(json);
  factory ToeicQuestion.fromJson(Map<String, dynamic> json) {
    return ToeicQuestion(
      id: json['id'] ?? 'q${json['questionNumber']}',
      testId: json['testId'] ?? 'test1',
      partNumber: json['partNumber'] ?? 1,
      questionNumber: json['questionNumber'] ?? 0,
      questionType: json['questionType'] ?? 'multiple-choice',
      questionText: json['questionText'],
      imageUrl: json['imageUrl'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      audioUrl: json['audioUrl'],
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],
      correctAnswer: json['correctAnswer'] ?? 'A',
      explanation: json['explanation'],
      transcript: json['transcript'],
      order: json['order'] ?? json['questionNumber'] ?? 0,
      groupId: json['groupId'],
      passageText: json['passageText'],
    );
  }
}
