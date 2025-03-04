import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:snipper_frontend/utils.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.onChange,
    this.searchMode,
    this.onSearch,
    this.getCountryDialCode,
    this.getCountryCode,
    this.margin,
    this.type,
    this.value,
    this.initialCountryCode,
    this.readOnly,
    this.focusNode,
  });

  ///1 = text, 2 = numbers, 3 = password, 4 = email, 5 = phonenumber, 6 = long text
  final int? type;
  final String hintText;
  final String? value;
  final int? margin;
  final Function(String) onChange;
  final Function(String)? getCountryDialCode;
  final Function(String)? getCountryCode;
  final Function()? onSearch;
  final bool? searchMode;
  final String? initialCountryCode;
  final bool? readOnly;
  final FocusNode? focusNode;


  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool passwordVisible = false;
  late TextEditingController _textFieldController;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;

    // Create anonymous function:
    () async {
      _textFieldController = TextEditingController(text: value);

      if (type == 1 || type == 6 || type == null) {
        keyboard = TextInputType.text;
        passwordVisible = false;
      } else if (type == 2) {
        keyboard = TextInputType.number;
        passwordVisible = false;
      } else if (type == 3) {
        keyboard = TextInputType.visiblePassword;
        passwordVisible = true;
      } else if (type == 4) {
        keyboard = TextInputType.emailAddress;
        passwordVisible = false;
      } else {
        // _textFieldController = TextEditingController(text: '237675080477');
        keyboard = TextInputType.phone;
        passwordVisible = false;
      }
      setState(() {
        // Update your UI with the desired changes.
      });
    }();
  }

  int? get type => widget.type;
  String get hintText => widget.hintText;
  String? get value => widget.value;
  int? get margin => widget.margin;
  Function(String) get onChange => widget.onChange;
  Function(String)? get getCountryDialCode => widget.getCountryDialCode;
  Function(String)? get getCountryCode => widget.getCountryCode;
  Function()? get onSearch => widget.onSearch;
  bool? get searchMode => widget.searchMode;
  bool get readOnly => widget.readOnly ?? false;
  FocusNode? get focusNode => widget.focusNode;

  ///Should be the code without +
  String get initialCountryCode => widget.initialCountryCode ?? 'CM';

  TextInputType keyboard = TextInputType.text;

  @override
  Widget build(BuildContext context) {
    double baseWidth = 390;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    bool search = searchMode ?? false;
    int marg = margin ?? 49;

    // print(initialCountryCode);

    return Container(
      margin: EdgeInsets.fromLTRB(marg * fem, 0 * fem, marg * fem, 13 * fem),
      child: (type != 5)
          ? TextField(
              maxLines: type == 6 ? 5 : 1,
              controller: _textFieldController,
              keyboardType: keyboard,
              obscureText: passwordVisible,
              focusNode: focusNode,
              readOnly: readOnly,
              inputFormatters:
                  type == 2 ? [FilteringTextInputFormatter.digitsOnly] : null,
              onChanged: (value) {
                onChange(value);
              },
              onSubmitted: (value) {
                if (search && onSearch != null) {
                  onSearch!();
                }
              },
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 14 * ffem,
              ),
              decoration: InputDecoration(
                suffixIcon: type == 3
                    ? IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              passwordVisible = !passwordVisible;
                            },
                          );
                        },
                      )
                    : (!readOnly
                        ? IconButton(
                            icon: Icon(
                              _textFieldController.value.text.isNotEmpty
                                  ? Icons.close
                                  : null,
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  onChange('');
                                  _textFieldController.text = '';
                                },
                              );
                            },
                          )
                        : null),
                prefixIcon: search
                    ? IconButton(
                        icon: Icon(Icons.search),
                        onPressed: onSearch,
                      )
                    : null,
                hintText: hintText,
                hintStyle: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 14 * ffem,
                ),
                contentPadding: search ? EdgeInsets.only(top: 20.0) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(search ? 55 : 5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(search ? 55 : 5),
                  borderSide:
                      const BorderSide(color: Color(0xff1862f0), width: 1),
                ),
              ),
            )
          : IntlPhoneField(
              initialCountryCode: initialCountryCode,
              controller: _textFieldController,
              keyboardType: keyboard,
              obscureText: passwordVisible,
              focusNode: focusNode,
              readOnly: readOnly,
              flagsButtonPadding: const EdgeInsets.all(8),
              dropdownIconPosition: IconPosition.trailing,
              disableLengthCheck: true,
              // validator: (phoneNumber) {
              //   // Implement custom validation logic here
              //   if (phoneNumber?.number.length != 9 &&
              //       phoneNumber?.countryISOCode == 'KE') {
              //     return 'Phone number must be 9 digits for Kenya';
              //   }
              //   return null;
              // },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: SafeGoogleFont(
                  'Montserrat',
                  fontSize: 14 * ffem,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(search ? 55 : 5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(search ? 55 : 5),
                  borderSide:
                      const BorderSide(color: Color(0xff1862f0), width: 1),
                ),
              ),
              onChanged: (phone) {
                onChange(phone.number);
              },
              onCountryChanged: (Country country) {
                print(country.dialCode);
                if (getCountryCode != null) {
                  getCountryCode!(country.code);
                }
                if (getCountryDialCode != null) {
                  getCountryDialCode!(country.dialCode);
                }
              },
              style: SafeGoogleFont(
                'Montserrat',
                fontSize: 14 * ffem,
              ),
            ),
    );
  }
}
