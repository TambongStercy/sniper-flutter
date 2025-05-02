import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:snipper_frontend/config.dart'; // Assuming base URL is in config
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:snipper_frontend/utils.dart'; // Ensure utils is imported
import 'dart:io'; // Import for File operations
import 'package:http_parser/http_parser.dart'; // Import for MediaType

class ApiService {
  // Use the base URL from your config
  final String _baseUrl = url; // Use gateway_url from config.dart

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Modify _handleResponse to potentially handle non-JSON for specific cases
  dynamic _handleResponse(http.Response response, {bool expectJson = true}) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (!expectJson) {
        // Return raw body for non-JSON expected responses (like VCF)
        return {
          'success': true,
          'data': response.body,
          'statusCode': response.statusCode
        };
      }

      // Existing JSON handling
      final Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        print(
            'Error decoding JSON response: ${response.statusCode} - ${response.body}');
        return {
          'error': 'Invalid response format',
          'statusCode': response.statusCode
        };
      }

      if (jsonResponse.containsKey('success') &&
          jsonResponse['success'] == false) {
        print(
            'API Error (Success False): ${response.statusCode} - ${jsonResponse['message'] ?? jsonResponse['error'] ?? response.body}');
        jsonResponse['statusCode'] = response.statusCode;
        return jsonResponse;
      }
      jsonResponse['statusCode'] = response.statusCode;
      return jsonResponse;
    } else {
      // Existing error handling for non-2xx status codes
      Map<String, dynamic> errorResponse = {};
      try {
        errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // Use raw body if JSON decoding fails for error
        errorResponse = {'error': response.body};
      }
      print(
          'API Error: ${response.statusCode} - ${errorResponse['message'] ?? errorResponse['error'] ?? response.body}');
      errorResponse['statusCode'] = response.statusCode;
      return errorResponse;
    }
  }

  // Modify GET helper to accept expectJson and requiresAuth parameters
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? headers,
      bool expectJson = true,
      bool requiresAuth = true}) async {
    Map<String, String> finalHeaders = {...?headers};

    if (requiresAuth) {
      final token = await _getToken();
      if (token == null) {
        print("Authentication token not found for protected route.");
        return {'error': 'Authentication required', 'statusCode': 401};
      }
      finalHeaders['Authorization'] = 'Bearer $token';
    }

    // Construct the final URL
    final uri = Uri.parse('$_baseUrl$endpoint');
    print("GET Request: ${uri.toString()}"); // Log the request URL

    final response = await http.get(
      uri,
      headers: finalHeaders, // Use the potentially modified headers
    );
    // Pass expectJson to _handleResponse
    return _handleResponse(response, expectJson: expectJson)
        as Map<String, dynamic>;
  }

  // Modify POST helper to accept requiresAuth parameter
  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, String>? headers,
      dynamic body,
      bool requiresAuth = true}) async {
    final defaultHeaders = {'Content-Type': 'application/json'};
    Map<String, String> finalHeaders = {
      ...defaultHeaders,
      ...?headers,
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token == null) {
        print("Authentication token not found for protected route.");
        return {'error': 'Authentication required', 'statusCode': 401};
      }
      finalHeaders['Authorization'] = 'Bearer $token';
    }

    final uri = Uri.parse('$_baseUrl$endpoint');
    print("POST Request: ${uri.toString()}"); // Log the request URL

    final response = await http.post(
      uri,
      headers: finalHeaders,
      body: jsonEncode(body), // Assume body is usually JSON
    );
    return _handleResponse(response);
  }

  // Modify PUT helper to accept requiresAuth parameter
  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, String>? headers,
      dynamic body,
      bool requiresAuth = true}) async {
    final defaultHeaders = {'Content-Type': 'application/json'};
    Map<String, String> finalHeaders = {
      ...defaultHeaders,
      ...?headers,
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token == null) {
        print("Authentication token not found for protected route.");
        return {'error': 'Authentication required', 'statusCode': 401};
      }
      finalHeaders['Authorization'] = 'Bearer $token';
    }

    final uri = Uri.parse('$_baseUrl$endpoint');
    print("PUT Request: ${uri.toString()}"); // Log the request URL

    final response = await http.put(
      uri,
      headers: finalHeaders,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // Add DELETE helper method
  Future<Map<String, dynamic>> delete(String endpoint,
      {Map<String, String>? headers,
      dynamic body,
      bool requiresAuth = true}) async {
    Map<String, String> finalHeaders = {...?headers};

    if (requiresAuth) {
      final token = await _getToken();
      if (token == null) {
        print("Authentication token not found for protected route.");
        return {'error': 'Authentication required', 'statusCode': 401};
      }
      finalHeaders['Authorization'] = 'Bearer $token';
    }

    // Add content-type if body is present
    if (body != null) {
      finalHeaders.putIfAbsent('Content-Type', () => 'application/json');
    }

    final uri = Uri.parse('$_baseUrl$endpoint');
    print("DELETE Request: ${uri.toString()}");

    final response = await http.delete(
      uri,
      headers: finalHeaders,
      body: body != null ? jsonEncode(body) : null, // Encode body if present
    );
    return _handleResponse(response);
  }

  // --- Specific API Methods ---

  /// Fetches the profile of the currently logged-in user.
  Future<Map<String, dynamic>> getUserProfile() async {
    // Default requiresAuth = true is appropriate
    return await get('/users/me');
  }

  /// Updates the profile of the currently logged-in user.
  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> updates) async {
    // Default requiresAuth = true is appropriate
    return await put('/users/me', body: updates);
  }

  /// Fetches the public profile of a specific user by their ID.
  Future<Map<String, dynamic>> getUserProfileById(String userId) async {
    // This endpoint should be public, so no auth required.
    return await get('/users/$userId');
  }

  /// Searches for contacts based on filters.
  Future<Map<String, dynamic>> searchContacts(
      Map<String, dynamic> filters) async {
    // Construct query parameters from the filters map
    final queryParams = Uri(
        queryParameters: filters
            .map((key, value) => MapEntry(key, value?.toString() ?? ''))).query;
    final endpoint = '/contacts/search?$queryParams';
    print("Search endpoint: $endpoint"); // Log the endpoint for debugging
    return await get(endpoint);
  }

  /// Exports contacts based on filters, returns VCF string in 'data'.
  Future<Map<String, dynamic>> exportContacts(
      Map<String, dynamic> filters) async {
    // Construct query parameters from the filters map
    final queryParams = Uri(
        queryParameters: filters
            .map((key, value) => MapEntry(key, value?.toString() ?? ''))).query;
    final endpoint = '/contacts/export?$queryParams';
    print("Export endpoint: $endpoint"); // Log the endpoint for debugging
    // Use expectJson: false for VCF export
    return await get(endpoint, expectJson: false);
  }

  /// Requests an OTP for verifying contact export/download.
  /// Requires authentication token.
  Future<Map<String, dynamic>> requestContactsExportOtp() async {
    // Endpoint assumption based on variable name createContactsOTPLink
    // Needs verification with actual backend implementation.
    final endpoint = '/contacts/request-otp'; // Example endpoint
    return await post(endpoint,
        body: {}); // Assuming POST request with no specific body needed besides auth
  }

  /// Registers a new user.
  /// Does not require authentication token.
  Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> userData) async {
    // Use the base http client directly as ApiService helpers assume auth by default
    // OR modify post helper to accept requiresAuth = false
    // Using modified post helper:
    return await post('/users/register', body: userData, requiresAuth: false);
    // Original implementation using direct http:
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/users/register'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(userData),
    // );
    // return _handleResponse(response);
  }

  /// Verifies the OTP sent during registration.
  /// Does not require authentication token.
  Future<Map<String, dynamic>> verifyRegistration(
      String userId, String otp) async {
    return await post(
      '/users/verify-registration',
      body: {'userId': userId, 'otp': otp},
      requiresAuth: false,
    );
  }

  /// Resends the registration verification OTP.
  /// Does not require authentication token.
  Future<Map<String, dynamic>> resendVerificationOtp(String userId) async {
    return await post(
      '/users/resend-verification-otp',
      body: {'userId': userId},
      requiresAuth: false,
    );
  }

  /// Initiates user login with email and password.
  /// Does not require authentication token.
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    return await post(
      '/users/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );
  }

  /// Verifies a generic OTP (likely for login 2FA).
  /// Does not require authentication token initially (uses userId from login step).
  Future<Map<String, dynamic>> verifyOtp(String userId, String otp) async {
    return await post(
      '/users/verify-otp',
      body: {'userId': userId, 'otpCode': otp},
      requiresAuth:
          false, // OTP verification itself doesn't use the Bearer token
    );
  }

  // --- Subscription Service Methods ---

  /// Fetches available subscription plans.
  /// Requires auth token based on userflow.http, but may be public.
  /// Adjust 'get' call if auth is not needed.
  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    // Assuming authentication is required as per userflow example structure
    // If public, replace with direct http.get
    return await get('/subscriptions/plans');
  }

  /// Initiates the purchase of a subscription plan.
  /// Requires auth token.
  Future<Map<String, dynamic>> purchaseSubscription(String planType) async {
    // Uses the authenticated 'post' helper
    return await post('/subscriptions/purchase', body: {'planType': planType});
  }

  String generatePaymentUrl(String sessionId) {
    return '$_baseUrl/payments/page/$sessionId';
  }

  // Add other subscription-related methods like upgrade, get active subs etc. later if needed

  // --- Product Service Methods ---

  /// Creates a new product for the current user.
  /// Handles image uploads (web: base64, mobile: path).
  /// Requires authentication token.
  Future<Map<String, dynamic>> createProduct(
      Map<String, String> productData, List<String> imagePathsOrData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$_baseUrl/products');

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    productData.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add image files
    for (final imagePathOrData in imagePathsOrData) {
      if (kIsWeb) {
        // Handle base64 encoded string for web
        final bytes = base64Decode(imagePathOrData);
        final imageName =
            'image_${DateTime.now().millisecondsSinceEpoch}.jpg'; // Generate a filename
        request.files.add(http.MultipartFile.fromBytes(
          'images', // Field name for all images
          bytes,
          filename: imageName,
          contentType:
              MediaType('image', 'jpeg'), // Adjust content type if needed
        ));
      } else {
        // Handle file path for mobile
        final file = File(imagePathOrData);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'images', // Field name for all images
            file.path,
            contentType: MediaType(
                'image', file.path.split('.').last), // Infer content type
          ));
        }
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print('Exception during createProduct API call: $e');
      return {'success': false, 'error': 'Network or request error: $e'};
    }
  }

  /// Fetches products based on search criteria and filters.
  /// Query parameters are passed in the [filters] map.
  /// Requires authentication token based on userflow example.
  Future<Map<String, dynamic>> getProducts(Map<String, dynamic> filters) async {
    // Construct query parameters from the filters map
    // Ensure pagination parameters (page, limit) are included if needed by the backend
    final queryParams = Uri(
        queryParameters: filters
            .map((key, value) => MapEntry(key, value?.toString() ?? ''))).query;
    // Using /products/search as endpoint based on userflow.http
    final endpoint = '/products/search?$queryParams';
    print("GetProducts endpoint: $endpoint");
    return await get(endpoint);
  }

  /// Submits a rating for a specific product.
  /// Requires authentication token.
  Future<Map<String, dynamic>> rateProduct(String productId, double rating,
      {String? review}) async {
    final body = {
      'rating': rating,
      if (review != null && review.isNotEmpty) 'review': review,
      // Add other potential fields like 'helpful' if needed
    };
    final endpoint = '/products/$productId/ratings';
    return await post(endpoint, body: body);
  }

  /// Updates an existing product owned by the current user.
  /// Handles optional new image uploads and lists existing images to keep.
  /// Requires authentication token.
  Future<Map<String, dynamic>> updateProduct(
      String productId,
      Map<String, String> productUpdates,
      List<String> newImagePathsOrData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$_baseUrl/products/$productId');

    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields for updates
    productUpdates.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add new image files ONLY if provided (API replaces existing set if 'images' field is present)
    if (newImagePathsOrData.isNotEmpty) {
      for (final imagePathOrData in newImagePathsOrData) {
        if (kIsWeb) {
          // Handle base64 encoded string for web
          final bytes = base64Decode(imagePathOrData);
          final imageName =
              'image_${DateTime.now().millisecondsSinceEpoch}.jpg'; // Generate a filename
          request.files.add(http.MultipartFile.fromBytes(
            'images', // Field name for all images
            bytes,
            filename: imageName,
            contentType:
                MediaType('image', 'jpeg'), // Adjust content type if needed
          ));
        } else {
          // Handle file path for mobile
          final file = File(imagePathOrData);
          if (await file.exists()) {
            request.files.add(await http.MultipartFile.fromPath(
              'images', // Field name for all images
              file.path,
              contentType: MediaType(
                  'image', file.path.split('.').last), // Infer content type
            ));
          }
        }
      }
    }
    // If newImagePathsOrData is empty, the 'images' field is NOT added,
    // and the API should keep the existing images according to the spec.

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print('Exception during updateProduct API call: $e');
      return {'success': false, 'error': 'Network or request error: $e'};
    }
  }

  /// Fetches a specific product by its ID (Public).
  Future<Map<String, dynamic>> getProductById(String productId) async {
    final endpoint = '/products/$productId';
    print("GetProductById endpoint: $endpoint");
    // This endpoint is public according to API doc 4.4
    return await get(endpoint, requiresAuth: false);
  }

  /// Fetches ratings for a specific product.
  /// Supports pagination via [page] and [limit].
  Future<Map<String, dynamic>> getProductRatings(String productId,
      {int page = 1, int limit = 10}) async {
    // Construct query parameters for pagination
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final endpoint =
        '/products/$productId/ratings?${Uri(queryParameters: queryParams).query}';
    print("GetProductRatings endpoint: $endpoint");
    // Assuming ratings are public, set requiresAuth: false
    return await get(endpoint, requiresAuth: false);
  }

  // --- Transaction Service Methods ---

  /// Fetches the transaction history for the currently logged-in user.
  /// Supports pagination via query parameters in the [filters] map (e.g., {'page': '1', 'limit': '10'}).
  /// Requires authentication token.
  Future<Map<String, dynamic>> getTransactions(
      Map<String, dynamic> filters) async {
    // Construct query parameters from the filters map
    final queryParams = Uri(
        queryParameters: filters
            .map((key, value) => MapEntry(key, value?.toString() ?? ''))).query;
    final endpoint = '/transactions/history?$queryParams'; // Correct endpoint
    print("GetTransactions endpoint: $endpoint");
    return await get(endpoint);
  }

  /// Fetches transaction statistics for the currently logged-in user.
  /// Requires authentication token.
  Future<Map<String, dynamic>> getTransactionStats() async {
    final endpoint = '/transactions/stats';
    print("GetTransactionStats endpoint: $endpoint");
    return await get(endpoint); // Requires auth by default
  }

  /// Fetches a specific transaction by its transactionId.
  /// Requires authentication token.
  Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    final endpoint = '/transactions/$transactionId';
    print("GetTransactionById endpoint: $endpoint");
    return await get(endpoint); // Requires auth by default
  }

  // --- Payout/Withdrawal Service Methods ---

  /// Requests an OTP for initiating a withdrawal.
  /// Requires authentication token.
  /// Body likely includes: amount, currency, operator, password (based on retrait.dart).
  Future<Map<String, dynamic>> requestWithdrawalOtp(
      Map<String, dynamic> withdrawalData) async {
    // Endpoint from userflow2.http
    return await post('/payouts/request-otp', body: withdrawalData);
  }

  /// Confirms a withdrawal using the OTP.
  /// Requires authentication token.
  /// Body likely includes: amount, currency, operator, password, otp (based on retrait.dart).
  Future<Map<String, dynamic>> confirmWithdrawal(
      Map<String, dynamic> withdrawalData) async {
    // Endpoint from userflow2.http
    return await post('/payouts/withdraw', body: withdrawalData);
  }

  // --- User Profile Service Methods ---

  /// Uploads a new avatar for the user.
  /// Handles both web (base64 String) and mobile (file path) uploads.
  Future<Map<String, dynamic>> uploadAvatar(
      String filePathOrBase64, String fileName) async {
    final token = await _getToken();
    if (token == null) {
      print("Authentication token not found.");
      return {'error': 'Authentication required', 'statusCode': 401};
    }

    final uri = Uri.parse(
        '$_baseUrl/users/upload-pp'); // Endpoint from profile-modify.dart
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    // 'email' field might not be needed if endpoint uses token, but include if required by backend
    // request.fields['email'] = await prefs.getString('email') ?? ''; // Example if needed

    if (kIsWeb) {
      // Decode base64 string to bytes for web
      try {
        final fileBytes = base64.decode(filePathOrBase64);
        request.files.add(http.MultipartFile.fromBytes(
          'file', // Field name expected by backend
          fileBytes,
          filename: fileName, // Use the generated filename
        ));
      } catch (e) {
        print("Error decoding base64 image: $e");
        return {'error': 'Invalid image data', 'statusCode': 400};
      }
    } else {
      // Add file directly from path for mobile
      try {
        request.files.add(await http.MultipartFile.fromPath(
          'file', // Field name expected by backend
          filePathOrBase64, // This is the actual file path on mobile
          filename: fileName, // Use the actual filename from path
        ));
      } catch (e) {
        print("Error attaching file: $e");
        return {'error': 'Failed to attach file', 'statusCode': 500};
      }
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final statusCode = response.statusCode;

      if (statusCode >= 200 && statusCode < 300) {
        try {
          // Attempt to parse as JSON, but handle potential non-JSON success response
          final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
          // Assuming success response includes the new avatar URL in 'data' or similar key
          // final newAvatarUrl = jsonResponse['data']?['avatarUrl'];
          jsonResponse['statusCode'] = statusCode;
          // jsonResponse['newAvatarUrl'] = newAvatarUrl;
          return jsonResponse;
        } catch (e) {
          // Handle non-JSON success response (e.g., just a success message string)
          print("Non-JSON success response from uploadAvatar: $responseBody");
          return {
            'success': true,
            'message': responseBody,
            'statusCode': statusCode
          };
        }
      } else {
        Map<String, dynamic> errorResponse = {};
        try {
          errorResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        } catch (e) {
          errorResponse = {'error': responseBody};
        }
        print(
            'API Error uploadAvatar: $statusCode - ${errorResponse['message'] ?? errorResponse['error'] ?? responseBody}');
        errorResponse['statusCode'] = statusCode;
        return errorResponse;
      }
    } catch (e) {
      print("Exception during avatar upload: $e");
      return {'error': 'Network error during upload', 'statusCode': 500};
    }
  }

  /// Requests an OTP to be sent for verifying an email change.
  /// Requires authentication token.
  /// Takes the user ID (or potentially relies on token). Adjust body if needed.
  Future<Map<String, dynamic>> requestEmailChangeOtp() async {
    // Note: Original code used userId in body. The /auth endpoint might not need it
    // if it uses the token. Sending empty body for now, adjust if backend requires userId.
    // final prefs = await SharedPreferences.getInstance();
    // final userId = prefs.getString('id');
    // if (userId == null) return {'error': 'User ID not found', 'statusCode': 400};
    // final body = {'userId': userId};

    // Endpoint from profile-modify.dart (createOTPLink)
    // Assuming createOTPLink resolves to something like /auth/request-email-otp
    return await post('/auth/create-otp-link', body: {}); // Sending empty body
  }

  /// Verifies the OTP for an email address change.
  /// Requires authentication token.
  Future<Map<String, dynamic>> verifyEmailChange(
      String newEmail, String otp) async {
    // Endpoint assumption: /auth/verify-email-change or similar
    // Needs verification with actual backend implementation.
    // Assumes backend uses token to identify user, only needs new email and OTP.
    final endpoint = '/auth/verify-email-change';
    return await post(
      endpoint,
      body: {
        'email': newEmail, // The new email address being verified
        'otpCode': otp,
        // 'id': userId, // Add if backend requires user ID explicitly
      },
      // This action requires the user to be logged in, so requiresAuth is true.
      requiresAuth: true,
    );
  }

  // --- Utility Service Methods ---

  /// Converts an amount from one currency to another.
  /// Authentication requirement depends on backend implementation.
  Future<Map<String, dynamic>> convertCurrency(
      String amount, String fromCurrency, String toCurrency) async {
    final queryParams = {
      'amount': amount,
      'from': fromCurrency,
      'to': toCurrency,
    };
    // Assuming endpoint /utils/convert-currency - Check config/userflow if different
    final endpoint =
        '/utils/convert-currency?${Uri(queryParameters: queryParams).query}';
    print("ConvertCurrency endpoint: $endpoint");
    // Assuming this might be public, setting requiresAuth: false
    return await get(endpoint, requiresAuth: false);
  }

  // --- Affiliation Service Methods ---

  /// Fetches affiliation information based on a code.
  /// Does not require authentication token.
  Future<Map<String, dynamic>> getAffiliationInfo(String code) async {
    // Endpoint from inscription.dart logic
    final endpoint =
        '/users/get-affiliation?referralCode=$code'; // Assuming /utils path, adjust if needed
    print("GetAffiliationInfo endpoint: $endpoint");
    return await get(endpoint, requiresAuth: false);
  }

  /// Logs out the current user.
  /// Requires authentication token.
  Future<Map<String, dynamic>> logoutUser() async {
    // Endpoint based on API Documentation: POST /users/logout
    // Assumes backend invalidates the token provided in the Authorization header.
    // No request body is typically needed if using token auth.
    return await post('/users/logout',
        body: {}); // Sending empty body, requires auth
  }

  // --- Password Management Methods ---

  /// Requests a password reset OTP to be sent to the user's email.
  /// Does not require authentication token.
  Future<Map<String, dynamic>> requestPasswordResetOtp(String email) async {
    // Endpoint assumption: /users/request-password-reset or similar
    // Needs verification with actual backend implementation.
    final endpoint = '/users/request-password-reset';
    return await post(endpoint, body: {'email': email}, requiresAuth: false);
  }

  /// Resets the user's password using an OTP.
  /// Does not require authentication token.
  Future<Map<String, dynamic>> resetPassword(
      String emailOrUserId, String otp, String newPassword) async {
    // Endpoint assumption: /users/reset-password or similar
    // Backend might require email or userId.
    // Needs verification with actual backend implementation.
    final endpoint = '/users/reset-password';
    return await post(
      endpoint,
      body: {
        'email': emailOrUserId, // Or potentially 'userId'
        'otpCode': otp,
        'newPassword': newPassword,
      },
      requiresAuth: false,
    );
  }

  // We will add specific API call methods here later, e.g.:
  // Future<Map<String, dynamic>> loginUser(String email, String password) async { ... }
  // Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async { ... }
  // Future<List<Map<String, dynamic>>> getFilteredContacts(Map<String, dynamic> filters) async { ... }

  // --- User Service Methods (Specific Product Fetch) ---

  /// Fetches a specific product listed by a seller, potentially requires current user context.
  /// Corresponds to the logic previously in utils.getProductOnline
  /// Endpoint might be /users/get-product based on original implementation context.
  Future<Map<String, dynamic>> getUserSpecificProduct(
      String sellerEmail, String productId) async {
    // Construct query parameters based on the original getProductOnline logic
    // Assuming the backend uses the token for the logged-in user's email if needed.
    final queryParams = {
      // 'email': loggedInUserEmail, // Potentially add if backend requires it alongside token
      'seller': sellerEmail,
      'id': productId,
    };
    // The endpoint needs clarification. Assuming it's under /users/
    // Based on variable name 'getProduct' likely mapping to config
    // Let's assume it maps to /users/get-product for now.
    final endpoint =
        '/users/get-product?${Uri(queryParameters: queryParams).query}';
    print("GetUserSpecificProduct endpoint: $endpoint");
    return await get(endpoint); // Requires auth by default
  }

  // --- Referral/Affiliation Service Methods ---

  /// Fetches the referral statistics for the currently logged-in user.
  /// Requires authentication token.
  Future<Map<String, dynamic>> getReferralStats() async {
    // Endpoint from API docs: /users/get-referals
    final endpoint = '/users/get-referals';
    return await get(endpoint); // Requires auth
  }

  /// Fetches the list of users referred by the currently logged-in user.
  /// Supports pagination via filters map (e.g., {'page': '1', 'limit': '20'}).
  /// Requires authentication token.
  Future<Map<String, dynamic>> getReferredUsers(
      Map<String, dynamic> filters) async {
    // Endpoint from API docs: /users/get-refered-users
    final queryParams = Uri(
        queryParameters: filters
            .map((key, value) => MapEntry(key, value?.toString() ?? ''))).query;
    final endpoint = '/users/get-refered-users?$queryParams';
    print("GetReferredUsers endpoint: $endpoint");
    return await get(endpoint); // Requires auth
  }

  // --- NEW: Get Current User's Affiliator (Sponsor) ---
  Future<Map<String, dynamic>> getMyAffiliator() async {
    // Use the get helper which handles token, base URL, and basic response processing
    // The get helper now returns Map<String, dynamic> directly after handling response
    return await get('/users/affiliator');
  }

  // --- NEW: Get Application Settings ---
  Future<Map<String, dynamic>> getAppSettings() async {
    // Settings are likely public, so no auth needed.
    return await get('/settings', requiresAuth: false);
  }

  /// Fetches the products owned by the currently logged-in user.
  /// Supports pagination via query parameters (e.g., page, limit).
  /// Requires authentication token.
  Future<Map<String, dynamic>> getUserProducts(
      {int page = 1, int limit = 10}) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final endpoint =
        '/products/user?${Uri(queryParameters: queryParams).query}';
    print("GetUserProducts endpoint: $endpoint");
    return await get(endpoint); // Requires auth by default
  }

  /// Deletes a specific product by its ID.
  /// Requires authentication token.
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    final endpoint = '/products/$productId';
    return await delete(
        endpoint); // Assuming a delete helper exists or will be added
  }
}
