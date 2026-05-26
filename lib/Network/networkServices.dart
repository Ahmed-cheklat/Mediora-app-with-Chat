// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
  });
}

class Result {
  final bool success;
  final String message;
  final String? token;

  Result({required this.success, required this.message, this.token});
}

class AuthService {
  String? _extractCookieValue(String setCookieHeader, String cookieName) {
    final parts = setCookieHeader.split(',');
    for (final part in parts) {
      final cookies = part.split(';');
      for (final cookie in cookies) {
        final trimmed = cookie.trim();
        if (trimmed.startsWith('$cookieName=')) {
          return trimmed.substring('$cookieName='.length);
        }
      }
    }
    return null;
  }

  // Define your base URL once so you don't have to repeat it
  static const String _baseUrl = 'https://mediora-back-2.onrender.com';

  // -------------------------
  // SIGN IN
  // -------------------------
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('FULL SIGNIN RESPONSE: $data');
        final prefs = await SharedPreferences.getInstance();

        if (data['token'] != null) {
          await prefs.setString('access_token', data['token']);
        }

        final String? refreshTokenHeader = response.headers['refresh_token'];

        if (refreshTokenHeader != null) {
          // If the token comes with "Bearer " prefix in the header, you might want to remove it:
          // final cleanToken = refreshTokenHeader.replaceFirst('Bearer ', '');

          await prefs.setString('refresh_token', refreshTokenHeader);
          print(
            'Refresh Token extracted from header and saved: $refreshTokenHeader',
          );
          print('Header refresh token: ${response.headers['refresh_token']}');
          print('Cookie header: ${response.headers['set-cookie']}');
          // In signIn, after saving tokens:
          final String? deviceIdCookie = _extractCookieValue(
            response.headers['set-cookie'] ?? '',
            'device_id',
          );
          if (deviceIdCookie != null) {
            await prefs.setString('device_id', deviceIdCookie);
            print('Device ID from backend saved: $deviceIdCookie');
          }
        } else {
          // Printing all header keys to help you debug what the actual key name is
          print(
            'No refresh token found. Available header keys: ${response.headers.keys}',
          );
        }

