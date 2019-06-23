// simple provider/consumer model for mobx: https://mobx.pub/
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

// TODO: make this keep values between hot reloads?
class Provider<T> extends InheritedWidget {
  final T _value;
  Provider({
    Key key,
    @required T value,
    Widget child,
  })  : _value = value,
        super(key: key, child: child);

  // from https://stackoverflow.com/questions/52891537/how-to-get-generic-type
  // and https://github.com/dart-lang/sdk/issues/11923.
  static Type _typeOf<T>() => T;
  static T of<T>(BuildContext context) =>
      ((context.inheritFromWidgetOfExactType(_typeOf<Provider<T>>())) as Provider<T>)._value;

  @override
  bool updateShouldNotify(Provider<T> oldWidget) => oldWidget._value != _value;
}

typedef ConsumerWidgetBuilder<T> = Widget Function(BuildContext context, T value);

class Consumer<T> extends StatelessWidget {
  final ConsumerWidgetBuilder<T> _builder;
  Consumer({@required ConsumerWidgetBuilder<T> builder}) : _builder = builder;

  static Type _typeOf<T>() => T;

  @override
  Widget build(BuildContext context) => Observer(
        name: _typeOf<T>().toString(),
        builder: (context) => _builder(context, Provider.of<T>(context)),
      );
}

class Prosumer<T> extends StatelessWidget {
  final T _value;
  final ConsumerWidgetBuilder<T> _builder;
  Prosumer(this._value, {@required ConsumerWidgetBuilder<T> builder}) : _builder = builder;

  @override
  Widget build(BuildContext context) =>
      Provider(value: _value, child: Consumer<T>(builder: _builder));
}
