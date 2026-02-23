import 'package:teczaleel/core/errors/failures.dart';
import 'package:teczaleel/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetCategories {
  final ProductRepository repository;

  GetCategories(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getCategories();
  }
}
