import 'package:flutter/material.dart';
import '../../data/teacher_static_data.dart';
import '../../models/course_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/animated_components.dart';
import 'marks_entry_screen.dart';
import 'marks_overview_screen.dart';

/// Teacher Grading screen with premium UI - Fixed overflow issues
class TeacherGradingScreen extends StatefulWidget {
  const TeacherGradingScreen({super.key});

  @override
  State<TeacherGradingScreen> createState() => _TeacherGradingScreenState();
}

class _TeacherGradingScreenState extends State<TeacherGradingScreen>
    with SingleTickerProviderStateMixin {
  TeacherCourse? _selectedCourse;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(isDarkMode),
      appBar: AppBar(
        title: const Text(
          'Grading',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface(isDarkMode),
        elevation: 0,
        actions: [
          if (_selectedCourse != null)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.table_chart, color: AppColors.primary, size: 20),
              ),
              onPressed: () => Navigator.push(
                context,
                SmoothPageRoute(page: MarksOverviewScreen(course: _selectedCourse!)),
              ),
              tooltip: 'View Overview',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeaderCard(isDarkMode),
              const SizedBox(height: 24),

              // Course Selection
              _buildSectionTitle('Select Course', isDarkMode),
              const SizedBox(height: 12),
              ...teacherCourses.map((course) => _buildCourseCard(course, isDarkMode)),

              if (_selectedCourse != null) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Grading Components', isDarkMode),
                const SizedBox(height: 12),
                if (_selectedCourse!.type == CourseType.theory)
                  _buildTheoryComponents(isDarkMode)
                else
                  _buildSessionalComponents(isDarkMode),
              ],
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
            ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
            : [AppColors.primary.withOpacity(0.9), AppColors.indigo.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: isDarkMode ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDarkMode ? null : [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.grading, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${teacherCourses.length} Courses',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Manage Marks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a course and component',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(isDarkMode),
      ),
    );
  }

  Widget _buildCourseCard(TeacherCourse course, bool isDarkMode) {
    final isSelected = _selectedCourse?.code == course.code;
    final color = course.type == CourseType.theory ? AppColors.primary : AppColors.accent;

    return AnimatedCard(
      accentColor: isSelected ? color : null,
      onTap: () => setState(() => _selectedCourse = course),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              course.type == CourseType.theory ? Icons.book : Icons.science,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      course.code,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.shortSemester,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  course.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildTheoryComponents(bool isDarkMode) {
    final components = [
      {'name': 'CT-1', 'max': 20, 'icon': Icons.quiz, 'color': AppColors.primary},
      {'name': 'CT-2', 'max': 10, 'icon': Icons.quiz, 'color': AppColors.info},
      {'name': 'Spot Test', 'max': 5, 'icon': Icons.flash_on, 'color': AppColors.warning},
      {'name': 'Assignment', 'max': 5, 'icon': Icons.assignment, 'color': AppColors.success},
      {'name': 'Attendance', 'max': 10, 'icon': Icons.fact_check, 'color': AppColors.teal},
      {'name': 'Term Exam', 'max': 105, 'icon': Icons.school, 'color': AppColors.indigo},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15, // Fixed: increased aspect ratio to prevent overflow
      ),
      itemCount: components.length,
      itemBuilder: (context, index) {
        final comp = components[index];
        return _buildComponentCard(
          comp['name'] as String,
          comp['max'] as int,
          comp['icon'] as IconData,
          comp['color'] as Color,
          isDarkMode,
          index,
        );
      },
    );
  }

  Widget _buildSessionalComponents(bool isDarkMode) {
    final components = [
      {'name': 'Lab Task', 'max': 50, 'icon': Icons.task, 'color': AppColors.accent},
      {'name': 'Lab Report', 'max': 20, 'icon': Icons.description, 'color': AppColors.teal},
      {'name': 'Quiz', 'max': 10, 'icon': Icons.quiz, 'color': AppColors.warning},
      {'name': 'Lab Test', 'max': 30, 'icon': Icons.science, 'color': AppColors.primary},
      {'name': 'Project', 'max': 30, 'icon': Icons.build, 'color': AppColors.success},
      {'name': 'Central Viva', 'max': 20, 'icon': Icons.record_voice_over, 'color': AppColors.indigo},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15, // Fixed: increased aspect ratio to prevent overflow
      ),
      itemCount: components.length,
      itemBuilder: (context, index) {
        final comp = components[index];
        return _buildComponentCard(
          comp['name'] as String,
          comp['max'] as int,
          comp['icon'] as IconData,
          comp['color'] as Color,
          isDarkMode,
          index,
        );
      },
    );
  }

  Widget _buildComponentCard(
    String name,
    int maxMarks,
    IconData icon,
    Color color,
    bool isDarkMode,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            SmoothPageRoute(
              page: MarksEntryScreen(
                course: _selectedCourse!,
                component: name,
                maxMarks: maxMarks,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : color.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                  ? Colors.black.withOpacity(0.3) 
                  : color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.textPrimary(isDarkMode),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Max: $maxMarks',
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
