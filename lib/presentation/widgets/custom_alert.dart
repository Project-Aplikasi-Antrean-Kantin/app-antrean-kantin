import 'package:flutter/material.dart';

class CustomAlert extends StatelessWidget {
  final String title;
  final String message;
  final String? textButtonOk;
  final String? textButtonCancel;
  final VoidCallback? onConfirmOk;
  final VoidCallback? onConfirmCancle;
  final Color? okBorderColor;
  final Color? cancelBorderColor;
  final Color? textButtonOkColor;
  final Color? textButtonCancelColor;

  const CustomAlert({
    Key? key,
    required this.title,
    required this.message,
    this.textButtonOk,
    this.textButtonCancel,
    this.onConfirmOk,
    this.onConfirmCancle,
    this.okBorderColor,
    this.cancelBorderColor,
    this.textButtonOkColor,
    this.textButtonCancelColor,
  })  : assert(textButtonOk != null || textButtonCancel != null,
            'At least one button text (textButtonOk or textButtonCancel) must be provided.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (textButtonCancel != null)
              TextButton(
                onPressed: onConfirmCancle,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                        color: cancelBorderColor ?? Colors.grey,
                      ),
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(100, 30),
                  ),
                ),
                child: Text(
                  textButtonCancel ?? "Batal",
                  style: TextStyle(
                    color: textButtonCancelColor ?? Colors.grey,
                  ),
                ),
              ),
            if (textButtonCancel != null && textButtonOk != null)
              const SizedBox(width: 16),
            if (textButtonOk != null)
              TextButton(
                onPressed: onConfirmOk,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                        color: okBorderColor ?? Colors.transparent,
                      ),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(
                    const Color.fromARGB(227, 244, 67, 54),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(100, 30),
                  ),
                ),
                child: Text(
                  textButtonOk ?? "Ok",
                  style: TextStyle(
                    color: textButtonOkColor ?? Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
