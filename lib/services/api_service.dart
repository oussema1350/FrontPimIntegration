import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/LoginResponse.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String BASE_URL = "http://192.168.1.18:3000/"; // Use your local network IP address

  ApiService() {
    _dio.options.baseUrl = BASE_URL;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  // Sign up method
  Future<SignUpResponse?> signUp(String name, String email, String password, [MultipartFile? profilePicture]) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        if (profilePicture != null) 'profilePicture': profilePicture,
      });

      print('Sending signup request with data: ${formData.fields}');

      final response = await _dio.post(
        'auth/signup',
        data: formData,
      );

      print('Signup response status: ${response.statusCode}');
      print('Signup response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SignUpResponse.fromJson(response.data);
      } else {
        print('Failed to sign up: ${response.statusCode} ${response.statusMessage}');
        throw Exception('Failed to sign up');
      }
    } catch (e) {
      print('Error during signup: $e');
      return null;
    }
  }

  // Login method
  Future<LoginResponse?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Login response data: ${response.data}');
        return LoginResponse.fromJson(response.data);
      } else {
        print('Failed to login: ${response.statusCode} ${response.statusMessage}');
        throw Exception('Failed to login');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Forgot password method
  Future<void> forgotPassword(String email) async {
    try {
      print('Sending forgot password request for email: $email');
      final response = await _dio.post(
        'auth/forgot-password',
        data: {
          'email': email,
        },
      );

      print('Forgot password response status: ${response.statusCode}');
      print('Forgot password response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Forgot password email sent successfully.');
      } else {
        print('Failed to send forgot password email: ${response.statusCode} ${response.statusMessage}');
        throw Exception('Failed to send forgot password email');
      }
    } catch (e) {
      print('Error during forgot password request: $e');
      throw Exception('Error during forgot password request');
    }
  }
}