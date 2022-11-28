import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String input = "";
  List todo = [];
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void createTodo(String todo, String user) async {
    await FirebaseFirestore.instance.collection('todo').add({
      'item': todo,
      'user': user,
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  Future<void> updateData(String todo, String user) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('todo')
          .where('item', isEqualTo: todo)
          .where('user', isEqualTo: user)
          .get();
      QueryDocumentSnapshot queryDocumentSnapshot = querySnapshot.docs[0];
      DocumentReference documentReference = queryDocumentSnapshot.reference;
      await documentReference.update({
        'item': todo,
      }).then((value) {
        Fluttertoast.showToast(msg: 'List successfully updated.');
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-do List'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: const Text('Add a to-do list'),
                  content: TextField(
                    onChanged: (String value) {
                      input = value;
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          createTodo(input, currentUser!.email.toString());
                          Navigator.of(context).pop();
                        },
                        child: const Text('ADD'))
                  ],
                );
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('todo')
              .where('user', isEqualTo: currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text('No items.'));
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.hasError.toString()));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              );
            }
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshot.data!.docs[index];
                  return Dismissible(
                      key: Key(index.toString()),
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          title: Text(documentSnapshot['item']),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: (() async {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    Widget cancelButton = TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                    Widget continueButton = TextButton(
                                      child: const Text(
                                        "Continue",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .runTransaction(
                                                (transaction) async =>
                                                    transaction.delete(snapshot
                                                        .data!
                                                        .docs[index]
                                                        .reference))
                                            .then((value) =>
                                                Navigator.of(context).pop());
                                      },
                                    );
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      content: Text(
                                          'Confirm to delete the item? \n\n$input'),
                                      actions: [
                                        cancelButton,
                                        continueButton,
                                      ],
                                    );
                                  });
                            }),
                          ),
                          onTap: () {
                            FirebaseFirestore.instance
                                .collection('todo')
                                .where('item', isEqualTo: input)
                                .where('user',
                                    isEqualTo: currentUser!.email.toString())
                                .get()
                                .then((value) {
                              textEditingController.text =
                                  documentSnapshot['item'];
                            });

                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    title: const Text('Update the to-do list'),
                                    content: TextFormField(
                                      onChanged: (newValue) {
                                        input = newValue;
                                      },
                                      controller: textEditingController,
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            DocumentReference
                                                documentReference =
                                                documentSnapshot.reference;
                                            documentReference.update({
                                              'item': input,
                                            }).then((value) {
                                              Fluttertoast.showToast(
                                                  msg: 'Update success.');
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          child: const Text('Update'))
                                    ],
                                  );
                                });
                          },
                        ),
                      ));
                });
          }),
    );
  }
}
