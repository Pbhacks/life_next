import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Life Next Messenger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text('Welcome to Life Next Messenger',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// Login, Signup, Forgot Password Screen
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

  Future<void> _loginUser() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainChatsPage()),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _signupUser() async {
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showError("Passwords do not match");
      return;
    }
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await userCredential.user!.sendEmailVerification();
      _showMessage("Verification email sent. Please check your inbox.");
      // Redirect to login page after signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showMessage("Password reset email sent");
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleUser = await _googleSignIn.signIn();
      final GoogleAuth = await GoogleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: GoogleAuth.accessToken,
        idToken: GoogleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainChatsPage()),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignupMode ? 'Sign Up' : 'Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            if (_isSignupMode || !_isSignupMode) ...[
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              if (_isSignupMode) ...[
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                ),
              ],
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSignupMode ? _signupUser : _loginUser,
              child: Text(_isSignupMode ? 'Sign Up' : 'Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => _signInWithGoogle(),
              child: Text('Login with Google'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _isSignupMode = !_isSignupMode;
              }),
              child: Text(_isSignupMode
                  ? 'Already have an account? Login'
                  : 'Create an Account'),
            ),
            TextButton(
              onPressed: () => _toggleFormMode(FormMode.forgotPassword),
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFormMode(FormMode formMode) {
    setState(() {
      if (formMode == FormMode.forgotPassword) {
        _isSignupMode = false;
      } else {
        _isSignupMode = formMode == FormMode.signup;
      }
    });
  }
}

enum FormMode { login, signup, forgotPassword }

// Main Chats Page (unchanged)
class MainChatsPage extends StatefulWidget {
  @override
  _MainChatsPageState createState() => _MainChatsPageState();
}

class _MainChatsPageState extends State<MainChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              // Logic to invite contacts
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invite contacts coming soon!')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Chat list items will be displayed here.
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('User 1'),
            subtitle: Text('Hello!'),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('User 2'),
            subtitle: Text('How are you?'),
          ),
          // More chat items...
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic for "Interconnect" feature
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Interconnect feature coming soon!')),
          );
        },
        child: Icon(Icons.connect_without_contact),
      ),
    );
  }
}
