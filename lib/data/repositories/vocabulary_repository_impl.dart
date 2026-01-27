// lib/data/repositories/vocabulary_repository_impl.dart

import '../../domain/entities/vocabulary_card.dart';
import '../../domain/entities/vocabulary_topic.dart';
import '../../domain/repository_interfaces/vocabulary_repository.dart';
import '../models/vocabulary_card_model.dart';

/// Implementation của VocabularyRepository với in-memory data.
///
/// **Data Source:** Hard-coded vocabulary cards và topics
/// **Note:** Đây là mock implementation. Trong production nên dùng Firestore.
class VocabularyRepositoryImpl implements VocabularyRepository {// ========== FOOD & DRINKS - Đồ ăn & Đồ uống ==========
  static final List<VocabularyCardModel> _foodCards = [
    // NOUNS
    VocabularyCardModel(
      id: 'food_1',
      vietnamese: 'Táo',
      english: 'Apple',
      meaning: 'Quả táo, trái táo',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/apple--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'food_2',
      vietnamese: 'Bánh mì',
      english: 'Bread',
      meaning: 'Bánh mì',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/bread--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'food_3',
      vietnamese: 'Sô cô la',
      english: 'Chocolate',
      meaning: 'Sô cô la, kẹo sô cô la',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/chocolate--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'food_4',
      vietnamese: 'Cà phê',
      english: 'Coffee',
      meaning: 'Cà phê',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/coffee--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'food_5',
      vietnamese: 'Trứng',
      english: 'Egg',
      meaning: 'Quả trứng',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/egg--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'food_6',
      vietnamese: 'Cá',
      english: 'Fish',
      meaning: 'Cá, thịt cá',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/fish--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'food_7',
      vietnamese: 'Sữa',
      english: 'Milk',
      meaning: 'Sữa',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/milk--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'food_8',
      vietnamese: 'Nước',
      english: 'Water',
      meaning: 'Nước',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/water--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
  ];
  // ========== BUSINESS & ECONOMICS - Kinh tế & Kinh doanh ==========
  static final List<VocabularyCardModel> _businessCards = [
    // NOUNS
    VocabularyCardModel(
      id: 'business_1',
      vietnamese: 'Kinh doanh',
      english: 'Business',
      meaning: 'Kinh doanh, việc buôn bán',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/business--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'business_2',
      vietnamese: 'Công ty',
      english: 'Company',
      meaning: 'Công ty, doanh nghiệp',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/company--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'business_3',
      vietnamese: 'Kinh tế',
      english: 'Economy',
      meaning: 'Nền kinh tế',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/economy--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'business_4',
      vietnamese: 'Thị trường',
      english: 'Market',
      meaning: 'Thị trường, chợ',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/market--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'business_5',
      vietnamese: 'Tiền',
      english: 'Money',
      meaning: 'Tiền, tiền bạc',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/money--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'business_6',
      vietnamese: 'Giá cả',
      english: 'Price',
      meaning: 'Giá, giá cả',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/price--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'business_7',
      vietnamese: 'Lợi nhuận',
      english: 'Profit',
      meaning: 'Lợi nhuận, tiền lời',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/profit--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    // VERBS
    VocabularyCardModel(
      id: 'business_8',
      vietnamese: 'Bán',
      english: 'Sell',
      meaning: 'Bán, buôn bán',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/sell--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['verb'],
    ),
  ];
  // ========== TECHNOLOGY - Công nghệ ==========
  static final List<VocabularyCardModel> _technologyCards = [
    // NOUNS
    VocabularyCardModel(
      id: 'tech_1',
      vietnamese: 'Máy tính',
      english: 'Computer',
      meaning: 'Máy vi tính, máy tính',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/computer--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'tech_2',
      vietnamese: 'Internet',
      english: 'Internet',
      meaning: 'Mạng internet, mạng toàn cầu',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/internet--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'tech_3',
      vietnamese: 'Điện thoại',
      english: 'Phone',
      meaning: 'Điện thoại',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/phone--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'tech_4',
      vietnamese: 'Phần mềm',
      english: 'Software',
      meaning: 'Phần mềm máy tính',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/software--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'tech_5',
      vietnamese: 'Công nghệ',
      english: 'Technology',
      meaning: 'Công nghệ, kỹ thuật',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/technology--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'tech_6',
      vietnamese: 'Trang web',
      english: 'Website',
      meaning: 'Trang web, website',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/website--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'tech_7',
      vietnamese: 'Dữ liệu',
      english: 'Data',
      meaning: 'Dữ liệu, thông tin',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/data--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'tech_8',
      vietnamese: 'Mạng',
      english: 'Network',
      meaning: 'Mạng, mạng lưới',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/network--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
  ];
  // ========== TRAVEL - Du lịch ==========
  static final List<VocabularyCardModel> _travelCards = [
    // NOUNS
    VocabularyCardModel(
      id: 'travel_1',
      vietnamese: 'Sân bay',
      english: 'Airport',
      meaning: 'Sân bay, phi trường',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/airport--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'travel_2',
      vietnamese: 'Khách sạn',
      english: 'Hotel',
      meaning: 'Khách sạn',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/hotel--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'travel_3',
      vietnamese: 'Hộ chiếu',
      english: 'Passport',
      meaning: 'Hộ chiếu',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/passport--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'travel_4',
      vietnamese: 'Chuyến bay',
      english: 'Flight',
      meaning: 'Chuyến bay',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/flight--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'travel_5',
      vietnamese: 'Hành lý',
      english: 'Luggage',
      meaning: 'Hành lý, va li',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/luggage--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'travel_6',
      vietnamese: 'Du khách',
      english: 'Tourist',
      meaning: 'Du khách, khách du lịch',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/tourist--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'travel_7',
      vietnamese: 'Bản đồ',
      english: 'Map',
      meaning: 'Bản đồ',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/map--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    // VERBS
    VocabularyCardModel(
      id: 'travel_8',
      vietnamese: 'Du lịch',
      english: 'Travel',
      meaning: 'Du lịch, đi du lịch',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/travel--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['verb'],
    ),
  ];
  // ========== HEALTH - Sức khỏe ==========
  static final List<VocabularyCardModel> _healthCards = [
    // NOUNS
    VocabularyCardModel(
      id: 'health_1',
      vietnamese: 'Bác sĩ',
      english: 'Doctor',
      meaning: 'Bác sĩ, thầy thuốc',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/doctor--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'health_2',
      vietnamese: 'Bệnh viện',
      english: 'Hospital',
      meaning: 'Bệnh viện',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/hospital--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'health_3',
      vietnamese: 'Sức khỏe',
      english: 'Health',
      meaning: 'Sức khỏe, tình trạng sức khỏe',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/health--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'health_4',
      vietnamese: 'Thuốc',
      english: 'Medicine',
      meaning: 'Thuốc, y học',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/medicine--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'health_5',
      vietnamese: 'Bệnh tật',
      english: 'Disease',
      meaning: 'Bệnh, bệnh tật',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/disease--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'health_6',
      vietnamese: 'Dinh dưỡng',
      english: 'Nutrition',
      meaning: 'Dinh dưỡng, chất dinh dưỡng',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/nutrition--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'health_7',
      vietnamese: 'Điều trị',
      english: 'Treatment',
      meaning: 'Điều trị, sự chữa trị',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/treatment--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    // VERBS
    VocabularyCardModel(
      id: 'health_8',
      vietnamese: 'Tập thể dục',
      english: 'Exercise',
      meaning: 'Tập thể dục, luyện tập',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/exercise--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['verb'],
    ),
  ];
  // ========== EDUCATION - Giáo dục ==========
  static final List<VocabularyCardModel> _educationCards = [
    // NOUNS
    VocabularyCardModel(
      id: 'edu_1',
      vietnamese: 'Giáo dục',
      english: 'Education',
      meaning: 'Giáo dục, sự giáo dục',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/education--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'edu_2',
      vietnamese: 'Học sinh',
      english: 'Student',
      meaning: 'Học sinh, sinh viên',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/student--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'edu_3',
      vietnamese: 'Giáo viên',
      english: 'Teacher',
      meaning: 'Giáo viên, thầy cô',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/teacher--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'edu_4',
      vietnamese: 'Trường học',
      english: 'School',
      meaning: 'Trường học, nhà trường',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/school--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'edu_5',
      vietnamese: 'Kiến thức',
      english: 'Knowledge',
      meaning: 'Kiến thức, hiểu biết',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/knowledge--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'edu_6',
      vietnamese: 'Sách',
      english: 'Book',
      meaning: 'Sách, quyển sách',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/book--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'edu_7',
      vietnamese: 'Bài học',
      english: 'Lesson',
      meaning: 'Bài học, bài giảng',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/lesson--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    // VERBS
    VocabularyCardModel(
      id: 'edu_8',
      vietnamese: 'Học tập',
      english: 'Study',
      meaning: 'Học tập, nghiên cứu',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/study--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['verb'],
    ),
  ];
  // ========== NATURE & ENVIRONMENT - Thiên nhiên & Môi trường ==========
  static final List<VocabularyCardModel> _natureCards = [
    // NOUNS
    VocabularyCardModel(
      id: 'nature_1',
      vietnamese: 'Thiên nhiên',
      english: 'Nature',
      meaning: 'Thiên nhiên, tự nhiên',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/nature--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'nature_2',
      vietnamese: 'Môi trường',
      english: 'Environment',
      meaning: 'Môi trường',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/environment--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'nature_3',
      vietnamese: 'Cây',
      english: 'Tree',
      meaning: 'Cây, cây cối',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/tree--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'nature_4',
      vietnamese: 'Hoa',
      english: 'Flower',
      meaning: 'Hoa, bông hoa',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/flower--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'nature_5',
      vietnamese: 'Rừng',
      english: 'Forest',
      meaning: 'Rừng, khu rừng',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/forest--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'nature_6',
      vietnamese: 'Biển',
      english: 'Ocean',
      meaning: 'Đại dương, biển',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/ocean--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'nature_7',
      vietnamese: 'Núi',
      english: 'Mountain',
      meaning: 'Núi, dãy núi',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/mountain--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
    VocabularyCardModel(
      id: 'nature_8',
      vietnamese: 'Sông',
      english: 'River',
      meaning: 'Sông, dòng sông',
      audioUrl: '//ssl.gstatic.com/dictionary/static/sounds/20200429/river--_gb_1.mp3',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      partsOfSpeech: ['noun'],
    ),
  ];

  // Map of topics
  static final Map<String, List<VocabularyCardModel>> _topicCardsMap = {
    'food': _foodCards,
    'business': _businessCards,
    'technology': _technologyCards,
    'travel': _travelCards,
    'health': _healthCards,
    'education': _educationCards,
    'nature': _natureCards,  };  
  
  /// Lấy danh sách tất cả các vocabulary topics (7 topics)
  /// Trả về: List chứa 7 topics với dữ liệu hardcoded
  /// Topics bao gồm: food, business, technology, travel, health, education, nature
  /// Mỗi topic có: metadata (name, description, imageUrl) và list cards
  /// Image URLs được lưu trên Firebase Storage
  @override
  Future<List<VocabularyTopic>> getVocabularyTopics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return all topics with Firebase Storage URLs
    return [
      VocabularyTopic(
        id: 'food',
        name: ' Food & Drinks',
        description: 'Học từ vựng về đồ ăn và đồ uống hàng ngày',
        cards: _foodCards,
        imageUrl: 'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/food.png',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      VocabularyTopic(
        id: 'business',
        name: ' Business & Economics',
        description: 'Từ vựng về kinh doanh, kinh tế và tài chính',
        cards: _businessCards,
        imageUrl: 'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/business.png',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
        updatedAt: DateTime.now(),
      ),
      VocabularyTopic(
        id: 'technology',
        name: ' Technology',
        description: 'Từ vựng về công nghệ thông tin và công nghệ hiện đại',
        cards: _technologyCards,
        imageUrl: 'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/technology.png',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 26)),
        updatedAt: DateTime.now(),
      ),
      VocabularyTopic(
        id: 'travel',
        name: ' Travel',
        description: 'Từ vựng thiết yếu cho du lịch và khám phá',
        cards: _travelCards,
        imageUrl: 'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/travel.png',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 24)),
        updatedAt: DateTime.now(),
      ),
      VocabularyTopic(
        id: 'health',
        name: ' Health',
        description: 'Từ vựng về sức khỏe, y tế và chăm sóc bản thân',
        cards: _healthCards,
        imageUrl: 'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/health.png',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
        updatedAt: DateTime.now(),
      ),
      VocabularyTopic(
        id: 'education',
        name: ' Education',
        description: 'Từ vựng về giáo dục, học tập và tri thức',
        cards: _educationCards,
        imageUrl: 'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/education.png',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      VocabularyTopic(
        id: 'nature',
        name: ' Nature & Environment',
        description: 'Từ vựng về thiên nhiên và môi trường xung quanh',
        cards: _natureCards,
        imageUrl: 'https://storage.googleapis.com/engoapp-91373.firebasestorage.app/topic_images/nature.png',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now(),
      ),    ];
  }

  /// Lấy một vocabulary topic theo ID
  /// Tham số: topicId - ID của topic cần tìm (vd: 'food', 'business')
  /// Trả về: VocabularyTopic nếu tìm thấy, null nếu không tồn tại
  /// Sử dụng firstWhere để tìm topic trong list, catch exception nếu không tìm thấy
  @override
  Future<VocabularyTopic?> getVocabularyTopicById(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final topics = await getVocabularyTopics();
    try {
      return topics.firstWhere((topic) => topic.id == topicId);
    } catch (e) {
      return null;    }
  }

  /// Lấy danh sách vocabulary cards của một topic cụ thể
  /// Tham số: topicId - ID của topic (vd: 'food', 'business')
  /// Trả về: List<VocabularyCard> chứa các cards của topic đó
  /// Nếu topicId không tồn tại, trả về list rỗng
  /// Cards đã được enriched với audio URLs từ Google Dictionary API
  @override
  Future<List<VocabularyCard>> getVocabularyCards(String topicId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return cards for specific topic    
    return _topicCardsMap[topicId] ?? [];
  }  
  
  /// Tìm một vocabulary card theo ID trong tất cả các topics
  /// Tham số: cardId - ID của card cần tìm (vd: 'food_1', 'business_5')
  /// Trả về: VocabularyCard nếu tìm thấy, null nếu không tồn tại
  /// Tìm kiếm tuần tự qua tất cả topics cho đến khi tìm thấy card matching
  /// Có logging để debug quá trình tìm kiếm
  @override
  Future<VocabularyCard?> getVocabularyCardById(String cardId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    print('🔍 [REPOSITORY] Searching for cardId: $cardId');
    print('🔍 [REPOSITORY] Available topics: ${_topicCardsMap.keys.join(", ")}');

    // Search across all topics
    var topicIndex = 0;
    for (var entry in _topicCardsMap.entries) {
      topicIndex++;
      final topicName = entry.key;
      final cards = entry.value;
      
      print('🔍 [REPOSITORY] Searching in topic $topicIndex: $topicName (${cards.length} cards)');
      
      for (var card in cards) {
        if (card.id == cardId) {
          print('✅ [REPOSITORY] FOUND! Card: ${card.english} in topic: $topicName');
          return card;
        }
      }
      
      print('❌ [REPOSITORY] Not found in topic: $topicName');
    }
    
    print('❌ [REPOSITORY] Card NOT FOUND in any topic: $cardId');    return null;
  }

  /// Tạo mới một vocabulary topic
  /// Tham số: topic - VocabularyTopic object cần tạo
  /// Chức năng: Lưu topic vào database (hiện tại chỉ là placeholder)
  /// TODO: Implement logic lưu vào Firestore khi cần thêm custom topics
  @override
  Future<void> createVocabularyTopic(VocabularyTopic topic) async {
    await Future.delayed(const Duration(milliseconds: 800));    // Implement create logic
  }

  /// Cập nhật thông tin của một topic đã tồn tại
  /// Tham số: topic - VocabularyTopic object với dữ liệu mới
  /// Chức năng: Update metadata topic (name, description, imageUrl)
  /// TODO: Implement logic update Firestore document
  @override
  Future<void> updateVocabularyTopic(VocabularyTopic topic) async {
    await Future.delayed(const Duration(milliseconds: 600));    // Implement update logic
  }

  /// Xóa một vocabulary topic
  /// Tham số: topicId - ID của topic cần xóa
  /// Chức năng: Xóa topic và tất cả cards bên trong
  /// Cảnh báo: Thao tác này không thể hoàn tác
  /// TODO: Implement cascade delete cho Firestore
  @override
  Future<void> deleteVocabularyTopic(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 400));    // Implement delete logic
  }

  /// Tạo mới một vocabulary card trong một topic
  /// Tham số: 
  ///   - topicId: ID của topic chứa card
  ///   - card: VocabularyCard object cần tạo
  /// Chức năng: Thêm card mới vào subcollection cards của topic
  /// TODO: Implement logic thêm vào Firestore subcollection
  @override
  Future<void> createVocabularyCard(String topicId, VocabularyCard card) async {
    await Future.delayed(const Duration(milliseconds: 600));    // Implement create card logic
  }

  /// Cập nhật thông tin của một vocabulary card
  /// Tham số: card - VocabularyCard object với dữ liệu mới
  /// Chức năng: Update các trường của card (vietnamese, english, meaning, etc.)
  /// TODO: Implement logic update Firestore document
  @override
  Future<void> updateVocabularyCard(VocabularyCard card) async {
    await Future.delayed(const Duration(milliseconds: 500));    // Implement update card logic
  }

  /// Xóa một vocabulary card
  /// Tham số: cardId - ID của card cần xóa
  /// Chức năng: Xóa card khỏi Firestore
  /// Cảnh báo: Không xóa card khỏi personal vocabulary của users
  /// TODO: Implement logic xóa Firestore document
  @override
  Future<void> deleteVocabularyCard(String cardId) async {
    await Future.delayed(const Duration(milliseconds: 400));    // Implement delete card logic
  }
  
  /// Tìm kiếm vocabulary cards theo từ khóa
  /// Tham số: query - Chuỗi tìm kiếm (tiếng Việt hoặc tiếng Anh)
  /// Trả về: List<VocabularyCard> chứa các cards khớp với từ khóa
  /// Tìm kiếm trong: vietnamese, english, meaning fields
  /// Không phân biệt hoa thường (case-insensitive)
  /// Tìm kiếm across tất cả topics
  @override
  Future<List<VocabularyCard>> searchVocabularyCards(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Search across all topics
    final allCards = <VocabularyCard>[];
    for (var cards in _topicCardsMap.values) {
      allCards.addAll(cards);
    }

    // Simple search implementation
    return allCards
        .where(
          (card) =>
              card.vietnamese.toLowerCase().contains(query.toLowerCase()) ||
              card.english.toLowerCase().contains(query.toLowerCase()) ||
              card.meaning.toLowerCase().contains(query.toLowerCase()),
        )        .toList();
  }

  /// Tìm kiếm vocabulary topics theo từ khóa
  /// Tham số: query - Chuỗi tìm kiếm (tên hoặc mô tả topic)
  /// Trả về: List<VocabularyTopic> chứa các topics khớp với từ khóa
  /// Tìm kiếm trong: name, description fields
  /// Không phân biệt hoa thường (case-insensitive)
  @override
  Future<List<VocabularyTopic>> searchVocabularyTopics(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final topics = await getVocabularyTopics();
    
    // Search by topic name or description
    return topics
        .where(
          (topic) =>
              topic.name.toLowerCase().contains(query.toLowerCase()) ||
              topic.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
