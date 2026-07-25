import 'package:flutter/material.dart';

class MyField extends StatelessWidget {
  const MyField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    required this.isError,
    required this.type,
    required this.onChanged,
    this.errorhint = '',
    this.isMask = false,
    this.enable = true
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType type;
  final int isError;
  final String errorhint;
  final bool isMask;
  final Function onChanged;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    Color activeColor =
        isError == 0
            ? Theme.of(context).colorScheme.onSurface
            : isError == 1
            ? Colors.green
            : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(bottom: errorhint == '' ? 10 : 0),
          decoration: BoxDecoration(
            border: Border.all(width: 1.5, color: activeColor),
          ),
          child: TextField(
            controller: controller,
            onChanged: (value) {
              onChanged(value);
            },
            enabled: enable,
            obscureText: isMask,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 20),
              border: InputBorder.none,
              icon: Icon(icon, size: 30, color: activeColor),
              suffixIcon:
                  isError == 0
                      ? Icon(Icons.verified, color: Colors.transparent)
                      : isError == 1
                      ? Icon(Icons.done, size: 30, color: Colors.green)
                      : Icon(Icons.error_outline, size: 30, color: Colors.red),
            ),
            style: TextStyle(fontSize: 20),
            keyboardType: type,
          ),
        ),
        errorhint == ''
            ? SizedBox()
            : Text(errorhint, style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
