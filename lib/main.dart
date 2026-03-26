import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Analyzer',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class AnalysisResult {
  final String confidence;
  final String tone;
  final String conclusion;
  final String advice;

  AnalysisResult({
    required this.confidence,
    required this.tone,
    required this.conclusion,
    required this.advice,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  AnalysisResult? _result;
  String _statusText = 'Вставь переписку ниже и нажми «Разобрать»';

  final List<String> _examples = [
    'Привет, как дела? Давно не виделись 🙂',
    'Я занят, потом отвечу.',
    'Да, конечно, давай встретимся завтра!',
    'Ок.',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fillExample(String text) {
    setState(() {
      _controller.text = text;
      _statusText = 'Пример загружен. Можно анализировать.';
      _result = null;
    });
  }

  void _clearAll() {
    setState(() {
      _controller.clear();
      _result = null;
      _statusText = 'Вставь переписку ниже и нажми «Разобрать»';
    });
  }

  void _analyze() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _result = null;
        _statusText = 'Сначала вставь текст переписки.';
      });
      return;
    }

    final result = _makeAnalysis(text);

    setState(() {
      _result = result;
      _statusText = 'Анализ готов.';
    });
  }

  AnalysisResult _makeAnalysis(String text) {
    final lower = text.toLowerCase();

    final wordCount = lower
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .length;

    final questionMarks = '?'.allMatches(text).length;
    final exclamations = '!'.allMatches(text).length;

    final positiveSignals = [
      'конечно',
      'давай',
      'хочу',
      'рад',
      'спасибо',
      'класс',
      'супер',
      'ок',
      'окей',
      '❤️',
      '😍',
      '🥰',
      '🙂',
    ];

    final negativeSignals = [
      'не хочу',
      'не сейчас',
      'занят',
      'потом',
      'позже',
      'отстань',
      'надоел',
      'бесишь',
      'нет',
      '🙄',
      '😒',
    ];

    final positiveCount =
        positiveSignals.where((s) => lower.contains(s)).length;
    final negativeCount =
        negativeSignals.where((s) => lower.contains(s)).length;

    final score =
        (positiveCount * 2) + questionMarks + exclamations - (negativeCount * 2);

    String confidence;
    if (wordCount < 8) {
      confidence = 'Очень мало текста, точность низкая.';
    } else if (wordCount < 20) {
      confidence = 'Текста немного, но уже можно сделать осторожный вывод.';
    } else {
      confidence = 'Текста достаточно для уверенного первичного разбора.';
    }

    String tone;
    if (negativeCount > positiveCount) {
      tone = 'Тон холодный, с дистанцией или раздражением.';
    } else if (questionMarks >= 2 && positiveCount > 0) {
      tone = 'Тон интересующийся, но аккуратный.';
    } else if (exclamations >= 2 || positiveCount >= 2) {
      tone = 'Тон живой, эмоциональный и вовлечённый.';
    } else {
      tone = 'Тон нейтральный, без сильного эмоционального сигнала.';
    }

    String conclusion;
    String advice;

    if (score >= 4) {
      conclusion = 'Похоже, человек расположен к общению и не закрывается.';
      advice = 'Можно отвечать спокойно, не давить и продолжать диалог естественно.';
    } else if (score >= 1) {
      conclusion = 'Интерес есть, но он слабый или нестабильный.';
      advice = 'Лучше писать коротко, без навязчивости, и смотреть на реакцию дальше.';
    } else if (score == 0) {
      conclusion = 'Сигналов мало, вывод делать рано.';
      advice = 'Нужна более длинная переписка, иначе анализ будет очень приблизительным.';
    } else {
      conclusion = 'Есть признаки охлаждения или нежелания продолжать разговор.';
      advice = 'Лучше снизить активность и не давить сообщениями.';
    }

    return AnalysisResult(
      confidence: confidence,
      tone: tone,
      conclusion: conclusion,
      advice: advice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Анализ переписки'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Что делает приложение',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Вставь переписку и получи быстрый разбор тона, интереса и вероятной реакции.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _statusText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Вставь переписку сюда...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _examples
                    .map(
                      (text) => ActionChip(
                        label: Text(
                          text.length > 24 ? '${text.substring(0, 24)}...' : text,
                        ),
                        onPressed: () => _fillExample(text),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _analyze,
                      child: const Text('Разобрать'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _clearAll,
                    child: const Text('Очистить'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_result != null) ...[
                _ResultCard(
                  title: 'Уверенность',
                  value: _result!.confidence,
                  icon: Icons.insights_outlined,
                ),
                const SizedBox(height: 12),
                _ResultCard(
                  title: 'Тон',
                  value: _result!.tone,
                  icon: Icons.chat_bubble_outline,
                ),
                const SizedBox(height: 12),
                _ResultCard(
                  title: 'Вывод',
                  value: _result!.conclusion,
                  icon: Icons.psychology_outlined,
                ),
                const SizedBox(height: 12),
                _ResultCard(
                  title: 'Совет',
                  value: _result!.advice,
                  icon: Icons.lightbulb_outline,
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.04),
                ),
                child: const Text(
                  'Следующий шаг: после этого экрана мы подключим Firebase и сделаем историю анализов.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}