        print('Token: ${data['token']}');
        return AuthResult(success: true, message: "Welcome Back");
      }
      if (response.statusCode == 401) {
        return AuthResult(success: false, message: "Wrong email or password");
      }
      print('Sign In Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Sign In: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  // -------------------------
  // -------------------------
  // CHECK EMAIL (Sign Up Step 1)
  // -------------------------
  Future<AuthResult> checkEmail({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/check-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: "Check your email for OTP code!",
        );
      }
      if (response.statusCode == 400 || response.statusCode == 409) {
        return AuthResult(success: false, message: "Email already in use");
      }
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      print('Check Email Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Check Email: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  // -------------------------
  // VERIFY EMAIL / Request OTP (Sign Up Step 2)
  // -------------------------
  Future<AuthResult> requestOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return AuthResult(success: true, message: "OTP sent to your email");
      }
      if (response.statusCode == 404) {
        return AuthResult(success: false, message: "Email not found");
      }
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      print('Request OTP Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Request OTP: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  //--------------------------
  Future<AuthResult> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/verify-email?code=$otp&email=$email'),
        headers: {'Content-Type': 'application/json'},
      );
      print('verifyEmail status: ${response.statusCode}');
      print('verifyEmail full response: ${response.body}');
      if (response.statusCode == 200) {
        print('verifyEmail full response: ${response.body}');
        final data = jsonDecode(response.body);
        return AuthResult(
          success: true,
          message: "Email verified successfully",
          token: data['token'],
        );
      }
      if (response.statusCode == 400) {
        print(response.statusCode);
        return AuthResult(success: false, message: "Invalid OTP code");
      }
      if (response.statusCode == 401) {
        return AuthResult(
          success: false,
          message: "Invalid or expired OTP code",
        );
      }
      if (response.statusCode == 404) {
        return AuthResult(success: false, message: "Email not found");
      }
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      print('Verify OTP Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Verify OTP: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }
  //--------------------------

  Future<AuthResult> checkUsername({required String username}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/check-username'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) {
          return AuthResult(success: false, message: "Username already taken");
        }
        return AuthResult(success: true, message: "");
      }
      if (response.statusCode == 400 || response.statusCode == 409) {
        return AuthResult(success: false, message: "Username already taken");
      }
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      print('Check Username Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Check Username: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  //---------------------------
  Future<AuthResult> SignUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String creationToken,
  }) async {
    print('Creation token being sent: $creationToken');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'creation-token': creationToken,
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          'email': email,
          'password': password,
          'role': 'user',
        }),
      );

      print("Stuts code of sign up : ${response.statusCode}");
      print("body of sign up : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        if (data['token'] != null) {
          // or 'access_token' depending on your API
          await prefs.setString('access_token', data['token']);
          print('Access token saved: ${data['token']}');
        }
        final String? refreshTokenHeader = response.headers['refresh_token'];
        if (refreshTokenHeader != null) {
          await prefs.setString('refresh_token', refreshTokenHeader);
          print('refresh token from sign up : $refreshTokenHeader');
        }
        final String? deviceIdCookie = _extractCookieValue(
          response.headers['set-cookie'] ?? '',
          'device_id',
        );
        if (deviceIdCookie != null) {
          await prefs.setString('device_id', deviceIdCookie);
        }

        if (data['exists'] == true) {
          return AuthResult(success: false, message: "Successfully siging up");
        }
        return AuthResult(success: true, message: "");
      }

      if (response.statusCode != 200 && response.statusCode != 500) {
        print('Error : ----------------------------: ${response.statusCode}');
        return AuthResult(success: false, message: "Something went wrong");
      }
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      print('Error : ----------------------------: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during validation: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  //--------------------------
  Future<AuthResult> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      //final String deviceId = await DeviceManager.getDeviceId();
      final String? refreshToken = prefs.getString('refresh_token');
      final String? deviceId = prefs.getString('device_id');
      print('SignOut - deviceId: $deviceId');
      print('SignOut - refreshToken: $refreshToken');
      final response = await http.delete(
        Uri.parse('$_baseUrl/auth/signout'),
        headers: {
          'Content-Type': 'application/json',
          'x-device-id': deviceId!,
          if (refreshToken != null) 'Authorization': 'Bearer $refreshToken',
        },
      );
      print('SignOut status: ${response.statusCode}');
      print('SignOut body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');

        return AuthResult(success: true, message: "Signed out successfully");
      }
      if (response.statusCode == 401) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        return AuthResult(success: false, message: "Already signed out");
      }
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      print('SignOut Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Sign Out: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  // // -------------------------
  // -------------------------
  // GET REFRESH TOKEN (Call this after signup)
  // -------------------------
  Future<AuthResult> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');
      final String? refreshToken = prefs.getString('refresh_token');
      final String? deviceId = prefs.getString('device_id');

      if (accessToken == null || refreshToken == null) {
        return AuthResult(
          success: false,
          message: "Session expired, please sign in again.",
        );
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Cookie':
              'access_token=$accessToken; refresh_token=$refreshToken;device_id=$deviceId',
          //'x-device-id': deviceId,
          //'Cookie': 'refresh_token=$refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final String? newAccessToken = response.headers['access_token'];
        final String? newRefreshToken = response.headers['refresh_token'];

        if (newAccessToken != null) {
          await prefs.setString('access_token', newAccessToken);
        }

        if (newRefreshToken != null) {
          await prefs.setString('refresh_token', newRefreshToken);
        }

        return AuthResult(
          success: true,
          message: "Token refreshed successfully",
        );
      }

      if (response.statusCode == 401) {
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        print('Refresh token failed with 401: ${response.body}');
        return AuthResult(
          success: false,
          message: "Session expired, please sign in again.",
        );
      }

      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Refresh: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  //--------------------------
  Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: "Reset code sent to your email",
        );
      }
      if (response.statusCode == 404 || response.statusCode == 401) {
        return AuthResult(success: false, message: "Email not found");
      }
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      print('ForgotPassword Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Forgot Password: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }
  //--------------------------

  Future<AuthResult> resetPassword({required String code}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        print('verifyEmail full response: ${response.body}');
        final data = jsonDecode(response.body);
        return AuthResult(
          success: true,
          message: "Code verified successfully",
          token: data["token"],
        );
      }
      if (response.statusCode == 400) {
        return AuthResult(success: false, message: "Invalid or expired code");
      }
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      print('ResetPassword Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Reset Password: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  //-------------------------
  Future<AuthResult> updatePasswordWithToken({
    required String password,
    required String resetToken,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/auth/update-password-with-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password, 'reset_token': resetToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        if (data['token'] != null) {
          await prefs.setString('access_token', data['token']);
        }
        return AuthResult(
          success: true,
          message: "Password updated successfully",
        );
      }
      if (response.statusCode == 400) {
        return AuthResult(success: false, message: "Invalid or expired token");
      }
      if (response.statusCode == 401) {
        return AuthResult(success: false, message: "Unauthorized");
      }
      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      print('UpdatePasswordWithToken Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Update Password: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  //-------------------------
  Future<AuthResult> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');
      final String? deviceId = prefs.getString('device_id');
      // 1. Check if the user is actually logged in
      if (accessToken == null) {
        return AuthResult(
          success: false,
          message: "Session expired, please sign in again.",
        );
      }

      // 2. Make the request to the backend
      // Note: Verify with your backend developer if this should be a PATCH or POST request,
      // and confirm the exact endpoint URL ('/auth/change-password').
      final response = await http.patch(
        Uri.parse('$_baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          if (deviceId != null) 'Cookie': 'device_id=$deviceId',
          //'x-device-id': deviceId!,
        },
        body: jsonEncode({
          'password': newPassword,
          'current_password': currentPassword,
        }),
      );

      // 3. Handle the responses
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          print('---------------------------- $data');
          if (data['token'] != null) {
            await prefs.setString('access_token', data['token']);
          }
        }

        final String? newAccessToken = response.headers['access_token'];
        final String? newRefreshToken = response.headers['refresh_token'];

        if (newAccessToken != null) {
          await prefs.setString('access_token', newAccessToken);
        }
        if (newRefreshToken != null) {
          await prefs.setString('refresh_token', newRefreshToken);
          print(
            'New refresh token saved after password change: $newRefreshToken',
          );
        }

        return AuthResult(
          success: true,
          message: "Password changed successfully",
        );
      }

      if (response.statusCode == 400 || response.statusCode == 401) {
        return AuthResult(
          success: false,
          message: "Incorrect current password",
        );
      }

      if (response.statusCode == 500) {
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      // Catch-all for unexpected status codes
      print('ChangePassword Failed: ${response.statusCode}');
      print('Response body: ${response.body}');
      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Network Error during Change Password: $e');
      return AuthResult(success: false, message: "No internet connection");
    }
  }

  //-------------------------

  //for app google sign in
  Future<AuthResult> googleSignIn() async {
    try {
      final result = await GoogleSignIn.instance.authenticate();
      final String? idToken = result.authentication.idToken;
      print("id token : $idToken");

      if (idToken == null) {
        return AuthResult(success: false, message: "Failed to get ID token");
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google/auth?id_token=$idToken'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Google SignIn response status: ${response.statusCode}');
        print('Google SignIn response body: ${response.body}');
        print('Google SignIn response headers: ${response.headers}');

        const secureStorage = FlutterSecureStorage();

        final String? accessToken = response.headers['access_token'];
        final String? refreshToken = response.headers['refresh_token'];
        final String? deviceIdCookie = _extractCookieValue(
          response.headers['set-cookie'] ?? '',
          'device_id',
        );

        if (accessToken != null) {
          await secureStorage.write(key: 'access_token', value: accessToken);
        }
        if (refreshToken != null) {
          await secureStorage.write(key: 'refresh_token', value: refreshToken);
        }
        if (deviceIdCookie != null) {
          await secureStorage.write(key: 'device_id', value: deviceIdCookie);
        }

        return AuthResult(success: true, message: "Welcome!");
      }

      if (response.statusCode == 401) {
        print('Google SignIn unexpected status: ${response.statusCode}');
        print('Google SignIn response body: ${response.body}');
        return AuthResult(
          success: false,
          message: "Unauthorized Google account",
        );
      }
      if (response.statusCode == 500) {
        print('Google SignIn unexpected status: ${response.statusCode}');
        print('Google SignIn response body: ${response.body}');
        return AuthResult(
          success: false,
          message: "Server error, try again later",
        );
      }

      return AuthResult(success: false, message: "Something went wrong");
    } catch (e) {
      print('Google SignIn error: $e');
      return AuthResult(success: false, message: "Google sign-in failed");
    }
  }
}
//---------------------------

