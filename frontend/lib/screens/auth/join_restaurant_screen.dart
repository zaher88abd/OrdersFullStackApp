import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../widgets/loading_button.dart';

class JoinRestaurantScreen extends StatefulWidget {
  const JoinRestaurantScreen({super.key});

  @override
  State<JoinRestaurantScreen> createState() => _JoinRestaurantScreenState();
}

class _JoinRestaurantScreenState extends State<JoinRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  JobType _selectedJobType = JobType.waiter;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _restaurantCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _joinRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.joinRestaurant(
      restaurantCode: _restaurantCodeController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      jobType: _selectedJobType,
    );

    if (success) {
      Fluttertoast.showToast(
        msg: 'Successfully joined restaurant! Signing you in...',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green,
      );
      
      // Automatically sign in the user since staff accounts are active immediately
      final signInSuccess = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (signInSuccess) {
        // Navigation will be handled automatically by GoRouter
        Fluttertoast.showToast(
          msg: 'Welcome! You are now signed in.',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
        );
      } else {
        // If auto sign-in fails, go to sign-in screen
        Fluttertoast.showToast(
          msg: 'Account created successfully. Please sign in.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.orange,
        );
        context.pushReplacement('/sign-in');
      }
    } else {
      Fluttertoast.showToast(
        msg: authProvider.error ?? 'Failed to join restaurant',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Restaurant'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Icon(
                  Icons.group_add,
                  size: 64,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 16),
                Text(
                  'Join Restaurant Team',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the restaurant code provided by your manager to join the team',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Restaurant Code Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restaurant Code',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ask your manager for the 7-character restaurant code',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _restaurantCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Restaurant Code *',
                            prefixIcon: Icon(Icons.qr_code),
                            border: OutlineInputBorder(),
                            hintText: 'e.g., ABC1234',
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter restaurant code';
                            }
                            if (value.trim().length != 7) {
                              return 'Restaurant code must be 7 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Personal Information Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address *',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email address';
                            }
                            if (!EmailValidator.validate(value.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Job Type Selection
                        DropdownButtonFormField<JobType>(
                          value: _selectedJobType,
                          decoration: const InputDecoration(
                            labelText: 'Job Role *',
                            prefixIcon: Icon(Icons.work),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: JobType.waiter,
                              child: Row(
                                children: [
                                  Icon(Icons.room_service, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  const Text('Waiter'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: JobType.chef,
                              child: Row(
                                children: [
                                  Icon(Icons.restaurant, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  const Text('Chef'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (JobType? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedJobType = newValue;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select your job role';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password *',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password *',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Join Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return LoadingButton(
                      onPressed: authProvider.isLoading ? null : _joinRestaurant,
                      isLoading: authProvider.isLoading,
                      child: const Text(
                        'Join Restaurant',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Back to Welcome
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back to Welcome'),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}