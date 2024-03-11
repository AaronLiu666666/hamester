import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hamster/file/file_finder.dart';

class FileListWidget extends StatefulWidget {
  @override
  _FileListWidgetState createState() => _FileListWidgetState();
}

class _FileListWidgetState extends State<FileListWidget> {
  late List<File> fileList;

  @override
  void initState() {
    super.initState();
    fileList = [];
    getFileList();
  }

  Future<void> getFileList() async {
    List<File> files = await FileFinder.findVideoFiles();
    setState(() {
      fileList = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fileList.length,
      itemBuilder: (context, index) {
        return Text(
          fileList[index].path,
        );
      },
    );
  }
}
