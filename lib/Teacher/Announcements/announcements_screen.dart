import 'package:flutter/material.dart';
import '../../data/teacher_static_data.dart';

/// Announcements screen - create and view announcements
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[600]!, Colors.deepOrange[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Announcements',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${sampleAnnouncements.length} active announcements',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildQuickAction('Class Test', Icons.quiz, Colors.red, isDarkMode)),
                const SizedBox(width: 12),
                Expanded(child: _buildQuickAction('Assignment', Icons.assignment, Colors.blue, isDarkMode)),
                const SizedBox(width: 12),
                Expanded(child: _buildQuickAction('Notice', Icons.info, Colors.green, isDarkMode)),
              ],
            ),
            const SizedBox(height: 24),

            // Announcements List
            Text(
              'Recent Announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...sampleAnnouncements.map(
              (announcement) => _buildAnnouncementCard(announcement, isDarkMode),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAnnouncementDialog(context, isDarkMode),
        backgroundColor: Colors.orange[600],
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showCreateAnnouncementDialog(context, isDarkMode, type: label),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement, bool isDarkMode) {
    final color = announcement.type == AnnouncementType.classTest
        ? Colors.red
        : announcement.type == AnnouncementType.assignment
            ? Colors.blue
            : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  announcement.type == AnnouncementType.classTest
                      ? Icons.quiz
                      : announcement.type == AnnouncementType.assignment
                          ? Icons.assignment
                          : Icons.info,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            announcement.courseCode,
                            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${announcement.createdAt.day}/${announcement.createdAt.month}/${announcement.createdAt.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[500]),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement.content,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context, bool isDarkMode, {String? type}) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedType = type ?? 'Notice';
    String selectedCourse = teacherCourses.first.code;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'New Announcement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Type Selector
              Row(
                children: ['Class Test', 'Assignment', 'Notice'].map((t) {
                  final isSelected = selectedType == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      onSelected: (selected) {
                        // This would need StatefulBuilder for actual state update
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Course Dropdown
              DropdownButtonFormField<String>(
                value: selectedCourse,
                decoration: InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: teacherCourses.map((c) => DropdownMenuItem(
                  value: c.code,
                  child: Text('${c.code} - ${c.title}'),
                )).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              // Title
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              // Content
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              // Post Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Announcement posted!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Post Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
