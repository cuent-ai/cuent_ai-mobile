import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_theme.dart';

class AuthForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController? nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final String buttonText;
  final bool showNameField;

  const AuthForm({
    super.key,
    required this.formKey,
    this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
    required this.buttonText,
    this.showNameField = false,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          if (widget.showNameField) ...[
            _buildNameField(),
            const SizedBox(height: 20),
          ],
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 30),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: widget.nameController,
      decoration: const InputDecoration(
        labelText: 'Nombre completo',
        hintText: 'Ingresa tu nombre',
        prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
      ),
      validator: Validators.validateName,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: widget.emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'Ingresa tu email',
        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: widget.passwordController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Ingresa tu contraseña',
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.primaryColor,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      obscureText: _obscurePassword,
      validator: Validators.validatePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => widget.onSubmit(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.buttonText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
