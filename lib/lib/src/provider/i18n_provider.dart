import 'package:flutter_advance_image_picker/lib/src/entity/options.dart';
import 'package:flutter_advance_image_picker/lib/src/provider/selected_provider.dart';

abstract class I18nProvider {
  const I18nProvider._();

  String getTitleText(Options options);

  String getSureText(Options options, int currentCount);

  String getPreviewText(Options options, SelectedProvider selectedProvider);

  String getSelectedOptionsText(Options options);

  String getMaxTipText(Options options);

  String getAllGalleryText(Options options);

  String loadingText() {
    return "Loading...";
  }

  I18NPermissionProvider getNotPermissionText(Options options);

  static const I18nProvider chinese = CNProvider();

  static const I18nProvider english = ENProvider();
}

class CNProvider extends I18nProvider {
  const CNProvider() : super._();

  @override
  String getTitleText(Options options) {
    return "Select Images";
  }

  @override
  String getPreviewText(Options options, SelectedProvider selectedProvider) {
    return "Preview(${selectedProvider.selectedCount})";
  }

  @override
  String getSureText(Options options, int currentCount) {
    return "Confirm($currentCount/${options.maxSelected})";
  }

  @override
  String getSelectedOptionsText(Options options) {
    return "Select";
  }

  @override
  String getMaxTipText(Options options) {
    return "You have selected ${options.maxSelected} images";
  }

  @override
  String getAllGalleryText(Options options) {
    return "All images";
  }

  @override
  String loadingText() {
    return "Loading ...";
  }

  @override
  I18NPermissionProvider getNotPermissionText(Options options) {
    return I18NPermissionProvider(
        cancelText: "Cancel", sureText: "Open", titleText: "没有访问相册的权限");
  }
}

class ENProvider extends I18nProvider {
  const ENProvider() : super._();

  @override
  String getTitleText(Options options) {
    return "Image Picker";
  }

  @override
  String getPreviewText(Options options, SelectedProvider selectedProvider) {
    return "Preview (${selectedProvider.selectedCount})";
  }

  @override
  String getSureText(Options options, int currentCount) {
    return "Save ($currentCount/${options.maxSelected})";
  }

  @override
  String getSelectedOptionsText(Options options) {
    return "Selected";
  }

  @override
  String getMaxTipText(Options options) {
    return "Select ${options.maxSelected} pictures at most";
  }

  @override
  String getAllGalleryText(Options options) {
    return "Recent";
  }

  @override
  I18NPermissionProvider getNotPermissionText(Options options) {
    return I18NPermissionProvider(
        cancelText: "Cancel",
        sureText: "Allow",
        titleText: "No permission to access gallery");
  }
}

abstract class I18NCustomProvider implements I18nProvider {
  final String maxTipText;
  final String previewText;
  final String selectedOptionsText;
  final String sureText;
  final String titleText;
  final I18NPermissionProvider notPermissionText;

  I18NCustomProvider(
      this.maxTipText,
      this.previewText,
      this.selectedOptionsText,
      this.sureText,
      this.titleText,
      this.notPermissionText);

  @override
  String getMaxTipText(Options options) {
    return maxTipText;
  }

  @override
  String getSelectedOptionsText(Options options) {
    return selectedOptionsText;
  }

  @override
  String getTitleText(Options options) {
    return titleText;
  }

  @override
  I18NPermissionProvider getNotPermissionText(Options options) {
    return notPermissionText;
  }
}

class I18NPermissionProvider {
  final String titleText;
  final String sureText;
  final String cancelText;

  const I18NPermissionProvider(
      {this.titleText, this.sureText, this.cancelText});
}
