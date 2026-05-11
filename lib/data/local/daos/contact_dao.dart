import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/contacts.dart';

part 'contact_dao.g.dart';

/// Data-access object for the [Contacts] table.
@DriftAccessor(tables: [Contacts])
class ContactDao extends DatabaseAccessor<AppDatabase> with _$ContactDaoMixin {
  ContactDao(AppDatabase db) : super(db);

  // ── Inserts / Updates ──────────────────────────────────────────────────────

  /// Inserts a new contact or updates the existing one if [peerId] matches.
  Future<int> insertOrUpdate(ContactsCompanion entry) {
    return into(contacts).insertOnConflictUpdate(entry);
  }

  // ── Queries ────────────────────────────────────────────────────────────────

  /// Returns all known contacts ordered by display name.
  Future<List<Contact>> getAllContacts() {
    return (select(contacts)
          ..orderBy([(c) => OrderingTerm.asc(c.displayName)]))
        .get();
  }

  /// Returns a single contact by [peerId], or `null` if not found.
  Future<Contact?> getContactByPeerId(String peerId) {
    return (select(contacts)..where((c) => c.peerId.equals(peerId)))
        .getSingleOrNull();
  }

  /// Searches contacts whose [displayName] contains [query] (case-insensitive).
  Future<List<Contact>> searchContacts(String query) {
    return (select(contacts)
          ..where(
            (c) => c.displayName.like('%${query.toLowerCase()}%'),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.displayName)]))
        .get();
  }

  // ── Deletes ────────────────────────────────────────────────────────────────

  /// Deletes a contact by [peerId].
  Future<int> deleteContact(String peerId) {
    return (delete(contacts)..where((c) => c.peerId.equals(peerId))).go();
  }
}
