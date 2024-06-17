import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gnml/Helper/auth.dart';
import 'package:gnml/UI/homepage.dart';
import 'package:gnml/UI/Authentication/register_page.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
// import 'package:mobx/mobx.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailInput = TextEditingController();
  final passwordInput = TextEditingController();
  final AuthService _authService = AuthService();

  String error = "";
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 30.0),
                child: Text(
                  "Welcome",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
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
                    validator: (value) =>
                        value!.isEmpty ? 'Password cannot be empty' : null,
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
                        setState(() {
                          isLoading = true;
                          setState(() {
                            error = "";
                          });
                        });
                        try {
                          dynamic user = await _authService.signIn(
                              emailInput.text, passwordInput.text);
                          if (user != null) {
                            Future.delayed(
                              const Duration(seconds: 1),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                );
                              },
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          // print(e.code);
                          if (e.code == "wrong-password") {
                            setState(
                                () => error = "Wrong username or password");
                          } else if (e.code == "invalid-email") {
                            setState(() => error = "Invalid email");
                          } else if (e.code == "user-not-found") {
                            setState(() => error = "User not found");
                          } else if (e.code == "user-disabled") {
                            setState(() => error =
                                "User account is disabled, contact support.");
                          } else {
                            setState(
                              () => error =
                                  "An error has occured. Please try again",
                            );
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: isLoading
                          ? const SizedBox(
                              height: 15,
                              width: 15,
                              child: CustomCPI(),
                            )
                          : const Text("Login"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text("Sign Up"),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
