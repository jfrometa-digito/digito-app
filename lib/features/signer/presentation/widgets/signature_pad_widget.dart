import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePadWidget extends StatefulWidget {
  const SignaturePadWidget({super.key});

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
  }

  Future<void> _export() async {
    if (_controller.isNotEmpty) {
      // In a real app, we would export bytes: await _controller.toPngBytes();
      // For now, we just return "true" to indicate a signature was captured.
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: Signature(
            controller: _controller,
            width: 300,
            height: 200,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: _clear,
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.isNotEmpty) {
                  _export();
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Please sign first')),
                   );
                }
              },
              child: const Text('Confirm Signature'),
            ),
          ],
        ),
      ],
    );
  }
}
