enum RequestStatus { draft, sent, completed, declined }

class SignatureRequest {
  final String id;
  final String title;
  final DateTime createdAt;
  final RequestStatus status;
  final String? documentPath; // Path to local PDF
  final List<String> recipients;

  const SignatureRequest({
    required this.id,
    required this.title,
    required this.createdAt,
    this.status = RequestStatus.draft,
    this.documentPath,
    this.recipients = const [],
  });
  
  // Placeholder for copyWith and JSON serialization if needed
}
