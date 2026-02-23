import 'package:teczaleel/core/errors/failures.dart';
import 'package:teczaleel/features/product/domain/entities/product.dart';
import 'package:teczaleel/features/product/domain/repositories/product_repository.dart';
import 'package:dartz/dartz.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<Either<Failure, List<Product>>> call({bool fromCache = false}) async {
    return await repository.getProducts(fromCache: fromCache);
  }
}
