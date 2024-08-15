import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        //backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
  }

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: Theme.of(context).colorScheme.secondary,
          size: 60,
        ),
      ),
    );
  }
}
