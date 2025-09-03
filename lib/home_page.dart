import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore? firebaseFirestore;
  @override
  void initState() {
    super.initState();
    firebaseFirestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: StreamBuilder(
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
                      return Card(
                        child: ListTile(
                          title: Text(note['title']),
                          subtitle: Text(note['description']),
                        ),
                      );
                    },
                  )
                : Center(child: Text('No notes found'));
          }
          return SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await firebaseFirestore!.collection("notes").add({
            "title": "My 3rd notes",
            "description": "This note is generated from flutter",
          });
          //setState(() {});
          //print(docRef.id);
          if (!context.mounted) {
            return; // ✅ ensures widget is still alive if (!context.mounted) return; // ✅ ensures widget is still alive
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Note added Sucefully')));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
