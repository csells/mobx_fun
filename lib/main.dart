import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'mobx_provider_consumer.dart';
import 'counter/counter_page.dart';
import 'todo/todo_list.dart';
import 'todo/todo_widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    // allow @observable setters to run
    mainContext.config = ReactiveConfig.main.clone(writePolicy: ReactiveWritePolicy.never);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'MobX',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomePage(),
      );
}

class HomePage extends StatelessWidget {
  final counter = Observable(0);
  final todoList = TodoList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
