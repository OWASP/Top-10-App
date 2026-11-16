import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/content_repository.dart';
import '../../content/models.dart';
import '../../content/providers.dart';
import '../../core/brand_icons.dart';
import '../../core/widgets.dart';
import '../../data/providers.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String? _selectedListId;
  int _questionIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _score = 0;
  bool _finished = false;

  void _resetQuiz({String? listId}) {
    setState(() {
      _selectedListId = listId;
      _questionIndex = 0;
      _selectedOption = null;
      _answered = false;
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ContentBundle> bundleAsync = ref.watch(
      contentBundleProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: bundleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) {
          final List<String> errors = error is ContentUnavailableException
              ? error.errors
              : <String>[error.toString()];
          return ContentUnavailableView(errors: errors);
        },
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(ContentBundle bundle) {
    final List<RiskList> listsWithQuiz = bundle.lists
        .where((RiskList list) => list.quiz.isNotEmpty)
        .toList(growable: false);

    if (listsWithQuiz.isEmpty) {
      return const EmptyState(
        message: 'Authored quizzes are still under review for these lists.',
        icon: Icons.quiz_outlined,
      );
    }

    final RiskList active = listsWithQuiz.firstWhere(
      (RiskList list) => list.id == _selectedListId,
      orElse: () => listsWithQuiz.first,
    );

    return Column(
      children: <Widget>[
        if (bundle.isDraft) const DraftContentBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: EvenFilterChips(
            chips:
                <
                  ({
                    String label,
                    bool selected,
                    VoidCallback onSelected,
                    Color accent,
                    bool emphasized,
                  })
                >[
                  for (final RiskList list in listsWithQuiz)
                    (
                      label: '${list.family.toUpperCase()} ${list.edition}',
                      selected: active.id == list.id,
                      accent: listAccent(context, list.id),
                      emphasized: isAiList(list.id),
                      onSelected: () => _resetQuiz(listId: list.id),
                    ),
                ],
          ),
        ),
        Expanded(
          child: _finished
              ? _ResultView(
                  list: active,
                  score: _score,
                  total: active.quiz.length,
                  onRestart: () => _resetQuiz(listId: active.id),
                  onBackToLearn: () => context.go('/learn'),
                )
              : _QuizView(
                  list: active,
                  question: active.quiz[_questionIndex],
                  questionIndex: _questionIndex,
                  total: active.quiz.length,
                  score: _score,
                  selectedOption: _selectedOption,
                  answered: _answered,
                  onAnswer: (int index) => _answer(active, index),
                  onNext: _answered ? () => _nextQuestion(active) : null,
                ),
        ),
      ],
    );
  }

  void _answer(RiskList list, int index) {
    if (_answered) return;
    final QuizQuestion question = list.quiz[_questionIndex];
    final bool correct = index == question.answerIndex;

    setState(() {
      _selectedOption = index;
      _answered = true;
      if (correct) _score++;
    });

    unawaited(
      ref
          .read(progressRepositoryProvider)
          .recordQuizAttempt(
            listId: list.id,
            questionId: question.id,
            selectedIndex: index,
            correct: correct,
          ),
    );
  }

  void _nextQuestion(RiskList active) {
    final bool isLast = _questionIndex + 1 >= active.quiz.length;

    setState(() {
      if (isLast) {
        _finished = true;
      } else {
        _questionIndex++;
        _selectedOption = null;
        _answered = false;
      }
    });
  }
}

class _QuizView extends StatefulWidget {
  const _QuizView({
    required this.list,
    required this.question,
    required this.questionIndex,
    required this.total,
    required this.score,
    required this.selectedOption,
    required this.answered,
    required this.onAnswer,
    required this.onNext,
  });

  final RiskList list;
  final QuizQuestion question;
  final int questionIndex;
  final int total;
  final int score;
  final int? selectedOption;
  final bool answered;
  final ValueChanged<int> onAnswer;
  final VoidCallback? onNext;

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(_QuizView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool answeredJustNow = widget.answered && !oldWidget.answered;
    final bool questionChanged =
        widget.questionIndex != oldWidget.questionIndex;
    if (!answeredJustNow && !questionChanged) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final double target = answeredJustNow
          ? _scrollController.position.maxScrollExtent
          : 0;
      if (MediaQuery.disableAnimationsOf(context)) {
        _scrollController.jumpTo(target);
        return;
      }
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = listAccent(context, widget.list.id);
    final Color onAccent = onColorFor(accent);
    final bool isLast = widget.questionIndex + 1 >= widget.total;

    final Widget content = ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Question ${widget.questionIndex + 1} of ${widget.total}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.score} correct',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Semantics(
                label: 'Quiz progress',
                value: '${widget.questionIndex + 1} of ${widget.total}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (widget.questionIndex + 1) / widget.total,
                    color: accent,
                    backgroundColor: accent.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(widget.question.prompt, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        for (int index = 0; index < widget.question.options.length; index++)
          _OptionTile(
            index: index,
            text: widget.question.options[index],
            selected: widget.selectedOption == index,
            answered: widget.answered,
            isCorrect: index == widget.question.answerIndex,
            onTap: () => widget.onAnswer(index),
          ),
        if (widget.answered) ...<Widget>[
          const SizedBox(height: 12),
          _Feedback(
            question: widget.question,
            selectedOption: widget.selectedOption,
          ),
        ],
        const SizedBox(height: 20),
        Text(
          '${widget.list.title} ${widget.list.edition}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    return Column(
      children: <Widget>[
        Expanded(child: content),
        if (widget.answered)
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: onAccent,
                  ),
                  child: Text(isLast ? 'See result' : 'Next question'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.text,
    required this.selected,
    required this.answered,
    required this.isCorrect,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool selected;
  final bool answered;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool showCorrect = answered && isCorrect;
    final bool showWrong = answered && selected && !isCorrect;

    final Color background = showCorrect
        ? scheme.primaryContainer
        : showWrong
        ? scheme.errorContainer
        : scheme.surfaceContainerLow;
    final Color titleColor = showCorrect
        ? scheme.onPrimaryContainer
        : showWrong
        ? scheme.onErrorContainer
        : scheme.onSurface;
    final Color badgeColor = showCorrect
        ? scheme.primary
        : showWrong
        ? scheme.error
        : scheme.surfaceContainerHighest;
    final Color badgeTextColor = showCorrect
        ? scheme.onPrimary
        : showWrong
        ? scheme.onError
        : scheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: showCorrect
              ? scheme.primary
              : showWrong
              ? scheme.error
              : selected
              ? scheme.primary
              : scheme.outlineVariant,
          width: selected || showCorrect || showWrong ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: answered ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 32,
                height: 32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: MediaQuery.withNoTextScaling(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          color: badgeTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(color: titleColor),
                ),
              ),
              if (showCorrect)
                Icon(
                  Icons.check_circle,
                  color: scheme.onPrimaryContainer,
                  semanticLabel: 'Correct answer',
                )
              else if (showWrong)
                Icon(
                  Icons.cancel,
                  color: scheme.onErrorContainer,
                  semanticLabel: 'Incorrect answer',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.question, required this.selectedOption});

  final QuizQuestion question;
  final int? selectedOption;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool correct = selectedOption == question.answerIndex;
    final Color background = correct
        ? scheme.primaryContainer
        : scheme.errorContainer;
    final Color foreground = correct
        ? scheme.onPrimaryContainer
        : scheme.onErrorContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExcludeSemantics(
            child: Icon(
              correct ? Icons.check_circle : Icons.cancel,
              color: foreground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  correct ? 'Correct' : 'Incorrect',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  question.explanation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.list,
    required this.score,
    required this.total,
    required this.onRestart,
    required this.onBackToLearn,
  });

  final RiskList list;
  final int score;
  final int total;
  final VoidCallback onRestart;
  final VoidCallback onBackToLearn;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = listAccent(context, list.id);
    final Color onAccent = onColorFor(accent);
    final int percent = total == 0 ? 0 : (score / total * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              label: 'Quiz result',
              value: '$score of $total correct, $percent percent',
              excludeSemantics: true,
              child: SizedBox(
                width: 148,
                height: 148,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 148,
                      height: 148,
                      child: CircularProgressIndicator(
                        value: total == 0 ? 0 : score / total,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        color: accent,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$percent%',
                          style: theme.textTheme.headlineMedium,
                        ),
                        Text(
                          '$score/$total',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$score of $total correct',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${list.title} ${list.edition}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Practice again'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onBackToLearn,
                child: const Text('Back to Learn'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
