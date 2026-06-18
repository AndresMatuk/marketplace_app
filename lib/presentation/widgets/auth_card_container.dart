import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';

class AuthCardContainer extends StatelessWidget {
  const AuthCardContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: Responsive.screenPadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.contentMaxWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}
