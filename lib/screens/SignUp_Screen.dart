import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/screens/password_input.dart';
import 'package:flutter_application_1/screens/text_input_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart'; // Import the dio package for MultipartFile

const kBodyText = TextStyle(
  fontSize: 16,
  color: Colors.white,
  height: 1.5,
);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  File? _profilePicture;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profilePicture = File(pickedFile.path);
        });
        print('Image selected: ${pickedFile.path}');
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final signUpResponse = await apiService.signUp(
        _firstNameController.text,
        _emailController.text,
        _passwordController.text,
        _profilePicture != null ? MultipartFile.fromFileSync(_profilePicture!.path) : null,
      );

      if (signUpResponse != null) {
        _isSuccess = true;
        _showSnackBar('Sign Up Successful!', Colors.green);
      } else {
        _isSuccess = false;
        _showSnackBar('Sign Up failed. Please try again.', Colors.red);
      }
    } catch (e) {
      _isSuccess = false;
      _showSnackBar('An error occurred: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Image de fond
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('asset/images/test.jpg'), // Vérifie le chemin de ton image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Effet de flou pour améliorer la lisibilité
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            // Contenu principal
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  // Logo avec fond transparent
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: _profilePicture != null ? FileImage(_profilePicture!) : null,
                        child: _profilePicture == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Titre principal
                  const Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color.fromARGB(255, 224, 224, 224),
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Formulaire de création de compte
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 20),
                        TextInputField(
                          controller: _firstNameController,
                          icon: FontAwesomeIcons.user,
                          hint: 'Prénom',
                          inputType: TextInputType.name,
                          inputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        TextInputField(
                          controller: _emailController,
                          icon: FontAwesomeIcons.envelope,
                          hint: 'Email',
                          inputType: TextInputType.emailAddress,
                          inputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        PasswordInput(
                          controller: _passwordController,
                          icon: FontAwesomeIcons.lock,
                          hint: 'Password',
                          inputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 30),
                        // Bouton de création de compte avec animation
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: _isLoading ? 70 : 150,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _isSuccess ? Colors.green : Colors.blue,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : TextButton(
                                    onPressed: _submitForm,
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Retour à la page de connexion avec Login en bleu
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1, color: Colors.transparent)),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: kBodyText,
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login',
                              style: kBodyText.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}