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
  final TextEditingController searchcontroller = TextEditingController();

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

  Future<void> update(DocumentSnapshot documentsnapshot) async {
    namecontroller.text = documentsnapshot['name'];
    positioncontroller.text = documentsnapshot['position'];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialogueBox(
            name: "update your data",
            condition: "Update",
            onpressed: () async {
              String name = namecontroller.text;
              String position = positioncontroller.text;
              // addItems(name, position);
              await myItems.doc(documentsnapshot.id).update({
                "name": name,
                "position": position,
              });
              namecontroller.text = '';
              positioncontroller.text = '';
              Navigator.pop(context);
            },
            context: context);
      },
    );
  }

  Future<void> delete(String productId) async {
    await myItems.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Deleted Successfully"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  String searchText = '';
  void onSearchChange(String value) {
    setState(() {
      searchText = value;
    });
  }

  bool isSearchClick = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        centerTitle: true,
        title: isSearchClick
            ? Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onChanged: onSearchChange,
                  controller: searchcontroller,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                    hintText: "Search...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                ),
              )
            : const Text(
                'Firestore CRUD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isSearchClick = !isSearchClick;
                });
              },
              icon: Icon(
                isSearchClick ? Icons.close : Icons.search,
                color: Colors.blue,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: myItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final List<DocumentSnapshot> items = streamSnapshot.data!.docs
                .where((doc) => doc['name']
                    .toLowerCase()
                    .contains(searchText.toLowerCase()))
                .toList();
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = items[index];
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
                      subtitle: Text(
                        documentSnapshot['position'],
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => update(documentSnapshot),
                              icon: const Icon(
                                  Icons.edit), //yo edit wala ho haii dost
                            ),
                            IconButton(
                              onPressed: () => delete(documentSnapshot.id),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ), //yo edit wala ho haii dost
                            ),
                          ],
                        ),
                      ),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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
