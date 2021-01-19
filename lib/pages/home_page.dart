import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manager_task_example/services/authentication_service.dart';
import 'customcard.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;

  @override
  initState() {
    taskTitleInputController = new TextEditingController();
    taskDescripInputController = new TextEditingController();
    super.initState();
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          children: <Widget>[
            Text("Please fill all fields to create a new task"),
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: 'Task Title*'),
                controller: taskTitleInputController,
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: 'Task Description'),
                controller: taskDescripInputController,
              ),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                taskTitleInputController.clear();
                taskDescripInputController.clear();
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Add'),
              onPressed: () {
                if (taskDescripInputController.text.isNotEmpty &&
                    taskTitleInputController.text.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('tasks')
                      .add({
                    "title": taskTitleInputController.text,
                    "description": taskDescripInputController.text
                  })
                      .then((result) => {
                    Navigator.pop(context),
                    taskTitleInputController.clear(),
                    taskDescripInputController.clear(),
                  })
                      .catchError((err) => print(err));
                }
              })

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toString()),
      ),
      body: Center(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tasks')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return new ListView(
                      children: snapshot.data.docs
                          .map((DocumentSnapshot document) {
                        return new CustomCard(
                          title: document['title'],
                          description: document['description'],
                        );
                      }).toList(),
                    );
                }
              },
            )),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        tooltip: 'Add',
        child: Icon(Icons.add),

      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple[400],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthenticationService>().signOut();
                })
          ],
        ),
      ),


    );

  }

}
