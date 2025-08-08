import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/providers/faliure.dart';

typedef FutureEither<T> = Future<Either<Faliure,T>>;
typedef FutureVoid = FutureEither<void>;