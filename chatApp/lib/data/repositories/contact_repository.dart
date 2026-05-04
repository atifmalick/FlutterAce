import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/base_repository.dart';
import '../models/user_model.dart';


class ContactRepository extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<bool> requestContactsPermission() async {
    try {
      // Check existing permission status using permission_handler first
      final status = await Permission.contacts.status;
      if (status.isGranted) return true;

      // Ask flutter_contacts for permission (plugin may show its own request flow)
      final granted = await FlutterContacts.requestPermission();
      if (granted) return true;

      // If not granted, check if permanently denied so caller can show guidance
      if (await Permission.contacts.isPermanentlyDenied) {
        print('[ContactRepo] Contacts permission permanently denied');
        return false;
      }

      print('[ContactRepo] Contacts permission denied');
      return false;
    } catch (e) {
      print('[ContactRepo] requestContactsPermission error: $e');
      return false;
    }
  }

  // Normalize to digits-only (keep leading + if present)
  String _digitsOnly(String input) {
    return input.replaceAll(RegExp(r'[^\d+]'), '');
  }

  // Generate possible normalized variants for matching
  // e.g. for input "03041234567" -> ["03041234567", "3041234567", "+923041234567", "923041234567"]
  Set<String> _generateVariants(String raw) {
    final s = _digitsOnly(raw);
    final variants = <String>{};

    if (s.isEmpty) return variants;

    String digits = s;
    // if starts with +, keep + in one variant and also add variant without +
    if (digits.startsWith('+')) {
      variants.add(digits); // +923041234567
      digits = digits.substring(1);
      variants.add(digits); // 923041234567
    }

    // always add plain digits
    variants.add(digits);

    // if digits start with 0 (local format), add variant without leading 0 and with country code 92 (Pakistan)
    if (digits.startsWith('0')) {
      final withoutZero = digits.replaceFirst(RegExp(r'^0+'), '');
      variants.add(withoutZero); // 3041234567
      variants.add('92$withoutZero'); // 923041234567
      variants.add('+92$withoutZero'); // +923041234567
    } else {
      // If digits look like country code + local (e.g., 923041234567), also add local variant without country code
      if (digits.length > 10 && digits.startsWith('92')) {
        final withoutCountry = digits.replaceFirst(RegExp(r'^92'), '');
        variants.add(withoutCountry); // 3041234567
        variants.add('0$withoutCountry'); // 03041234567
      }
    }

    // Also add variants with leading zero if missing and length matches local length
    if (!digits.startsWith('0') && digits.length == 10) {
      variants.add('0$digits');
    }

    // Final cleanup: remove empty strings
    variants.removeWhere((e) => e.isEmpty);
    return variants;
  }

  Future<List<Map<String, dynamic>>> getRegisteredContacts() async {
    try {
      print('[ContactRepo] Starting getRegisteredContacts...');

      bool hasPermission = await requestContactsPermission();
      print('[ContactRepo] Permission granted: $hasPermission');
      if (!hasPermission) {
        print('[ContactRepo] Contacts permission denied');
        return [];
      }

      // Get device contacts with phone numbers
      print('[ContactRepo] Fetching device contacts...');
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      print('[ContactRepo] Found ${contacts.length} device contacts');

      // Extract all phone numbers and normalize them (handle multiple phones per contact)
      final phoneEntries = <Map<String, dynamic>>[];
      for (final contact in contacts) {
        if (contact.phones.isEmpty) continue;
        for (final ph in contact.phones) {
          final normalized = _digitsOnly(ph.number);
          if (normalized.isEmpty) continue;
          phoneEntries.add({
            'name': contact.displayName,
            'phoneNumber': ph.number,
            'phoneDigits': normalized,
            'photo': contact.photo,
          });
          print('[ContactRepo] Device contact: ${contact.displayName} -> $normalized');
        }
      }
      print('[ContactRepo] Total phone entries extracted: ${phoneEntries.length}');

      // Get all users from Firestore
      print('[ContactRepo] Fetching Firestore users...');
      final usersSnapshot = await firestore.collection('users').get();
      print('[ContactRepo] Found ${usersSnapshot.docs.length} users in Firestore');

      final registeredUsers = usersSnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      // Log all user phone numbers for debugging
      for (final user in registeredUsers) {
        print('[ContactRepo] Firestore user: ${user.username} (${user.uid}) -> ${user.phoneNumber}');
      }

      // Precompute user variants map: userId -> set of variants
      final Map<String, Set<String>> userVariants = {};
      for (final user in registeredUsers) {
        final variants = _generateVariants(user.phoneNumber);
        userVariants[user.uid] = variants;
        print('[ContactRepo] User ${user.username} variants: $variants');
      }

      final matched = <Map<String, dynamic>>[];

      for (final entry in phoneEntries) {
        final contactDigits = entry['phoneDigits'] as String;
        final contactVariants = _generateVariants(contactDigits);
        print('[ContactRepo] Trying to match contact ${entry['name']} (variants: $contactVariants)');

        // find first user whose variants intersect with contactVariants and not current user
        try {
          final matchedUser = registeredUsers.firstWhere((u) {
            if (u.uid == currentUserId) {
              print('[ContactRepo]   - Skipping current user: ${u.uid}');
              return false;
            }
            final variants = userVariants[u.uid] ?? <String>{};
            final hasIntersection = variants.intersection(contactVariants).isNotEmpty;
            print('[ContactRepo]   - Checking ${u.username} (${u.uid}): variants=$variants, intersection=${variants.intersection(contactVariants)}, match=$hasIntersection');
            return hasIntersection;
          });

          print('[ContactRepo] MATCHED: ${entry['name']} -> ${matchedUser.username}');
          matched.add({
            'id': matchedUser.uid,
            'name': entry['name'],
            'phoneNumber': entry['phoneNumber'],
          });
        } catch (_) {
          print('[ContactRepo] NO MATCH for ${entry['name']}');
        }
      }

      print('[ContactRepo] Returning ${matched.length} matched contacts');
      return matched;
    } catch (e) {
      print('[ContactRepo] ERROR: $e');
      return [];
    }
  }
}