class DeviceManager {
  static const String _deviceIdKey = 'device_id';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      // Generate a new unique device ID
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  static Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }
}

//---------------------------
class AppointementService {
  static const String _baseUrl = 'https://mediora-back-2.onrender.com';

  Future<List<dynamic>> fetchDoctors({
    required String specialty,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/doctors?speciality=$specialty&skip=$skip&limit=$limit',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      print('fetchDoctors status: ${response.statusCode}');
      print('fetchDoctors body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data["data"];
        return list is List ? list : [];
      }
      return [];
    } catch (e) {
      print('Network Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDoctor({required String id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/doctors/info/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print(
          'data of the doctor :-------------------------------------------------------- $data',
        );
        return data['data'] as Map<String, dynamic>;
      }

      if (response.statusCode == 401) {
        final refreshed = await AuthService().getRefreshToken();
        if (refreshed.success) {
          return await getDoctor(id: id); // retry with new token
        }
        return null;
      }

      return null;
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

  //------------------------
  //function to get all services with their price and description
  Future<List<dynamic>?> getServices({required String id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/doctors/$id/services'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('services : $data');
        return List<dynamic>.from(data['data']);
      } else if (response.statusCode == 401) {
        final refreshed = await AuthService().getRefreshToken();
        if (refreshed.success) {
          return await getServices(id: id);
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }

  //check if the doctor is free :
  Future<Result> doctorIsFree({
    required String serviceId,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final uri = Uri.parse(
        '$_baseUrl/doctors/is-free?service_id=$serviceId&date=$date',
      );

      final response = await http.get(
        Uri.parse('$_baseUrl/doctors/is-free?service_id=$serviceId&date=$date'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Code of doctorIsFree : $data');

        if (data is Map && data['message'] != null) {
          final message = data['message'].toString().trim().toLowerCase();
          if (message.contains('free')) {
            return Result(success: true, message: 'Can appoint');
          }
          return Result(success: false, message: 'Cannot appoint');
        }

        return Result(success: false, message: 'Unexpected response format');
      }
      if (response.statusCode == 401) {
        final refreshed = await AuthService().getRefreshToken();
        if (refreshed.success) {
          return await doctorIsFree(serviceId: serviceId, date: date);
        }
      }
      print('error: ${response.statusCode} - ${response.body}');
      return Result(success: false, message: 'Something went wrong');
    } catch (e) {
      print(e);
      return Result(success: false, message: 'No internet connection');
    }
  }

  //get doctor time off
  Future<Result> doctorTimeOffs({required String id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/doctors/timeoffs'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Time of rest of the doctor : $data');
        return Result(success: true, message: 'doctor is free gotten');
      }
      if (response.statusCode == 401) {
        final refreshed = await AuthService().getRefreshToken();
        if (refreshed.success) {
          return await doctorTimeOffs(id: id);
        }
      }
      print('error: ${response.statusCode} - ${response.body}');
      return Result(success: false, message: 'Something went wrong');
    } catch (e) {
      print(e);
      return Result(success: false, message: 'No internet connection');
    }
  }

  //Make an appointment
  Future<Result> makeAppointement({
    required String serviceId,
    required String date,
    required String id,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('$_baseUrl/appointments/'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'service_id': serviceId, 'date': date}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final url = data['data']?['url']?.toString();
        print('Payment URL: $url');
        return Result(
          success: true,
          message: url ?? '',
        ); // url stored in message field
      }
      if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final detail = data['detail']?.toString() ?? 'Something went wrong';
        print('Error 400: $detail');
        return Result(success: false, message: detail);
      }
      if (response.statusCode == 401) {
        final refreshed = await AuthService().getRefreshToken();
        if (refreshed.success) {
          return await makeAppointement(
            serviceId: serviceId,
            date: date,
            id: id,
          );
        }
      }
      print('Error: ${response.statusCode} - ${response.body}');
      return Result(success: false, message: 'Something went wrong');
    } catch (e) {
      print(e);
      return Result(success: false, message: 'Something went wrong');
    }
  }

