import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/instructor.dart';
import '../../../domain/entities/lesson.dart';
import '../../auth/providers/auth_provider.dart';
import '../../course_list/providers/course_list_provider.dart';

class AddEditCourseScreen extends ConsumerStatefulWidget {
  const AddEditCourseScreen({super.key});

  @override
  ConsumerState<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends ConsumerState<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  // Course Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // Initial Lesson Controllers
  final _lessonTitleController = TextEditingController();
  final _lessonDescController = TextEditingController();
  final _durationMinutesController = TextEditingController(text: '12');
  final _videoUrlController = TextEditingController(
    text: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  );

  bool _isLoading = false;

  // Pre-configured dropdowns
  final List<Map<String, String>> _categories = [
    {'id': 'cat-matematika', 'name': 'Matematika', 'slug': 'matematika'},
    {'id': 'cat-fisika', 'name': 'Fisika', 'slug': 'fisika'},
    {'id': 'cat-kimia', 'name': 'Kimia', 'slug': 'kimia'},
    {'id': 'cat-biologi', 'name': 'Biologi', 'slug': 'biologi'},
    {'id': 'cat-bahasa', 'name': 'Bahasa & Literasi', 'slug': 'bahasa'},
    {'id': 'cat-utbk', 'name': 'Persiapan UTBK', 'slug': 'utbk'},
  ];

  late String _selectedCategorySlug;

  final List<String> _levels = [
    'Kelas 10',
    'Kelas 11',
    'Kelas 12',
    'Kelas 10 - 12',
    'Persiapan UTBK & SNBT',
  ];
  late String _selectedLevel;

  // Sample video presets for easy selection
  final List<Map<String, String>> _videoPresets = [
    {
      'name': 'Lesson Video 1 (Sample MP4)',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    },
    {
      'name': 'Lesson Video 2 (Sample MP4)',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    },
    {
      'name': 'Lesson Video 3 (Sample MP4)',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategorySlug = _categories[0]['slug']!;
    _selectedLevel = _levels[1]; // Kelas 11
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _lessonTitleController.dispose();
    _lessonDescController.dispose();
    _durationMinutesController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final currentUser = ref.read(currentUserProvider);
    final courseId = 'course-${DateTime.now().millisecondsSinceEpoch}';
    final lessonId = 'ls-${DateTime.now().millisecondsSinceEpoch}';

    final categoryMap = _categories.firstWhere(
      (c) => c['slug'] == _selectedCategorySlug,
      orElse: () => _categories[0],
    );

    final durationMin = int.tryParse(_durationMinutesController.text.trim()) ?? 10;
    final durationSec = durationMin * 60;

    final initialLesson = Lesson(
      id: lessonId,
      courseId: courseId,
      title: _lessonTitleController.text.trim().isEmpty
          ? 'Pengantar & Konsep Dasar'
          : _lessonTitleController.text.trim(),
      description: _lessonDescController.text.trim().isEmpty
          ? 'Introductory material and fundamental concepts of this topic.'
          : _lessonDescController.text.trim(),
      durationSeconds: durationSec,
      videoUrl: _videoUrlController.text.trim(),
      order: 1,
      isPreview: true,
      isCompleted: false,
    );

    final newCourse = Course(
      id: courseId,
      title: _titleController.text.trim(),
      category: Category(
        id: categoryMap['id']!,
        name: categoryMap['name']!,
        slug: categoryMap['slug']!,
      ),
      instructor: Instructor(
        id: currentUser?.id ?? 'inst-${DateTime.now().millisecondsSinceEpoch}',
        name: currentUser?.name ?? 'Luma Teacher',
        role: 'High School Teacher',
        avatarUrl: currentUser?.avatarUrl ??
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        bio: currentUser?.bio ?? 'Verified high school subject teacher.',
      ),
      description: _descController.text.trim(),
      thumbnailUrl:
          'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=800&q=80',
      rating: 5.0,
      totalReviews: 1,
      totalDurationSeconds: durationSec,
      level: _selectedLevel,
      lessons: [initialLesson],
    );

    try {
      await ServiceLocator.addCourseUseCase.execute(newCourse);

      // Invalidate course list so UI reflects the new item
      ref.invalidate(coursesProvider);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Course "${newCourse.title}" published successfully!',
              style: GoogleFonts.poppins(fontSize: 12.5),
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add course: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'New Course',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.heading,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.heading),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Courses and videos you add will be immediately accessible to all Luma students.',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: AppTheme.heading,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Section 1: Informasi Mata Pelajaran ──
                Text(
                  '1. Course Information',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.heading,
                  ),
                ),
                const SizedBox(height: 14),

                // Judul Materi
                _buildLabel('Course Title'),
                _buildTextField(
                  controller: _titleController,
                  hintText: 'Misal: Dinamika Gerak & Hukum Newton SMA',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Course title is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Kategori & Tingkat (Row)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Category'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.outline),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategorySlug,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.heading,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: _categories.map((c) {
                                  return DropdownMenuItem(
                                    value: c['slug'],
                                    child: Text(c['name']!),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedCategorySlug = v);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Grade Level'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.outline),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLevel,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.heading,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: _levels.map((l) {
                                  return DropdownMenuItem(
                                    value: l,
                                    child: Text(l),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedLevel = v);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Deskripsi Materi
                _buildLabel('Course Description'),
                _buildTextField(
                  controller: _descController,
                  hintText: 'Describe the learning objectives, course scope, and competencies covered...',
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Course description is required'
                      : null,
                ),
                const SizedBox(height: 28),

                // ── Section 2: Video Pelajaran Pertama ──
                Text(
                  '2. First Lesson & Video',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.heading,
                  ),
                ),
                const SizedBox(height: 14),

                // Judul Video / Lesson
                _buildLabel('Lesson Title'),
                _buildTextField(
                  controller: _lessonTitleController,
                  hintText: 'Misal: Pengantar Hukum I dan II Newton',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Lesson title is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Deskripsi Lesson & Durasi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Ringkasan Video'),
                          _buildTextField(
                            controller: _lessonDescController,
                            hintText: 'Poin penting video...',
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Duration (Minutes)'),
                          _buildTextField(
                            controller: _durationMinutesController,
                            hintText: '12',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // URL Video
                _buildLabel('Lesson Video URL (MP4 Streaming)'),
                _buildTextField(
                  controller: _videoUrlController,
                  hintText: 'https://domain.com/video.mp4',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'URL video tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 8),

                // Video presets chips
                Text(
                  'Preset Video Contoh:',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.neutral,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _videoPresets.map((preset) {
                    final isSelected = _videoUrlController.text == preset['url'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _videoUrlController.text = preset['url']!;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : AppTheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.outline,
                          ),
                        ),
                        child: Text(
                          preset['name']!,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.primary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppTheme.primary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Save & Publish Course',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppTheme.heading,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outline, width: 1.2),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppTheme.heading,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 12.5,
            color: AppTheme.neutral,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: validator,
      ),
    );
  }
}
