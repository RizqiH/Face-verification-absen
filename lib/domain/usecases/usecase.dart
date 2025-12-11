/// Base interface for all use cases
/// 
/// Type parameters:
/// - Type: The return type of the use case
/// - Params: The input parameters type
/// 
/// This follows the Clean Architecture principle of having
/// business logic encapsulated in use cases.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// For use cases that don't require parameters
class NoParams {
  const NoParams();
}

