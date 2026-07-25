import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void toast(BuildContext context,String data) {
  Clipboard.setData(ClipboardData(text: data));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "$data Copied !",
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      closeIconColor: Theme.of(context).colorScheme.onSurface,
      backgroundColor: Colors.green[500],
    ),
  );
}
