import 'package:flutter/material.dart';
import 'package:mobx_fun/todo/todo.dart';
import '../mobx_provider_consumer.dart';
import 'todo_list.dart';

class TodoExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Column(children: [AddTodo(), ActionBar(), Description(), TodoListView()]));
}

class Description extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<TodoList>(
        builder: (_, list) => Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                list.itemsDescription,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
      );
}

class TodoListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<TodoList>(
        builder: (_, list) => Flexible(
              child: ListView.builder(
                itemCount: list.visibleTodos.length,
                itemBuilder: (_, index) => Prosumer<Todo>(
                      list.visibleTodos[index],
                      builder: (_, todo) => CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: todo.done,
                            onChanged: (done) => todo.done = done,
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    todo.description,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => list.todos.remove(todo),
                                ),
                              ],
                            ),
                          ),
                    ),
              ),
            ),
      );
}

class ActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<TodoList>(
        builder: (_, list) => Column(
              children: [
                Column(
                  children: [
                    RadioListTile(
                        dense: true,
                        title: Text('All'),
                        value: VisibilityFilter.all,
                        groupValue: list.filter,
                        onChanged: (filter) => list.filter = filter),
                    RadioListTile(
                        dense: true,
                        title: Text('Pending'),
                        value: VisibilityFilter.pending,
                        groupValue: list.filter,
                        onChanged: (filter) => list.filter = filter),
                    RadioListTile(
                        dense: true,
                        title: Text('Completed'),
                        value: VisibilityFilter.completed,
                        groupValue: list.filter,
                        onChanged: (filter) => list.filter = filter),
                  ],
                ),
                ButtonBar(
                  children: [
                    RaisedButton(
                      child: Text('Remove Completed'),
                      onPressed: list.canRemoveAllCompleted ? list.removeCompleted : null,
                    ),
                    RaisedButton(
                      child: Text('Mark All Completed'),
                      onPressed: list.canMarkAllCompleted ? list.markAllAsCompleted : null,
                    ),
                  ],
                ),
              ],
            ),
      );
}

class AddTodo extends StatelessWidget {
  final _textController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) => Consumer<TodoList>(
        builder: (_, list) => TextField(
              autofocus: true,
              decoration:
                  InputDecoration(labelText: 'Add a Todo', contentPadding: EdgeInsets.all(8)),
              controller: _textController,
              onSubmitted: (value) {
                list.todos.add(Todo()..description = _textController.text);
                _textController.clear();
              },
            ),
      );
}
