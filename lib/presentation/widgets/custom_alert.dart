import 'package:flutter/material.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

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
  final bool isLoading;

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
    this.isLoading = false,
  })  : assert(textButtonOk != null || textButtonCancel != null,
            'At least one button text (textButtonOk or textButtonCancel) must be provided.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundColor,
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
                onPressed: isLoading ? null : onConfirmCancle,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                        color: isLoading
                            ? Colors.grey
                            : (cancelBorderColor ?? Colors.grey),
                      ),
                    ),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(100, 30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      )
                    : Text(
                        textButtonCancel ?? "Batal",
                        style: TextStyle(
                          color: isLoading
                              ? Colors.grey
                              : (textButtonCancelColor ?? Colors.grey),
                        ),
                      ),
              ),
            if (textButtonCancel != null && textButtonOk != null)
              const SizedBox(width: 16),
            if (textButtonOk != null)
              TextButton(
                onPressed: isLoading ? null : onConfirmOk,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(
                        color: isLoading
                            ? Colors.grey
                            : (okBorderColor ?? Colors.transparent),
                      ),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(
                    isLoading ? Colors.grey : AppColors.primaryColor,
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(100, 30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        textButtonOk ?? "Ok",
                        style: TextStyle(
                          color: isLoading
                              ? Colors.grey
                              : (textButtonOkColor ?? Colors.white),
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
