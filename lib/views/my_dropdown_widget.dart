import 'package:flutter/material.dart';
class MyDropdownWidget extends StatefulWidget {
  final Function(String) onChanged;

  const MyDropdownWidget({super.key, required this.onChanged});

  @override
  State<MyDropdownWidget> createState() => _MyDropdownWidgetState();
}

class _MyDropdownWidgetState extends State<MyDropdownWidget> {
  String? _selectedValue;

  final List<String> options = ['Java', 'J2EE', 'Web'];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Sélectionnez votre spécialité',
        border: OutlineInputBorder(),
      ),
      value: _selectedValue,
      items: options.map((value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedValue = value;
        });
        widget.onChanged(value!);
      },
      validator: (value) {
        if (value == null) {
          return 'Veuillez choisir une spécialité';
        }
        return null;
      },
    );
  }
}
