import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  FirebaseFirestore? firebaseFirestore;
  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  DateFormat df = DateFormat('dd-MM-yyyy hh:mm a');
  @override
  void initState() {
    super.initState();
    firebaseFirestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            SearchBar(
              controller: searchController,
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 11),
              ),
              leading: Icon(Icons.search),
              trailing: [
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () async {
                      searchController.clear();
                    },
                  ),
              ],
              onChanged: (value) async {},
            ),
            SizedBox(height: 11),
            Expanded(
              child: StreamBuilder(
                stream: firebaseFirestore!.collection("notes").snapshots(),
                /*
              FutureBuilder(
                future: firebaseFirestore!.collection("notes").get(),
              */
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Something went wrong ${snapshot.error}'),
                    );
                  }

                  if (snapshot.hasData) {
                    return snapshot.data!.docs.isNotEmpty
                        ? ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              var note = snapshot.data!.docs[index].data();
                              String id = snapshot.data!.docs[index].id;
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    note['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(note['description']),
                                      Text(
                                        df.format(
                                          DateTime.fromMicrosecondsSinceEpoch(
                                            int.parse(note['createdAt']),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext buildContext) {
                                          return deleteModalUI(
                                            buildContext,
                                            id: id,
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                  onTap: () {
                                    //print('note===> $note $id');
                                    titleController.text = note['title'];
                                    descriptionController.text =
                                        note['description'];
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true, // 👈 Important!
                                      //Returns the widget you want to display inside the bottom sheet.
                                      builder: (BuildContext buildcontext) =>
                                          bottomSheetUI(
                                            buildcontext,
                                            isUpdate: true,
                                            id: id,
                                          ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        : Center(child: Text('No notes found'));
                  }
                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // 👈 Important!
            //Returns the widget you want to display inside the bottom sheet.
            builder: (BuildContext buildcontext) =>
                bottomSheetUI(buildcontext, isUpdate: false),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget bottomSheetUI(
    BuildContext context, {
    bool isUpdate = false,
    String id = '',
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 11,
          bottom: 11 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Text(
              isUpdate ? 'Update notes' : 'Add new notes',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 11),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                labelText: 'Title',
                hintText: 'Enter note title',
              ),
            ),
            SizedBox(height: 11),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                labelText: 'Description',
                hintText: 'Enter note desc',
              ),
            ),
            SizedBox(height: 11),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    if (isUpdate) {
                      await firebaseFirestore!
                          .collection("notes")
                          .doc(id)
                          .update({
                            "title": titleController.text.trim(),
                            "description": descriptionController.text.trim(),
                          });
                    } else {
                      await firebaseFirestore!.collection("notes").add({
                        "title": titleController.text.trim(),
                        "description": descriptionController.text.trim(),
                        "createdAt": DateTime.now().millisecondsSinceEpoch
                            .toString(),
                      });
                      //setState(() {});
                      //print(docRef.id);
                      if (!context.mounted) {
                        return; // ✅ ensures widget is still alive if (!context.mounted) return; // ✅ ensures widget is still alive
                      }

                      Navigator.pop(context);
                      titleController.clear();
                      descriptionController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Note added Sucefully')),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
                SizedBox(width: 11),
                OutlinedButton(
                  onPressed: () {
                    titleController.clear();
                    descriptionController.clear();
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  deleteModalUI(BuildContext buildContext, {required String id}) {
    return Container(
      padding: EdgeInsets.all(11),
      height: 140,
      child: Column(
        children: [
          Text(
            'Are you sure you ant to delete',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () async {
                  await firebaseFirestore!.collection("notes").doc(id).delete();
                  if (!context.mounted) {
                    return; // ✅ ensures widget is still alive if (!context.mounted) return; // ✅ ensures widget is still alive
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: Text('Yes'),
              ),
              SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
