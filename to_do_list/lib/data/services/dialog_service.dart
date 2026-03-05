import 'package:flutter/material.dart';

import '../../common_widgets/info_dialog.dart';
import '../../common_widgets/progress_dialog.dart';

class DialogService {
  Future<void> showErrorDialog({
    required BuildContext context,
    required String error,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return InfoDialog(
          title: "Error",
          content: error,
          confirmButtonTitle: "OK",
          onConfirm: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void showProgressDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ProgressDialog();
      },
    );
  }

  void hideProgressDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
