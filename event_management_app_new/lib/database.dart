import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:event_management_app/saved_data.dart';
import 'auth.dart';

final Databases databases = Databases(client);

const String databaseId = "68fb0b4a000e7ff34dd4";
const String userCollectionId = "user_data";
const String eventCollectionId = "events";

// ----------------------------
// SESSION CHECK HELPER
// ----------------------------
Future<bool> ensureSession() async {
  final loggedIn = await checkSessions();
  if (!loggedIn) {
    print("❌ User not logged in. Please log in first.");
    return false;
  }
  return true;
}

// ----------------------------
// USER MANAGEMENT
// ----------------------------
Future<void> saveUserData(String name, String email, String userId) async {
  if (!await ensureSession()) return;

  try {
    await databases.createDocument(
      databaseId: databaseId,
      collectionId: userCollectionId,
      documentId: userId,
      data: {
        "name": name,
        "email": email,
        "user_id": userId,
      },
      // ✅ Allow the user to read/write their own document
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
        Permission.write(Role.user(userId)),
      ],
    );
    print("✅ User document created successfully");
  } catch (e) {
    print("❌ Error creating user document: $e");
  }
}

Future<void> getUserData() async {
  if (!await ensureSession()) return;

  final userId = SavedData.getUserId();
  print("🔎 Getting user data for ID: $userId");

  try {
    final doc = await databases.getDocument(
      databaseId: databaseId,
      collectionId: userCollectionId,
      documentId: userId,
    );

    SavedData.saveUserName(doc.data['name']);
    SavedData.saveUserEmail(doc.data['email']);
    print("✅ User data loaded successfully");
  } catch (e) {
    print("⚠️ No user document found, creating default...");
    await saveUserData("Unknown Name", "unknown@email.com", userId);
  }
}

// ----------------------------
// EVENT MANAGEMENT
// ----------------------------
Future<void> createEvent(
    String name,
    String desc,
    String image,
    String location,
    String datetime,
    String createdBy,
    bool isinPersonOrNot,
    String guest,
    String sponsors,
    ) async {
  if (!await ensureSession()) return;

  final userId = await SavedData.getUserId();

  try {
    await databases.createDocument(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      documentId: ID.unique(),
      permissions: [
        Permission.read(Role.any()), // 👈 or Role.user(createdBy)
        Permission.write(Role.user(createdBy)),
        Permission.update(Role.user(createdBy)),
        Permission.delete(Role.user(createdBy)),
      ],
      data: {
        "name": name,
        "description": desc,
        "image": image,
        "location": location,
        "datetime": datetime,
        "createdBy": createdBy,
        "isinPerson": isinPersonOrNot,
        "guests": guest,
        "sponsors": sponsors,
      },
    );

    print("✅ Event created successfully");
  } catch (e) {
    print("❌ Error creating event: $e");
  }
}

Future<List<Document>> getAllEvents() async {
  if (!await ensureSession()) return [];

  try {
    final response = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: eventCollectionId,
    );
    print("✅ Fetched ${response.documents.length} events");
    return response.documents;
  } catch (e) {
    print("❌ Error fetching events: $e");
    return [];
  }
}

Future<bool> rsvpEvent(List participants, String documentId) async {
  if (!await ensureSession()) return false;

  final userId = await SavedData.getUserId();
  if (!participants.contains(userId)) {
    participants.add(userId);
  }

  try {
    await databases.updateDocument(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      documentId: documentId,
      data: {"participants": participants},
    );
    print("✅ RSVP successful");
    return true;
  } catch (e) {
    print("❌ Error RSVP-ing event: $e");
    return false;
  }
}

Future<List<Document>> manageEvents() async {
  if (!await ensureSession()) return [];

  final userId = await SavedData.getUserId();
  try {
    final response = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      queries: [Query.equal("createdBy", userId)],
    );
    return response.documents;
  } catch (e) {
    print("❌ Error managing events: $e");
    return [];
  }
}

Future<void> updateEvent(
    String name,
    String desc,
    String image,
    String location,
    String datetime,
    String createdBy,
    bool isInPersonOrNot,
    String guest,
    String sponsors,
    String docID,
    ) async {
  if (!await ensureSession()) return;

  try {
    await databases.updateDocument(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      documentId: docID,
      data: {
        "name": name,
        "description": desc,
        "image": image,
        "location": location,
        "datetime": datetime,
        "createdBy": createdBy,
        "isInPerson": isInPersonOrNot,
        "guests": guest,
        "sponsors": sponsors,
      },
    );
    print("✅ Event updated successfully");
  } catch (e) {
    print("❌ Error updating event: $e");
  }
}

Future<void> deleteEvent(String docID) async {
  if (!await ensureSession()) return;

  try {
    await databases.deleteDocument(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      documentId: docID,
    );
    print("✅ Event deleted");
  } catch (e) {
    print("❌ Error deleting event: $e");
  }
}

Future<List<Document>> getUpcomingEvents() async {
  if (!await ensureSession()) return [];

  try {
    final now = DateTime.now().toIso8601String();
    final response = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      queries: [Query.greaterThan("datetime", now)],
    );
    return response.documents;
  } catch (e) {
    print("❌ Error fetching upcoming events: $e");
    return [];
  }
}

Future<List<Document>> getPastEvents() async {
  if (!await ensureSession()) return [];

  try {
    final now = DateTime.now().toIso8601String();
    final response = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      queries: [Query.lessThan("datetime", now)],
    );
    return response.documents;
  } catch (e) {
    print("❌ Error fetching past events: $e");
    return [];
  }
}
