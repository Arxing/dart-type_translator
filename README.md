![](https://img.shields.io/badge/language-dart-orange.svg)
![](https://img.shields.io/badge/pub-v1.0.3-blue.svg)

`type_translator` can resolve any type that includes primitive and custom class transformation.

## Usage

```dart
import 'package:type_translator/type_translator.dart';
import 'package:type_token/type_token.dart';

main() {
  dynamic input;

  // -> int
  input = "1000";
  print(translateT<int>(input)); // print: 1000
  input = 2000;
  print(translateT<int>(input)); // print: 2000
  input = "apple";
//  print(translateT<int>(input)); // error

  // -> String
  input = 1000;
  print(translateT<String>(input)); // print: "1000"
  input = true;
  print(translateT<String>(input)); // print: "true"
  input = 50.8;
  print(translateT<String>(input)); // print: "50.8"

  // -> double
  input = 1000;
  print(translateT<double>(input)); // print: 1000.0
  input = "10.555";
  print(translateT<double>(input)); // print: 10.555

  // custom translator
  registerPrimitiveTranslatorT(customTranslator);
  input = A();
  print(translateT<int>(input)); // print: 90

  registerPrimitiveTranslatorT(customTranslator2);
  input = 1.55;
  print(translateT<int>(input));

  registerPrimitiveTranslatorT(customTranslator3);
  input = B(999);
  print(translateT<int>(input));
}

class A {}

class B {
  int data;

  B(this.data);
}

TypeTranslator<A, int> get customTranslator => TypeTranslator((input) => 90);

TypeTranslator get customTranslator2 => TypeTranslator.fromToken(TypeToken.ofDouble(), TypeToken.ofInt(), (input) => 10);

TypeTranslator get customTranslator3 => TypeTranslator.fromToken(TypeToken.of(B), TypeToken.ofInt(), (input) => input.data);
```