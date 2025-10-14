import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:event_management_app/saved_data.dart';
import 'auth.dart';

// ✅ Use your actual Database ID
String databaseId = "68fb0b4a000e7ff34dd4";

// ✅ Define collection IDs clearly
const String userCollectionId = "user_data";
const String eventCollectionId = "events"; // make sure you have this in Appwrite

final Databases databases = Databases(client);

/// ----------------------------
/// USER MANAGEMENT
/// ----------------------------

// ✅ Save the user data to Appwrite database
Future<void> saveUserData(String name, String email, String userId) async {
  try {
    await databases.createDocument(
      databaseId: databaseId,
      collectionId: userCollectionId,
      documentId: userId, // Use Appwrite user ID as document ID
      data: {
        "name": name,
        "email": email,
        "user_id": userId, // Required by schema
      },
    );
    print("✅ User document created successfully");
  } catch (e) {
    print("❌ Error creating user document: $e");
  }
}


// ✅ Get user data from Appwrite database
Future<void> getUserData() async {
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
    print("⚠️ No user document found for $userId, creating one...");
    // Auto-create with default values matching schema
    await saveUserData("Unknown Name", "unknown@email.com", userId);
  }
}


/// ----------------------------
/// EVENT MANAGEMENT
/// ----------------------------

// ✅ Create a new event
Future<void> createEvent(
    String name,
    String desc,
    String image,
    String location,
    String datetime,
    String createdBy,
    bool isInPersonOrNot,
    String guest,
    String sponsors,
    ) async {
  try {
    await databases.createDocument(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      documentId: ID.unique(),
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
    print("✅ Event created successfully");
  } catch (e) {
    print("❌ Error creating event: $e");
  }
}

// ✅ Get all events
Future<List<Document>> getAllEvents() async {
  try {
    final response = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: eventCollectionId,
    );
    return response.documents;
  } catch (e) {
    print("❌ Error fetching events: $e");
    return [];
  }
}

// ✅ RSVP event
Future<bool> rsvpEvent(List participants, String documentId) async {
  final userId = SavedData.getUserId();
  participants.add(userId);

  try {
    await databases.updateDocument(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      documentId: documentId,
      data: {"participants": participants},
    );
    return true;
  } catch (e) {
    print("❌ Error RSVP-ing event: $e");
    return false;
  }
}

// ✅ Get events created by the user
Future<List<Document>> manageEvents() async {
  final userId = SavedData.getUserId();
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

// ✅ Update an existing event
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

// ✅ Delete event
Future<void> deleteEvent(String docID) async {
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

// ✅ Upcoming events
Future<List<Document>> getUpcomingEvents() async {
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

// ✅ Past events
Future<List<Document>> getPastEvents() async {
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
