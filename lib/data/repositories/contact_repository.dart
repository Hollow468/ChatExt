import 'dart:typed_data';

import 'package:drift/drift.dart';

import '../local/daos/contact_dao.dart';
import '../local/database.dart';
import '../models/chat_contact.dart' as model;

/// Repository for managing chat contacts.
///
/// Wraps [ContactDao] to provide domain-level operations and model mapping.
class ContactRepository {
  ContactRepository({required ContactDao contactDao}) : _dao = contactDao;

  final ContactDao _dao;

  // ── Create / Update ────────────────────────────────────────────────────────

  /// Persists a new contact or updates the existing one matched by [peerId].
  Future<void> addContact({
    required String peerId,
    required String displayName,
    required Uint8List publicKeyData,
    String? avatarUrl,
  }) async {
    await _dao.insertOrUpdate(
      ContactsCompanion(
        peerId: Value(peerId),
        displayName: Value(displayName),
        avatarUrl: Value(avatarUrl),
        publicKeyData: Value(publicKeyData),
      ),
    );
  }

  /// Updates the online status of the contact identified by [peerId].
  Future<void> updateOnlineStatus({
    required String peerId,
    required bool isOnline,
  }) async {
    final existing = await _dao.getContactByPeerId(peerId);
    if (existing == null) return;

    await _dao.insertOrUpdate(
      ContactsCompanion(
        peerId: Value(peerId),
        displayName: Value(existing.displayName),
        avatarUrl: Value(existing.avatarUrl),
        lastMessageAt: Value(existing.lastMessageAt),
        isOnline: Value(isOnline),
        publicKeyData: Value(existing.publicKeyData),
      ),
    );
  }

  /// Updates the [lastMessageAt] timestamp for [peerId].
  Future<void> updateLastMessageAt({
    required String peerId,
    required int timestampMs,
  }) async {
    final existing = await _dao.getContactByPeerId(peerId);
    if (existing == null) return;

    await _dao.insertOrUpdate(
      ContactsCompanion(
        peerId: Value(peerId),
        displayName: Value(existing.displayName),
        avatarUrl: Value(existing.avatarUrl),
        lastMessageAt: Value(timestampMs),
        isOnline: Value(existing.isOnline),
        publicKeyData: Value(existing.publicKeyData),
      ),
    );
  }

  // ── Queries ────────────────────────────────────────────────────────────────

  /// Returns all contacts, mapped to domain models.
  Future<List<model.ChatContact>> getContacts() async {
    final rows = await _dao.getAllContacts();
    return rows.map(_fromRow).toList();
  }

  /// Returns a single contact by [peerId], or `null`.
  Future<model.ChatContact?> getContactByPeerId(String peerId) async {
    final row = await _dao.getContactByPeerId(peerId);
    return row == null ? null : _fromRow(row);
  }

  /// Searches contacts whose display name contains [query].
  Future<List<model.ChatContact>> searchContacts(String query) async {
    final rows = await _dao.searchContacts(query);
    return rows.map(_fromRow).toList();
  }

  // ── Deletes ────────────────────────────────────────────────────────────────

  /// Removes the contact identified by [peerId].
  Future<void> deleteContact(String peerId) => _dao.deleteContact(peerId);

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Converts a Drift [Contact] row to the domain model.
  model.ChatContact _fromRow(Contact row) {
    return model.ChatContact(
      peerId: row.peerId,
      displayName: row.displayName,
      avatarUrl: row.avatarUrl,
      lastMessageAt: row.lastMessageAt,
      isOnline: row.isOnline,
    );
  }
}
