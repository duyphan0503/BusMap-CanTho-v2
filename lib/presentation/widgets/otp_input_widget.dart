import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputWidget extends StatefulWidget {
  final Function(String) onCompleted;
  final int length;
  final double boxSize;
  final double spacing;

  const OtpInputWidget({
    super.key,
    required this.onCompleted,
    this.length = 6,
    this.boxSize = 50,
    this.spacing = 8,
  });

  @override
  OtpInputWidgetState createState() => OtpInputWidgetState();
}

class OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _otpValues;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _otpValues = List.generate(widget.length, (index) => '');
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

  void _checkComplete() {
    final otp = _otpValues.join();
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: SizedBox(
            width: widget.boxSize,
            height: widget.boxSize,
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    _controllers[index].text.isEmpty &&
                    index > 0) {
                  _focusNodes[index - 1].requestFocus();
                  _controllers[index - 1]
                      .selection = TextSelection.fromPosition(
                    TextPosition(offset: _controllers[index - 1].text.length),
                  );
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.length == 1) {
                    _otpValues[index] = value;
                    if (index < widget.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    }
                  } else if (value.isEmpty && index > 0) {
                    _otpValues[index] = '';
                    _focusNodes[index - 1].requestFocus();
                    _controllers[index - 1]
                        .selection = TextSelection.fromPosition(
                      TextPosition(offset: _controllers[index - 1].text.length),
                    );
                  }
                  _checkComplete();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
