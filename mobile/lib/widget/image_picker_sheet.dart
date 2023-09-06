import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 图片选择器sheet
* @author wuxubaiyang
* @Time 2023/8/16 16:36
*/
class ImagePickerSheet extends StatefulWidget {
  // 是否只展示相册选择
  final bool onlyGallery;

  const ImagePickerSheet({
    super.key,
    this.onlyGallery = false,
  });

  static Future<File?> show(BuildContext context, {bool onlyGallery = false}) {
    return showModalBottomSheet<File>(
      context: context,
      showDragHandle: false,
      builder: (_) {
        return ImagePickerSheet(
          onlyGallery: onlyGallery,
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _ImagePickerSheetState();
}

/*
* 图片选择器sheet-状态
* @author wuxubaiyang
* @Time 2023/8/16 16:37
*/
class _ImagePickerSheetState extends State<ImagePickerSheet> {
  // 图片选择器
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        if (!widget.onlyGallery)
          ListTile(
            title: const Text('拍照'),
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ListTile(
          title: const Text('从相册中选择'),
          onTap: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  // 跳转选择图片
  Future<void> _pickImage(ImageSource source) async {
    final result = await picker.pickImage(source: source);
    if (result == null) return router.pop();
    router.pop(File(result.path));
  }
}
