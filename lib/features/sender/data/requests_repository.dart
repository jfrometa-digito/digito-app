import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/models/signature_request.dart';

class RequestsRepository {
  static const _storageKey = 'digito_requests_v1';

  Future<List<SignatureRequest>> getAllRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<SignatureRequest> requests = [];
      for (final json in jsonList) {
        try {
          requests.add(SignatureRequest.fromJson(json as Map<String, dynamic>));
        } catch (e) {
          // Continue to next one instead of failing entire list
        }
      }
      return requests;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveRequest(SignatureRequest request) async {
    final requests = await getAllRequests();
    final index = requests.indexWhere((r) => r.id == request.id);

    if (index != -1) {
      requests[index] = request;
    } else {
      requests.add(request);
    }

    await _persistInfo(requests);
  }

  Future<void> deleteRequest(String id) async {
    final requests = await getAllRequests();
    requests.removeWhere((r) => r.id == id);
    await _persistInfo(requests);
  }

  Future<void> _persistInfo(List<SignatureRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = requests.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
}
