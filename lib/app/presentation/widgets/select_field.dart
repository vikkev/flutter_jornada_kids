import 'package:flutter/material.dart';

class Select<T> extends StatelessWidget {
  final T? selectedValue;
  final List<T> options;
  final String hintText;
  final ValueChanged<T?> onChanged;
  final String Function(T) getLabel;

  const Select({
    Key? key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    required this.getLabel,
    this.hintText = 'Selecione uma opção',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          hint: Text(
            hintText,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          items: options.map((T option) {
            return DropdownMenuItem<T>(
              value: option,
              child: Text(getLabel(option)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