  //Days of work
  Future<List<dynamic>> daysAndTimeOfWork({required String id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.get(
        // GET not POST
        Uri.parse('$_baseUrl/doctors/$id/schedule'), // confirm URL with backend
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Schedule data: $data");
        final list = data['data'];
        return list is List ? list : [];
      }
      if (response.statusCode == 401) {
        final refreshed = await AuthService().getRefreshToken();
        if (refreshed.success) return await daysAndTimeOfWork(id: id);
      }
      return [];
    } catch (e) {
      print('daysAndTimeOfWork error: $e');
      return [];
    }
  }

  //Get user's appointments
  Future<List<dynamic>> getUserAppointment({
    required int page,
    required int limit,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/appointments?status=scheduled&page=$page&limit=$limit',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data["data"];
        return list is List ? list : [];
      }
      if (response.statusCode == 401) {
        final result = AuthService().getRefreshToken();
      }
      return [];
    } catch (e) {
      print('Network Error: $e');
      return [];
    }
  }

  // Cancel an appointment
  Future<Result> cancelAppointement({required String id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.delete(
        Uri.parse('$_baseUrl/appointments/$id/cancel'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return Result(
          success: true,
          message: "appointment canceled successfully",
        );
      } else {
        return Result(success: false, message: "Something went wrong");
      }
    } catch (e) {
      print('Something went wrong $e');
      return Result(success: false, message: "something went wrong");
    }
  }
}
//---------------------------

