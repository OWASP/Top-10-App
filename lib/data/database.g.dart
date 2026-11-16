// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ReadProgressTable extends ReadProgress
    with TableInfo<$ReadProgressTable, ReadProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _riskIdMeta = const VerificationMeta('riskId');
  @override
  late final GeneratedColumn<String> riskId = GeneratedColumn<String>(
    'risk_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [riskId, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'read_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('risk_id')) {
      context.handle(
        _riskIdMeta,
        riskId.isAcceptableOrUnknown(data['risk_id']!, _riskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_riskIdMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {riskId};
  @override
  ReadProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadProgressEntry(
      riskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_id'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      )!,
    );
  }

  @override
  $ReadProgressTable createAlias(String alias) {
    return $ReadProgressTable(attachedDatabase, alias);
  }
}

class ReadProgressEntry extends DataClass
    implements Insertable<ReadProgressEntry> {
  final String riskId;
  final DateTime readAt;
  const ReadProgressEntry({required this.riskId, required this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['risk_id'] = Variable<String>(riskId);
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  ReadProgressCompanion toCompanion(bool nullToAbsent) {
    return ReadProgressCompanion(riskId: Value(riskId), readAt: Value(readAt));
  }

  factory ReadProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadProgressEntry(
      riskId: serializer.fromJson<String>(json['riskId']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'riskId': serializer.toJson<String>(riskId),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  ReadProgressEntry copyWith({String? riskId, DateTime? readAt}) =>
      ReadProgressEntry(
        riskId: riskId ?? this.riskId,
        readAt: readAt ?? this.readAt,
      );
  ReadProgressEntry copyWithCompanion(ReadProgressCompanion data) {
    return ReadProgressEntry(
      riskId: data.riskId.present ? data.riskId.value : this.riskId,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadProgressEntry(')
          ..write('riskId: $riskId, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(riskId, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadProgressEntry &&
          other.riskId == this.riskId &&
          other.readAt == this.readAt);
}

class ReadProgressCompanion extends UpdateCompanion<ReadProgressEntry> {
  final Value<String> riskId;
  final Value<DateTime> readAt;
  final Value<int> rowid;
  const ReadProgressCompanion({
    this.riskId = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadProgressCompanion.insert({
    required String riskId,
    required DateTime readAt,
    this.rowid = const Value.absent(),
  }) : riskId = Value(riskId),
       readAt = Value(readAt);
  static Insertable<ReadProgressEntry> custom({
    Expression<String>? riskId,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (riskId != null) 'risk_id': riskId,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadProgressCompanion copyWith({
    Value<String>? riskId,
    Value<DateTime>? readAt,
    Value<int>? rowid,
  }) {
    return ReadProgressCompanion(
      riskId: riskId ?? this.riskId,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (riskId.present) {
      map['risk_id'] = Variable<String>(riskId.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadProgressCompanion(')
          ..write('riskId: $riskId, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarkEntriesTable extends BookmarkEntries
    with TableInfo<$BookmarkEntriesTable, BookmarkEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _riskIdMeta = const VerificationMeta('riskId');
  @override
  late final GeneratedColumn<String> riskId = GeneratedColumn<String>(
    'risk_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [riskId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('risk_id')) {
      context.handle(
        _riskIdMeta,
        riskId.isAcceptableOrUnknown(data['risk_id']!, _riskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_riskIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {riskId};
  @override
  BookmarkEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkEntry(
      riskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarkEntriesTable createAlias(String alias) {
    return $BookmarkEntriesTable(attachedDatabase, alias);
  }
}

class BookmarkEntry extends DataClass implements Insertable<BookmarkEntry> {
  final String riskId;
  final DateTime createdAt;
  const BookmarkEntry({required this.riskId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['risk_id'] = Variable<String>(riskId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarkEntriesCompanion toCompanion(bool nullToAbsent) {
    return BookmarkEntriesCompanion(
      riskId: Value(riskId),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkEntry(
      riskId: serializer.fromJson<String>(json['riskId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'riskId': serializer.toJson<String>(riskId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarkEntry copyWith({String? riskId, DateTime? createdAt}) =>
      BookmarkEntry(
        riskId: riskId ?? this.riskId,
        createdAt: createdAt ?? this.createdAt,
      );
  BookmarkEntry copyWithCompanion(BookmarkEntriesCompanion data) {
    return BookmarkEntry(
      riskId: data.riskId.present ? data.riskId.value : this.riskId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkEntry(')
          ..write('riskId: $riskId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(riskId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkEntry &&
          other.riskId == this.riskId &&
          other.createdAt == this.createdAt);
}

class BookmarkEntriesCompanion extends UpdateCompanion<BookmarkEntry> {
  final Value<String> riskId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarkEntriesCompanion({
    this.riskId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarkEntriesCompanion.insert({
    required String riskId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : riskId = Value(riskId),
       createdAt = Value(createdAt);
  static Insertable<BookmarkEntry> custom({
    Expression<String>? riskId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (riskId != null) 'risk_id': riskId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarkEntriesCompanion copyWith({
    Value<String>? riskId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookmarkEntriesCompanion(
      riskId: riskId ?? this.riskId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (riskId.present) {
      map['risk_id'] = Variable<String>(riskId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkEntriesCompanion(')
          ..write('riskId: $riskId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizAttemptEntriesTable extends QuizAttemptEntries
    with TableInfo<$QuizAttemptEntriesTable, QuizAttemptEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizAttemptEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedIndexMeta = const VerificationMeta(
    'selectedIndex',
  );
  @override
  late final GeneratedColumn<int> selectedIndex = GeneratedColumn<int>(
    'selected_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _attemptedAtMeta = const VerificationMeta(
    'attemptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> attemptedAt = GeneratedColumn<DateTime>(
    'attempted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    questionId,
    selectedIndex,
    correct,
    attemptedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_attempt_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizAttemptEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected_index')) {
      context.handle(
        _selectedIndexMeta,
        selectedIndex.isAcceptableOrUnknown(
          data['selected_index']!,
          _selectedIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedIndexMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('attempted_at')) {
      context.handle(
        _attemptedAtMeta,
        attemptedAt.isAcceptableOrUnknown(
          data['attempted_at']!,
          _attemptedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attemptedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizAttemptEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAttemptEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      selectedIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_index'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      attemptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}attempted_at'],
      )!,
    );
  }

  @override
  $QuizAttemptEntriesTable createAlias(String alias) {
    return $QuizAttemptEntriesTable(attachedDatabase, alias);
  }
}

class QuizAttemptEntry extends DataClass
    implements Insertable<QuizAttemptEntry> {
  final int id;
  final String listId;
  final String questionId;
  final int selectedIndex;
  final bool correct;
  final DateTime attemptedAt;
  const QuizAttemptEntry({
    required this.id,
    required this.listId,
    required this.questionId,
    required this.selectedIndex,
    required this.correct,
    required this.attemptedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<String>(listId);
    map['question_id'] = Variable<String>(questionId);
    map['selected_index'] = Variable<int>(selectedIndex);
    map['correct'] = Variable<bool>(correct);
    map['attempted_at'] = Variable<DateTime>(attemptedAt);
    return map;
  }

  QuizAttemptEntriesCompanion toCompanion(bool nullToAbsent) {
    return QuizAttemptEntriesCompanion(
      id: Value(id),
      listId: Value(listId),
      questionId: Value(questionId),
      selectedIndex: Value(selectedIndex),
      correct: Value(correct),
      attemptedAt: Value(attemptedAt),
    );
  }

  factory QuizAttemptEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAttemptEntry(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      selectedIndex: serializer.fromJson<int>(json['selectedIndex']),
      correct: serializer.fromJson<bool>(json['correct']),
      attemptedAt: serializer.fromJson<DateTime>(json['attemptedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<String>(listId),
      'questionId': serializer.toJson<String>(questionId),
      'selectedIndex': serializer.toJson<int>(selectedIndex),
      'correct': serializer.toJson<bool>(correct),
      'attemptedAt': serializer.toJson<DateTime>(attemptedAt),
    };
  }

  QuizAttemptEntry copyWith({
    int? id,
    String? listId,
    String? questionId,
    int? selectedIndex,
    bool? correct,
    DateTime? attemptedAt,
  }) => QuizAttemptEntry(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    questionId: questionId ?? this.questionId,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    correct: correct ?? this.correct,
    attemptedAt: attemptedAt ?? this.attemptedAt,
  );
  QuizAttemptEntry copyWithCompanion(QuizAttemptEntriesCompanion data) {
    return QuizAttemptEntry(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      selectedIndex: data.selectedIndex.present
          ? data.selectedIndex.value
          : this.selectedIndex,
      correct: data.correct.present ? data.correct.value : this.correct,
      attemptedAt: data.attemptedAt.present
          ? data.attemptedAt.value
          : this.attemptedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptEntry(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('correct: $correct, ')
          ..write('attemptedAt: $attemptedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, listId, questionId, selectedIndex, correct, attemptedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAttemptEntry &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.questionId == this.questionId &&
          other.selectedIndex == this.selectedIndex &&
          other.correct == this.correct &&
          other.attemptedAt == this.attemptedAt);
}

class QuizAttemptEntriesCompanion extends UpdateCompanion<QuizAttemptEntry> {
  final Value<int> id;
  final Value<String> listId;
  final Value<String> questionId;
  final Value<int> selectedIndex;
  final Value<bool> correct;
  final Value<DateTime> attemptedAt;
  const QuizAttemptEntriesCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.selectedIndex = const Value.absent(),
    this.correct = const Value.absent(),
    this.attemptedAt = const Value.absent(),
  });
  QuizAttemptEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String listId,
    required String questionId,
    required int selectedIndex,
    required bool correct,
    required DateTime attemptedAt,
  }) : listId = Value(listId),
       questionId = Value(questionId),
       selectedIndex = Value(selectedIndex),
       correct = Value(correct),
       attemptedAt = Value(attemptedAt);
  static Insertable<QuizAttemptEntry> custom({
    Expression<int>? id,
    Expression<String>? listId,
    Expression<String>? questionId,
    Expression<int>? selectedIndex,
    Expression<bool>? correct,
    Expression<DateTime>? attemptedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (questionId != null) 'question_id': questionId,
      if (selectedIndex != null) 'selected_index': selectedIndex,
      if (correct != null) 'correct': correct,
      if (attemptedAt != null) 'attempted_at': attemptedAt,
    });
  }

  QuizAttemptEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? listId,
    Value<String>? questionId,
    Value<int>? selectedIndex,
    Value<bool>? correct,
    Value<DateTime>? attemptedAt,
  }) {
    return QuizAttemptEntriesCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      questionId: questionId ?? this.questionId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      correct: correct ?? this.correct,
      attemptedAt: attemptedAt ?? this.attemptedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (selectedIndex.present) {
      map['selected_index'] = Variable<int>(selectedIndex.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (attemptedAt.present) {
      map['attempted_at'] = Variable<DateTime>(attemptedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptEntriesCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('correct: $correct, ')
          ..write('attemptedAt: $attemptedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingEntriesTable extends SettingEntries
    with TableInfo<$SettingEntriesTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingEntriesTable createAlias(String alias) {
    return $SettingEntriesTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String key;
  final String value;
  const SettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingEntry copyWith({String? key, String? value}) =>
      SettingEntry(key: key ?? this.key, value: value ?? this.value);
  SettingEntry copyWithCompanion(SettingEntriesCompanion data) {
    return SettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingEntriesCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReadProgressTable readProgress = $ReadProgressTable(this);
  late final $BookmarkEntriesTable bookmarkEntries = $BookmarkEntriesTable(
    this,
  );
  late final $QuizAttemptEntriesTable quizAttemptEntries =
      $QuizAttemptEntriesTable(this);
  late final $SettingEntriesTable settingEntries = $SettingEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    readProgress,
    bookmarkEntries,
    quizAttemptEntries,
    settingEntries,
  ];
}

typedef $$ReadProgressTableCreateCompanionBuilder =
    ReadProgressCompanion Function({
      required String riskId,
      required DateTime readAt,
      Value<int> rowid,
    });
typedef $$ReadProgressTableUpdateCompanionBuilder =
    ReadProgressCompanion Function({
      Value<String> riskId,
      Value<DateTime> readAt,
      Value<int> rowid,
    });

class $$ReadProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ReadProgressTable> {
  $$ReadProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get riskId => $composableBuilder(
    column: $table.riskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadProgressTable> {
  $$ReadProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get riskId => $composableBuilder(
    column: $table.riskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadProgressTable> {
  $$ReadProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get riskId =>
      $composableBuilder(column: $table.riskId, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$ReadProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadProgressTable,
          ReadProgressEntry,
          $$ReadProgressTableFilterComposer,
          $$ReadProgressTableOrderingComposer,
          $$ReadProgressTableAnnotationComposer,
          $$ReadProgressTableCreateCompanionBuilder,
          $$ReadProgressTableUpdateCompanionBuilder,
          (
            ReadProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $ReadProgressTable,
              ReadProgressEntry
            >,
          ),
          ReadProgressEntry,
          PrefetchHooks Function()
        > {
  $$ReadProgressTableTableManager(_$AppDatabase db, $ReadProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> riskId = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadProgressCompanion(
                riskId: riskId,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String riskId,
                required DateTime readAt,
                Value<int> rowid = const Value.absent(),
              }) => ReadProgressCompanion.insert(
                riskId: riskId,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadProgressTable, ReadProgressEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReadProgressTable,
                    ReadProgressEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadProgressTable,
      ReadProgressEntry,
      $$ReadProgressTableFilterComposer,
      $$ReadProgressTableOrderingComposer,
      $$ReadProgressTableAnnotationComposer,
      $$ReadProgressTableCreateCompanionBuilder,
      $$ReadProgressTableUpdateCompanionBuilder,
      (
        ReadProgressEntry,
        BaseReferences<_$AppDatabase, $ReadProgressTable, ReadProgressEntry>,
      ),
      ReadProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$BookmarkEntriesTableCreateCompanionBuilder =
    BookmarkEntriesCompanion Function({
      required String riskId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BookmarkEntriesTableUpdateCompanionBuilder =
    BookmarkEntriesCompanion Function({
      Value<String> riskId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BookmarkEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarkEntriesTable> {
  $$BookmarkEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get riskId => $composableBuilder(
    column: $table.riskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarkEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarkEntriesTable> {
  $$BookmarkEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get riskId => $composableBuilder(
    column: $table.riskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarkEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarkEntriesTable> {
  $$BookmarkEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get riskId =>
      $composableBuilder(column: $table.riskId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarkEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarkEntriesTable,
          BookmarkEntry,
          $$BookmarkEntriesTableFilterComposer,
          $$BookmarkEntriesTableOrderingComposer,
          $$BookmarkEntriesTableAnnotationComposer,
          $$BookmarkEntriesTableCreateCompanionBuilder,
          $$BookmarkEntriesTableUpdateCompanionBuilder,
          (
            BookmarkEntry,
            BaseReferences<_$AppDatabase, $BookmarkEntriesTable, BookmarkEntry>,
          ),
          BookmarkEntry,
          PrefetchHooks Function()
        > {
  $$BookmarkEntriesTableTableManager(
    _$AppDatabase db,
    $BookmarkEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> riskId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarkEntriesCompanion(
                riskId: riskId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String riskId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BookmarkEntriesCompanion.insert(
                riskId: riskId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarkEntriesTable, BookmarkEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BookmarkEntriesTable,
                    BookmarkEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarkEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarkEntriesTable,
      BookmarkEntry,
      $$BookmarkEntriesTableFilterComposer,
      $$BookmarkEntriesTableOrderingComposer,
      $$BookmarkEntriesTableAnnotationComposer,
      $$BookmarkEntriesTableCreateCompanionBuilder,
      $$BookmarkEntriesTableUpdateCompanionBuilder,
      (
        BookmarkEntry,
        BaseReferences<_$AppDatabase, $BookmarkEntriesTable, BookmarkEntry>,
      ),
      BookmarkEntry,
      PrefetchHooks Function()
    >;
typedef $$QuizAttemptEntriesTableCreateCompanionBuilder =
    QuizAttemptEntriesCompanion Function({
      Value<int> id,
      required String listId,
      required String questionId,
      required int selectedIndex,
      required bool correct,
      required DateTime attemptedAt,
    });
typedef $$QuizAttemptEntriesTableUpdateCompanionBuilder =
    QuizAttemptEntriesCompanion Function({
      Value<int> id,
      Value<String> listId,
      Value<String> questionId,
      Value<int> selectedIndex,
      Value<bool> correct,
      Value<DateTime> attemptedAt,
    });

class $$QuizAttemptEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $QuizAttemptEntriesTable> {
  $$QuizAttemptEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuizAttemptEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizAttemptEntriesTable> {
  $$QuizAttemptEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuizAttemptEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizAttemptEntriesTable> {
  $$QuizAttemptEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<DateTime> get attemptedAt => $composableBuilder(
    column: $table.attemptedAt,
    builder: (column) => column,
  );
}

class $$QuizAttemptEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuizAttemptEntriesTable,
          QuizAttemptEntry,
          $$QuizAttemptEntriesTableFilterComposer,
          $$QuizAttemptEntriesTableOrderingComposer,
          $$QuizAttemptEntriesTableAnnotationComposer,
          $$QuizAttemptEntriesTableCreateCompanionBuilder,
          $$QuizAttemptEntriesTableUpdateCompanionBuilder,
          (
            QuizAttemptEntry,
            BaseReferences<
              _$AppDatabase,
              $QuizAttemptEntriesTable,
              QuizAttemptEntry
            >,
          ),
          QuizAttemptEntry,
          PrefetchHooks Function()
        > {
  $$QuizAttemptEntriesTableTableManager(
    _$AppDatabase db,
    $QuizAttemptEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizAttemptEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizAttemptEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizAttemptEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<int> selectedIndex = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<DateTime> attemptedAt = const Value.absent(),
              }) => QuizAttemptEntriesCompanion(
                id: id,
                listId: listId,
                questionId: questionId,
                selectedIndex: selectedIndex,
                correct: correct,
                attemptedAt: attemptedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String listId,
                required String questionId,
                required int selectedIndex,
                required bool correct,
                required DateTime attemptedAt,
              }) => QuizAttemptEntriesCompanion.insert(
                id: id,
                listId: listId,
                questionId: questionId,
                selectedIndex: selectedIndex,
                correct: correct,
                attemptedAt: attemptedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuizAttemptEntriesTable, QuizAttemptEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $QuizAttemptEntriesTable,
                    QuizAttemptEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuizAttemptEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuizAttemptEntriesTable,
      QuizAttemptEntry,
      $$QuizAttemptEntriesTableFilterComposer,
      $$QuizAttemptEntriesTableOrderingComposer,
      $$QuizAttemptEntriesTableAnnotationComposer,
      $$QuizAttemptEntriesTableCreateCompanionBuilder,
      $$QuizAttemptEntriesTableUpdateCompanionBuilder,
      (
        QuizAttemptEntry,
        BaseReferences<
          _$AppDatabase,
          $QuizAttemptEntriesTable,
          QuizAttemptEntry
        >,
      ),
      QuizAttemptEntry,
      PrefetchHooks Function()
    >;
typedef $$SettingEntriesTableCreateCompanionBuilder =
    SettingEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingEntriesTableUpdateCompanionBuilder =
    SettingEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingEntriesTable,
          SettingEntry,
          $$SettingEntriesTableFilterComposer,
          $$SettingEntriesTableOrderingComposer,
          $$SettingEntriesTableAnnotationComposer,
          $$SettingEntriesTableCreateCompanionBuilder,
          $$SettingEntriesTableUpdateCompanionBuilder,
          (
            SettingEntry,
            BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingEntry>,
          ),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingEntriesTableTableManager(
    _$AppDatabase db,
    $SettingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingEntriesTable, SettingEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingEntriesTable,
                    SettingEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingEntriesTable,
      SettingEntry,
      $$SettingEntriesTableFilterComposer,
      $$SettingEntriesTableOrderingComposer,
      $$SettingEntriesTableAnnotationComposer,
      $$SettingEntriesTableCreateCompanionBuilder,
      $$SettingEntriesTableUpdateCompanionBuilder,
      (
        SettingEntry,
        BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingEntry>,
      ),
      SettingEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReadProgressTableTableManager get readProgress =>
      $$ReadProgressTableTableManager(_db, _db.readProgress);
  $$BookmarkEntriesTableTableManager get bookmarkEntries =>
      $$BookmarkEntriesTableTableManager(_db, _db.bookmarkEntries);
  $$QuizAttemptEntriesTableTableManager get quizAttemptEntries =>
      $$QuizAttemptEntriesTableTableManager(_db, _db.quizAttemptEntries);
  $$SettingEntriesTableTableManager get settingEntries =>
      $$SettingEntriesTableTableManager(_db, _db.settingEntries);
}
