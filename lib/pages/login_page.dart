// // lib/pages/login_page.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';
// import 'register_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _signIn() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       try {
//         final authService = context.read<AuthService>();
//         final error = await authService.signIn(
//           _emailController.text.trim(),
//           _passwordController.text.trim(),
//         );

//         if (error != null) {
//           setState(() {
//             _errorMessage = error;
//           });
//         }
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _registerWithGoogle() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser!.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential =
//           await FirebaseAuth.instance.signInWithCredential(credential);

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set({
//         'name': userCredential.user!.displayName ?? 'Google User',
//         'email': userCredential.user!.email,
//         'created_at': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       await FirebaseFirestore.instance
//           .collection('userToMatches')
//           .doc(userCredential.user!.uid)
//           .set({
//         'matchIds': [],
//       }, SetOptions(merge: true));

//       Navigator.pop(context);
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Google Sign-In failed: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     'Game-Cast',
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 48),
//                   TextFormField(
//                     controller: _emailController,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email),
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email';
//                       }
//                       if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                           .hasMatch(value)) {
//                         return 'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _passwordController,
//                     decoration: const InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: Icon(Icons.lock),
//                       border: OutlineInputBorder(),
//                     ),
//                     obscureText: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       if (value.length < 6) {
//                         return 'Password must be at least 6 characters';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 24),
//                   if (_errorMessage != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 16),
//                       child: Text(
//                         _errorMessage!,
//                         style: const TextStyle(color: Colors.red),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _signIn,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text('Sign In'),
//                   ),
//                   const SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const RegisterPage()),
//                     ),
//                     child: const Text('Don\'t have an account? Register'),
//                   ),
//                   GestureDetector(
//                     onTap: _isLoading ? null : _registerWithGoogle,
//                     child: Container(
//                       padding: const EdgeInsets.all(10.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white, // Background color
//                         borderRadius: BorderRadius.circular(
//                             30.0), // Fully rounded borders
//                         boxShadow: [
//                           BoxShadow(
//                             color:
//                                 Colors.black.withOpacity(0.1), // Shadow color
//                             spreadRadius: 1, // Spread radius
//                             blurRadius: 6, // Blur radius
//                             offset: const Offset(0, 1), // Shadow offset
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.network(
//                             "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Google_2015_logo.svg/500px-Google_2015_logo.svg.png",
//                             height: 24,
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           const Text("Sign In"),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/custom_captcha_service.dart'; // Add this import
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController(); // Add this
  bool _isLoading = false;
  String? _errorMessage;
  late String _captchaText; // Add this

  @override
  void initState() {
    super.initState();
    _refreshCaptcha();
  }

  void _refreshCaptcha() {
    setState(() {
      _captchaText = CustomCaptchaService.generateRandomString(6);
      _captchaController.clear();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _captchaController.dispose(); // Add this
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Add captcha validation
      print(_captchaText);
      print(_captchaController.text.trim());
      if (_captchaController.text.trim() != _captchaText) {
        setState(() {
          _errorMessage = 'Invalid captcha. Please try again.';
          _refreshCaptcha();
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = context.read<AuthService>();
        final error = await authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (error != null) {
          setState(() {
            _errorMessage = error;
            _refreshCaptcha(); // Refresh captcha on error
          });
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _registerWithGoogle() async {
    // Add captcha validation
    print(_captchaText);
    print(_captchaController.text.trim());
    if (_captchaController.text.trim() != _captchaText) {
      setState(() {
        _errorMessage = 'Invalid captcha. Please try again.';
        _refreshCaptcha();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': userCredential.user!.displayName ?? 'Google User',
        'email': userCredential.user!.email,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('userToMatches')
          .doc(userCredential.user!.uid)
          .set({
        'matchIds': [],
      }, SetOptions(merge: true));

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-In failed: ${e.toString()}';
        _refreshCaptcha(); // Refresh captcha on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Game-Cast',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Add Captcha Widget
                  Row(
                    children: [
                      Expanded(
                        child: CustomCaptchaService.buildCaptchaWidget(
                          captchaText: _captchaText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshCaptcha,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _captchaController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Captcha',
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the captcha text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: const Text('Don\'t have an account? Register'),
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : _registerWithGoogle,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Google_2015_logo.svg/500px-Google_2015_logo.svg.png",
                            height: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text("Sign In"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
