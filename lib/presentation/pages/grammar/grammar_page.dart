// lib/presentation/pages/grammar/grammar_page.dart
import 'package:flutter/material.dart';
import '../../layout/main_layout.dart';
import '../../../core/constants/app_colors.dart';

class GrammarPage extends StatelessWidget {
  const GrammarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'GRAMMAR',
      currentIndex: -1,
      child: Container(
        color: kBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildGrammarTopics(context),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildGrammarTopics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopicSection(context, 'Basic Grammar', [
          GrammarTopic('Parts of Speech', 'Nouns, Verbs, Adjectives, Adverbs, etc.'),
          GrammarTopic('Sentence Structure', 'Subject + Verb + Object'),
          GrammarTopic('Articles', 'Using a, an, the correctly'),
          GrammarTopic('Pronouns', 'I, you, he, she, it, we, they'),
        ]),
        
        _buildTopicSection(context, 'Tenses', [
          GrammarTopic('Present Simple', 'I work, He works'),
          GrammarTopic('Present Continuous', 'I am working'),
          GrammarTopic('Past Simple', 'I worked'),
          GrammarTopic('Past Continuous', 'I was working'),
          GrammarTopic('Present Perfect', 'I have worked'),
          GrammarTopic('Future Simple', 'I will work'),
        ]),
        
        _buildTopicSection(context, 'Advanced Topics', [
          GrammarTopic('Modal Verbs', 'can, could, must, should, would'),
          GrammarTopic('Conditional Sentences', 'If clauses and results'),
          GrammarTopic('Passive Voice', 'The book was written by...'),
          GrammarTopic('Reported Speech', 'He said that...'),
        ]),
        
        _buildTopicSection(context, 'Common Mistakes', [
          GrammarTopic('Subject-Verb Agreement', 'Singular and plural forms'),
          GrammarTopic('Prepositions', 'in, on, at, by, for, with'),
          GrammarTopic('Word Order', 'Correct sentence arrangement'),
          GrammarTopic('Countable vs Uncountable', 'many vs much, few vs little'),
        ]),
      ],
    );
  }

  Widget _buildTopicSection(BuildContext context, String title, List<GrammarTopic> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...topics.map((topic) => _buildTopicCard(context, topic)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTopicCard(BuildContext context, GrammarTopic topic) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topic.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showTopicDetail(context, topic),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTopicDetail(BuildContext context, GrammarTopic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(topic.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(topic.description),
              const SizedBox(height: 16),
              Text(
                _getDetailedExplanation(topic.title),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  String _getDetailedExplanation(String title) {
    switch (title) {
      // BASIC GRAMMAR TOPICS
      case 'Parts of Speech':
        return '''Parts of Speech (Các từ loại):

1. NOUN (Danh từ):
• Người: teacher, student, doctor
• Vật: book, car, computer
• Địa điểm: school, hospital, park
• Ý tưởng: love, happiness, freedom

2. VERB (Động từ):
• Hành động: run, eat, write, study
• Trạng thái: be, have, seem, appear

3. ADJECTIVE (Tính từ):
• Mô tả danh từ: big, beautiful, smart, red
• Vị trí: before noun hoặc after linking verb

4. ADVERB (Trạng từ):
• Mô tả động từ: quickly, carefully, well
• Mô tả tính từ: very beautiful, quite good
• Kết thúc bằng -ly: slowly, happily

5. PRONOUN (Đại từ):
• Personal: I, you, he, she, it, we, they
• Possessive: my, your, his, her, our, their

6. PREPOSITION (Giới từ):
• Vị trí: in, on, at, under, above
• Thời gian: before, after, during, since

7. CONJUNCTION (Liên từ):
• And, but, or, so, because, although

8. INTERJECTION (Thán từ):
• Oh! Wow! Oops! Ah!''';

      case 'Sentence Structure':
        return '''Sentence Structure (Cấu trúc câu):

CẤU TRÚC CƠ BẢN:
S + V + O (Subject + Verb + Object)
• I (S) read (V) books (O)
• She (S) loves (V) music (O)

CÁC THÀNH PHẦN KHÁC:
1. SUBJECT (Chủ ngữ):
• Là ai hoặc cái gì thực hiện hành động
• I, You, The teacher, My friend

2. VERB (Động từ):
• Diễn tả hành động hoặc trạng thái
• Action verbs: eat, run, study
• Linking verbs: am, is, are, seem

3. OBJECT (Tân ngữ):
• Direct Object: nhận trực tiếp hành động
• Indirect Object: người nhận lợi ích

VÍ DỤ PHỨC TẠP:
• I (S) gave (V) my sister (IO) a book (DO)
• The teacher (S) is (V) very kind (Complement)
• We (S) study (V) English (O) at school (Adverbial)

THỨ TỰ TỪ:
Subject + Verb + Object + Place + Time
• I study English at home every evening''';

      case 'Articles':
        return '''Articles (Mạo từ):

A / AN (Mạo từ không xác định):
1. Dùng "A" trước:
• Phụ âm: a book, a car, a university
• Âm /ju/: a European, a one-way ticket

2. Dùng "AN" trước:
• Nguyên âm: an apple, an hour, an umbrella
• Âm câm h: an honest person, an honor

THE (Mạo từ xác định):
1. Dùng khi:
• Đã được nhắc đến: I saw a dog. The dog was big.
• Duy nhất: the sun, the moon, the president
• So sánh nhất: the best, the most beautiful
• Nhạc cụ: play the piano, the guitar

2. Không dùng với:
• Tên riêng: Vietnam, John (trừ: the USA, the UK)
• Danh từ số nhiều chung chung: Dogs are friendly
• Môn học: I study Math and English
• Bữa ăn: have breakfast, lunch, dinner

VÍ DỤ:
• I need a pen. (bất kỳ cái bút nào)
• I need the pen you borrowed. (cái bút cụ thể)
• An elephant is bigger than a mouse.
• The elephant in the zoo is very old.''';

      case 'Pronouns':
        return '''Pronouns (Đại từ):

1. PERSONAL PRONOUNS (Đại từ nhân xưng):
Subject: I, you, he, she, it, we, they
Object: me, you, him, her, it, us, them

VÍ DỤ:
• I love you. / You love me.
• He sees her. / She sees him.
• We help them. / They help us.

2. POSSESSIVE PRONOUNS (Đại từ sở hữu):
Adjectives: my, your, his, her, its, our, their
Pronouns: mine, yours, his, hers, ours, theirs

VÍ DỤ:
• This is my book. / This book is mine.
• That's your car. / That car is yours.
• Our house is big. / The big house is ours.

3. REFLEXIVE PRONOUNS (Đại từ phản thân):
myself, yourself, himself, herself, itself, ourselves, yourselves, themselves

VÍ DỤ:
• I hurt myself. (tôi tự làm tổn thương mình)
• She prepared dinner by herself. (cô ấy tự chuẩn bị bữa tối)
• We enjoyed ourselves. (chúng tôi tự thưởng thức)

4. DEMONSTRATIVE PRONOUNS (Đại từ chỉ định):
this, that, these, those

VÍ DỤ:
• This is my phone. That is yours.
• These are apples. Those are oranges.''';

      // TENSES
      case 'Present Simple':
        return '''Present Simple (Hiện tại đơn):

CÁCH SỬ DỤNG:
1. Thói quen, hành động lặp lại:
• I go to work every day. (Tôi đi làm mỗi ngày)
• She drinks coffee in the morning. (Cô ấy uống cà phê vào buổi sáng)

2. Sự thật hiển nhiên, chân lý:
• The sun rises in the east. (Mặt trời mọc ở phía đông)
• Water boils at 100°C. (Nước sôi ở 100°C)

3. Lịch trình cố định:
• The train leaves at 8 AM. (Tàu khởi hành lúc 8 giờ sáng)
• The meeting starts at 2 PM. (Cuộc họp bắt đầu lúc 2 giờ chiều)

CÂU TRÚC:
• Khẳng định: S + V(s/es) + O
  - I work. / He works.
  - We study. / She studies.

• Phủ định: S + don't/doesn't + V + O
  - I don't work. / He doesn't work.
  - We don't study. / She doesn't study.

• Nghi vấn: Do/Does + S + V + O?
  - Do you work? / Does he work?
  - Do we study? / Does she study?

DẤU HIỆU NHẬN BIẾT:
always, usually, often, sometimes, never, every day/week/month, on Mondays''';

      case 'Present Continuous':
        return '''Present Continuous (Hiện tại tiếp diễn):

CÁCH SỬ DỤNG:
1. Hành động đang xảy ra tại thời điểm nói:
• I am reading a book now. (Tôi đang đọc sách bây giờ)
• She is cooking dinner. (Cô ấy đang nấu bữa tối)

2. Kế hoạch trong tương lai gần:
• We are meeting tomorrow. (Chúng ta sẽ gặp nhau ngày mai)
• I am flying to Vietnam next week. (Tôi sẽ bay đến Việt Nam tuần tới)

3. Thói quen tạm thời:
• I am staying at a hotel this month. (Tôi đang ở khách sạn trong tháng này)

CẤU TRÚC:
• Khẳng định: S + am/is/are + V-ing + O
  - I am working. / He is working.
  - We are studying. / She is studying.

• Phủ định: S + am/is/are + not + V-ing + O
  - I am not working. / He is not working.
  - We are not studying. / She is not studying.

• Nghi vấn: Am/Is/Are + S + V-ing + O?
  - Am I working? / Is he working?
  - Are we studying? / Is she studying?

DẤU HIỆU NHẬN BIẾT:
now, right now, at the moment, currently, these days, this week/month/year

LƯU Ý:
Một số động từ không dùng ở thì tiếp diễn: love, like, hate, know, understand, believe''';

      case 'Past Simple':
        return '''Past Simple (Quá khứ đơn):

CÁCH SỬ DỤNG:
1. Hành động đã hoàn thành trong quá khứ:
• I visited Paris last year. (Tôi đã thăm Paris năm ngoái)
• She graduated in 2020. (Cô ấy đã tốt nghiệp năm 2020)

2. Chuỗi hành động trong quá khứ:
• He opened the door and walked in. (Anh ấy mở cửa và bước vào)
• I got up, brushed my teeth, and had breakfast. (Tôi thức dậy, đánh răng và ăn sáng)

3. Thói quen trong quá khứ:
• When I was young, I played football every day. (Khi còn nhỏ, tôi chơi bóng đá mỗi ngày)

CẤU TRÚC:
• Khẳng định: S + V2/Ved + O
  - I worked. / He went. / She studied.

• Phủ định: S + didn't + V + O
  - I didn't work. / He didn't go. / She didn't study.

• Nghi vấn: Did + S + V + O?
  - Did you work? / Did he go? / Did she study?

ĐỘNG TỪ BẤT QUY TẮC:
go → went, see → saw, buy → bought, eat → ate, drink → drank

DẤU HIỆU NHẬN BIẾT:
yesterday, last (week/month/year), ago, in 1990, when I was young''';

      case 'Past Continuous':
        return '''Past Continuous (Quá khứ tiếp diễn):

CÁCH SỬ DỤNG:
1. Hành động đang diễn ra tại một thời điểm cụ thể trong quá khứ:
• I was reading at 8 PM yesterday. (Tôi đang đọc sách lúc 8 giờ tối hôm qua)
• She was cooking when I called. (Cô ấy đang nấu ăn khi tôi gọi)

2. Hai hành động cùng diễn ra trong quá khứ:
• While I was studying, my brother was playing games. 
  (Trong khi tôi đang học, anh trai tôi đang chơi game)

3. Hành động dài bị gián đoạn bởi hành động ngắn:
• I was sleeping when the phone rang. (Tôi đang ngủ thì điện thoại reo)

CẤU TRÚC:
• Khẳng định: S + was/were + V-ing + O
  - I was working. / They were working.

• Phủ định: S + was/were + not + V-ing + O
  - I was not working. / They were not working.

• Nghi vấn: Was/Were + S + V-ing + O?
  - Was I working? / Were they working?

PHỐI HỢP THỜI:
• When + Past Simple, Past Continuous
  When he arrived, I was cooking.
• While + Past Continuous, Past Simple
  While I was driving, it started to rain.

DẤU HIỆU NHẬN BIẾT:
while, when, as, at that time, at 8 PM yesterday''';

      case 'Present Perfect':
        return '''Present Perfect (Hiện tại hoàn thành):

CÁCH SỬ DỤNG:
1. Hành động đã xảy ra, không rõ thời gian cụ thể:
• I have visited Japan. (Tôi đã từng đến Nhật Bản)
• She has read that book. (Cô ấy đã đọc cuốn sách đó)

2. Hành động bắt đầu trong quá khứ, tiếp tục đến hiện tại:
• I have lived here for 5 years. (Tôi đã sống ở đây được 5 năm)
• We have been friends since 2010. (Chúng tôi đã là bạn từ năm 2010)

3. Hành động vừa mới xảy ra:
• I have just finished my homework. (Tôi vừa mới làm xong bài tập)
• She has already left. (Cô ấy đã rời đi rồi)

CẤU TRÚC:
• Khẳng định: S + have/has + V3/Ved + O
  - I have worked. / She has worked.

• Phủ định: S + have/has + not + V3/Ved + O
  - I have not worked. / She has not worked.

• Nghi vấn: Have/Has + S + V3/Ved + O?
  - Have you worked? / Has she worked?

ĐỘNG TỪ BẤT QUY TẮC:
see → seen, go → gone, eat → eaten, write → written, buy → bought

DẤU HIỆU NHẬN BIẾT:
just, already, yet, ever, never, recently, lately, so far, since, for, up to now''';

      case 'Future Simple':
        return '''Future Simple (Tương lai đơn):

CÁCH SỬ DỤNG:
1. Quyết định tức thời:
• I will help you. (Tôi sẽ giúp bạn)
• I think it will rain tomorrow. (Tôi nghĩ ngày mai sẽ mưa)

2. Dự đoán về tương lai:
• She will be a good doctor. (Cô ấy sẽ là một bác sĩ giỏi)
• Technology will change our lives. (Công nghệ sẽ thay đổi cuộc sống chúng ta)

3. Lời hứa, lời đề nghị:
• I will call you tonight. (Tôi sẽ gọi cho bạn tối nay)
• Will you marry me? (Bạn có cưới tôi không?)

CẤU TRÚC:
• Khẳng định: S + will + V + O
  - I will go. / She will study.

• Phủ định: S + will not (won't) + V + O
  - I will not go. / She won't study.

• Nghi vấn: Will + S + V + O?
  - Will you go? / Will she study?

BE GOING TO:
Dùng cho kế hoạch đã định trước:
• I am going to buy a car next month. (Tôi định mua xe tháng tới)
• We are going to travel to Europe. (Chúng tôi định du lịch châu Âu)

DẤU HIỆU NHẬN BIẾT:
tomorrow, next (week/month/year), in the future, soon, later, tonight

WILL vs BE GOING TO:
• Will: quyết định tức thời, dự đoán
• Be going to: kế hoạch đã định, dấu hiệu rõ ràng''';

      // ADVANCED TOPICS
      case 'Modal Verbs':
        return '''Modal Verbs (Động từ khuyết thiếu):

1. CAN / COULD:
• Can: khả năng hiện tại, xin phép
  - I can swim. (Tôi biết bơi)
  - Can I help you? (Tôi có thể giúp bạn không?)

• Could: khả năng quá khứ, lịch sự hơn can
  - I could swim when I was 5. (Tôi biết bơi khi 5 tuổi)
  - Could you help me? (Bạn có thể giúp tôi không?)

2. MUST / HAVE TO:
• Must: bắt buộc từ người nói
  - You must do your homework. (Con phải làm bài tập)
  - I must go now. (Tôi phải đi bây giờ)

• Have to: bắt buộc từ bên ngoài
  - I have to work on Sunday. (Tôi phải làm việc Chủ nhật)

3. SHOULD / OUGHT TO:
• Lời khuyên, điều nên làm
  - You should study harder. (Bạn nên học chăm hơn)
  - We should help the poor. (Chúng ta nên giúp người nghèo)

4. WOULD:
• Lịch sự, điều kiện
  - Would you like some tea? (Bạn có muốn chút trà không?)
  - I would go if I had time. (Tôi sẽ đi nếu có thời gian)

5. MAY / MIGHT:
• Khả năng, xin phép
  - It may rain today. (Hôm nay có thể mưa)
  - May I come in? (Tôi có thể vào không?)
  - He might be late. (Anh ấy có thể đến muộn)

CẤU TRÚC:
S + Modal Verb + V(nguyên mẫu) + O''';

      case 'Conditional Sentences':
        return '''Conditional Sentences (Câu điều kiện):

TYPE 0 - ZERO CONDITIONAL (Sự thật hiển nhiên):
If + Present Simple, Present Simple
• If you heat water to 100°C, it boils.
  (Nếu bạn đun nước đến 100°C, nó sẽ sôi)
• If it rains, the ground gets wet.
  (Nếu trời mưa, đất sẽ ướt)

TYPE 1 - FIRST CONDITIONAL (Có thể xảy ra):
If + Present Simple, will + V
• If it rains tomorrow, I will stay home.
  (Nếu ngày mai trời mưa, tôi sẽ ở nhà)
• If you study hard, you will pass the exam.
  (Nếu bạn học chăm, bạn sẽ đậu kỳ thi)

TYPE 2 - SECOND CONDITIONAL (Không có thật ở hiện tại):
If + Past Simple, would + V
• If I were rich, I would travel the world.
  (Nếu tôi giàu, tôi sẽ đi du lịch khắp thế giới)
• If I had wings, I would fly.
  (Nếu tôi có cánh, tôi sẽ bay)

TYPE 3 - THIRD CONDITIONAL (Không có thật trong quá khứ):
If + Past Perfect, would have + V3
• If I had studied harder, I would have passed.
  (Nếu tôi đã học chăm hơn, tôi đã đậu rồi)
• If she had left earlier, she wouldn't have been late.
  (Nếu cô ấy đã đi sớm hơn, cô ấy đã không bị muộn)

MIXED CONDITIONALS:
• If I had studied medicine, I would be a doctor now.
  (Nếu tôi đã học y khoa, bây giờ tôi đã là bác sĩ rồi)

UNLESS = IF NOT:
• Unless it rains, we will go picnic. (Trừ khi trời mưa...)
• I won't go unless you come with me. (Tôi sẽ không đi trừ khi bạn đi cùng)''';

      case 'Passive Voice':
        return '''Passive Voice (Câu bị động):

CÁCH CHUYỂN ĐỔI:
Active: S + V + O
Passive: O + be + V3/Ved + (by S)

CÁC THÌ THÔNG DỤNG:

1. PRESENT SIMPLE:
• Active: People speak English worldwide.
• Passive: English is spoken worldwide (by people).

2. PRESENT CONTINUOUS:
• Active: They are building a new bridge.
• Passive: A new bridge is being built (by them).

3. PAST SIMPLE:
• Active: Shakespeare wrote Romeo and Juliet.
• Passive: Romeo and Juliet was written by Shakespeare.

4. PAST CONTINUOUS:
• Active: They were repairing the road.
• Passive: The road was being repaired (by them).

5. PRESENT PERFECT:
• Active: Someone has stolen my bike.
• Passive: My bike has been stolen (by someone).

6. FUTURE SIMPLE:
• Active: They will complete the project next month.
• Passive: The project will be completed next month (by them).

KHI NÀO DÙNG PASSIVE:
1. Không biết ai thực hiện hành động:
• My car was stolen last night. (Xe tôi bị trộm đêm qua)

2. Hành động quan trọng hơn người thực hiện:
• The Mona Lisa was painted in the 16th century.

3. Muốn nhấn mạnh đối tượng chịu tác động:
• The president was elected by the people.

4. Văn phong trang trọng, khoa học:
• The experiment was conducted carefully.

LƯU Ý:
• Động từ ngoại động mới có câu bị động
• "by + agent" có thể bỏ nếu không quan trọng''';

      case 'Reported Speech':
        return '''Reported Speech (Câu gián tiếp):

QUY TẮC CHUNG:
Direct Speech → Reported Speech
Thay đổi: thì, đại từ, trạng từ chỉ thời gian/nơi chốn

THAY ĐỔI THÌ (Backshift):
• Present Simple → Past Simple
• Present Continuous → Past Continuous  
• Past Simple → Past Perfect
• Present Perfect → Past Perfect
• Future Simple → Would + V
• Can → Could
• May → Might
• Must → Had to

VÍ DỤ:
• "I am happy," she said.
  → She said (that) she was happy.

• "I will help you," he promised.
  → He promised (that) he would help me.

• "I have finished my work," Mary said.
  → Mary said (that) she had finished her work.

THAY ĐỔI TRẠNG TỪ:
• today → that day
• tomorrow → the next day
• yesterday → the day before
• now → then
• here → there
• this → that
• these → those

CÂU HỎI GIÁN TIẾP:
1. Yes/No Questions:
• "Are you happy?" he asked.
  → He asked if/whether I was happy.

2. Wh-Questions:
• "Where do you live?" she asked.
  → She asked where I lived.

• "What time is it?" he asked.
  → He asked what time it was.

CÂU MỆNH LỆNH:
• "Open the door," he said.
  → He told me to open the door.

• "Don't be late," she said.
  → She told me not to be late.

ĐỘNG TỪ TƯỜNG THUẬT:
said, told, asked, explained, promised, warned, suggested, advised''';

      // COMMON MISTAKES
      case 'Subject-Verb Agreement':
        return '''Subject-Verb Agreement (Sự hòa hợp chủ - vị):

QUY TẮC CƠ BẢN:
• Chủ ngữ số ít + Động từ số ít
• Chủ ngữ số nhiều + Động từ số nhiều

VÍ DỤ:
✓ The student is studying.
✓ The students are studying.
✗ The student are studying.
✗ The students is studying.

CÁC TRƯỜNG HỢP ĐẶC BIỆT:

1. DANH TỪ TẬP HỢP:
• Team, family, class, group + động từ số ít (khi coi như một đơn vị)
  The team is winning.
• + động từ số nhiều (khi nhấn mạnh các cá nhân)
  The team are arguing among themselves.

2. EITHER...OR / NEITHER...NOR:
Động từ theo chủ ngữ gần nhất:
• Either John or his friends are coming.
• Neither the teacher nor the students know the answer.

3. THERE IS / THERE ARE:
• There is a book on the table.
• There are books on the table.
• There is a pen and some papers. (theo danh từ đầu tiên)

4. ĐƠN VỊ ĐO LƯỜNG, TIỀN TỆ, THỜI GIAN:
Coi như số ít:
• Five dollars is not much.
• Two hours is too long.

5. DANH TỪ LUÔN SỐ NHIỀU:
scissors, pants, glasses, news, mathematics
• The scissors are sharp.
• Mathematics is difficult.

6. PERCENTAGE:
• 50% of the students are absent.
• 50% of the water is polluted.

7. SOME/ALL/MOST + OF:
• Some of the cake is sweet. (không đếm được)
• Some of the students are absent. (đếm được)

LƯU Ý:
Chủ ngữ thật là từ chính, không phải từ trong cụm giới từ:
• The box of apples is heavy. (box là chủ ngữ)''';

      case 'Prepositions':
        return '''Prepositions (Giới từ):

GIỚI TỪ CHỈ THỜI GIAN:

1. AT:
• Thời điểm cụ thể: at 3 o'clock, at midnight, at noon
• Dịp lễ: at Christmas, at Easter
• Tuổi: at the age of 18

2. IN:
• Tháng: in January, in December
• Năm: in 2023, in the 21st century
• Buổi: in the morning, in the evening
• Mùa: in summer, in winter

3. ON:
• Ngày: on Monday, on January 1st
• Ngày cụ thể: on my birthday, on Christmas Day

GIỚI TỪ CHỈ NƠI CHỐN:

1. AT:
• Địa điểm cụ thể: at school, at home, at the airport
• Sự kiện: at a party, at a concert

2. IN:
• Không gian kín: in the room, in the car, in the box
• Thành phố/quốc gia: in Vietnam, in Ho Chi Minh City
• Khu vực: in the garden, in the street

3. ON:
• Bề mặt: on the table, on the wall, on the floor
• Đường phố: on Nguyen Hue Street
• Phương tiện: on the bus, on a plane

GIỚI TỪ CHỈ HƯỚNG:

1. TO:
• Hướng đến: go to school, come to my house
• Đích đến: from Vietnam to Japan

2. FROM:
• Xuất phát: from home, from 9 to 5

3. INTO:
• Vào trong: walk into the room, put into the bag

4. OUT OF:
• Ra khỏi: get out of the car, take out of the box

GIỚI TỪ KHÁC:

1. BY:
• Phương tiện: by car, by plane, by bus
• Tác nhân: written by Shakespeare
• Thời hạn: by tomorrow, by 5 PM

2. WITH:
• Đi cùng: go with friends
• Dụng cụ: write with a pen, cut with a knife

3. FOR:
• Mục đích: study for the exam
• Thời gian: for 2 hours, for a long time
• Dành cho: a gift for you

4. ABOUT:
• Về chủ đề: talk about love, book about history

CỤMGIỚI TỪ CỐ ĐỊNH:
• Interested in, good at, afraid of, worried about
• Depend on, look for, listen to, wait for''';

      case 'Word Order':
        return '''Word Order (Trật tự từ):

TRẬT TỰ CƠ BẢN:
S + V + O + Place + Time
Subject + Verb + Object + Nơi chốn + Thời gian

VÍ DỤ:
• I study English at home every evening.
  (Tôi học tiếng Anh ở nhà mỗi tối)

TRẬT TỰ TÍNH TỪ:
Opinion + Size + Age + Shape + Color + Origin + Material + Purpose + Noun

VÍ DỤ:
• A beautiful small old round red Chinese wooden dining table
• My lovely big new square blue American plastic storage box

NGẮN GỌN HƠN:
1. Opinion (Ý kiến): beautiful, nice, ugly, good
2. Size (Kích thước): big, small, tiny, huge
3. Age (Tuổi tác): old, new, young, ancient
4. Color (Màu sắc): red, blue, green, white
5. Origin (Xuất xứ): Vietnamese, Chinese, American
6. Material (Chất liệu): wooden, plastic, metal, glass

TRẬT TỰ TRẠNG TỪ:
Manner + Place + Time (Cách thức + Nơi chốn + Thời gian)

VÍ DỤ:
• She sang beautifully at the concert last night.
  (Cô ấy đã hát hay tại buổi hòa nhạc tối qua)

TRẬT TỰ CÂU HỎI:
Wh-word + Auxiliary + Subject + Main Verb + Object?

VÍ DỤ:
• What are you doing?
• Where did you go yesterday?
• When will she arrive?

TRẬT TỰ CÂU MỆNH LỆNH:
Verb + Object + Place + Time

VÍ DỤ:
• Put the book on the shelf now.
• Meet me at the cafe at 3 PM.

TRẬT TỰ VỚI FREQUENCY ADVERBS:
• Be + always/usually/often/sometimes/never
  I am always happy.
• Other verbs + always/usually/often/sometimes/never
  I always go to school early.

ĐẢO NGỮ (INVERSION):
• Never have I seen such a beautiful sunset.
• Only then did I understand the truth.
• Here comes the bus.

LƯU Ý:
• Không đặt trạng từ giữa động từ và tân ngữ trực tiếp
  ✓ I speak English fluently.
  ✗ I speak fluently English.''';

      case 'Countable vs Uncountable':
        return '''Countable vs Uncountable Nouns:

COUNTABLE NOUNS (Danh từ đếm được):

Đặc điểm:
• Có thể đếm: 1, 2, 3...
• Có dạng số ít và số nhiều
• Có thể dùng với a/an

VÍ DỤ:
• book → books
• apple → apples  
• child → children
• person → people

Định lượng từ:
• many books (nhiều sách)
• few friends (ít bạn)
• a few minutes (vài phút)
• several options (một số lựa chọn)
• a number of students (một số học sinh)

UNCOUNTABLE NOUNS (Danh từ không đếm được):

Đặc điểm:
• Không thể đếm từng cái
• Chỉ có dạng số ít
• Không dùng với a/an
• Động từ chia số ít

VÍ DỤ:
• water, milk, coffee (chất lỏng)
• rice, bread, sugar (thức ăn)
• music, information, advice (trừu tượng)
• furniture, luggage, equipment (tập hợp)

Định lượng từ:
• much water (nhiều nước)
• little time (ít thời gian)
• a little sugar (một ít đường)
• some information (một số thông tin)
• a great deal of money (rất nhiều tiền)

SO SÁNH:

MANY vs MUCH:
• Many + countable: many students, many books
• Much + uncountable: much water, much money

FEW vs LITTLE:
• Few + countable (ít, mang nghĩa tiêu cực): few friends
• A few + countable (vài, mang nghĩa tích cực): a few friends
• Little + uncountable (ít): little water
• A little + uncountable (một ít): a little water

SOME vs ANY:
• Some: câu khẳng định và lời mời lịch sự
  I have some books. / Would you like some tea?
• Any: câu phủ định và nghi vấn
  I don't have any money. / Do you have any questions?

ĐƠN VỊ ĐO LƯỜNG:
Để đếm uncountable nouns:
• a glass of water (một ly nước)
• a piece of advice (một lời khuyên)
• a loaf of bread (một ổ bánh mì)
• a cup of coffee (một tách cà phê)
• a bottle of milk (một chai sữa)

DANH TỪ ĐẶC BIỆT:
• Hair: uncountable (tóc nói chung), countable (từng sợi tóc)
• Paper: uncountable (giấy), countable (tờ giấy, báo)
• Time: uncountable (thời gian), countable (lần)
• Experience: uncountable (kinh nghiệm), countable (trải nghiệm)''';

      default:
        return 'Detailed explanation for this topic will be added soon.';
    }
  }
}

class GrammarTopic {
  final String title;
  final String description;
  
  GrammarTopic(this.title, this.description);
}
