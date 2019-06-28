import 'dart:convert';
import 'dart:io';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'mobx_provider_consumer.dart';
import 'counter/counter_page.dart';
import 'todo/todo_list.dart';
import 'todo/todo_widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'MobX',
        theme: ThemeData(primarySwatch: Colors.red),
        home: HomePage(),
      );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final counter = Observable<int>(0);
  final todoList = TodoList();

  Future<File> get _jsonFile async {
    var directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/todos.json');
  }

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // load TodoList from disk
  void _loadTodos() async {
    var file = await _jsonFile;
    if (!await file.exists()) return;

    try {
      var json = await file.readAsString();
      todoList.todos = ObservableList_Todo.fromJson(jsonDecode(json));
    } catch (err) {
      print('couldn\'t load from file ${file.path}: $err');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _saveTodos();
  }

  // save TodoList to disk
  void _saveTodos() async {
    var file = await _jsonFile;
    try {
      var json = jsonEncode(todoList.todos);
      await file.writeAsString(json);
    } catch (err) {
      print('couldn\'t save to file ${file.path}: $err');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('MobX Fun')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonNavigator(
                  name: 'Counter', builder: (_) => Provider(value: counter, child: CounterPage())),
              ButtonNavigator(
                  name: 'Todo', builder: (_) => Provider(value: todoList, child: TodoExample())),
            ],
          ),
        ),
      );
}

class ButtonNavigator extends StatelessWidget {
  final String name;
  final WidgetBuilder builder;

  const ButtonNavigator({
    @required this.name,
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) => RaisedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: builder)),
        child: Text(name),
      );
}
