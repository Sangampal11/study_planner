import 'package:flutter/material.dart';
import 'package:hubby/features/tasks.dart';
import '../../services/timetable_service.dart';   // ← Yeh import sahi hona chahiye

class StudyInputCard extends StatefulWidget {
  const StudyInputCard({super.key});

  @override
  State<StudyInputCard> createState() => _StudyInputCardState();
}

class _StudyInputCardState extends State<StudyInputCard> {
  String? _selectedClass;
  final _examDateController = TextEditingController();
  double _dailyHours = 4.0;
  String _selectedStrength = 'Moderate';

  final List<String> _classes = [
    // 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6',
    // 'Class 7', 'Class 8', 'Class 9', 'Class 10',
    // 'Class 11 Science', 'Class 11 Commerce',
    '12',
    // 'NEET', 'JEE Mains', 'JEE Advanced',
  ];

  final List<SubjectModel> _subjects = [];
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _examDateController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  // ==================== DATE PICKER FUNCTION ====================
  Future<void> _selectExamDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 60)),  // Default 2 months ahead
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A4CFF),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      setState(() {
        _examDateController.text = formattedDate;
      });
    }
  }

  // ==================== ADD SUBJECT FUNCTION ====================
  void _addSubject() {
    final name = _subjectController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subject name can't be empty!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _subjects.add(SubjectModel(name: name, strength: _selectedStrength));
      _subjectController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Added: $name"), backgroundColor: Colors.green),
    );
  }

  // ==================== GENERATE TIMETABLE ====================
  Future<void> _generateTimetable() async {
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one subject!"), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final cleanClassLevel = (_selectedClass ?? '12')
        .trim()
        .replaceAll('Class ', '')
        .replaceAll(' Science', '')
        .replaceAll(' Commerce', '')
        .split(' ')[0];

    final result = await generateAndSaveTimetable(
      examDate: _examDateController.text,
      dailyHours: _dailyHours,
      subjects: _subjects,
      classLevel: cleanClassLevel,
    ).timeout(const Duration(seconds: 40), onTimeout: () {
      print("Timeout! Server slow");
      return null;
    });

    Navigator.pop(context);  // loading band

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎉 Success! ${result['total_tasks'] ?? 0} tasks generated"),
          backgroundColor: Colors.green,
        ),
      );
      print("✅ Generated Tasks: ${result['tasks']}");

      // Yeh line add kar – Tasks page pe jump karo (auto reload hoga)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TasksPage(onAddTask: () {})),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to generate. Check connection or inputs."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGenerate = _selectedClass != null &&
        _examDateController.text.isNotEmpty &&
        _subjects.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black54),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================== CLASS SELECTION ====================
          const Text(
            "Select Your Class",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedClass,
            decoration: InputDecoration(
              hintText: "Choose class...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _classes.map((String cls) {
              return DropdownMenuItem<String>(
                value: cls,
                child: Text(cls),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedClass = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // ==================== EXAM DATE ====================
          const Text(
            "Exam Date",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _examDateController,
            readOnly: true,  // Manual typing band, sirf picker se
            decoration: InputDecoration(
              hintText: "Pick exam date (dd-mm-yyyy)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6A4CFF)),
            ),
            onTap: _selectExamDate,  // Date picker trigger
          ),
          const SizedBox(height: 20),

          // ==================== DAILY HOURS SLIDER ====================
          const Text(
            "Daily Study Hours",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _dailyHours,
            min: 1.0,
            max: 8.0,
            divisions: 7,
            label: _dailyHours.toStringAsFixed(0),
            activeColor: const Color(0xFF6A4CFF),
            onChanged: (value) {
              setState(() {
                _dailyHours = value;
              });
            },
          ),
          Text(
            "${_dailyHours.toStringAsFixed(0)} hours/day",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),

          // ==================== ADD SUBJECTS SECTION ====================
          const Text(
            "Add Subjects",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              hintText: "Enter subject name (e.g., Math)...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onSubmitted: (_) => _addSubject(),  // Enter press pe add ho jaye
          ),
          const SizedBox(height: 16),

          // Strength Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStrengthButton("Weak", Colors.red, Icons.warning_amber),
              _buildStrengthButton("Moderate", Colors.orange, Icons.remove_circle),
              _buildStrengthButton("Strong", Colors.green, Icons.check_circle),
            ],
          ),
          const SizedBox(height: 20),

          // ==================== ADD SUBJECT BUTTON ====================
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Subject",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4CFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _addSubject,
            ),
          ),
          const SizedBox(height: 16),

          // ==================== SUBJECTS LIST (Bonus - Dekh sake added subjects) ====================
          if (_subjects.isNotEmpty) ...[
            const Text(
              "Added Subjects:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ..._subjects.map((subj) => Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(subj.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    subj.strength,
                    style: TextStyle(
                      color: subj.strength == 'Weak' ? Colors.red : subj.strength == 'Moderate' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),
          ],

          // ==================== GENERATE TIMETABLE BUTTON ====================
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome, size: 26, color: Colors.white),
              label: const Text(
                "Generate Timetable",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: canGenerate ? const Color(0xFF6A4CFF) : Colors.grey.shade400,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: canGenerate ? 6 : 0,
              ),
              onPressed: canGenerate ? _generateTimetable : null,
            ),
          ),
        ],
      ),
    );
  }

  // Strength button widget
  Widget _buildStrengthButton(String label, Color color, IconData icon) {
    final selected = _selectedStrength == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStrength = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.25) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? color : Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectModel {
  final String name;
  final String strength;
  SubjectModel({required this.name, required this.strength});
}