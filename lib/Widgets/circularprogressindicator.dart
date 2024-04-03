import 'package:flutter/material.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:provider/provider.dart';

class CustomCPI extends StatelessWidget {
  const CustomCPI({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Color(Provider.of<ThemeProvider>(context).color),
      ),
    );
  }
}
