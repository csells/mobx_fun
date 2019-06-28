import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import '../mobx_provider_consumer.dart';
part 'counter_page.g.dart';

class Counter extends _Counter with _$Counter {}

abstract class _Counter with Store {
  @observable
  int value = 0;
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<Counter>(
        builder: (_, counter) => Scaffold(
              appBar: AppBar(title: Text('MobX Counter')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('You have pushed the button ${counter.value} times')],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => counter.value++,
                tooltip: 'Increment',
                child: Icon(Icons.add),
              ),
            ),
      );
}
