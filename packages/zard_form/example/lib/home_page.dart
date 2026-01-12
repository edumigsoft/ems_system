import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:zard_form/zard_form.dart'; // ajuste conforme seu package

final schema = z.map({
  'email': z.string().email(),
  'password': z.string().min(6),
});

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final form = useForm<Map<String, dynamic>>(
    resolver: zardResolver<Map<String, dynamic>>(schema),
    mode: ValidationMode.onSubmit,
    defaultValues: {
      'email': '',
      'password': '',
    },
  );

  Future<void> onSubmit(dynamic data) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    log('Form submitted: $data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZFormBuilder(
        form: form,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              spacing: 16,
              children: [
                TextField(
                  controller: form.register('email'),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: state.errors['email'],
                  ),
                ),
                TextField(
                  controller: form.register('password'),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: state.errors['password'],
                  ),
                ),
                SubmitButton(
                  text: 'Login',
                  isLoading: state.isSubmitting,
                  onPressed: () => form.handleSubmit(onSubmit),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(text),
    );
  }
}
