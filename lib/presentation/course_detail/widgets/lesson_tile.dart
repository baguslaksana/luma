import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/lesson.dart';

class LessonTile extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool isCurrentPlaying;
  final VoidCallback onTap;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.index,
    this.isCurrentPlaying = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentPlaying ? AppTheme.tertiary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrentPlaying ? AppTheme.secondary : AppTheme.outline.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          children: [
            // Circular Play Icon Button
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isCurrentPlaying ? AppTheme.primary : AppTheme.tertiary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrentPlaying
                    ? Icons.play_arrow_rounded
                    : Icons.play_arrow_rounded,
                color: isCurrentPlaying ? Colors.white : AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Lesson Title
            Expanded(
              child: Text(
                lesson.title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isCurrentPlaying ? FontWeight.w700 : FontWeight.w600,
                  color: isCurrentPlaying ? AppTheme.primary : AppTheme.heading,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            // Duration
            Text(
              Formatters.formatVideoTime(
                Duration(seconds: lesson.durationSeconds),
              ),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
