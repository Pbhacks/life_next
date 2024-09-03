import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSignupMode = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loginUser() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }

  Future<void> _signupUser() async {
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      // Handle password mismatch
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        // Save user details in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': '', // You may want to ask for this during signup
          'email': user.email,
          'profilePic': '', // Optionally, handle profile picture later
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Save user details in Firestore
        await _firestore.collection('users').doc(user.uid).set(
            {
              'name': user.displayName ??
                  '', // Using the Google user's display name
              'email': user.email,
              'profilePic': user.photoURL ??
                  '', // Using the Google user's profile picture URL
              'createdAt': FieldValue.serverTimestamp(),
            },
            SetOptions(
                merge: true)); // Use merge to avoid overwriting existing data
      }
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Enter your email',
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Enter your password',
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            if (_isSignupMode)
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Confirm your password',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSignupMode ? _signupUser : _loginUser,
              child: Text(_isSignupMode ? 'Sign Up' : 'Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: _signInWithGoogle,
              child: Text('Login with Google'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _isSignupMode = !_isSignupMode;
              }),
              child: Text(_isSignupMode
                  ? 'Already have an account? Login'
                  : 'Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
