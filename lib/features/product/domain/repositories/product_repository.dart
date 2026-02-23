import 'package:teczaleel/core/errors/failures.dart';
import 'package:teczaleel/features/product/domain/entities/product.dart';
import 'package:dartz/dartz.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({bool fromCache = false});
  Future<Either<Failure, List<String>>> getCategories({bool fromCache = false});
}
