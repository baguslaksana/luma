import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/course.dart';

// State Provider untuk kategori yang sedang aktif
final selectedCategorySlugProvider = StateProvider<String>((ref) => 'all');

// State Provider untuk query pencarian
final searchQueryProvider = StateProvider<String>((ref) => '');

// FutureProvider untuk daftar kategori
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ServiceLocator.getCategoriesUseCase.execute();
});

// FutureProvider untuk daftar courses yang reaktif terhadap kategori & query pencarian
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final categorySlug = ref.watch(selectedCategorySlugProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return ServiceLocator.getCoursesUseCase.execute(
    categorySlug: categorySlug == 'all' ? null : categorySlug,
    searchQuery: searchQuery,
  );
});
