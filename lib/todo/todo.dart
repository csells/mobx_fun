import 'package:mobx/mobx.dart';
import 'package:json_annotation/json_annotation.dart';
part 'todo.g.dart';

// from https://github.com/mobxjs/mobx.dart/issues/147
@JsonSerializable()
class Todo extends _Todo with _$Todo {
  Todo();
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);
}

abstract class _Todo with Store {
  @observable
  String description = '';

  @observable
  bool done = false;
}
