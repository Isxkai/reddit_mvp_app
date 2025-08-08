import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/providers/faliure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/providers/type_defs.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/models/user_model.dart';

final userProfileRepositoryProvider = Provider(
  (ref) => UserProfileRepository(firestore: ref.watch(firestoreProvider)),
);

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  UserProfileRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _user =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_user.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Faliure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) =>
              event.docs
                  .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
                  .toList(),
        );
  }

  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_user.doc(user.uid).update({
        'karma':  user.karma
        },),);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Faliure(e.toString()));
    }
  }
}
