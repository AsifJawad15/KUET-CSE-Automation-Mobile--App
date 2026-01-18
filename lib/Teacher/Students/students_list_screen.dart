import 'package:flutter/material.dart';
import '../../data/teacher_static_data.dart';
import '../../models/user_model.dart';
import 'student_detail_screen.dart';

/// Students List screen - view and manage students
class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  String _selectedSection = 'A';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final students = getStudentsBySection(_selectedSection)
        .where((s) => s.roll.contains(_searchQuery) || s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddStudentDialog(context, isDarkMode),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: Column(
              children: [
                // Search
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by roll or name...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Section Filter
                Row(
                  children: [
                    Text(
                      'Section:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildSectionChip('A', isDarkMode),
                    const SizedBox(width: 8),
                    _buildSectionChip('B', isDarkMode),
                    const Spacer(),
                    Text(
                      '${students.length} students',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Student List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentCard(student, isDarkMode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionChip(String section, bool isDarkMode) {
    final isSelected = _selectedSection == section;
    return GestureDetector(
      onTap: () => setState(() => _selectedSection = section),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          section,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentUser student, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StudentDetailScreen(student: student)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal.withOpacity(0.1),
              child: Text(
                student.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                style: TextStyle(
                  color: Colors.teal[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          student.roll,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Section ${student.section}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Student'),
        content: const Text('This feature will be available with admin access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
