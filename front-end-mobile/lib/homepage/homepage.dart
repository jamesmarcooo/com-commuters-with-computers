import 'package:flutter/widgets.dart';

main() => runApp(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: MyStatelessWidget()),
      ),
    );

class MyStatelessWidget extends StatelessWidget {
  // @override annotation is needed for optimization, by using it
  // we say that we don't need the same method from the parent class
  // so the compiler can drop it
  @override
  Widget build(BuildContext context) {
    // I'll describe [context] later
    return Text('Hello!');
  }
}
