import 'package:flutter/material.dart';
import 'package:snipper_frontend/config.dart';
import 'package:snipper_frontend/utils.dart';

class CustomDropdown extends StatelessWidget {
  CustomDropdown({
    super.key,
    required this.items,
    required this.ffem,
    required this.value,
    required this.onChange,
  });

  final List<String> items;
  final String value;
  final double ffem;
  final Function(String) onChange;

  List<DropdownMenuItem<String>> get dropdownItems {
    return items
        .where((item) => item.isNotEmpty) // Exclude empty strings
        .map((item) {
      String capitalizedStr = item[0].toUpperCase() + item.substring(1);
      return DropdownMenuItem(child: Text(capitalizedStr), value: item);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure `value` is in items, else set a default
    String? selectedValue = items.contains(value) ? value : items.first;

    return DropdownButtonFormField(
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.category_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      value: selectedValue, // Use the verified `selectedValue`
      onChanged: (String? newValue) {
        onChange(newValue ?? '');
      },
      items: dropdownItems,
      style: SafeGoogleFont(
        'Montserrat',
        fontSize: 15 * ffem,
        fontWeight: FontWeight.w600,
        color: Color(0xff000000),
      ),
    );
  }
}
