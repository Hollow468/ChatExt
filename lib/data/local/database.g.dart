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

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creatorPeerIdMeta =
      const VerificationMeta('creatorPeerId');
  @override
  late final GeneratedColumn<String> creatorPeerId = GeneratedColumn<String>(
      'creator_peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, creatorPeerId, avatarUrl, description, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<Group> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('creator_peer_id')) {
      context.handle(
          _creatorPeerIdMeta,
          creatorPeerId.isAcceptableOrUnknown(
              data['creator_peer_id']!, _creatorPeerIdMeta));
    } else if (isInserting) {
      context.missing(_creatorPeerIdMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      creatorPeerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}creator_peer_id'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  /// Unique group identifier (UUID v4).
  final String id;

  /// Display name of the group.
  final String name;

  /// Peer ID of the group creator / admin.
  final String creatorPeerId;

  /// Optional avatar URL.
  final String? avatarUrl;

  /// Optional group description.
  final String? description;

  /// Unix timestamp in milliseconds when the group was created.
  final int createdAt;
  const Group(
      {required this.id,
      required this.name,
      required this.creatorPeerId,
      this.avatarUrl,
      this.description,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['creator_peer_id'] = Variable<String>(creatorPeerId);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      creatorPeerId: Value(creatorPeerId),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      creatorPeerId: serializer.fromJson<String>(json['creatorPeerId']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'creatorPeerId': serializer.toJson<String>(creatorPeerId),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Group copyWith(
          {String? id,
          String? name,
          String? creatorPeerId,
          Value<String?> avatarUrl = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? createdAt}) =>
      Group(
        id: id ?? this.id,
        name: name ?? this.name,
        creatorPeerId: creatorPeerId ?? this.creatorPeerId,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
      );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      creatorPeerId: data.creatorPeerId.present
          ? data.creatorPeerId.value
          : this.creatorPeerId,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorPeerId: $creatorPeerId, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, creatorPeerId, avatarUrl, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.name == this.name &&
          other.creatorPeerId == this.creatorPeerId &&
          other.avatarUrl == this.avatarUrl &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> creatorPeerId;
  final Value<String?> avatarUrl;
  final Value<String?> description;
  final Value<int> createdAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.creatorPeerId = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required String name,
    required String creatorPeerId,
    this.avatarUrl = const Value.absent(),
    this.description = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        creatorPeerId = Value(creatorPeerId),
        createdAt = Value(createdAt);
  static Insertable<Group> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? creatorPeerId,
    Expression<String>? avatarUrl,
    Expression<String>? description,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (creatorPeerId != null) 'creator_peer_id': creatorPeerId,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? creatorPeerId,
      Value<String?>? avatarUrl,
      Value<String?>? description,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorPeerId: creatorPeerId ?? this.creatorPeerId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (creatorPeerId.present) {
      map['creator_peer_id'] = Variable<String>(creatorPeerId.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('creatorPeerId: $creatorPeerId, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
      'peer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [groupId, peerId, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  VerificationContext validateIntegrity(Insertable<GroupMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('peer_id')) {
      context.handle(_peerIdMeta,
          peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta));
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, peerId};
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      peerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peer_id'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}joined_at'])!,
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  /// Group ID (foreign key to [Groups.id]).
  final String groupId;

  /// Peer ID of the member.
  final String peerId;

  /// Unix timestamp in milliseconds when the member joined.
  final int joinedAt;
  const GroupMember(
      {required this.groupId, required this.peerId, required this.joinedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['peer_id'] = Variable<String>(peerId);
    map['joined_at'] = Variable<int>(joinedAt);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      groupId: Value(groupId),
      peerId: Value(peerId),
      joinedAt: Value(joinedAt),
    );
  }

  factory GroupMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      groupId: serializer.fromJson<String>(json['groupId']),
      peerId: serializer.fromJson<String>(json['peerId']),
      joinedAt: serializer.fromJson<int>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'peerId': serializer.toJson<String>(peerId),
      'joinedAt': serializer.toJson<int>(joinedAt),
    };
  }

  GroupMember copyWith({String? groupId, String? peerId, int? joinedAt}) =>
      GroupMember(
        groupId: groupId ?? this.groupId,
        peerId: peerId ?? this.peerId,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      peerId: data.peerId.present ? data.peerId.value : this.peerId,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('groupId: $groupId, ')
          ..write('peerId: $peerId, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, peerId, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.groupId == this.groupId &&
          other.peerId == this.peerId &&
          other.joinedAt == this.joinedAt);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<String> groupId;
  final Value<String> peerId;
  final Value<int> joinedAt;
  final Value<int> rowid;
  const GroupMembersCompanion({
    this.groupId = const Value.absent(),
    this.peerId = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    required String groupId,
    required String peerId,
    required int joinedAt,
    this.rowid = const Value.absent(),
  })  : groupId = Value(groupId),
        peerId = Value(peerId),
        joinedAt = Value(joinedAt);
  static Insertable<GroupMember> custom({
    Expression<String>? groupId,
    Expression<String>? peerId,
    Expression<int>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (peerId != null) 'peer_id': peerId,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembersCompanion copyWith(
      {Value<String>? groupId,
      Value<String>? peerId,
      Value<int>? joinedAt,
      Value<int>? rowid}) {
    return GroupMembersCompanion(
      groupId: groupId ?? this.groupId,
      peerId: peerId ?? this.peerId,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('peerId: $peerId, ')
          ..write('joinedAt: $joinedAt, ')
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
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final MessageDao messageDao = MessageDao(this as AppDatabase);
  late final ContactDao contactDao = ContactDao(this as AppDatabase);
  late final GroupDao groupDao = GroupDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [messages, contacts, groups, groupMembers];
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
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  required String id,
  required String name,
  required String creatorPeerId,
  Value<String?> avatarUrl,
  Value<String?> description,
  required int createdAt,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> creatorPeerId,
  Value<String?> avatarUrl,
  Value<String?> description,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get creatorPeerId => $composableBuilder(
      column: $table.creatorPeerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get creatorPeerId => $composableBuilder(
      column: $table.creatorPeerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get creatorPeerId => $composableBuilder(
      column: $table.creatorPeerId, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, BaseReferences<_$AppDatabase, $GroupsTable, Group>),
    Group,
    PrefetchHooks Function()> {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> creatorPeerId = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            name: name,
            creatorPeerId: creatorPeerId,
            avatarUrl: avatarUrl,
            description: description,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String creatorPeerId,
            Value<String?> avatarUrl = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            name: name,
            creatorPeerId: creatorPeerId,
            avatarUrl: avatarUrl,
            description: description,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, BaseReferences<_$AppDatabase, $GroupsTable, Group>),
    Group,
    PrefetchHooks Function()>;
typedef $$GroupMembersTableCreateCompanionBuilder = GroupMembersCompanion
    Function({
  required String groupId,
  required String peerId,
  required int joinedAt,
  Value<int> rowid,
});
typedef $$GroupMembersTableUpdateCompanionBuilder = GroupMembersCompanion
    Function({
  Value<String> groupId,
  Value<String> peerId,
  Value<int> joinedAt,
  Value<int> rowid,
});

class $$GroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));
}

class $$GroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get peerId => $composableBuilder(
      column: $table.peerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));
}

class $$GroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get peerId =>
      $composableBuilder(column: $table.peerId, builder: (column) => column);

  GeneratedColumn<int> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$GroupMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (
      GroupMember,
      BaseReferences<_$AppDatabase, $GroupMembersTable, GroupMember>
    ),
    GroupMember,
    PrefetchHooks Function()> {
  $$GroupMembersTableTableManager(_$AppDatabase db, $GroupMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> groupId = const Value.absent(),
            Value<String> peerId = const Value.absent(),
            Value<int> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupMembersCompanion(
            groupId: groupId,
            peerId: peerId,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String groupId,
            required String peerId,
            required int joinedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupMembersCompanion.insert(
            groupId: groupId,
            peerId: peerId,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GroupMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (
      GroupMember,
      BaseReferences<_$AppDatabase, $GroupMembersTable, GroupMember>
    ),
    GroupMember,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
}
