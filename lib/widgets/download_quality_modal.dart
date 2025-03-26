import 'package:flutter/material.dart';

class DownloadQualityModal extends StatefulWidget {
  final List<Map<String, String>> qualities;
  final Function(Map<String, String>) onQualitySelected;



  const DownloadQualityModal({
    super.key,
    required this.qualities,
    required this.onQualitySelected,
  });

  @override
  State<DownloadQualityModal> createState() => _DownloadQualityModalState();
}

class _DownloadQualityModalState extends State<DownloadQualityModal> {
  String selectedQuality = ''; // ✅ User selected label (e.g., 720p)

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F8FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Quality",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E65FF),
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: widget.qualities.map((q) {
              final isSelected = selectedQuality == q['label'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedQuality = q['label']!;
                  });
                },
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1E65FF) : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E65FF)
                          : const Color(0xFFE0E7FF),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      if (isSelected)
                        const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        q['label']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected ? Colors.white : const Color(0xFF0042BA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        q['size']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : const Color(0xFF1E65FF),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (selectedQuality.isNotEmpty) {
                  final selected = widget.qualities.firstWhere(
                        (q) => q['label'] == selectedQuality,
                    orElse: () => {},
                  );

                  if (selected.isNotEmpty) {
                    widget.onQualitySelected(selected);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a quality")),
                  );
                }
              },
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: const Text(
                "Save Video",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E65FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              if (selectedQuality.isNotEmpty) {
                final selected = widget.qualities.firstWhere(
                      (q) => q['label'] == selectedQuality,
                  orElse: () => {},
                );

                if (selected.isNotEmpty) {
                  widget.onQualitySelected(selected);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a quality")),
                );
              }
            },
            child: const Text(
              "Watch Video",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