class UserServices {
  static const String _baseUrl = 'https://mediora-back-2.onrender.com';

  // Returns a Map containing the user data from the 'data' field of the response
  Future<Map<String, dynamic>> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        Map<String, dynamic> userData;
        // Assuming the response structure contains a 'data' field with user info
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is Map) {
          userData = jsonResponse['data'] as Map<String, dynamic>;
        } else {
          // If no 'data' field, return the whole response (fallback)
          userData = jsonResponse;
        }
        final secureStorage = const FlutterSecureStorage();
        final picture = userData['picture']?.toString() ?? '';
        await secureStorage.write(key: 'picture', value: picture);
        print('Picture saved from getUser: $picture');

        return userData;
      } else {
        // Handle non-200 responses
        throw Exception(
          'Failed to load user: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      // Re-throw or handle as needed
      throw Exception('Error fetching user: $e');
    }
  }
  //Modify user information

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? phone,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      // Only include fields that were actually provided
      final Map<String, dynamic> body = {};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (username != null) body['username'] = username;
      if (phone != null) body['phone'] = phone;
      if (gender != null) body['gender'] = gender.toLowerCase();
      if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;

      final response = await http.patch(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        final refreshed = await AuthService().getRefreshToken();
        if (refreshed.success) {
          return await updateProfile(
            firstName: firstName,
            lastName: lastName,
            username: username,
            phone: phone,
            gender: gender,
            dateOfBirth: dateOfBirth,
          );
        }
        return false;
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  //Upload profile picture
  Future<String?> uploadProfilePicture(File image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final cloudinary = CloudinaryPublic('dc7qsxfpb', 'tcs7z4na');
      final cloudinaryResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final cloudinaryUrl =
          cloudinaryResponse.secureUrl; // ← save before backend call

      await http.post(
        Uri.parse('$_baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'public_id': cloudinaryResponse.publicId,
          'format': 'jpg',
          'resource_type': 'image',
          'secure_url': cloudinaryUrl,
        }),
      );

      return cloudinaryUrl; // ← always return Cloudinary URL regardless of backend
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  //add phone numbe
  Future<bool> addPhoneNumber(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.patch(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({"phone": phoneNumber}), // was missing { }
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Phone added successfully ');
        return true;
      } else {
        print('Something went wrong ${response.body}');
        return false;
      }
    } catch (e) {
      print("Something went wrong $e");
      return false;
    }
  }
}

