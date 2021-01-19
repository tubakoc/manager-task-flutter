import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manager_task_example/models/user_model.dart';


class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  UserModel userModel = UserModel();
  final userRef = FirebaseFirestore.instance.collection("users");

  AuthenticationService(this._firebaseAuth);

// managing the user state via stream.
// stream provides an immediate event of
// the user's current authentication state,
// and then provides subsequent events whenever
// the authentication state changes.
  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();


  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return "Signed In";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        return "Wrong password provided for that user.";
      } else {
        return "Something Went Wrong.";
      }
    }
  }


  Future<String> signUp({String email, String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return "Signed Up";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        return "The account already exists for that email.";
      } else {
        return "Something Went Wrong.";
      }
    } catch (e) {
      print(e);
    }
  }


  Future<void> addUserToDB(
      {String uid, String username, String email, DateTime timestamp}) async {
    userModel = UserModel(
        uid: uid, username: username, email: email, timestamp: timestamp);

    await userRef.doc(uid).set(userModel.toMap(userModel));
  }


  Future<UserModel> getUserFromDB({String uid}) async {
    final DocumentSnapshot doc = await userRef.doc(uid).get();

    //print(doc.data());

    return UserModel.fromMap(doc.data());
  }


   Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
