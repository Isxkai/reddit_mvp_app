import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/providers/faliure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/providers/type_defs.dart';
import 'package:reddit_clone/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return left(Faliure('Sign in was cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return left(Faliure('Could not get auth details'));
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        return left(Faliure('Could not get user details'));
      }

      final user = userCredential.user!;
      final userDoc = await _users.doc(user.uid).get();

      UserModel userModel;
      if (!userDoc.exists) {
        userModel = UserModel(
          name: user.displayName ?? 'No Name',
          profilePic: user.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: user.uid,
          isAuthenticated: true,
          karma: 0,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );
        await _users.doc(user.uid).set(userModel.toMap());
      } else {
        userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }

      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Faliure(e.message ?? 'Firebase Error'));
    } catch (e) {
      return left(Faliure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((event) {
      final data = event.data();
      if (data == null) {
        throw Exception('User data is null for uid: $uid');
      }
      return UserModel.fromMap(data as Map<String, dynamic>);
    });
  }

  void logOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