class ChatServices {
  static const String _baseUrl = 'https://mediora-back-2.onrender.com';

  //Get contact with latest messages
  Future<List<dynamic>> getLatestContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/chat/contacts/latest'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      print('getLatestContacts status: ${response.statusCode}');
      print('getLatestContacts body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("data of conevrsation : $data");
        return data is List ? data : [];
      }
      if (response.statusCode == 401) {
        final refreshed = await AuthService().getRefreshToken();
        if (refreshed.success) return await getLatestContacts();
      }
      return [];
    } catch (e) {
      print('getLatestContacts error: $e');
      return [];
    }
  }

  //get messages for a specific conversation
  Future<List<dynamic>> getConversationMessages(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/chat/conversations/$id/messages'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      print('getConversationMessages status: ${response.statusCode}');
      print('getConversationMessages body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('data of conversation: $data');
        return data is List ? data : [];
      }
      if (response.statusCode == 401) {
        final refreshed = await AuthService().getRefreshToken();
        if (refreshed.success) return await getConversationMessages(id);
      }
      return [];
    } catch (e) {
      print('getConversationMessages error: $e');
      return [];
    }
  }

  // ── WebSocket ─────────────────────────────────────────────────────────────

  static const String _wsBaseUrl = 'wss://mediora-back-2.onrender.com';
  WebSocketChannel? _channel;

  // Connect to WebSocket
  Future<WebSocketChannel?> connectToChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        print('WebSocket: no access token');
        return null;
      }

      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsBaseUrl/chat/ws?token=$accessToken'),
      );

      print('WebSocket: connected');
      return _channel;
    } catch (e) {
      print('WebSocket connect error: $e');
      return null;
    }
  }

  // Disconnect from WebSocket
  void disconnectChat() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
    print('WebSocket: disconnected');
  }

  // Send a text message
  void sendMessage({required String conversationId, required String message}) {
    if (_channel == null) {
      print('WebSocket: not connected');
      return;
    }
    final payload = jsonEncode({
      'type': 'message',
      'conversation_id': conversationId,
      'message': message,
    });
    _channel!.sink.add(payload);
    print('WebSocket sendMessage: $payload');
  }

  // Send typing indicator
  void sendTyping({required String conversationId}) {
    if (_channel == null) return;
    final payload = jsonEncode({
      'type': 'typing',
      'conversation_id': conversationId,
    });
    _channel!.sink.add(payload);
  }

  // Send read receipt
  void sendReadReceipt({
    required String conversationId,
    required String messageId,
  }) {
    if (_channel == null) return;
    final payload = jsonEncode({
      'type': 'read',
      'conversation_id': conversationId,
      'message': messageId,
    });
    _channel!.sink.add(payload);
  }

  // Stream of incoming messages
  Stream? get messageStream => _channel?.stream;
}
