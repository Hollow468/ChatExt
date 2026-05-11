// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
      'sender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _replyToMeta =
      const VerificationMeta('replyTo');
  @override
  late final GeneratedColumn<String> replyTo = GeneratedColumn<String>(
      'reply_to', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mediaUrlMeta =
      const VerificationMeta('mediaUrl');
  @override
  late final GeneratedColumn<String> mediaUrl = GeneratedColumn<String>(
      'media_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, sender, content, timestamp, type, replyTo, mediaUrl, isRead];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(_senderMeta,
          sender.isAcceptableOrUnknown(data['sender']!, _senderMeta));
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('reply_to')) {
      context.handle(_replyToMeta,
          replyTo.isAcceptableOrUnknown(data['reply_to']!, _replyToMeta));
    }
    if (data.containsKey('media_url')) {
      context.handle(_mediaUrlMeta,
          mediaUrl.isAcceptableOrUnknown(data['media_url']!, _mediaUrlMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      replyTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_to']),
      mediaUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_url']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  /// Unique message identifier (UUID v4).
  final String id;

  /// Base58-encoded public key of the message sender.
  final String sender;

  /// Plain-text body of the message.
  final String content;

  /// Unix timestamp in milliseconds when the message was created.
  final int timestamp;

  /// Message type encoded as an integer (see [MessageType] enum).
  ///
  /// 0 = text, 1 = image, 2 = file, 3 = system.
  final int type;

  /// Optional ID of the message being replied to.
  final String? replyTo;

  /// Optional URL for media attachments.
  final String? mediaUrl;

  /// Whether the message has been read by the local user.
  final bool isRead;
  const Message(
      {required this.id,
      required this.sender,
      required this.content,
      required this.timestamp,
      required this.type,
      this.replyTo,
      this.mediaUrl,
      required this.isRead});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sender'] = Variable<String>(sender);
    map['content'] = Variable<String>(content);
    map['timestamp'] = Variable<int>(timestamp);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || replyTo != null) {
      map['reply_to'] = Variable<String>(replyTo);
    }
    if (!nullToAbsent || mediaUrl != null) {
      map['media_url'] = Variable<String>(mediaUrl);
    }
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      sender: Value(sender),
      content: Value(content),
      timestamp: Value(timestamp),
      type: Value(type),
      replyTo: replyTo == null && nullToAbsent
          ? const Value.absent()
          : Value(replyTo),
      mediaUrl: mediaUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaUrl),
      isRead: Value(isRead),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      sender: serializer.fromJson<String>(json['sender']),
      content: serializer.fromJson<String>(json['content']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      type: serializer.fromJson<int>(json['type']),
      replyTo: serializer.fromJson<String?>(json['replyTo']),
      mediaUrl: serializer.fromJson<String?>(json['mediaUrl']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sender': serializer.toJson<String>(sender),
      'content': serializer.toJson<String>(content),
      'timestamp': serializer.toJson<int>(timestamp),
      'type': serializer.toJson<int>(type),
      'replyTo': serializer.toJson<String?>(replyTo),
      'mediaUrl': serializer.toJson<String?>(mediaUrl),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  Message copyWith(
          {String? id,
          String? sender,
          String? content,
          int? timestamp,
          int? type,
          Value<String?> replyTo = const Value.absent(),
          Value<String?> mediaUrl = const Value.absent(),
          bool? isRead}) =>
      Message(
        id: id ?? this.id,
        sender: sender ?? this.sender,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        type: type ?? this.type,
        replyTo: replyTo.present ? replyTo.value : this.replyTo,
        mediaUrl: mediaUrl.present ? mediaUrl.value : this.mediaUrl,
        isRead: isRead ?? this.isRead,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      sender: data.sender.present ? data.sender.value : this.sender,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      type: data.type.present ? data.type.value : this.type,
      replyTo: data.replyTo.present ? data.replyTo.value : this.replyTo,
      mediaUrl: data.mediaUrl.present ? data.mediaUrl.value : this.mediaUrl,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('replyTo: $replyTo, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sender, content, timestamp, type, replyTo, mediaUrl, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.sender == this.sender &&
          other.content == this.content &&
          other.timestamp == this.timestamp &&
          other.type == this.type &&
          other.replyTo == this.replyTo &&
          other.mediaUrl == this.mediaUrl &&
          other.isRead == this.isRead);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> sender;
  final Value<String> content;
  final Value<int> timestamp;
  final Value<int> type;
  final Value<String?> replyTo;
  final Value<String?> mediaUrl;
  final Value<bool> isRead;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.sender = const Value.absent(),
    this.content = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.type = const Value.absent(),
    this.replyTo = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String sender,
    required String content,
    required int timestamp,
    this.type = const Value.absent(),
    this.replyTo = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sender = Value(sender),
        content = Value(content),
        timestamp = Value(timestamp);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? sender,
    Expression<String>? content,
    Expression<int>? timestamp,
    Expression<int>? type,
    Expression<String>? replyTo,
    Expression<String>? mediaUrl,
    Expression<bool>? isRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sender != null) 'sender': sender,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (type != null) 'type': type,
      if (replyTo != null) 'reply_to': replyTo,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (isRead != null) 'is_read': isRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? sender,
      Value<String>? content,
      Value<int>? timestamp,
      Value<int>? type,
      Value<String?>? replyTo,
      Value<String?>? mediaUrl,
      Value<bool>? isRead,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      replyTo: replyTo ?? this.replyTo,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isRead: isRead ?? this.isRead,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (replyTo.present) {
      map['reply_to'] = Variable<String>(replyTo.value);
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('replyTo: $replyTo, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('isRead: $isRead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageAtMeta =
      const VerificationMeta('lastMessageAt');
  @override
  late final GeneratedColumn<int> lastMessageAt = GeneratedColumn<int>(
      'last_message_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isOnlineMeta =
      const VerificationMeta('isOnline');
  @override
  late final GeneratedColumn<bool> isOnline = GeneratedColumn<bool>(
      'is_online', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_online" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _publicKeyDataMeta =
      const VerificationMeta('publicKeyData');
  @override
  late final GeneratedColumn<Uint8List> publicKeyData =
      GeneratedColumn<Uint8List>('public_key_data', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [peerId, displayName, avatarUrl, lastMessageAt, isOnline, publicKeyData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
          _lastMessageAtMeta,
          lastMessageAt.isAcceptableOrUnknown(
              data['last_message_at']!, _lastMessageAtMeta));
    }
    if (data.containsKey('is_online')) {
      context.handle(_isOnlineMeta,
          isOnline.isAcceptableOrUnknown(data['is_online']!, _isOnlineMeta));
    }
    if (data.containsKey('public_key_data')) {
      context.handle(
          _publicKeyDataMeta,
          publicKeyData.isAcceptableOrUnknown(
              data['public_key_data']!, _publicKeyDataMeta));
    } else if (isInserting) {
      context.missing(_publicKeyDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerId};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      lastMessageAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_message_at']),
      isOnline: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_online'])!,
      publicKeyData: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}public_key_data'])!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  /// Base58-encoded public key that uniquely identifies this peer.
  final String peerId;

  /// Human-readable display name.
  final String displayName;

  /// Optional URL for the contact's avatar image.
  final String? avatarUrl;

  /// Unix milliseconds of the last message exchanged with this contact.
  final int? lastMessageAt;

  /// Whether the contact is currently online / reachable.
  final bool isOnline;

  /// Raw public key bytes for cryptographic operations.
  final Uint8List publicKeyData;
  const Contact(
      {required this.peerId,
      required this.displayName,
      this.avatarUrl,
      this.lastMessageAt,
      required this.isOnline,
      required this.publicKeyData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_id'] = Variable<String>(peerId);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<int>(lastMessageAt);
    }
    map['is_online'] = Variable<bool>(isOnline);
    map['public_key_data'] = Variable<Uint8List>(publicKeyData);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      peerId: Value(peerId),
      displayName: Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
      isOnline: Value(isOnline),
      publicKeyData: Value(publicKeyData),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      peerId: serializer.fromJson<String>(json['peerId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      lastMessageAt: serializer.fromJson<int?>(json['lastMessageAt']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
      publicKeyData: serializer.fromJson<Uint8List>(json['publicKeyData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerId': serializer.toJson<String>(peerId),
      'displayName': serializer.toJson<String>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'lastMessageAt': serializer.toJson<int?>(lastMessageAt),
      'isOnline': serializer.toJson<bool>(isOnline),
      'publicKeyData': serializer.toJson<Uint8List>(publicKeyData),
    };
  }

  Contact copyWith(
          {String? peerId,
          String? displayName,
          Value<String?> avatarUrl = const Value.absent(),
          Value<int?> lastMessageAt = const Value.absent(),
          bool? isOnline,
          Uint8List? publicKeyData}) =>
      Contact(
        peerId: peerId ?? this.peerId,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        lastMessageAt:
            lastMessageAt.present ? lastMessageAt.value : this.lastMessageAt,
        isOnline: isOnline ?? this.isOnline,
        publicKeyData: publicKeyData ?? this.publicKeyData,
      );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      peerId: data.peerId.present ? data.peerId.value : this.peerId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      isOnline: data.isOnline.present ? data.isOnline.value : this.isOnline,
      publicKeyData: data.publicKeyData.present
          ? data.publicKeyData.value
          : this.publicKeyData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('peerId: $peerId, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('isOnline: $isOnline, ')
          ..write('publicKeyData: $publicKeyData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(peerId, displayName, avatarUrl, lastMessageAt,
      isOnline, $driftBlobEquality.hash(publicKeyData));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.peerId == this.peerId &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.lastMessageAt == this.lastMessageAt &&
          other.isOnline == this.isOnline &&
          $driftBlobEquality.equals(other.publicKeyData, this.publicKeyData));
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> peerId;
  final Value<String> displayName;
  final Value<String?> avatarUrl;
  final Value<int?> lastMessageAt;
  final Value<bool> isOnline;
  final Value<Uint8List> publicKeyData;
  final Value<int> rowid;
  const ContactsCompanion({
    this.peerId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.isOnline = const Value.absent(),
    this.publicKeyData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String peerId,
    required String displayName,
    this.avatarUrl = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.isOnline = const Value.absent(),
    required Uint8List publicKeyData,
    this.rowid = const Value.absent(),
  })  : peerId = Value(peerId),
        displayName = Value(displayName),
        publicKeyData = Value(publicKeyData);
  static Insertable<Contact> custom({
    Expression<String>? peerId,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<int>? lastMessageAt,
    Expression<bool>? isOnline,
    Expression<Uint8List>? publicKeyData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerId != null) 'peer_id': peerId,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (isOnline != null) 'is_online': isOnline,
      if (publicKeyData != null) 'public_key_data': publicKeyData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith(
      {Value<String>? peerId,
      Value<String>? displayName,
      Value<String?>? avatarUrl,
      Value<int?>? lastMessageAt,
      Value<bool>? isOnline,
      Value<Uint8List>? publicKeyData,
      Value<int>? rowid}) {
    return ContactsCompanion(
      peerId: peerId ?? this.peerId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isOnline: isOnline ?? this.isOnline,
      publicKeyData: publicKeyData ?? this.publicKeyData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<int>(lastMessageAt.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    if (publicKeyData.present) {
      map['public_key_data'] = Variable<Uint8List>(publicKeyData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('peerId: $peerId, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('isOnline: $isOnline, ')
          ..write('publicKeyData: $publicKeyData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final MessageDao messageDao = MessageDao(this as AppDatabase);
  late final ContactDao contactDao = ContactDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [messages, contacts];
}

typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String sender,
  required String content,
  required int timestamp,
  Value<int> type,
  Value<String?> replyTo,
  Value<String?> mediaUrl,
  Value<bool> isRead,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> sender,
  Value<String> content,
  Value<int> timestamp,
  Value<int> type,
  Value<String?> replyTo,
  Value<String?> mediaUrl,
  Value<bool> isRead,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyTo => $composableBuilder(
      column: $table.replyTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaUrl => $composableBuilder(
      column: $table.mediaUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sender => $composableBuilder(
      column: $table.sender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyTo => $composableBuilder(
      column: $table.replyTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaUrl => $composableBuilder(
      column: $table.mediaUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get replyTo =>
      $composableBuilder(column: $table.replyTo, builder: (column) => column);

  GeneratedColumn<String> get mediaUrl =>
      $composableBuilder(column: $table.mediaUrl, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sender = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<String?> replyTo = const Value.absent(),
            Value<String?> mediaUrl = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            sender: sender,
            content: content,
            timestamp: timestamp,
            type: type,
            replyTo: replyTo,
            mediaUrl: mediaUrl,
            isRead: isRead,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sender,
            required String content,
            required int timestamp,
            Value<int> type = const Value.absent(),
            Value<String?> replyTo = const Value.absent(),
            Value<String?> mediaUrl = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            sender: sender,
            content: content,
            timestamp: timestamp,
            type: type,
            replyTo: replyTo,
            mediaUrl: mediaUrl,
            isRead: isRead,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  required String peerId,
  required String displayName,
  Value<String?> avatarUrl,
  Value<int?> lastMessageAt,
  Value<bool> isOnline,
  required Uint8List publicKeyData,
  Value<int> rowid,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<String> peerId,
  Value<String> displayName,
  Value<String?> avatarUrl,
  Value<int?> lastMessageAt,
  Value<bool> isOnline,
  Value<Uint8List> publicKeyData,
  Value<int> rowid,
});

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOnline => $composableBuilder(
      column: $table.isOnline, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get publicKeyData => $composableBuilder(
      column: $table.publicKeyData, builder: (column) => ColumnFilters(column));
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOnline => $composableBuilder(
      column: $table.isOnline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get publicKeyData => $composableBuilder(
      column: $table.publicKeyData,
      builder: (column) => ColumnOrderings(column));
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerId =>
      $composableBuilder(column: $table.peerId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => column);

  GeneratedColumn<bool> get isOnline =>
      $composableBuilder(column: $table.isOnline, builder: (column) => column);

  GeneratedColumn<Uint8List> get publicKeyData => $composableBuilder(
      column: $table.publicKeyData, builder: (column) => column);
}

class $$ContactsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
    Contact,
    PrefetchHooks Function()> {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> peerId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<int?> lastMessageAt = const Value.absent(),
            Value<bool> isOnline = const Value.absent(),
            Value<Uint8List> publicKeyData = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion(
            peerId: peerId,
            displayName: displayName,
            avatarUrl: avatarUrl,
            lastMessageAt: lastMessageAt,
            isOnline: isOnline,
            publicKeyData: publicKeyData,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String peerId,
            required String displayName,
            Value<String?> avatarUrl = const Value.absent(),
            Value<int?> lastMessageAt = const Value.absent(),
            Value<bool> isOnline = const Value.absent(),
            required Uint8List publicKeyData,
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion.insert(
            peerId: peerId,
            displayName: displayName,
            avatarUrl: avatarUrl,
            lastMessageAt: lastMessageAt,
            isOnline: isOnline,
            publicKeyData: publicKeyData,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContactsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
    Contact,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
}
