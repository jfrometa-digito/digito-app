import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/signature_pad_widget.dart';

class SigningScreen extends StatefulWidget {
  final String requestId;

  const SigningScreen({super.key, required this.requestId});

  @override
  State<SigningScreen> createState() => _SigningScreenState();
}

class _SigningScreenState extends State<SigningScreen> {
  // Mock State
  bool _isSigned = false;
  final ScrollController _scrollController = ScrollController();

  void _onSignFieldTapped() async {
    // Open Signature Pad
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const SignaturePadDialog(), // To be implemented
    );

    if (result == true) {
      setState(() {
        _isSigned = true;
      });
    }
  }

  void _onFinish() {
    // Finish Logic
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success'),
        content: const Text('The document has been signed successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              context.go('/');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Request #${widget.requestId}'),
        automaticallyImplyLeading:
            false, // Don't allow back if deep linked usually
      ),
      body: Stack(
        children: [
          // Document Scroller
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(
                top: 16, bottom: 100, left: 16, right: 16),
            itemCount: 2,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  height: 500,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(blurRadius: 5, color: Colors.black12)
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                          child: Text('Page ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 40, color: Colors.black12))),
                      if (index == 1) // Mock placing a field on page 2
                        Positioned(
                          top: 200,
                          left: 100,
                          child: GestureDetector(
                            onTap: _onSignFieldTapped,
                            child: Container(
                              width: 150,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _isSigned
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.indigo.withOpacity(0.1),
                                border: Border.all(
                                    color: _isSigned
                                        ? Colors.green
                                        : Colors.indigo,
                                    width: 2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: _isSigned
                                    ? const Text('Signed',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold))
                                    : const Text('Tap to Sign',
                                        style: TextStyle(
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              );
            },
          ),

          // Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2))
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isSigned ? '1/1 Signed' : '0/1 Signed',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: _isSigned ? _onFinish : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSigned ? Colors.green : Colors.grey,
                      ),
                      child: Text(_isSigned ? 'Finish & Submit' : 'Next Field'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignaturePadDialog extends StatelessWidget {
  const SignaturePadDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Sign Document'),
      content: SignaturePadWidget(),
      // Actions handled inside the widget for simplicity
    );
  }
}
