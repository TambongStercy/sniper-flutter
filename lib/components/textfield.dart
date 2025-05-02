import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:snipper_frontend/utils.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:snipper_frontend/localization_extension.dart'; // For translations

// Enum for different field types
enum CustomFieldType {
  text,
  password,
  email,
  phone,
  number,
  multiline,
  date,
  dropdown,
  multiSelect
}

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.hintText = '', // Made optional
    this.onChange, // Made optional for new types
    this.searchMode,
    this.onSearch,
    this.getCountryDialCode,
    this.getCountryCode,
    this.margin,
    this.fieldType = CustomFieldType.text, // Use enum, default to text
    this.value, // Keep for text-based inputs
    this.initialCountryCode,
    this.readOnly,
    this.focusNode,
    // New parameters for additional types
    this.items, // For Dropdown
    this.selectedDropdownValue, // For Dropdown state
    this.onDropdownChanged, // For Dropdown callback
    this.currentDateValue, // For Date picker state
    this.onDateSelected, // For Date picker callback
    this.allOptions, // For MultiSelect
    this.selectedOptions, // For MultiSelect state
    this.onSaveMultiSelect, // For MultiSelect callback
    this.displayMap, // For MultiSelect display
    this.label, // Optional label for all types
  });

  ///1 = text, 2 = numbers, 3 = password, 4 = email, 5 = phonenumber, 6 = long text
  final CustomFieldType fieldType;
  final String hintText;
  final String? value;
  final int? margin;
  final Function(String)? onChange;
  final Function(String)? getCountryDialCode;
  final Function(String)? getCountryCode;
  final Function()? onSearch;
  final bool? searchMode;
  final String? initialCountryCode;
  final bool? readOnly;
  final FocusNode? focusNode;

  // Dropdown specific
  final List<Map<String, String>>? items;
  final String? selectedDropdownValue;
  final ValueChanged<String?>? onDropdownChanged;

  // Date specific
  final DateTime? currentDateValue;
  final ValueChanged<DateTime?>? onDateSelected;

  // MultiSelect specific
  final List<String>? allOptions;
  final List<String>? selectedOptions;
  final ValueChanged<List<String>>? onSaveMultiSelect;
  final Map<String, String>? displayMap;

  final String? label; // Optional Label

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool passwordVisible = false;
  late TextEditingController _textFieldController;
  // State for Date Picker display
  final TextEditingController _dateController = TextEditingController();
  // State for MultiSelect display
  String _multiSelectButtonText = '';

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDisplayFields();
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if the initial value changes externally
    if (widget.value != oldWidget.value &&
        (widget.fieldType == CustomFieldType.text ||
            widget.fieldType == CustomFieldType.password ||
            widget.fieldType == CustomFieldType.email ||
            widget.fieldType == CustomFieldType.number ||
            widget.fieldType == CustomFieldType.multiline)) {
      // Avoid cursor jumping if controller already exists
      Future.delayed(Duration.zero, () {
        if (mounted) {
          _textFieldController.text = widget.value ?? '';
          // Optionally move cursor to end:
          // _textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: _textFieldController.text.length));
        }
      });
    }
    // Update display texts for Date and MultiSelect if their state changes
    if (widget.currentDateValue != oldWidget.currentDateValue) {
      _updateDateDisplay();
    }
    if (widget.selectedOptions != oldWidget.selectedOptions) {
      _updateMultiSelectDisplay();
    }
  }

  void _initializeController() {
    passwordVisible = widget.fieldType == CustomFieldType.password;
    _textFieldController = TextEditingController(text: widget.value ?? '');
  }

  void _updateDisplayFields() {
    _updateDateDisplay();
    _updateMultiSelectDisplay();
  }

  void _updateDateDisplay() {
    if (widget.fieldType == CustomFieldType.date &&
        widget.currentDateValue != null) {
      try {
        _dateController.text =
            DateFormat.yMMMd().format(widget.currentDateValue!);
      } catch (e) {
        _dateController.text = context.translate('invalid_date_format');
      }
    } else if (widget.fieldType == CustomFieldType.date) {
      _dateController.text = ''; // Clear if null
    }
  }

  void _updateMultiSelectDisplay() {
    if (widget.fieldType == CustomFieldType.multiSelect) {
      final selected = widget.selectedOptions ?? [];
      if (selected.isEmpty) {
        _multiSelectButtonText = context.translate('tap_to_select');
      } else if (widget.displayMap != null) {
        _multiSelectButtonText =
            selected.map((val) => widget.displayMap![val] ?? val).join(', ');
      } else {
        _multiSelectButtonText = selected.join(', ');
        // _multiSelectButtonText = context.translate('selected_count', args: {'count': selected.length.toString()});
      }
      // No need to call setState here if build method reads _multiSelectButtonText directly
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Getters for widget properties (simplified)
  CustomFieldType get fieldType => widget.fieldType;
  String get hintText => widget.hintText;
  String? get value => widget.value;
  int? get margin => widget.margin;
  Function(String)? get onChange => widget.onChange;
  bool get readOnly => widget.readOnly ?? false;
  String? get label => widget.label;

  // --- Build Method --- F
  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    int marg = margin ?? 10; // Default margin to 10 if not provided

    // Common Input Decoration
    InputDecoration inputDecoration = InputDecoration(
      hintText: hintText,
      hintStyle: SafeGoogleFont(
        'Montserrat',
        fontSize: 14 * ffem,
        color: Colors.grey[500],
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13 * fem)),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 10 * fem, vertical: 15 * fem),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13 * fem),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13 * fem),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13 * fem),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13 * fem),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        // For readOnly state
        borderRadius: BorderRadius.circular(13 * fem),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    );

    Widget fieldWidget;

    switch (fieldType) {
      case CustomFieldType.text:
      case CustomFieldType.email:
      case CustomFieldType.number:
      case CustomFieldType.multiline:
        fieldWidget = _buildTextField(inputDecoration, fem, ffem);
        break;
      case CustomFieldType.password:
        fieldWidget = _buildPasswordField(inputDecoration, fem, ffem);
        break;
      case CustomFieldType.phone:
        fieldWidget = _buildPhoneField(fem);
        break;
      case CustomFieldType.date:
        fieldWidget = _buildDateField(inputDecoration, fem, ffem);
        break;
      case CustomFieldType.dropdown:
        fieldWidget = _buildDropdownField(inputDecoration, fem, ffem);
        break;
      case CustomFieldType.multiSelect:
        fieldWidget = _buildMultiSelectField(inputDecoration, fem, ffem);
        break;
      default:
        fieldWidget = SizedBox.shrink(); // Or throw an error
        print("Error: Unhandled CustomFieldType: $fieldType");
    }

    return Container(
      margin: EdgeInsets.fromLTRB(marg * fem, 0 * fem, marg * fem,
          15 * fem), // Use 15 for bottom margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null && label!.isNotEmpty) ...[
            Container(
              margin: EdgeInsets.only(bottom: 8 * fem),
              child: Text(
                label!,
              style: SafeGoogleFont(
                'Montserrat',
                  fontSize: 12 * ffem,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6d7d8b),
                ),
              ),
            ),
          ],
          fieldWidget,
        ],
      ),
    );
  }

  // --- Helper build methods for different field types ---

  Widget _buildTextField(InputDecoration decoration, double fem, double ffem) {
    return TextField(
      controller: _textFieldController,
      keyboardType: fieldType == CustomFieldType.email
          ? TextInputType.emailAddress
          : (fieldType == CustomFieldType.number
              ? TextInputType.number
              : (fieldType == CustomFieldType.multiline
                  ? TextInputType.multiline
                  : TextInputType.text)),
      maxLines: fieldType == CustomFieldType.multiline ? 5 : 1,
      obscureText: false,
      readOnly: readOnly,
      focusNode: widget.focusNode,
      inputFormatters: fieldType == CustomFieldType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      onChanged: onChange,
      onSubmitted: (value) {
        if (widget.searchMode == true && widget.onSearch != null) {
          widget.onSearch!();
        }
      },
      style: SafeGoogleFont('Montserrat',
          fontSize: 14 * ffem, color: Color(0xff25313c)),
      decoration: decoration.copyWith(
        suffixIcon: !readOnly && _textFieldController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                onPressed: () {
                  _textFieldController.clear();
                  if (onChange != null) onChange!('');
                },
              )
            : null,
        prefixIcon: widget.searchMode == true
                    ? IconButton(
                icon: Icon(Icons.search, color: Colors.grey[600]),
                onPressed: widget.onSearch,
              )
            : null,
      ),
    );
  }

  Widget _buildPasswordField(
      InputDecoration decoration, double fem, double ffem) {
    return TextField(
      controller: _textFieldController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: !passwordVisible, // Use negated state
      readOnly: readOnly,
      focusNode: widget.focusNode,
      onChanged: onChange,
      style: SafeGoogleFont('Montserrat',
          fontSize: 14 * ffem, color: Color(0xff25313c)),
      decoration: decoration.copyWith(
        suffixIcon: IconButton(
                        icon: Icon(
            passwordVisible ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: Colors.grey[600],
                        ),
                        onPressed: () {
            setState(() {
                              passwordVisible = !passwordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPhoneField(double fem) {
    // Note: IntlPhoneField handles its own decoration internally to some extent.
    // We might need to customize it further if needed.
    return IntlPhoneField(
      initialValue: widget.value, // Pass initial value if any
      initialCountryCode: widget.initialCountryCode ?? 'CM',
      focusNode: widget.focusNode,
      readOnly: readOnly,
      decoration: InputDecoration(
        // Apply some base decoration
        hintText: hintText,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(13 * fem)),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 10 * fem, vertical: 15 * fem),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13 * fem),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13 * fem),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        // Add other border states if necessary
      ),
      languageCode: "en", // Or use locale
      onChanged: (phone) {
        if (onChange != null) onChange!(phone.completeNumber);
        if (widget.getCountryDialCode != null)
          widget.getCountryDialCode!(phone.countryCode.replaceAll('+', ''));
        if (widget.getCountryCode != null) {
          // Find country ISO code from dial code (might need a lookup map or use package features)
          final country = countries.firstWhere(
              (c) => c.dialCode == phone.countryCode.replaceAll('+', ''),
              orElse: () => countries.firstWhere((c) => c.code == 'CM'));
          widget.getCountryCode!(country.code);
        }
      },
      onCountryChanged: (country) {
        if (widget.getCountryDialCode != null)
          widget.getCountryDialCode!(country.dialCode);
        if (widget.getCountryCode != null) widget.getCountryCode!(country.code);
      },
    );
  }

  Widget _buildDateField(InputDecoration decoration, double fem, double ffem) {
    return TextField(
      controller: _dateController, // Use dedicated controller for display
      readOnly: true,
      focusNode: widget.focusNode,
      style: SafeGoogleFont('Montserrat',
          fontSize: 14 * ffem, color: Color(0xff25313c)),
      decoration: decoration.copyWith(
        hintText: hintText.isNotEmpty
            ? hintText
            : context.translate('select_date_of_birth'),
        suffixIcon:
            Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
      ),
      onTap: readOnly
          ? null
          : () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: widget.currentDateValue ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null && widget.onDateSelected != null) {
                widget.onDateSelected!(pickedDate);
                // Update display controller manually since state is managed by parent
                try {
                  _dateController.text = DateFormat.yMMMd().format(pickedDate);
                } catch (e) {
                  _dateController.text =
                      context.translate('invalid_date_format');
                }
              }
            },
    );
  }

  Widget _buildDropdownField(
      InputDecoration decoration, double fem, double ffem) {
    return DropdownButtonFormField<String?>(
      value: widget.selectedDropdownValue,
      hint: Text(hintText, style: decoration.hintStyle),
      items: widget.items?.map((item) {
            return DropdownMenuItem<String?>(
              value: item['value'],
              child: Text(item['display']!,
                  style: SafeGoogleFont('Montserrat',
                      fontSize: 14 * ffem, color: Color(0xff25313c))),
            );
          }).toList() ??
          [],
      onChanged: readOnly ? null : widget.onDropdownChanged,
      decoration: decoration,
      isExpanded: true,
      focusNode: widget.focusNode,
      style: SafeGoogleFont('Montserrat',
          fontSize: 14 * ffem,
          color: Color(0xff25313c)), // Style for selected item
    );
  }

  Widget _buildMultiSelectField(
      InputDecoration decoration, double fem, double ffem) {
    // Use InkWell to make the display area tappable
    return InkWell(
      focusNode: widget.focusNode,
      onTap: readOnly
          ? null
          : () {
              if (widget.allOptions != null &&
                  widget.selectedOptions != null &&
                  widget.onSaveMultiSelect != null) {
                _showMultiSelectDialog(
                  context: context,
                  title: label ?? hintText, // Use label or hint as title
                  allOptions: widget.allOptions!,
                  initiallySelectedOptions: widget.selectedOptions!,
                  onSave: widget.onSaveMultiSelect!,
                  fem: fem,
                  ffem: ffem,
                  displayMap: widget.displayMap,
                );
              }
            },
      child: InputDecorator(
        // Mimics TextField appearance
        decoration: decoration.copyWith(
          contentPadding: EdgeInsets.symmetric(
              horizontal: 10 * fem,
              vertical: 16.5 * fem), // Adjust padding slightly
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _multiSelectButtonText, // Display generated text
                style: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 14 * ffem,
                  color: (widget.selectedOptions?.isEmpty ?? true)
                      ? Colors.grey[600]
                      : Color(0xff25313c),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  // --- MultiSelect Dialog Logic (moved inside state) ---
  Future<void> _showMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<String> allOptions,
    required List<String> initiallySelectedOptions,
    required ValueChanged<List<String>> onSave,
    required double fem,
    required double ffem,
    Map<String, String>? displayMap,
  }) async {
    final TextEditingController searchController = TextEditingController();
    List<String> tempSelectedOptions = List.from(initiallySelectedOptions);
    List<String> filteredOptions = List.from(allOptions);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void filterSearchResults(String query) {
              if (query.isEmpty) {
                filteredOptions = List.from(allOptions);
              } else {
                filteredOptions = allOptions.where((option) {
                  final displayValue = displayMap?[option] ?? option;
                  return displayValue
                      .toLowerCase()
                      .contains(query.toLowerCase());
                }).toList();
              }
              setDialogState(() {});
            }

            return AlertDialog(
              title: Text(title),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: context.translate('search'),
                        hintText: context.translate('search'),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8 * fem)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10 * fem),
                      ),
                      onChanged: filterSearchResults,
                    ),
                    SizedBox(height: 10 * fem),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredOptions.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = filteredOptions[index];
                          final displayValue = displayMap?[option] ?? option;
                          final bool isSelected =
                              tempSelectedOptions.contains(option);
                          return CheckboxListTile(
                            title: Text(displayValue,
                                style: TextStyle(fontSize: 14 * ffem)),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelectedOptions.add(option);
                                } else {
                                  tempSelectedOptions.remove(option);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(context.translate('cancel')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(context.translate('save')),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    onSave(tempSelectedOptions); // Use ValueChanged callback
                    // Update local display text immediately after saving
                    // setState(() { _updateMultiSelectDisplay(); }); // This won't work as expected here
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
