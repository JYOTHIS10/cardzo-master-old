import 'dart:async';
import 'package:Cardzo/DocScanner/Providers/documentProvider.dart';
import 'package:Cardzo/DocScanner/Search.dart';
import 'package:Cardzo/DocScanner//drawer.dart';
import 'package:Cardzo/DocScanner//pdfScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:Cardzo/DocScanner/NewImage.dart';

//Doc Scanner Home page class
class DSHome extends StatefulWidget {
  DSHome({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _DSHomeState createState() => _DSHomeState();
}

class _DSHomeState extends State<DSHome> {
  MethodChannel channel = MethodChannel('opencv');
  File _file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  static GlobalKey<AnimatedListState> animatedListKey =
  GlobalKey<AnimatedListState>();

  //home page widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SafeArea(
        child: Drawer(
           child: DocDrawer(),
      )),
      appBar: AppBar(
        title: Text("Doc Scan"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              showSearch(context: context, delegate: Search());
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () async {
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(

          onPressed: () {},
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.camera),
                iconSize: 35,
                onPressed: () async {
                  chooseImage(ImageSource.camera);
                },
              ),
              Container(
                color: Colors.white.withOpacity(0.2),
                width: 5,
                height: 15,
              ),
              IconButton(
                icon: Icon(Icons.image),
                iconSize: 35,
                onPressed: () async {
                  chooseImage(ImageSource.gallery);
                },
              )
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder(
        future: getAllDocuments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print("has not data");
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            print("error");
            return CircularProgressIndicator();
          }
          return Container(
              height: MediaQuery.of(context).size.height - 81,
              child: AnimatedList(
                key: animatedListKey,
                itemBuilder: (context, index, animation) {
                  if (index ==
                      Provider.of<DocumentProvider>(context)
                              .allDocuments
                              .length -
                          1) {
                    print("last");
                    return SizedBox(height: 100);
                  }
                  return buildDocumentCard(index, animation);
                },
                initialItemCount:
                    Provider.of<DocumentProvider>(context).allDocuments.length,
              )
          );
        },
      ),
    );
  }

  //choose image from gallery or capture image and pass that image to "NewImage.dart" file
  void chooseImage(ImageSource source) async {
    // ignore: deprecated_member_use
    File fileGallery = await ImagePicker.pickImage(source: source);
    if (fileGallery != null) {
      _file = fileGallery;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NewImage(fileGallery, animatedListKey)));
    }
  }

  Future<bool> getAllDocuments() async {
    print("inside get documents");
    return await Provider.of<DocumentProvider>(context, listen: false)
        .getDocuments();
  }

  Future<void> onRefresh() async {
    print("refreshed");
    Provider.of<DocumentProvider>(context, listen: false).getDocuments();
  }

  //widget for user interface of documents.
  Widget buildDocumentCard(int index, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: StatefulBuilder(
        builder: (context, setState) => GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PDFScreen(
                document:
                    Provider.of<DocumentProvider>(context).allDocuments[index],
                    animatedListKey: animatedListKey,
              ),
            ));
          },
          child: Card(
            color: ThemeData.dark().cardColor,
            elevation: 3,
            margin: EdgeInsets.only(left: 12, right: 12, bottom: 5, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 12, top: 12, right: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(color: Colors.grey[300]),
                          right: BorderSide(color: Colors.grey[300]),
                          top: BorderSide(color: Colors.grey[300])),
                    ),
                    child: Image.file(
                      new File(Provider.of<DocumentProvider>(context)
                          .allDocuments[index]
                          .documentPath),
                      height: 150,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                          Container(
                            width: 150,
                            padding: EdgeInsets.all(12),
                            child: Text(
                              Provider.of<DocumentProvider>(context)
                                .allDocuments[index]
                                .name,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                           ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 12),
                            child: Text(
                              Provider.of<DocumentProvider>(context)
                                      .allDocuments[index]
                                      .dateTime
                                      .day
                                      .toString() +
                                  "-" +
                                  Provider.of<DocumentProvider>(context)
                                      .allDocuments[index]
                                      .dateTime
                                      .month
                                      .toString() +
                                  "-" +
                                  Provider.of<DocumentProvider>(context)
                                      .allDocuments[index]
                                      .dateTime
                                      .year
                                      .toString(),
                              style: TextStyle(color: Colors.grey[400]),
                            )),
                      ],
                    )),
                    SizedBox(
                      height: 60,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width - 180,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.share,color: ThemeData.dark().accentColor,),
                                onPressed: () {
                                  shareDocument(Provider.of<DocumentProvider>(
                                          context,
                                          listen: false)
                                      .allDocuments[index]
                                      .pdfPath);
                                }),
                            IconButton(
                              icon: Icon(Icons.cloud_upload,color: ThemeData.dark().accentColor,),
                              onPressed: () {},
                            ),
                            IconButton(
                                icon: Icon(Icons.more_vert,color: ThemeData.dark().accentColor,),
                                onPressed: () {
                                  showModalSheet(
                                      index: index,
                                      filePath: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .documentPath,
                                      dateTime: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .dateTime,
                                      name: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .name,
                                      pdfPath: Provider.of<DocumentProvider>(
                                              context,
                                              listen: false)
                                          .allDocuments[index]
                                          .pdfPath,
                                      favorite: Provider.of<DocumentProvider>(
                                            context,
                                            listen: false)
                                            .allDocuments[index]
                                            .pdfPath);
                                })
                          ],
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //sharing pdf documents
  void shareDocument(String pdfPath) async {
    await FlutterShare.shareFile(title: "pdf", filePath: pdfPath);
  }

  ////when select more_vert icon; more options are: print,delete,rename
  void showModalSheet(
      {int index,
      String filePath,
      String name,
      DateTime dateTime,
      String pdfPath,
      String favorite}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300])),
                      child: Image.file(
                        new File(filePath),
                        height: 80,
                        width: 50,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 150,
                        padding: EdgeInsets.only(left: 12, bottom: 12),
                        child: Text(
                          name,
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            dateTime.day.toString() +
                                "-" +
                                dateTime.month.toString() +
                                "-" +
                                dateTime.year.toString(),
                            style: TextStyle(color: Colors.grey[400]),
                          )),
                    ],
                  )
                ],
              ),
              Divider(
                thickness: 2,
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Rename"),
                onTap: () {
                  Navigator.pop(context);
                  showRenameDialog(
                      index: index, name: name, dateTime: dateTime);
                },
              ),
              ListTile(
                leading: Icon(Icons.print),
                title: Text("Print"),
                onTap: () async {
                  Navigator.pop(context);
                  final pdf = File(pdfPath);
                  await Printing.layoutPdf(
                      onLayout: (_) => pdf.readAsBytesSync());
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete"),
                onTap: () {
                  Navigator.pop(context);
                  showDeleteDialog1(index: index, dateTime: dateTime);
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text("Add to favorites"),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  //for deleting document
  void showDeleteDialog1({int index, DateTime dateTime}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
            Text(
              "Delete file",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(
              thickness: 2,
            ),
            Text(
              "Are you sure you want to delete this file?",
              style: TextStyle(color: Colors.grey[500]),
            )
          ],
        )),
        actions: <Widget>[
          OutlineButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
          OutlineButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              Navigator.of(context).pop();

              Provider.of<DocumentProvider>(context, listen: false)
                  .deleteDocument(
                      index, dateTime.millisecondsSinceEpoch.toString());
              Timer(Duration(milliseconds: 300), () {
                animatedListKey.currentState.removeItem(
                    index,
                    (context, animation) =>
                        buildDocumentCard(index, animation));
              });
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  //for rename the document
  void showRenameDialog({int index, DateTime dateTime, String name}) {
    TextEditingController controller = TextEditingController();
    controller.text = name;
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Text("Rename"),
            TextFormField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                suffix: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                    })),
            ),
        ],
        )),
        actions: <Widget>[
          OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel")),
          OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<DocumentProvider>(context, listen: false)
                    .renameDocument(
                        index,
                        dateTime.millisecondsSinceEpoch.toString(),
                        controller.text);

              },
              child: Text("Rename")),
        ],
      ),
    );
  }
}
