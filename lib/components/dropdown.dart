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
    List<DropdownMenuItem<String>> menuItems =
        items.where((item) => item != '').map((item) {
      String capitalizedStr =
          item.substring(0, 1).toUpperCase() + item.substring(1);

      return DropdownMenuItem(child: Text(capitalizedStr), value: item);
    }).toList();

    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: blue,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: blue, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      value: value,
      onChanged: (String? newValue) {
        print(newValue);
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
