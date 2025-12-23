import 'package:genui/genui.dart';

class MyTool extends AiTool<Map<String, Object?>> {
  MyTool()
      : super(
          name: 'test',
          description: 'desc',
          // parameters: const Schema.object(properties: {}),
        ); // I'll uncomment in next file write if I want to test

  @override
  Future<Map<String, dynamic>> invoke(Map<String, Object?> args) async => {};
}
