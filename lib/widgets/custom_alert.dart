import 'package:flutter/material.dart';

class CustomAlert extends StatelessWidget {
  const CustomAlert({super.key, required this.joinMatch});

  final Function(bool) joinMatch;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Join"),
      content: const Text("Do you want to join the match?"),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            joinMatch(false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Text(
            "No",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            joinMatch(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Text(
            "Yes",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}
