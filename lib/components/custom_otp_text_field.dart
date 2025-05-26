import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOtpTextField extends StatefulWidget {
  final int numberOfFields;
  final double fieldWidth;
  final double fieldHeight;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final ValueChanged<String>
      onSubmit; // This will now be called by an explicit action
  final ValueChanged<String>? onChanged;
  final bool autoFocus;

  const CustomOtpTextField({
    Key? key,
    this.numberOfFields = 6,
    this.fieldWidth = 40.0,
    this.fieldHeight = 45.0,
    this.textStyle,
    this.decoration,
    required this.onSubmit,
    this.onChanged,
    this.autoFocus = false,
    // keyboardType is removed as it's always TextInputType.text internally
  }) : super(key: key);

  @override
  _CustomOtpTextFieldState createState() => _CustomOtpTextFieldState();
}

class _CustomOtpTextFieldState extends State<CustomOtpTextField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _pin;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
        widget.numberOfFields, (index) => TextEditingController());
    _focusNodes = List.generate(widget.numberOfFields, (index) => FocusNode());
    _pin = List.generate(widget.numberOfFields, (index) => '');

    for (int i = 0; i < widget.numberOfFields; i++) {
      // _controllers[i].addListener(() => _onControllerChanged(i)); // Changed listener
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          _controllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[i].text.length,
          );
        }
      });
    }

    if (widget.autoFocus && widget.numberOfFields > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      });
    }
  }

  // Consolidated input handling
  void _onInputChanged(int index, String value) {
    if (value.isEmpty) {
      // Handle clear or backspace from onChanged
      _pin[index] = '';
      // Optional: move focus back if current field is cleared by user directly
      // if (index > 0 && _controllers[index-1].text.isNotEmpty) {
      //   FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      // }
      _notifyChanged();
      return;
    }

    // Handle paste or multiple character input
    if (value.length > 1) {
      String pastedValue = value;
      for (int i = 0;
          i < pastedValue.length && (index + i) < widget.numberOfFields;
          i++) {
        int currentField = index + i;
        _pin[currentField] = pastedValue[i];
        _controllers[currentField].text = pastedValue[i];
        if (currentField < widget.numberOfFields - 1) {
          FocusScope.of(context).requestFocus(_focusNodes[currentField + 1]);
        } else {
          _focusNodes[currentField]
              .unfocus(); // Unfocus last field on paste completion
          // DO NOT auto-submit here. Submission is handled by external button.
        }
      }
    } else {
      // Single character input
      _pin[index] = value;
      _controllers[index].text = value; // Ensure controller has the single char

      if (index < widget.numberOfFields - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus(); // Last field, unfocus
        // DO NOT auto-submit here. Submission is handled by external button.
      }
    }
    _notifyChanged();
    // Check if all fields are filled and then call onSubmit
    // This is still somewhat an auto-submit, so we'll remove it based on user feedback.
    // if (_pin.join().length == widget.numberOfFields) {
    //   _submit();
    // }
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].clear();
      _pin[index - 1] = '';
    } else {
      _controllers[index].clear();
      _pin[index] = '';
    }
    _notifyChanged();
  }

  // _submit method is kept if explicit submission from parent is ever needed via a GlobalKey
  // but it's not called automatically anymore from _onInputChanged.
  void _submit() {
    final otp = _pin.join();
    if (otp.length == widget.numberOfFields) {
      widget.onSubmit(otp);
    }
  }

  void _notifyChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_pin.join());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.numberOfFields, (index) {
        return SizedBox(
          width: widget.fieldWidth,
          height: widget.fieldHeight,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.backspace) {
                  _handleBackspace(index);
                }
              }
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              style: widget.textStyle ??
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.text,
              inputFormatters: [
                // LengthLimitingTextInputFormatter(1), // Allow paste logic to handle length
                FilteringTextInputFormatter.singleLineFormatter,
              ],
              decoration: widget.decoration ??
                  InputDecoration(
                    counterText: "",
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
              onChanged: (value) {
                _onInputChanged(index, value);
              },
            ),
          ),
        );
      }),
    );
  }
}
