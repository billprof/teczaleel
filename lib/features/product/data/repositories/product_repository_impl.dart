import 'package:dartz/dartz.dart';
import 'package:teczaleel/core/errors/exceptions.dart';
import 'package:teczaleel/core/errors/failures.dart';
import 'package:teczaleel/core/network/network_info.dart';
import 'package:teczaleel/features/product/data/datasources/local/product_local_data_source.dart';
import 'package:teczaleel/features/product/data/datasources/remote/product_remote_data_source.dart';
import 'package:teczaleel/features/product/domain/entities/product.dart';
import 'package:teczaleel/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProducts();
        await localDataSource.cacheProducts(remoteProducts);
        return Right(remoteProducts);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localProducts = await localDataSource.getLastProducts();
        return Right(localProducts);
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategories = await remoteDataSource.getCategories();
        await localDataSource.cacheCategories(remoteCategories);
        return Right(remoteCategories);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localCategories = await localDataSource.getLastCategories();
        return Right(localCategories);
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }
}
