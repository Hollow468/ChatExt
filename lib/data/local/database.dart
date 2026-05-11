import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/contact_dao.dart';
import 'daos/message_dao.dart';
import 'tables/contacts.dart';
import 'tables/messages.dart';

part 'database.g.dart';

/// Application-wide Drift database.
///
/// Uses drift_sqflite on Android/iOS and NativeDatabase on desktop.
@DriftDatabase(tables: [Messages, Contacts], daos: [MessageDao, ContactDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test constructor that accepts a custom [QueryExecutor].
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

QueryExecutor _openConnection() {
  if (Platform.isAndroid || Platform.isIOS) {
    // Mobile: use drift_sqflite (wraps sqflite, no FFI needed)
    return SqfliteQueryExecutor.inDatabaseFolder(
      path: 'chatext.sqlite',
      singleInstance: true,
    );
  } else {
    // Desktop: use NativeDatabase via FFI
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'chatext.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
