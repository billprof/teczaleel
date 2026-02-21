class AppConstants {
  static const String baseUrl = 'https://fakestoreapi.com';

  static const String productsBox = 'productsBox';
  static const String cartBox = 'cartBox';
  static const String categoriesBox = 'categoriesBox';

  static const String cachedProductsKey = 'CACHED_PRODUCTS';
  static const String cachedCategoriesKey = 'CACHED_CATEGORIES';

  static const Duration productCacheDuration = Duration(hours: 4);
  static const Duration categoryCacheDuration = Duration(hours: 12);

  // Custom Pagination Simulation since API doesn't support it directly
  static const int paginationLimit = 10;
}
