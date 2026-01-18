import 'package:flutter/material.dart';
import '../../data/teacher_static_data.dart';
import '../../models/course_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/animated_components.dart';
import 'roll_call_screen.dart';

/// Teacher Attendance screen with date picker and multi-semester support
class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen>
    with TickerProviderStateMixin {
  TeacherCourse? _selectedCourse;
  DateTime _selectedDate = DateTime.now();
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
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface(isDarkMode),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showAttendanceHistory(context, isDarkMode),
            tooltip: 'View History',
          ),
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
              // Header Card
              _buildHeaderCard(isDarkMode),
              const SizedBox(height: 24),

              // Date Picker
              _buildDateSection(isDarkMode),
              const SizedBox(height: 24),

              // Course Selection
              _buildSectionTitle('Select Course', isDarkMode),
              const SizedBox(height: 12),
              ...teacherCourses.map((course) => _buildCourseCard(course, isDarkMode)),

              if (_selectedCourse != null) ...[
                const SizedBox(height: 24),
                _buildSectionTitle(
                  _selectedCourse!.type == CourseType.theory
                      ? 'Select Section'
                      : 'Select Group',
                  isDarkMode,
                ),
                const SizedBox(height: 12),
                _buildSectionOrGroupSelector(isDarkMode),
              ],

              const SizedBox(height: 24),

              // Recent Records
              _buildSectionTitle('Recent Attendance', isDarkMode),
              const SizedBox(height: 12),
              _buildRecentRecords(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.fact_check, color: Colors.white, size: 28),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Take Attendance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select a course and section to start roll call',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration(isDarkMode, accentColor: AppColors.success),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event, color: AppColors.success, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(isDarkMode),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          AnimatedPressButton(
            onTap: () => _selectDate(context),
            backgroundColor: AppColors.success.withOpacity(0.15),
            shadowColor: AppColors.success,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_calendar, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Change',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(isDarkMode),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildCourseCard(TeacherCourse course, bool isDarkMode) {
    final isSelected = _selectedCourse?.code == course.code;
    final color = course.type == CourseType.theory ? AppColors.primary : AppColors.accent;
    final attendanceCount = course.type == CourseType.theory
        ? getAttendanceCount(course.code, course.sections.first)
        : getAttendanceCount(course.code, course.groups.first);

    return AnimatedCard(
      accentColor: isSelected ? color : null,
      onTap: () => setState(() => _selectedCourse = course),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              course.type == CourseType.theory ? Icons.book : Icons.science,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
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
                        fontSize: 15,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course.shortSemester,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  course.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(isDarkMode),
                  ),
                ),
                const SizedBox(height: 8),
                // Progress
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: attendanceCount / course.expectedClasses,
                          minHeight: 4,
                          backgroundColor: AppColors.border(isDarkMode),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$attendanceCount / ${course.expectedClasses} classes',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionOrGroupSelector(bool isDarkMode) {
    final isTodayAttendanceExists = attendanceSessions.any(
      (s) => s.courseCode == _selectedCourse!.code &&
             s.date.day == _selectedDate.day &&
             s.date.month == _selectedDate.month &&
             s.date.year == _selectedDate.year,
    );

    if (isTodayAttendanceExists) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.cardDecoration(isDarkMode, accentColor: AppColors.warning),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Attendance already taken for ${_formatDate(_selectedDate)}. Select a different date.',
                style: TextStyle(
                  color: AppColors.textSecondary(isDarkMode),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedCourse!.type == CourseType.theory) {
      return Row(
        children: _selectedCourse!.sections.map((section) {
          final studentCount = 60;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: section == _selectedCourse!.sections.last ? 0 : 8,
              ),
              child: _buildSectionButton(
                'Section $section',
                'Roll ${section == "A" ? "001-060" : "061-120"}',
                '$studentCount students',
                section,
                section == 'A' ? AppColors.primary : AppColors.accent,
                isDarkMode,
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0, // Fixed: reduced to prevent overflow
        children: _selectedCourse!.groups.map((group) {
          final colors = {
            'A1': AppColors.primary,
            'A2': AppColors.info,
            'B1': AppColors.accent,
            'B2': AppColors.teal,
          };
          final rollRanges = {
            'A1': '001-030',
            'A2': '031-060',
            'B1': '061-090',
            'B2': '091-120',
          };
          return _buildSectionButton(
            'Group $group',
            'Roll ${rollRanges[group]}',
            '30 students',
            group,
            colors[group] ?? AppColors.primary,
            isDarkMode,
          );
        }).toList(),
      );
    }
  }

  Widget _buildSectionButton(
    String title,
    String rollRange,
    String studentCount,
    String sectionOrGroup,
    Color color,
    bool isDarkMode,
  ) {
    return AnimatedPressButton(
      onTap: () {
        Navigator.push(
          context,
          SmoothPageRoute(
            page: RollCallScreen(
              course: _selectedCourse!,
              sectionOrGroup: sectionOrGroup,
              date: _selectedDate,
            ),
          ),
        );
      },
      backgroundColor: color.withOpacity(0.15),
      shadowColor: color,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.groups, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rollRange,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          Text(
            studentCount,
            style: TextStyle(
              color: AppColors.textSecondary(isDarkMode),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecords(bool isDarkMode) {
    if (attendanceSessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: AppColors.cardDecoration(isDarkMode),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'No attendance records yet',
                style: TextStyle(
                  color: AppColors.textSecondary(isDarkMode),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: attendanceSessions.take(5).map((session) {
        final course = teacherCourses.firstWhere(
          (c) => c.code == session.courseCode,
          orElse: () => teacherCourses.first,
        );
        final color = course.type == CourseType.theory ? AppColors.primary : AppColors.accent;

        return AnimatedCard(
          accentColor: AppColors.success,
          onTap: () {},
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.check_circle, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${session.courseCode} - ${course.type == CourseType.theory ? "Section" : "Group"} ${session.sectionOrGroup}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(session.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${session.attendanceRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: session.attendanceRate >= 80 ? AppColors.success : 
                             session.attendanceRate >= 60 ? AppColors.warning : AppColors.danger,
                    ),
                  ),
                  Text(
                    '${session.presentCount}P / ${session.lateCount}L / ${session.absentCount}A',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.success,
              onPrimary: Colors.white,
              surface: AppColors.surface(isDarkMode),
              onSurface: AppColors.textPrimary(isDarkMode),
            ),
            dialogBackgroundColor: AppColors.surface(isDarkMode),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showAttendanceHistory(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(isDarkMode),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border(isDarkMode),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Attendance History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDarkMode),
                ),
              ),
              const SizedBox(height: 16),
              ...attendanceSessions.map((session) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: AppColors.cardDecoration(isDarkMode),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${session.courseCode} - ${session.sectionOrGroup}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(isDarkMode),
                            ),
                          ),
                          Text(
                            _formatDate(session.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (session.attendanceRate >= 80 ? AppColors.success : 
                                 session.attendanceRate >= 60 ? AppColors.warning : AppColors.danger)
                                 .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${session.attendanceRate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: session.attendanceRate >= 80 ? AppColors.success : 
                                   session.attendanceRate >= 60 ? AppColors.warning : AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
