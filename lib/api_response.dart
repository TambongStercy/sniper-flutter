import 'dart:convert';

class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> body;
  final bool isSuccessByStatusCode;
  final bool
      apiReportedSuccess; // From response body e.g. {'success': true/false}
  final String message;
  final dynamic rawError; // To store the original exception if one occurs

  ApiResponse({
    required this.statusCode,
    required this.body,
    required this.isSuccessByStatusCode,
    required this.apiReportedSuccess,
    required this.message,
    this.rawError,
  });

  // Helper to determine overall success based on both status code and API's 'success' field
  bool get isOverallSuccess {
    return isSuccessByStatusCode && apiReportedSuccess;
  }

  factory ApiResponse.fromHttpReponse(
      int statusCode, String responseBodyString, Map<String, String> headers) {
    Map<String, dynamic> body = {};
    String message = '';
    bool apiSuccess = false;

    try {
      if (responseBodyString.isNotEmpty) {
        body = jsonDecode(responseBodyString);
        message = body['message']?.toString() ?? '';
        // Ensure 'success' is treated as boolean, default to false if not present or wrong type
        if (body['success'] is bool) {
          apiSuccess = body['success'];
        } else if (body['success'] is String) {
          apiSuccess = (body['success'] as String).toLowerCase() == 'true';
        } else {
          // If 'success' field is missing or not bool/string, and status code is 2xx,
          // we might infer success for certain endpoints if that's the API behavior.
          // However, since the user confirmed 'success: true/false' is consistent,
          // we'll rely on its presence. If it's missing, it's safer to assume not explicitly successful.
          apiSuccess = false;
        }
      }
    } catch (e) {
      print('Error decoding JSON response in ApiResponse.fromHttpReponse: $e');
      message = 'Failed to parse server response.';
      apiSuccess = false; // If parsing fails, cannot determine API success
    }

    final bool successByStatusCode = statusCode >= 200 && statusCode < 300;

    // If API didn't provide a message, but it's a successful status code, provide a generic one.
    if (message.isEmpty && successByStatusCode && apiSuccess) {
      message = 'Operation successful.';
    } else if (message.isEmpty && !successByStatusCode) {
      message = 'An unknown error occurred.';
    }

    return ApiResponse(
      statusCode: statusCode,
      body: body,
      isSuccessByStatusCode: successByStatusCode,
      apiReportedSuccess: apiSuccess,
      message: message,
    );
  }

  factory ApiResponse.fromError(dynamic error, {int statusCode = 0}) {
    String errorMessage = 'An unexpected error occurred.';
    if (error is String) {
      errorMessage = error;
    } else if (error is Exception) {
      errorMessage = error.toString();
    }
    // You could add more specific error type checking here if needed

    return ApiResponse(
      statusCode:
          statusCode, // 0 or a specific error code like 500 for internal
      body: {'error': errorMessage, 'success': false},
      isSuccessByStatusCode: false,
      apiReportedSuccess: false,
      message: errorMessage,
      rawError: error,
    );
  }
}
