import 'package:flutter/material.dart';
import 'Attendance/teacher_attendance_screen.dart';
import 'Grading/teacher_grading_screen.dart';
import 'Schedule/teacher_schedule_screen.dart';
import 'Announcements/announcements_screen.dart';
import 'Students/students_list_screen.dart';
import '../data/teacher_static_data.dart';
import '../models/course_model.dart';
import '../theme/app_colors.dart';
import '../theme/animated_components.dart';

/// Main Teacher Dashboard screen with Premium Dark Mode UI
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(isDarkMode),
      appBar: AppBar(
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: AppColors.surface(isDarkMode),
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(isDarkMode),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(isDarkMode)),
              ),
              child: const Icon(Icons.notifications_none, size: 20),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(isDarkMode),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(isDarkMode)),
              ),
              child: const Icon(Icons.logout, size: 20),
            ),
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card with Gradient
                _buildWelcomeCard(isDarkMode),
                const SizedBox(height: 24),

                // Quick Stats
                _buildQuickStats(isDarkMode),
                const SizedBox(height: 24),

                // Course Overview
                _buildSectionHeader('My Courses', isDarkMode, onSeeAll: () => _showCoursesDialog(context, isDarkMode)),
                const SizedBox(height: 12),
                _buildCourseCards(isDarkMode),
                const SizedBox(height: 24),

                // Feature Grid
                _buildSectionHeader('Quick Actions', isDarkMode),
                const SizedBox(height: 12),
                _buildFeatureGrid(isDarkMode),
                const SizedBox(height: 24),

                // Recent Announcements
                _buildSectionHeader('Recent Announcements', isDarkMode),
                const SizedBox(height: 12),
                ...sampleAnnouncements.take(3).map(
                  (announcement) => _buildAnnouncementCard(announcement, isDarkMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.info.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentTeacher.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.work_outline,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                currentTeacher.designation,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDarkMode) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          '${teacherCourses.length}',
          'Courses',
          Icons.library_books,
          AppColors.primary,
          isDarkMode,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          '${teacherCourses.where((c) => c.type == CourseType.theory).fold(0, (sum, c) => sum + (c.sections.length * 60))}',
          'Students',
          Icons.people,
          AppColors.teal,
          isDarkMode,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          '${sampleAnnouncements.length}',
          'Pending',
          Icons.pending_actions,
          AppColors.warning,
          isDarkMode,
        )),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, bool isDarkMode) {
    return AnimatedPressButton(
      onTap: () {},
      backgroundColor: AppColors.surfaceElevated(isDarkMode),
      shadowColor: color,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(isDarkMode),
            letterSpacing: 0.3,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCourseCards(bool isDarkMode) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: teacherCourses.length,
        itemBuilder: (context, index) {
          final course = teacherCourses[index];
          final color = course.type == CourseType.theory ? AppColors.primary : AppColors.accent;
          final attendanceCount = course.type == CourseType.theory
              ? getAttendanceCount(course.code, course.sections.first)
              : getAttendanceCount(course.code, course.groups.first);
          
          return Container(
            width: 220,
            margin: EdgeInsets.only(right: index < teacherCourses.length - 1 ? 12 : 0),
            child: AnimatedCard(
              accentColor: color,
              padding: const EdgeInsets.all(16),
              margin: EdgeInsets.zero,
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          course.type == CourseType.theory ? Icons.book : Icons.science,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  const Spacer(),
                  Text(
                    course.code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(isDarkMode),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Progress bar for attendance
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
                      const SizedBox(width: 8),
                      Text(
                        '$attendanceCount/${course.expectedClasses}',
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
          );
        },
      ),
    );
  }

  Widget _buildFeatureGrid(bool isDarkMode) {
    final features = [
      {'icon': Icons.fact_check, 'title': 'Attendance', 'color': AppColors.attendance, 'screen': const TeacherAttendanceScreen()},
      {'icon': Icons.grading, 'title': 'Grading', 'color': AppColors.grading, 'screen': const TeacherGradingScreen()},
      {'icon': Icons.schedule, 'title': 'Schedule', 'color': AppColors.schedule, 'screen': const TeacherScheduleScreen()},
      {'icon': Icons.campaign, 'title': 'Announce', 'color': AppColors.announcements, 'screen': const AnnouncementsScreen()},
      {'icon': Icons.people, 'title': 'Students', 'color': AppColors.students, 'screen': const StudentsListScreen()},
      {'icon': Icons.library_books, 'title': 'Courses', 'color': AppColors.courses, 'onTap': () => _showCoursesDialog(context, isDarkMode)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return AnimatedPressButton(
          onTap: () {
            if (feature['screen'] != null) {
              Navigator.push(
                context,
                SmoothPageRoute(page: feature['screen'] as Widget),
              );
            } else if (feature['onTap'] != null) {
              (feature['onTap'] as VoidCallback)();
            }
          },
          backgroundColor: AppColors.surfaceElevated(isDarkMode),
          shadowColor: feature['color'] as Color,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (feature['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: feature['color'] as Color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                feature['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.textPrimary(isDarkMode),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement, bool isDarkMode) {
    final color = announcement.type == AnnouncementType.classTest
        ? AppColors.danger
        : announcement.type == AnnouncementType.assignment
            ? AppColors.primary
            : announcement.type == AnnouncementType.quiz
                ? AppColors.warning
                : AppColors.success;

    final icon = announcement.type == AnnouncementType.classTest
        ? Icons.quiz
        : announcement.type == AnnouncementType.assignment
            ? Icons.assignment
            : announcement.type == AnnouncementType.quiz
                ? Icons.help_outline
                : Icons.info;

    return AnimatedCard(
      accentColor: color,
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        announcement.courseCode,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  announcement.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(isDarkMode),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurfaceElevated
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary(true))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCoursesDialog(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(isDarkMode),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              'My Courses',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            ...teacherCourses.map((course) {
              final color = course.type == CourseType.theory ? AppColors.primary : AppColors.accent;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(isDarkMode),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border(isDarkMode)),
                ),
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${course.code} - ${course.title}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(isDarkMode),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${course.semesterName} | ${course.creditsString}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
