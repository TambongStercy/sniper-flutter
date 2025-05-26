import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:snipper_frontend/config.dart'; // Assuming base URL is in config
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:snipper_frontend/utils.dart'; // Ensure utils is imported
import 'dart:io'; // Import for File operations
import 'package:http_parser/http_parser.dart'; // Import for MediaType
import './api_response.dart'; // Import the ApiResponse class
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:path_provider/path_provider.dart'; // For getApplicationDocumentsDirectory

class ApiService {
  // Use the base URL from your config
  final String _baseUrl = '${host}api'; // Use gateway_url from config.dart
  String? _token; // Internal cache for the token

  // Load token from SharedPreferences and cache it
  Future<void> _loadToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
    }
  }

  // Retrieve the cached token
  Future<String?> _getToken() async {
    await _loadToken(); // Ensure token is loaded
    return _token;
  }

  // Prepare headers for API requests
  Future<Map<String, String>> _getHeaders(
      {bool requiresAuth = true, bool isFormData = false}) async {
    Map<String, String> headers = {};
    if (!isFormData) {
      headers['Content-Type'] = 'application/json';
    }
    headers['Accept'] = 'application/json';

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        print("Warning: Auth token is null for a protected route.");
        // Optionally, throw an error or handle cases where token is required but missing
      }
    }
    return headers;
  }

  // Centralized response handling
  ApiResponse _handleHttpResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    final contentType = response.headers['content-type'];
    final isJson = contentType?.contains('application/json') ?? false;

    if (response.body.length > 1024) {
      print('Response Body: [Truncated due to length > 1024 characters]');
    } else {
      print('Response Body: ${response.body}');
    }
    print('Response Headers: ${response.headers}');

    if (isJson) {
      return ApiResponse.fromHttpReponse(
          response.statusCode, response.body, response.headers);
    } else {
      // For non-JSON responses (like VCF files)
      // Return a generic success/failure ApiResponse. The actual file content
      // should be handled by the caller using the raw http.Response.body directly.
      bool success = response.statusCode >= 200 && response.statusCode < 300;
      return ApiResponse.fromHttpReponse(
          response.statusCode,
          // Provide a minimal valid JSON string for the body to avoid parsing errors,
          // as the actual VCF content is in the original response.body.
          success
              ? '{"data": "File content type, not JSON. Handled by caller.", "message": "File retrieval successful."}'
              : '{"message": "File retrieval failed."}',
          response.headers);
    }
  }

  // Generic GET request
  Future<ApiResponse> get(String endpoint,
      {bool requiresAuth = true, Map<String, String>? queryParameters}) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    var uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    print('GET Request: $uri');
    print('Headers: $headers');

    try {
      final response = await http.get(uri, headers: headers);
      return _handleHttpResponse(response);
    } on SocketException catch (e) {
      print('SocketException in GET $endpoint: $e');
      return ApiResponse.fromError(
          'Network error: Please check your connection and try again.',
          statusCode: -1);
    } on HttpException catch (e) {
      print('HttpException in GET $endpoint: $e');
      return ApiResponse.fromError(
          'Could not connect to the server: Please try again later.',
          statusCode: -2);
    } catch (e) {
      print('Exception in GET $endpoint: $e');
      return ApiResponse.fromError(
          'An unexpected error occurred: ${e.toString()}',
          statusCode: -3);
    }
  }

  // Generic POST request
  Future<ApiResponse> post(String endpoint,
      {required Map<String, dynamic> body, bool requiresAuth = true}) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final url = Uri.parse('$_baseUrl$endpoint');
    final encodedBody = jsonEncode(body);

    try {
      final response =
          await http.post(url, headers: headers, body: encodedBody);
      return _handleHttpResponse(response);
    } on SocketException catch (e) {
      print('SocketException in POST $endpoint: $e');
      return ApiResponse.fromError(
          'Network error: Please check your connection and try again.',
          statusCode: -1);
    } on HttpException catch (e) {
      print('HttpException in POST $endpoint: $e');
      return ApiResponse.fromError(
          'Could not connect to the server: Please try again later.',
          statusCode: -2);
    } catch (e) {
      print('Exception in POST $endpoint: $e');
      return ApiResponse.fromError(
          'An unexpected error occurred: ${e.toString()}',
          statusCode: -3);
    }
  }

  // Generic PUT request
  Future<ApiResponse> put(String endpoint,
      {required Map<String, dynamic> body, bool requiresAuth = true}) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final url = Uri.parse('$_baseUrl$endpoint');
    final encodedBody = jsonEncode(body);

    print('PUT Request: $url');
    print('Headers: $headers');
    print('Body: $encodedBody');

    try {
      final response = await http.put(url, headers: headers, body: encodedBody);
      return _handleHttpResponse(response);
    } on SocketException catch (e) {
      print('SocketException in PUT $endpoint: $e');
      return ApiResponse.fromError(
          'Network error: Please check your connection and try again.',
          statusCode: -1);
    } on HttpException catch (e) {
      print('HttpException in PUT $endpoint: $e');
      return ApiResponse.fromError(
          'Could not connect to the server: Please try again later.',
          statusCode: -2);
    } catch (e) {
      print('Exception in PUT $endpoint: $e');
      return ApiResponse.fromError(
          'An unexpected error occurred: ${e.toString()}',
          statusCode: -3);
    }
  }

  // Generic DELETE request
  Future<ApiResponse> delete(String endpoint,
      {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final url = Uri.parse('$_baseUrl$endpoint');
    final encodedBody = body != null ? jsonEncode(body) : null;

    print('DELETE Request: $url');
    print('Headers: $headers');
    if (encodedBody != null) print('Body: $encodedBody');

    try {
      final response =
          await http.delete(url, headers: headers, body: encodedBody);
      return _handleHttpResponse(response);
    } on SocketException catch (e) {
      print('SocketException in DELETE $endpoint: $e');
      return ApiResponse.fromError(
          'Network error: Please check your connection and try again.',
          statusCode: -1);
    } on HttpException catch (e) {
      print('HttpException in DELETE $endpoint: $e');
      return ApiResponse.fromError(
          'Could not connect to the server: Please try again later.',
          statusCode: -2);
    } catch (e) {
      print('Exception in DELETE $endpoint: $e');
      return ApiResponse.fromError(
          'An unexpected error occurred: ${e.toString()}',
          statusCode: -3);
    }
  }

  // --- File Upload Helper ---
  Future<ApiResponse> uploadFiles({
    required String endpoint,
    required List<File> files,
    required String fieldName, // e.g., 'productImages', 'avatar'
    Map<String, String>? fields, // Other text fields to send with the files
    bool requiresAuth = true,
    String httpMethod = 'POST', // 'POST' or 'PUT'
  }) async {
    final headers =
        await _getHeaders(requiresAuth: requiresAuth, isFormData: true);
    final url = Uri.parse('$_baseUrl$endpoint');

    print('File Upload Request ($httpMethod): $url');
    print('Headers: $headers');
    print('Files: ${files.map((f) => f.path).toList()}');
    print('FieldName: $fieldName');
    if (fields != null) print('Fields: $fields');

    try {
      var request = http.MultipartRequest(httpMethod, url);
      request.headers.addAll(headers);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      for (var file in files) {
        http.ByteStream fileStream = http.ByteStream(file.openRead());
        int fileLength = await file.length();
        http.MultipartFile multipartFile = http.MultipartFile(
          fieldName,
          fileStream,
          fileLength,
          filename: file.path.split('/').last,
          contentType: MediaType.parse(
              lookupMimeType(file.path) ?? 'application/octet-stream'),
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return _handleHttpResponse(response);
    } on SocketException catch (e) {
      print('SocketException during file upload $endpoint: $e');
      return ApiResponse.fromError(
        'Network error during file upload. Please check your connection.',
        statusCode: -1,
      );
    } on HttpException catch (e) {
      print('HttpException during file upload $endpoint: $e');
      return ApiResponse.fromError(
        'Could not connect to the server for file upload.',
        statusCode: -2,
      );
    } catch (e) {
      print('Exception during file upload $endpoint: $e');
      return ApiResponse.fromError(
        'An unexpected error occurred during file upload: ${e.toString()}',
        statusCode: -3,
      );
    }
  }

  // --- User and Auth Related Methods ---
  Future<ApiResponse> loginUser(String email, String password) async {
    return await post(
      '/users/login', // Endpoint based on documentation or common practice
      body: {'email': email, 'password': password},
      requiresAuth: false, // Login does not require a token
    );
  }

  Future<ApiResponse> verifyOtp(String userId, String otp) async {
    return await post(
      '/users/verify-otp', // Endpoint based on existing code
      body: {'userId': userId, 'otpCode': otp},
      requiresAuth:
          false, // OTP verification might be public or use a temporary token
    );
  }

  Future<ApiResponse> resendVerificationOtp(String userId) async {
    return await post(
      '/users/resend-otp',
      body: {'userId': userId},
      requiresAuth: false,
    );
  }

  Future<ApiResponse> registerUser(Map<String, dynamic> userData) async {
    return await post('/users/register', body: userData);
  }

  Future<ApiResponse> getUserProfile() async {
    return await get('/users/me');
  }

  Future<ApiResponse> updateUserProfile(Map<String, dynamic> updates) async {
    return await put('/users/me', body: updates);
  }

  Future<ApiResponse> uploadAvatar(String pathOrBase64, String fileName) async {
    if (kIsWeb) {
      // For web, pathOrBase64 is a base64 string.
      // This simplified version assumes backend can take base64 string directly.
      return await post('/users/me/avatar-base64', body: {
        // Assuming a specific endpoint for base64
        'avatarBase64': pathOrBase64,
        'fileName': fileName
      });
    } else {
      // For mobile, pathOrBase64 is a file path
      File file = File(pathOrBase64);
      return await uploadFiles(
        // Reusing the generic uploadFiles helper
        endpoint: '/users/me/avatar', // Standard multipart endpoint for avatar
        files: [file],
        fieldName: 'avatar',
      );
    }
  }

  Future<ApiResponse> getUserProfileById(String userId) async {
    return await get('/users/$userId'); // Assuming public profile
  }

  Future<ApiResponse> logoutUser() async {
    return await post('/users/logout',
        body: {}); // Assumes token in header is enough
  }

  // --- Password Management Methods ---
  Future<ApiResponse> requestPasswordResetOtp(String email) async {
    final endpoint = '/users/request-password-reset';
    return await post(endpoint, body: {'email': email}, requiresAuth: false);
  }

  Future<ApiResponse> resetPassword(
      String emailOrUserId, String otp, String newPassword) async {
    final endpoint = '/users/reset-password';
    return await post(
      endpoint,
      body: {
        'email': emailOrUserId,
        'otpCode': otp,
        'newPassword': newPassword,
      },
      requiresAuth: false,
    );
  }

  // --- Email Change Methods ---
  Future<ApiResponse> requestEmailChangeOtp(String newEmail) async {
    return await post('/users/request-email-change',
        body: {'newEmail': newEmail});
  }

  Future<ApiResponse> confirmEmailChange(
      String newEmail, String otpCode) async {
    return await post('/users/confirm-change-email',
        body: {'newEmail': newEmail, 'otpCode': otpCode});
  }

  Future<ApiResponse> verifyEmailChange(String newEmail, String otp) async {
    return await post('/users/verify-email-change', body: {
      'newEmail': newEmail,
      'otp': otp,
    });
  }

  Future<ApiResponse> resendOtpByEmail(String email, String purpose) async {
    return await post('/users/resend-otp', body: {
      'email': email,
      'purpose': purpose,
    });
  }

  // --- Product/Service Methods ---
  Future<ApiResponse> getProducts({Map<String, String>? filters}) async {
    return await get('/products/search', queryParameters: filters);
  }

  Future<ApiResponse> getProductDetails(String productId) async {
    return await get('/products/$productId');
  }

  Future<ApiResponse> getProductRatings(String productId,
      {int page = 1, int limit = 10}) async {
    return await get('/products/$productId/ratings', queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  Future<ApiResponse> addProduct(Map<String, dynamic> productData,
      {List<File>? imageFiles}) async {
    // Convert all productData values to strings for the 'fields' parameter
    final Map<String, String> stringProductData = productData.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    if (imageFiles != null && imageFiles.isNotEmpty) {
      return await uploadFiles(
        endpoint: '/products',
        files: imageFiles,
        fieldName: 'images', // Field name for the image files
        fields: stringProductData, // Other product data as string fields
        requiresAuth: true,
        httpMethod: 'POST',
      );
    } else {
      // If there are no images, we can still send as multipart if the backend expects it,
      // or fall back to a regular JSON post if the backend supports that for no-image cases.
      // For consistency with the HTTP file, let's assume multipart is preferred.
      return await uploadFiles(
        endpoint: '/products',
        files: [], // Empty list of files
        fieldName:
            'images', // Still need a fieldName, even if no files, or adjust backend
        fields: stringProductData,
        requiresAuth: true,
        httpMethod: 'POST',
      );
      // Alternative for no images, if backend supports JSON post:
      // return await post('/products', body: productData);
    }
  }

  Future<ApiResponse> updateProduct(
      String productId, Map<String, String> updates,
      {List<String>? imageFiles}) async {
    if (imageFiles != null && imageFiles.isNotEmpty) {
      // For now, without uploadFiles, just update text fields
      // In a real implementation, you'd need to handle multipart uploads
      print(
          "Warning: Image files would be uploaded but uploadFiles not implemented");
      // Just do a regular update without images
    }
    // Always use a regular PUT request for now
    Map<String, dynamic> dynamicUpdates = Map<String, dynamic>.from(updates);
    return await put('/products/$productId', body: dynamicUpdates);
  }

  Future<ApiResponse> deleteProduct(String productId) async {
    return await delete('/products/$productId');
  }

  Future<ApiResponse> rateProduct(String productId, double rating,
      {String? review}) async {
    final Map<String, dynamic> body = {'rating': rating};
    if (review != null && review.isNotEmpty) {
      body['review'] = review;
    }
    return await post('/products/$productId/ratings', body: body);
  }

  // --- Contact Management Methods ---
  Future<ApiResponse> searchContacts(Map<String, dynamic> filters) async {
    final queryParams =
        filters.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    return await get('/contacts/search', queryParameters: queryParams);
  }

  Future<ApiResponse> exportContacts(Map<String, dynamic> filters) async {
    // This response might be a file stream or VCF data, needs special handling in _handleHttpResponse if not JSON
    // For now, assuming ApiResponse.fromHttpReponse can handle it or will be adapted
    final queryParams =
        filters.map((key, value) => MapEntry(key, value?.toString() ?? ''));
    // If it returns a file, the 'get' method might need an 'expectJson: false' type of flag,
    // or the _handleHttpResponse needs to be smarter about content-type.
    // For now, let's assume it's a JSON response with a link or raw VCF data in a field.
    return await get('/contacts/export', queryParameters: queryParams);
  }

  Future<ApiResponse> requestContactsExportOtp() async {
    return await post('/contacts/request-otp', body: {});
  }

  // --- Subscription and Payment ---
  Future<ApiResponse> getSubscriptionPlans() async {
    return await get('/subscriptions/plans',
        requiresAuth: false); // Often public
  }

  Future<ApiResponse> getCurrentSubscription() async {
    return await get('/subscriptions/me');
  }

  Future<ApiResponse> createPaymentIntent(
      String planId, String paymentMethod) async {
    return await post('/payments/create-intent',
        body: {'planId': planId, 'paymentMethod': paymentMethod});
  }

  Future<ApiResponse> confirmPayment(
      String paymentId, Map<String, dynamic> confirmationData) async {
    return await post('/payments/$paymentId/confirm', body: confirmationData);
  }

  // --- Wallet / Withdrawal ---
  Future<ApiResponse> getWalletDetails() async {
    return await get('/wallet/me');
  }

  Future<ApiResponse> requestWithdrawal(String operator, String phoneNumber,
      double amount, String password) async {
    return await post('/wallet/withdraw', body: {
      'operator': operator,
      'phoneNumber': phoneNumber,
      'amount': amount,
      'password': password // Assuming password confirmation for withdrawal
    });
  }

  Future<ApiResponse> convertCurrency(
      String amount, String fromCurrency, String toCurrency) async {
    return await post('/wallet/convert-currency', body: {
      // Assuming a POST endpoint
      'amount': amount,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
    });
  }

  Future<ApiResponse> requestWithdrawalOtp(
      Map<String, dynamic> withdrawalData) async {
    return await post('/wallet/request-withdrawal-otp', body: withdrawalData);
  }

  Future<ApiResponse> confirmWithdrawal(
      Map<String, dynamic> withdrawalData) async {
    return await post('/wallet/confirm-withdrawal', body: withdrawalData);
  }

  Future<ApiResponse> getTransactionHistory(
      {Map<String, String>? filters}) async {
    return await get('/transactions/history', queryParameters: filters);
  }

  // --- Affiliation ---
  Future<ApiResponse> getAffiliationDetails() async {
    return await get('/users/affiliation/me');
  }

  Future<ApiResponse> getMyAffiliator() async {
    return await get('/users/affiliator'); // Assuming this endpoint
  }

  Future<ApiResponse> getAffiliationInfo(String code) async {
    return await get('/users/get-affiliation',
        queryParameters: {'referralCode': code});
  }

  // New method for referral stats
  Future<ApiResponse> getReferralStats() async {
    return await get(
        '/users/get-referals'); // Replace with your actual endpoint
  }

  // New method for referred users
  Future<ApiResponse> getReferredUsers(Map<String, String> filters) async {
    return await get('/users/get-refered-users',
        queryParameters: filters); // Replace with your actual endpoint
  }

  // --- Notifications ---
  Future<ApiResponse> getNotifications() async {
    return await get('/notifications/me');
  }

  Future<ApiResponse> markNotificationAsRead(String notificationId) async {
    return await post('/notifications/$notificationId/mark-read', body: {});
  }

  // --- Support ---
  Future<ApiResponse> getFaqs() async {
    return await get('/support/faq', requiresAuth: false);
  }

  Future<ApiResponse> submitSupportTicket(
      Map<String, dynamic> ticketData) async {
    return await post('/support/tickets', body: ticketData);
  }

  // --- App Settings ---
  Future<ApiResponse> getAppSettings() async {
    return await get('/settings',
        requiresAuth: false); // Assuming public or specific endpoint
  }

  // --- Transaction Related Methods ---
  Future<ApiResponse> getTransactions(Map<String, String>? filters) async {
    return await get('/transactions/history', queryParameters: filters);
  }

  Future<ApiResponse> getPartnerTransactions(
      Map<String, String>? filters) async {
    return await get('/partners/me/transactions', queryParameters: filters);
  }

  Future<ApiResponse> getTransactionById(String transactionId) async {
    return await get('/transactions/$transactionId');
  }

  Future<ApiResponse> getTransactionStats() async {
    return await get('/transactions/stats'); // Assuming this is the endpoint
  }

  // --- Partner Related Methods ---
  Future<ApiResponse> getPartnerDetails() async {
    return await get('/partners/me');
  }

  // --- Subscription Related Methods ---
  Future<ApiResponse> upgradeSubscription() async {
    return await post('/subscriptions/upgrade', body: {});
  }

  String generatePaymentUrl(String sessionId) {
    return '$_baseUrl/payments/page/$sessionId';
  }

  // --- Subscription Purchase Method ---
  Future<ApiResponse> purchaseSubscription(String planTypeString) async {
    return await post('/subscriptions/purchase',
        body: {'planType': planTypeString});
  }

  // --- User's Products ---
  Future<ApiResponse> getUserProducts({Map<String, String>? filters}) async {
    return await get('/products/user',
        queryParameters: filters); // Endpoint for current user's products
  }

  // ... Add other specific API methods here, refactoring them to return ApiResponse ...
}
