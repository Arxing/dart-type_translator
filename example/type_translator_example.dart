import 'package:type_translator/type_translator.dart';

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
}

class A {}

TypeTranslator<A, int> get customTranslator => TypeTranslator((input) => 90);
