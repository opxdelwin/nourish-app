import 'package:flutter/material.dart';

/// A reusable custom dialog widget to display a list of notes (as bullet points).
///
/// The dialog includes:
/// - A title ("Note:")
/// - A close button in the top-right corner
/// - A dynamically built list of bullet point messages
///
/// This widget is intended to be used anywhere in the app where the user
/// needs to be shown a short, instructional or informational list.
///
/// Example usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => ExerciseNoteDialog(
///     onClose: () => Navigator.of(context).pop(),
///     notes: [
///       "Drink water regularly.",
///       "Stretch after exercise.",
///       "Maintain a balanced diet.",
///     ],
///   ),
/// );
/// ```
class ExerciseNoteDialog extends StatelessWidget {
  /// Function to be called when the close icon is tapped.
  final VoidCallback onClose;

  /// The list of bullet point strings to display in the dialog.
  final List<String> notes;

  /// Constructor for the ExerciseNoteDialog.
  ///
  /// Requires [onClose] and [notes] parameters.
  const ExerciseNoteDialog({
    super.key,
    required this.onClose,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, // Sets the dialog background to white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Gives rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24), // Inner spacing
        child: Column(
          mainAxisSize: MainAxisSize.min, // Dialog wraps its content
          children: [
            // Top row: title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Note:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                // Close button (top-right)
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),

            const SizedBox(height: 16), // Space between title and content

            // Display each note as a bullet item
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notes
                    .map((text) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BulletText(text), // custom widget below
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that represents a single bullet-pointed line of text.
///
/// This is used inside the [ExerciseNoteDialog] to present each item cleanly.
class BulletText extends StatelessWidget {
  /// The content of the bullet point.
  final String text;

  const BulletText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns bullet to top
      children: [
        const Text("• ", style: TextStyle(fontSize: 16)), // Bullet symbol
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}

/// A helper function to show the [ExerciseNoteDialog] with test/demo content.
///
/// This function wraps `showDialog` and provides example note strings.
/// Can be reused or customized elsewhere in the app.
///
/// Usage:
/// ```dart
/// showExercisePopup(context);
/// ```
void showExercisePopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => ExerciseNoteDialog(
      onClose: () => Navigator.of(context).pop(), // Closes the dialog
      notes: const [
        "This is a test for reusable popup content.",
        "As you can see I have changed the content and it’s customizable.",
        "You can just change these lines to change the content.",
      ],
    ),
  );
}




