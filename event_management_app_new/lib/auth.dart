import 'package:appwrite/appwrite.dart';
import 'package:event_management_app/database.dart';
import 'package:event_management_app/saved_data.dart';

Client client = Client()
    .setEndpoint('https://nyc.cloud.appwrite.io/v1')
    .setProject('68faf6ff001d1fd7c779')
    .setSelfSigned(status: true); // Only for development

Account account = Account(client);

// ----------------------------
// CREATE USER
// ----------------------------
Future<String> createUser(String name, String email, String password) async {
  try {
    final user = await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );

    // Save to database
    await saveUserData(name, email, user.$id);

    // Save locally
    SavedData.saveUserId(user.$id);

    print("✅ User created successfully");
    return "success";
  } on AppwriteException catch (e) {
    print("❌ Error creating user: ${e.message}");
    return e.message ?? "Error creating user";
  }
}

// ----------------------------
// LOGIN USER
// ----------------------------
Future<bool> loginUser(String email, String password) async {
  try {
    final session = await account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    // Save user ID locally
    SavedData.saveUserId(session.userId);

    // Load user data
    await getUserData();

    print("✅ User logged in successfully");
    return true;
  } on AppwriteException catch (e) {
    print("❌ Login failed: ${e.message}");
    return false;
  }
}

// ----------------------------
// LOGOUT USER
// ----------------------------
Future<void> logoutUser() async {
  try {
    await account.deleteSession(sessionId: 'current');
    await SavedData.clearSavedData();
    print("✅ Logged out successfully");
  } catch (e) {
    print("❌ Logout failed: $e");
  }
}

// ----------------------------
// CHECK ACTIVE SESSION
// ----------------------------
Future<bool> checkSessions() async {
  try {
    await account.getSession(sessionId: 'current');
    return true;
  } catch (e) {
    print("❌ No active session");
    return false;
  }
}
