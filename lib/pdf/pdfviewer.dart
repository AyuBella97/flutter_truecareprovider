import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:http/http.dart' as http;

class Pdfviewer1 extends StatefulWidget {
  final String url;
  final String title;

  const Pdfviewer1({Key? key, required this.url, required this.title}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Pdfviewer1> {
  final controller = PdfViewerController();
  // Load from URL

  @override
  void initState() {
    // TODO: implement initState

  }

  late String assetPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: ValueListenableBuilder<Object>(
            // The controller is compatible with ValueListenable<Matrix4> and you can receive notifications on scrolling and zooming of the view.
            valueListenable: controller,
            builder: (context, _, child) => Text(controller.isReady ? '${widget.title} Page #${controller.currentPageNumber}' : 'Page -')
          ),
        ),
        backgroundColor: Colors.grey,
        body: PdfViewer(
          doc: PdfDocument.openAsset(assetPath),
          viewerController: controller,
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(heroTag: 'firstPage', child: Icon(Icons.first_page), onPressed: () => controller.goToPage(pageNumber: 1)),
            FloatingActionButton(heroTag: 'lastPage', child: Icon(Icons.last_page), onPressed: () => controller.goToPage(pageNumber: controller.pageCount)),
          ]
        )
      );
  }
}