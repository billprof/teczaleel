import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teczaleel/core/network/network_info.dart';
import 'package:teczaleel/features/product/data/datasources/local/product_local_data_source.dart';
import 'package:teczaleel/features/product/data/datasources/remote/product_remote_data_source.dart';
import 'package:teczaleel/core/errors/exceptions.dart';
import 'package:teczaleel/core/errors/failures.dart';
import 'package:teczaleel/features/product/data/models/product_model.dart';
import 'package:teczaleel/features/product/data/repositories/product_repository_impl.dart';

class MockRemoteDataSource extends Mock implements ProductRemoteDataSource {}

class MockLocalDataSource extends Mock implements ProductLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ProductRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tProductModel = ProductModel(
    id: 1,
    title: 'Test Product',
    price: 100,
    description: 'Test Description',
    category: 'electronics',
    image: 'image.jpg',
    rating: RatingModel(rate: 4.5, count: 10),
  );

  const tProductModelList = [tProductModel];
  const tProductList = tProductModelList;
  const tCategoriesList = ['electronics', 'jewelery'];

  group('getProducts', () {
    test('should return local data when fromCache is true', () async {
      // arrange
      when(
        () => mockLocalDataSource.getLastProducts(),
      ).thenAnswer((_) async => tProductList);

      // act
      final result = await repository.getProducts(fromCache: true);

      // Print data to see the results
      result.fold(
        (failure) => print('Failed with: $failure'),
        (products) =>
            print('Success! Found ${products.length} products: $products'),
      );

      // assert
      expect(result, const Right(tProductList));
      verify(() => mockLocalDataSource.getLastProducts());
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test(
      'should return remote data and cache it when device is online',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.getProducts(),
        ).thenAnswer((_) async => tProductModelList);
        when(
          () => mockLocalDataSource.cacheProducts(any()),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.getProducts(fromCache: false);

        // assert
        expect(result, const Right(tProductList));
        verify(() => mockRemoteDataSource.getProducts());
        verify(() => mockLocalDataSource.cacheProducts(tProductList));
      },
    );

    test('should return cached data when device is offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocalDataSource.getLastProducts(),
      ).thenAnswer((_) async => tProductList);

      // act
      final result = await repository.getProducts(fromCache: false);

      // assert
      expect(result, const Right(tProductList));
      verifyZeroInteractions(mockRemoteDataSource);
      verify(() => mockLocalDataSource.getLastProducts());
    });

    test(
      'should return ServerFailure when the call to remote data source is unsuccessful',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.getProducts(),
        ).thenThrow(ServerException());

        // act
        final result = await repository.getProducts(fromCache: false);

        // assert
        expect(result, const Left(ServerFailure()));
        verify(() => mockRemoteDataSource.getProducts());
        verifyZeroInteractions(mockLocalDataSource);
      },
    );

    test(
      'should return CacheFailure when the call to local data source is unsuccessful',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(
          () => mockLocalDataSource.getLastProducts(),
        ).thenThrow(CacheException());

        // act
        final result = await repository.getProducts(fromCache: false);

        // assert
        expect(result, const Left(CacheFailure()));
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastProducts());
      },
    );
  });
  group('getCategories', () {
    test('should return local data when fromCache is true', () async {
      // arrange
      when(
        () => mockLocalDataSource.getLastCategories(),
      ).thenAnswer((_) async => tCategoriesList);

      // act
      final result = await repository.getCategories(fromCache: true);

      // Print data to see the results
      result.fold(
        (failure) => print('Failed with: $failure'),
        (categories) => print(
          'Success! Found ${categories.length} categories: $categories',
        ),
      );

      // assert
      expect(result, const Right(tCategoriesList));
      verify(() => mockLocalDataSource.getLastCategories());
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test(
      'should return remote data and cache it when device is online',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.getCategories(),
        ).thenAnswer((_) async => tCategoriesList);
        when(
          () => mockLocalDataSource.cacheCategories(any()),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.getCategories(fromCache: false);

        // assert
        expect(result, const Right(tCategoriesList));
        verify(() => mockRemoteDataSource.getCategories());
        verify(() => mockLocalDataSource.cacheCategories(tCategoriesList));
      },
    );

    test('should return cached data when device is offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocalDataSource.getLastCategories(),
      ).thenAnswer((_) async => tCategoriesList);

      // act
      final result = await repository.getCategories(fromCache: false);

      // assert
      expect(result, const Right(tCategoriesList));
      verifyZeroInteractions(mockRemoteDataSource);
      verify(() => mockLocalDataSource.getLastCategories());
    });

    test(
      'should return ServerFailure when the call to remote data source is unsuccessful',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRemoteDataSource.getCategories(),
        ).thenThrow(ServerException());

        // act
        final result = await repository.getCategories(fromCache: false);

        // assert
        expect(result, const Left(ServerFailure()));
        verify(() => mockRemoteDataSource.getCategories());
        verifyZeroInteractions(mockLocalDataSource);
      },
    );

    test(
      'should return CacheFailure when the call to local data source is unsuccessful',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(
          () => mockLocalDataSource.getLastCategories(),
        ).thenThrow(CacheException());

        // act
        final result = await repository.getCategories(fromCache: false);

        // assert
        expect(result, const Left(CacheFailure()));
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastCategories());
      },
    );
  });
}
