// lib/presentation/pages/grammar/simple_grammar_page.dart
import 'package:flutter/material.dart';
import '../../layout/main_layout.dart';
import '../../../core/constants/app_colors.dart';

class SimpleGrammarPage extends StatelessWidget {
  const SimpleGrammarPage({super.key});

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
              _buildHeader(),
              const SizedBox(height: 24),
              _buildGrammarTopics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'English Grammar Guide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn English grammar step by step with clear explanations and examples.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopicSection('Basic Grammar', [
          GrammarTopic('Parts of Speech', 'Nouns, Verbs, Adjectives, Adverbs, etc.'),
          GrammarTopic('Sentence Structure', 'Subject + Verb + Object'),
          GrammarTopic('Articles', 'Using a, an, the correctly'),
          GrammarTopic('Pronouns', 'I, you, he, she, it, we, they'),
        ]),
        
        _buildTopicSection('Tenses', [
          GrammarTopic('Present Simple', 'I work, He works'),
          GrammarTopic('Present Continuous', 'I am working'),
          GrammarTopic('Past Simple', 'I worked'),
          GrammarTopic('Past Continuous', 'I was working'),
          GrammarTopic('Present Perfect', 'I have worked'),
          GrammarTopic('Future Simple', 'I will work'),
        ]),
        
        _buildTopicSection('Advanced Topics', [
          GrammarTopic('Modal Verbs', 'can, could, must, should, would'),
          GrammarTopic('Conditional Sentences', 'If clauses and results'),
          GrammarTopic('Passive Voice', 'The book was written by...'),
          GrammarTopic('Reported Speech', 'He said that...'),
        ]),
        
        _buildTopicSection('Common Mistakes', [
          GrammarTopic('Subject-Verb Agreement', 'Singular and plural forms'),
          GrammarTopic('Prepositions', 'in, on, at, by, for, with'),
          GrammarTopic('Word Order', 'Correct sentence arrangement'),
          GrammarTopic('Countable vs Uncountable', 'many vs much, few vs little'),
        ]),
      ],
    );
  }

  Widget _buildTopicSection(String title, List<GrammarTopic> topics) {
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
        ...topics.map((topic) => _buildTopicCard(topic)).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTopicCard(GrammarTopic topic) {
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
            onTap: () => _showTopicDetail(topic),
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

  void _showTopicDetail(GrammarTopic topic) {
    // Sẽ được implement sau - hiện tại chỉ là placeholder
  }
}

class GrammarTopic {
  final String title;
  final String description;
  
  GrammarTopic(this.title, this.description);
}
