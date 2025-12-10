/*
 * test_provider.dart
 *
 * Chức năng:
 * - Quản lý flow của bài kiểm tra (test): load test metadata, start test, track current question, submit answer, tính điểm, end test, lưu kết quả.
 *
 * Được sử dụng ở đâu:
 * - TestScreen, ResultScreen, ReviewScreen.
 *
 * API (public/state) gợi ý:
 * - Test? currentTest;
 * - int currentIndex;
 * - Map<int, Answer> answers;
 * - TestState state; // idle / running / completed / submitting / error
 * - Future<void> loadTest(String testId);
 * - void startTest();
 * - void selectAnswer(int questionIndex, Answer a);
 * - Future<void> submit();
 * - void reset();
 *
 * Lưu ý kỹ thuật:
 * - Sử dụng timer nếu bài test timed; expose remainingTime và pause/resume logic.
 * - Đảm bảo atomicity khi submit (disable submit button khi đang gửi).
 * - Tách xử lý scoring ra service/utility để dễ test.
 * - Xử lý network failure: giữ local draft để retry nếu cần.
 * - Test: unit test scoring logic, integration test flow start→answer→submit.
 */