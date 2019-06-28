import 'package:mobx/mobx.dart';
import 'package:json_annotation/json_annotation.dart';
import 'todo.dart';
part 'todo_list.g.dart';

enum VisibilityFilter { all, pending, completed }

// from https://github.com/mobxjs/mobx.dart/issues/147
@JsonSerializable()
class TodoList extends _TodoList with _$TodoList {
  TodoList();
  factory TodoList.fromJson(Map<String, dynamic> json) => _$TodoListFromJson(json);
  Map<String, dynamic> toJson() => _$TodoListToJson(this);
}

// ignore: camel_case_types
class ObservableList_Todo extends ObservableList<Todo> {
  ObservableList_Todo();
  factory ObservableList_Todo.fromJson(List<dynamic> json) =>
      ObservableList_Todo()..addAll(json.map((t) => Todo.fromJson(t)));
  List<dynamic> toJson() => map((t) => t.toJson()).toList();
}

abstract class _TodoList with Store {
  @observable
  ObservableList_Todo todos = ObservableList_Todo();

  @observable
  Todo editing; // the Todo item currently being edited

  @observable
  VisibilityFilter filter = VisibilityFilter.all;

  @computed
  ObservableList<Todo> get pendingTodos =>
      ObservableList.of(todos.where((todo) => todo.done != true));

  @computed
  ObservableList<Todo> get completedTodos =>
      ObservableList.of(todos.where((todo) => todo.done == true));

  @computed
  bool get hasCompletedTodos => completedTodos.isNotEmpty;

  @computed
  bool get hasPendingTodos => pendingTodos.isNotEmpty;

  @computed
  String get itemsDescription {
    if (todos.isEmpty) {
      return "There are no Todos here. Why don't you add one?.";
    }

    final suffix = pendingTodos.length == 1 ? 'todo' : 'todos';
    return '${pendingTodos.length} pending $suffix, ${completedTodos.length} completed';
  }

  @computed
  ObservableList<Todo> get visibleTodos {
    switch (filter) {
      case VisibilityFilter.pending:
        return pendingTodos;
      case VisibilityFilter.completed:
        return completedTodos;
      default:
        return todos;
    }
  }

  @computed
  bool get canRemoveAllCompleted => hasCompletedTodos && filter != VisibilityFilter.pending;

  @computed
  bool get canMarkAllCompleted => hasPendingTodos && filter != VisibilityFilter.completed;

  @action
  void removeCompleted() => todos.removeWhere((todo) => todo.done);

  @action
  void markAllAsCompleted() => todos.forEach((todo) => todo.done = true);
}
