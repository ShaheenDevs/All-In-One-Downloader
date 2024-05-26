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
      appBar: AppBar(
        title: const Text('Instagram Video Downloader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: viewModel.urlCtrl,
              decoration: const InputDecoration(
                labelText: 'Instagram Video URL',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  viewModel.isBusy ? null : () => viewModel.downloadVideo(),
              child: viewModel.isBusy
                  ? const CircularProgressIndicator()
                  : const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(InstagramViewModel viewModel) {
    viewModel.onViewModelReady();
    super.onViewModelReady(viewModel);
  }

  @override
  InstagramViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      InstagramViewModel();
}
