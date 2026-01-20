import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Lógica simulada de login
  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      // AQUÍ conectarás más adelante con tu backend (Spring Boot / FastAPI)
      print("Enviando a API: ${_emailController.text}");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conectando con el servidor...'),
          backgroundColor: Colors.indigo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.code_rounded, size: 80, color: Colors.indigo),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Iniciar Sesión',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Input Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration('Correo Electrónico', Icons.email_outlined),
                    
                  ),
                  const SizedBox(height: 20),

                  // Input Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration('Contraseña', Icons.lock_outline).copyWith(
                     
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _submitLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Entrar', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Método helper para no repetir estilos en los inputs
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.indigo.shade300),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
    );
  }
}