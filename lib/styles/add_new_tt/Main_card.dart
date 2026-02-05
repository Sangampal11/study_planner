import 'package:flutter/material.dart';

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
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11 Science',
    'Class 11 Commerce',
    'Class 12 Science',
    'Class 12 Commerce',
    'NEET',
    'JEE Mains',
    'JEE Advanced',
  ];

  final List<SubjectModel> _subjects = [];
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _examDateController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Your Class ───────────────────────────────
          Row(
            children: [ 
              Icon(Icons.school_outlined,size: 20,),
              SizedBox(width: 5,),
              Text(
              "Your Class",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),]
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedClass,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: "Select your class",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _classes.map((cls) {
              return DropdownMenuItem(
                value: cls,
                child: Text(cls),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedClass = value);
            },
          ),

          const SizedBox(height: 24),

          // ── Exam Date ────────────────────────────────
           Row(
             children:[
               Icon(Icons.calendar_today,size: 15,),
               SizedBox(width: 5,),
               Text(
              "Exam Date",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
                       ),]
           ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _examDateController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "dd-mm-yyyy",
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                _examDateController.text =
                "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
              }
            },
          ),

          const SizedBox(height: 24),

          // ── Daily Study Hours ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined,size: 20,),
                  SizedBox(width: 5,),
                  Text(
                  "Daily Study Hours",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),]
              ),
              Text(
                "${_dailyHours.toStringAsFixed(0)}h",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A4CFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: Colors.grey,
              thumbColor: const Color(0xFF6A4CFF),
            ),
            child: Slider(
              value: _dailyHours,
              min: 1,
              max: 12,
              divisions: 11,
              label: "${_dailyHours.toInt()}h",
              onChanged: (value) {
                setState(() => _dailyHours = value);
              },
            ),
          ),

          const SizedBox(height: 28),

          // ── Add Subjects ─────────────────────────────
          const Text(
            "Add Subjects",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              hintText: "Enter subject name...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 16),

          // Strength buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStrengthButton("Weak", Colors.red, Icons.warning_amber),
              _buildStrengthButton("Moderate", Colors.orange, Icons.remove_circle),
              _buildStrengthButton("Strong", Colors.green, Icons.check_circle),
            ],
          ),

          const SizedBox(height: 20),

          // Add Subject Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                "Add Subject",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4CFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _subjectController.text.trim().isEmpty
                  ? null
                  : () {
                setState(() {
                  _subjects.add(SubjectModel(
                    name: _subjectController.text.trim(),
                    strength: _selectedStrength,
                  ));
                  _subjectController.clear();
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Selected subjects chips
          if (_subjects.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _subjects.map((sub) {
                final color = sub.strength == 'Weak'
                    ? Colors.red
                    : sub.strength == 'Strong'
                    ? Colors.green
                    : Colors.orange;

                final icon = sub.strength == 'Weak'
                    ? Icons.warning_amber
                    : sub.strength == 'Strong'
                    ? Icons.check_circle
                    : Icons.remove_circle_outline;

                return Chip(
                  avatar: Icon(icon, size: 18, color: Colors.white),
                  label: Text(sub.name),
                  backgroundColor: color.withOpacity(0.12),
                  deleteIconColor: color,
                  onDeleted: () => setState(() => _subjects.remove(sub)),
                );
              }).toList(),
            ),

        ],
      ),
    );
  }

  Widget _buildStrengthButton(String label, Color color, IconData icon) {
    final selected = _selectedStrength == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedStrength = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.25) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
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