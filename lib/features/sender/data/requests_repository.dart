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
      return jsonList
          .map(
              (json) => SignatureRequest.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // In case of migration or corruption error, return empty for now
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
