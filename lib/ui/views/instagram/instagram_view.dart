import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'instagram_viewmodel.dart';

class InstagramView extends StackedView<InstagramViewModel> {
  const InstagramView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    InstagramViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      ),
    );
  }

  @override
  InstagramViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      InstagramViewModel();
}
