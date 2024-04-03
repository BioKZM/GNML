import 'package:flutter/material.dart';
import 'package:gnml/Helper/auth.dart';
import 'package:gnml/UI/homepage.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameInput = TextEditingController();
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();
  final repasswordInput = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: Text(
                    "Register",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      controller: usernameInput,
                      decoration: const InputDecoration(hintText: 'Username'),
                      validator: (value) =>
                          value!.isEmpty ? 'Username cannot be empty' : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      controller: emailInput,
                      decoration: const InputDecoration(hintText: 'Email'),
                      validator: (value) =>
                          value!.isEmpty ? 'Email cannot be empty' : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      obscureText: true,
                      controller: passwordInput,
                      decoration: const InputDecoration(hintText: 'Password'),
                      validator: (value) => value!.length < 6
                          ? 'Your password must be at least 6 characters long'
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      obscureText: true,
                      controller: repasswordInput,
                      decoration:
                          const InputDecoration(hintText: 'Re-enter Password'),
                      validator: (value) => value != passwordInput.text
                          ? 'Passwords does not match'
                          : null,
                    ),
                  ),
                ),
                Text(
                  error,
                  style: const TextStyle(
                      fontFamily: "NotoSansBold",
                      fontSize: 15,
                      color: Colors.red),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          isLoading = true;
                          if (_formKey.currentState!.validate()) {
                            DateTime today = DateTime.now();
                            String date =
                                "${today.day}/${today.month}/${today.year}";
                            dynamic result = await _authService.registerENP(
                              usernameInput.text,
                              emailInput.text,
                              passwordInput.text,
                              date,
                            );
                            if (result == null) {
                              setState(() =>
                                  error = "Please input a valid email adress");
                              isLoading = false;
                            } else {
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            }
                          }
                        },
                        child: isLoading
                            ? const SizedBox(
                                height: 15,
                                width: 15,
                                child: CustomCPI(),
                              )
                            : const Text("Register"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
