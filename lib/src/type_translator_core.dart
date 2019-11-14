import 'package:type_token/type_token.dart';

class TypeTranslators {
  // ======================================================================== primitive -> int

  static TypeTranslator<int, int> intToIntTranslator = TypeTranslator((input) => input);

  static TypeTranslator<String, int> stringToIntTranslator =
      TypeTranslator((input) => int.tryParse(input) ?? (throw _translationError(String, int)));

  static TypeTranslator<bool, int> boolToIntTranslator = TypeTranslator((input) => input ? 1 : 0);

// ======================================================================== primitive -> bool

  static TypeTranslator<bool, bool> boolToBoolTranslator = TypeTranslator((input) => input);

  static TypeTranslator<String, bool> stringToBoolTranslator = TypeTranslator((input) {
    var sBool = input.toLowerCase();
    return sBool == "true" ? true : sBool == "false" ? false : throw _translationError(String, bool);
  });

  static TypeTranslator<int, bool> intToBoolTranslator =
      TypeTranslator((input) => input == 1 ? true : input == 0 ? false : throw _translationError(int, bool));

// ======================================================================== primitive -> double

  static TypeTranslator<double, double> doubleToDoubleTranslator = TypeTranslator((input) => input);

  static TypeTranslator<String, double> stringToDoubleTranslator =
      TypeTranslator((input) => double.tryParse(input) ?? (throw _translationError(String, double)));

  static TypeTranslator<int, double> intToDoubleTranslator = TypeTranslator((input) => input.toDouble());

// ======================================================================== primitive -> String

  static TypeTranslator<int, String> intToStringTranslator = TypeTranslator((input) => input.toString());

  static TypeTranslator<double, String> doubleToStringTranslator = TypeTranslator((input) => input.toString());

  static TypeTranslator<bool, String> boolToStringTranslator = TypeTranslator((input) => input.toString());

  static TypeTranslator<String, String> stringToStringTranslator = TypeTranslator((input) => input);
}

String _translationErrorToken(TypeToken input, TypeToken expect) {
  return "Occur primitive translation error on ${input.fullTypeName} to ${expect.fullTypeName}";
}

String _translationError(Type input, Type expect) => _translationErrorToken(TypeToken.of(input), TypeToken.of(expect));

// ======================================================================== default translator factory

Map<TypeToken, _TypeTranslatorGroup> _translatorFactory = {
  TypeToken.ofInt(): _TypeTranslatorGroup<int>([
    TypeTranslators.intToIntTranslator,
    TypeTranslators.stringToIntTranslator,
    TypeTranslators.boolToIntTranslator,
  ]),
  TypeToken.ofDouble(): _TypeTranslatorGroup<double>([
    TypeTranslators.doubleToDoubleTranslator,
    TypeTranslators.intToDoubleTranslator,
    TypeTranslators.stringToDoubleTranslator,
  ]),
  TypeToken.ofBool(): _TypeTranslatorGroup<bool>([
    TypeTranslators.boolToBoolTranslator,
    TypeTranslators.intToBoolTranslator,
    TypeTranslators.stringToBoolTranslator,
  ]),
  TypeToken.ofString(): _TypeTranslatorGroup<String>([
    TypeTranslators.boolToStringTranslator,
    TypeTranslators.doubleToStringTranslator,
    TypeTranslators.intToStringTranslator,
    TypeTranslators.stringToStringTranslator,
  ]),
};

void registerPrimitiveTranslatorT<T, R>(TypeTranslator<T, R> translator) {
  TypeToken output = translator.outputType;
  if (!_translatorFactory.containsKey(output)) _translatorFactory[output] = _TypeTranslatorGroup<R>();
  _TypeTranslatorGroup group = _translatorFactory[output];
  group.add(translator);
}

void unregisterPrimitiveTranslatorByType(Type inputType, Type outputType) {
  TypeToken input = TypeToken.of(inputType);
  TypeToken output = TypeToken.of(outputType);
  if (_translatorFactory.containsKey(output)) {
    _TypeTranslatorGroup group = _translatorFactory[output];
    group.removeOnInput(input);
  }
}

void unregisterPrimitiveTranslator<T, R>() => unregisterPrimitiveTranslatorByType(T, R);

dynamic translateToken(dynamic input, TypeToken outputType) {
  if (input == null) return null;
  if (_translatorFactory.containsKey(outputType)) {
    _TypeTranslatorGroup group = _translatorFactory[outputType];
    return group.translate(input);
  }
  throw _translationErrorToken(TypeToken.of(input.runtimeType), outputType);
}

dynamic translate(dynamic input, Type outputType) => translateToken(input, TypeToken.of(outputType));

R translateT<R>(dynamic input) => translate(input, R);

int translateInt(dynamic input) => translateT<int>(input);

double translateDouble(dynamic input) => translateT<double>(input);

bool translateBool(dynamic input) => translateT<bool>(input);

String translateString(dynamic input) => translateT<String>(input);

// ======================================================================== define translator class

class TypeTranslator<T, R> {
  final R Function(T) _translationFunc;
  final TypeToken _inputType;
  final TypeToken _outputType;

  TypeTranslator(this._translationFunc)
      : _inputType = TypeToken.of(T),
        _outputType = TypeToken.of(R);

  TypeTranslator.fromToken(this._inputType, this._outputType, this._translationFunc);

  TypeToken get inputType => _inputType;

  TypeToken get outputType => _outputType;

  R translate(T input) => _translationFunc(input);
}

// ======================================================================== define translator group class

class _TypeTranslatorGroup<R> {
  final TypeToken outputType;
  Map<TypeToken, TypeTranslator> _translators = {};

  _TypeTranslatorGroup([List<TypeTranslator> initTranslators]) : outputType = TypeToken.of(R) {
    if (initTranslators != null) addAll(initTranslators);
  }

  void addT<T>(TypeTranslator<T, R> translator) {
    _translators[TypeToken.of(T)] = translator;
  }

  void add(TypeTranslator translator) {
    TypeToken inputType = translator.inputType;
    TypeToken outputType = translator.outputType;
    if (outputType != TypeToken.of(R)) throw "_TranslatorGroup<$R>.add<$outputType>() type must be same";
    _translators[inputType] = translator;
  }

  void addAll(List<TypeTranslator> translators) => translators.forEach((o) => add(o));

  void removeOnInput(TypeToken type) {
    if (_translators.containsKey(type)) {
      _translators.remove(type);
      print("unregister primitive translator $type -> $R");
    }
  }

  void removeOnInputType(Type type) => this.removeOnInput(TypeToken.of(type));

  R translate(dynamic input) {
    if (input == null) return null;
    TypeToken inputType = TypeToken.of(input.runtimeType);
    if (_translators.containsKey(inputType)) {
      TypeTranslator translator = _translators[inputType];
      return translator.translate(input);
    }
    throw _translationErrorToken(inputType, outputType);
  }
}
