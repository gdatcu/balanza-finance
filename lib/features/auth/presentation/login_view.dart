import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:balanza/l10n/app_localizations.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final StreamSubscription<AuthState> _authSubscription;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // 3. Auth State Listener on supabase.auth.onAuthStateChange
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn && mounted) {
        // User successfully signed in via Supabase
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 2. Native Google Authentication with Supabase signInWithIdToken
  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pass the Web Client ID configured in Google Cloud (do NOT use Android Client ID here)
      const String webClientId = '932149633166-cv1mmulfifvf2nrs22o0qeqosi7984i0.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? webClientId : null,
        serverClientId: kIsWeb ? null : webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled native sign-in flow
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw const AuthException('No ID Token returned from Google authentication.');
      }

      // Authenticate with Supabase using signInWithIdToken
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } on AuthException catch (e) {
      if (mounted) _showErrorSnackBar(e.message);
    } catch (e) {
      if (mounted) _showErrorSnackBar('Google Sign-In error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AuthException catch (e) {
      if (mounted) _showErrorSnackBar(e.message);
    } catch (e) {
      if (mounted) _showErrorSnackBar(AppLocalizations.of(context)!.unexpectedErrorSignIn);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (response.user != null) {
        if (mounted) _showSuccessSnackBar(AppLocalizations.of(context)!.registrationSuccessful);
      } else {
        if (mounted) _showSuccessSnackBar(AppLocalizations.of(context)!.registrationSubmitted);
      }
    } on AuthException catch (e) {
      if (mounted) _showErrorSnackBar(e.message);
    } catch (e) {
      if (mounted) _showErrorSnackBar(AppLocalizations.of(context)!.unexpectedErrorRegistration);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade600,
              Colors.deepPurple.shade400,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 12,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo / Header
                        Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.appTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.appTagline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterEmail;
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _signIn(),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.pleaseEnterPassword;
                            }
                            if (value.length < 6) {
                              return AppLocalizations.of(context)!.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Action Buttons
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else ...[
                          // Continue with Google Button
                          ElevatedButton.icon(
                            onPressed: signInWithGoogle,
                            icon: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                              height: 20,
                              width: 20,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.g_mobiledata, size: 28, color: Colors.blue),
                            ),
                            label: const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade400)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text('OR', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade400)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.signIn,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _signUp,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.colorScheme.primary),
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.signUp,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
