# mobx_fun
This project is just me playing around with [mobX for Flutter](https://pub.dev/packages/flutter_mobx). I flipped a run-time setting, implemented a simple provider/consumer and reimplemented some of the samples from [mobx.pub](https://mobx.pub). Mostly this is to see how far I can push the usability of mobx, because in general it's PFM!

## Allowing @observerable properties to mutate
To start, I flip the ReactiveWritePolicy policy when the app is created:

```dart
MyApp() {
  // allow @observable setters to run
  mainContext.config = ReactiveConfig.main.clone(writePolicy: ReactiveWritePolicy.never);
}
```

By default, if something in [the mobx code generator](https://pub.dev/packages/mobx_codegen) sees the setter being called for an @observable, it throws an exception. Honestly, I don't know why that is; purity? I'm not the pure.

By removing this restriction, I can simplify the data types because I no longer need to write setters manually just to mark them as @action. For example, the Todo example class w/ the restriction needs to look like this:

```dart
abstract class _Todo with Store {
  @observable
  String description = '';

  @observable
  bool done = false;

  // ed: this looks like a setter to me...
  @action
  void markDone(bool flag) {
    done = flag;
  }
}
```

By lifting the restriction, I can simply remove this method and others like it:

```dart
abstract class _Todo with Store {
  @observable
  String description = '';

  @observable
  bool done = false;
}
```

Then, in the client code, I can call ```todo.done = true``` instead of ```todo.markDone()```. Methods are great when they do something besides change a property, but otherwise I prefer setters.

## Providers, Consumers and Prosumers, oh my!
Another thing that [the mobx samples](https://mobx.pub/examples/todos) do is pass around data via global variables or as ctor args, neither are best practices. I'm also a big fan of [Provider](https://pub.dev/packages/provider), which allows you to drop a hunk of data into the tree in one spot and grab it from wherever else you want it. In mobx, there is no such facility; instead you drop an Observer into the tree and if you happen to be using an observable, the right thing happens, but it provides no facility for looking up something further up the tree (not that mobx allows you to put anything into the tree anyway...). So, inspired by Provider, I built a simple Provider/Consumer for mobx.

To put something into the tree looks like this:

```dart
class HomePage extends StatelessWidget {
  final todoList = TodoList();

  @override
  Widget build(BuildContext context) => Scaffold(body:
       // add the data into the tree via the Provider
       Provider(value: todoList, child: TodoExample())
    );
  }
}
```

Pulling it back out again happens via the Consumer:

```dart
class Description extends StatelessWidget {
  @override
  // use the Consumer to grab the data out of the tree
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
```

Like Provider, this simple Provider/Consumer implementation uses InheritedWidget, which provides type-based scoping of data, which is why you need to pass the type you want to find in the tree. As part of the builder, you give it a name and use it like any other variable. The magic is that the Consumer drops a mobx Observer into the tree, too, so as you update the data, it keeps the widgets that use it up to date. PFM!

Now, in the case that you want to drop something from a list into the tree and then use it right away, e.g. as you're building a ListView, you may find yourself using a Provider immediate following by a Consumer, e.g.

```dart
ListView.builder(
  itemCount: list.visibleTodos.length,
  // Using Provider + Consumer at the same time manually
  itemBuilder: (_, index) => Provider(
    value: list.visibleTodos[index],
    child: Consumer<Todo>(
        builder: (_, todo) => CheckboxListTile(
              value: todo.done,
              onChanged: (done) => todo.done = done,
              ...
```

Here we're pulling a specific Todo item out of the TodoList using the ListView builder's index, then immediately using it via a Consumer. For this case, I've invented the 'Prosumer':

```dart
ListView.builder(
  itemCount: list.visibleTodos.length,
  // Using Provider + Consumer at the same time automatically
  itemBuilder: (_, index) => Prosumer<Todo>(
      list.visibleTodos[index],
      builder: (_, todo) => CheckboxListTile(
            value: todo.done,
            onChanged: (done) => todo.done = done,
            ...
```

Under the hood, it's just a Provider + a Consumer, but this syntax pulls one level out of the tree you're writing, which always makes me happy...