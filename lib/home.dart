import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController positioncontroller = TextEditingController();

  final CollectionReference myItems =
      FirebaseFirestore.instance.collection("CRUDitems");

  Future<void> create() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialogueBox(
            name: "create operation",
            condition: "create",
            onpressed: () {
              String name = namecontroller.text;
              String position = positioncontroller.text;
              addItems(name, position);
              Navigator.pop(context);
            },
            context: context);
      },
    );
  }

  void addItems(String name, String position) {
    myItems.add({
      "name": name,
      "position": position,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Read Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: myItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: ListTile(
                      title: Text(
                        documentSnapshot['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Text(documentSnapshot['position']),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: create,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Dialog myDialogueBox(
          {required BuildContext context,
          required name,
          required condition,
          required VoidCallback onpressed}) =>
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  const Text(
                    'CREATE operation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              TextField(
                controller: namecontroller,
                decoration: const InputDecoration(
                  hintText: 'Eg: Max',
                  labelText: 'Enter your name',
                ),
              ),
              TextField(
                controller: positioncontroller,
                decoration: const InputDecoration(
                  hintText: 'Eg: developer',
                  labelText: 'Enter your position',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onpressed,
                child: Text(condition),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      );
}
