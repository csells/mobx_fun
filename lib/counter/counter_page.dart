import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import '../mobx_provider_consumer.dart';

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<Observable<int>>(
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
