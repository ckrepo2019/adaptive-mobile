import 'package:flutter/material.dart';
import 'package:flutter_lms/widgets/base_widgets.dart';

class CustomTextField extends BaseWidget {
  final bool obscure;
  final String title;
  final TextEditingController textController;

  const CustomTextField({
    super.key,
    required this.title,
    required this.obscure,
    required this.textController
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      child: Center(
        child: TextField(
          controller: textController,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: title,
            hintStyle: TextStyle(fontSize: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
