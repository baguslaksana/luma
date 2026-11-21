import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/lesson.dart';
import '../../course_detail/providers/course_detail_provider.dart';
import '../../course_list/providers/course_list_provider.dart';

class AddLessonScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String courseTitle;
  final int nextOrder;

  const AddLessonScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.nextOrder,
  });

  @override
  ConsumerState<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends ConsumerState<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController(text: '15');
  final _videoUrlController = TextEditingController(
    text: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  );

  bool _isPreview = false;
  bool _isLoading = false;

  final List<Map<String, String>> _videoPresets = [
    {
      'name': 'Sample 1 - Elephants Dream',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    },
    {
      'name': 'Sample 2 - For Bigger Blazes',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    },
    {
      'name': 'Sample 3 - Tears of Steel',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    },
    {
      'name': 'Sample 4 - Big Buck Bunny',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final durationMin = int.tryParse(_durationController.text.trim()) ?? 10;
    final durationSec = durationMin * 60;
    final lessonId = 'ls-${DateTime.now().millisecondsSinceEpoch}';

    final lesson = Lesson(
      id: lessonId,
      courseId: widget.courseId,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? 'Luma learning lesson chapter.'
          : _descController.text.trim(),
      durationSeconds: durationSec,
      videoUrl: _videoUrlController.text.trim(),
      order: widget.nextOrder,
      isPreview: _isPreview,
      isCompleted: false,
    );

    try {
      await ServiceLocator.addLessonUseCase.execute(widget.courseId, lesson);

      // Refresh detail and courses providers
      ref.invalidate(courseDetailProvider(widget.courseId));
      ref.invalidate(coursesProvider);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lesson "${lesson.title}" added successfully!',
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
            content: Text('Failed to add lesson: $e'),
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
          'Add Lesson',
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
                // Info target course
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.video_library_rounded, color: AppTheme.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adding to course:',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppTheme.neutral,
                              ),
                            ),
                            Text(
                              widget.courseTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.heading,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Bab #${widget.nextOrder}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Judul Lesson
                _buildLabel('Lesson Title'),
                _buildTextField(
                  controller: _titleController,
                  hintText: 'Misal: Latihan Soal & Trik Cepat Pembagian Aljabar',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Lesson title is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Deskripsi & Durasi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Brief Description'),
                          _buildTextField(
                            controller: _descController,
                            hintText: 'Poin yang dibahas dalam video...',
                            maxLines: 2,
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
                          _buildLabel('Duration (Min)'),
                          _buildTextField(
                            controller: _durationController,
                            hintText: '15',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Video URL
                _buildLabel('URL Video Streaming (Format MP4 / WebM)'),
                _buildTextField(
                  controller: _videoUrlController,
                  hintText: 'https://domain.com/video.mp4',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'URL video tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 10),

                // Presets
                Text(
                  'Preset Video Pilihan Cepat:',
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
                const SizedBox(height: 20),

                // Free preview toggle
                Row(
                  children: [
                    Switch.adaptive(
                      value: _isPreview,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setState(() => _isPreview = v),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jadikan Video Preview Gratis',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.heading,
                            ),
                          ),
                          Text(
                            'Students can watch this lesson directly.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppTheme.neutral,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitLesson,
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
                            'Save & Publish Lesson',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
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
