String _translationError(Type input, Type expect) => "Occur primitive translation error on $input to $expect";

// ======================================================================== primitive -> int

TypeTranslator<int, int> _intToIntTranslator = TypeTranslator((input) => input);

TypeTranslator<String, int> _stringToIntTranslator =
    TypeTranslator((input) => int.tryParse(input) ?? (throw _translationError(String, int)));

TypeTranslator<bool, int> _boolToIntTranslator = TypeTranslator((input) => input ? 1 : 0);

// ======================================================================== primitive -> bool

TypeTranslator<bool, bool> _boolToBoolTranslator = TypeTranslator((input) => input);

TypeTranslator<String, bool> _stringToBoolTranslator = TypeTranslator((input) {
  var sBool = input.toLowerCase();
  return sBool == "true" ? true : sBool == "false" ? false : throw _translationError(String, bool);
});

TypeTranslator<int, bool> _intToBoolTranslator =
    TypeTranslator((input) => input == 1 ? true : input == 0 ? false : throw _translationError(int, bool));

// ======================================================================== primitive -> double

TypeTranslator<double, double> _doubleToDoubleTranslator = TypeTranslator((input) => input);

TypeTranslator<String, double> _stringToDoubleTranslator =
    TypeTranslator((input) => double.tryParse(input) ?? (throw _translationError(String, double)));

TypeTranslator<int, double> _intToDoubleTranslator = TypeTranslator((input) => input.toDouble());

// ======================================================================== primitive -> String

TypeTranslator<int, String> _intToStringTranslator = TypeTranslator((input) => input.toString());

TypeTranslator<double, String> _doubleToStringTranslator = TypeTranslator((input) => input.toString());

TypeTranslator<bool, String> _boolToStringTranslator = TypeTranslator((input) => input.toString());

TypeTranslator<String, String> _stringToStringTranslator = TypeTranslator((input) => input);

// ======================================================================== default translator factory

Map<Type, _TypeTranslatorGroup> _translatorFactory = {
  int: _TypeTranslatorGroup<int>([
    _intToIntTranslator,
    _stringToIntTranslator,
    _boolToIntTranslator,
  ]),
  double: _TypeTranslatorGroup<double>([
    _doubleToDoubleTranslator,
    _intToDoubleTranslator,
    _stringToDoubleTranslator,
  ]),
  bool: _TypeTranslatorGroup<bool>([
    _boolToBoolTranslator,
    _intToBoolTranslator,
    _stringToBoolTranslator,
  ]),
  String: _TypeTranslatorGroup<String>([
    _boolToStringTranslator,
    _doubleToStringTranslator,
    _intToStringTranslator,
    _stringToStringTranslator,
  ]),
};

void registerPrimitiveTranslatorT<T, R>(TypeTranslator<T, R> translator) {
  if (!_translatorFactory.containsKey(R)) _translatorFactory[R] = _TypeTranslatorGroup<R>();
  _TypeTranslatorGroup group = _translatorFactory[R];
  group.addT<T>(translator);
}

void unregisterPrimitiveTranslatorByType(Type input, Type output) {
  if (_translatorFactory.containsKey(output)) {
    _TypeTranslatorGroup group = _translatorFactory[output];
    group.removeOnInput(input);
  }
}

void unregisterPrimitiveTranslator<T, R>() => unregisterPrimitiveTranslatorByType(T, R);

dynamic translate(dynamic input, Type outputType) {
  if (input == null) return null;
  if (_translatorFactory.containsKey(outputType)) {
    _TypeTranslatorGroup group = _translatorFactory[outputType];
    return group.translate(input);
  }
  throw _translationError(input.runtimeType, outputType);
}

R translateT<R>(dynamic input) => translate(input, R);

int translateInt(dynamic input) => translateT<int>(input);

double translateDouble(dynamic input) => translateT<double>(input);

bool translateBool(dynamic input) => translateT<bool>(input);

String translateString(dynamic input) => translateT<String>(input);

// ======================================================================== define translator class

class TypeTranslator<T, R> {
  final R Function(T) _translationFunc;

  TypeTranslator(this._translationFunc);

  Type get inputType => T;

  Type get outputType => R;

  R translate(T input) => _translationFunc(input);
}

// ======================================================================== define translator group class

class _TypeTranslatorGroup<R> {
  final Type outputType;
  Map<Type, TypeTranslator> _translators = {};

  _TypeTranslatorGroup([List<TypeTranslator> initTranslators]) : outputType = R {
    addAll(initTranslators);
  }

  void addT<T>(TypeTranslator<T, R> translator) {
    _translators[T] = translator;
  }

  void add(TypeTranslator translator) {
    Type inputType = translator.inputType;
    Type outputType = translator.outputType;
    if (outputType != R) throw "_TranslatorGroup<$R>.add<$outputType>() type must be same";
    _translators[inputType] = translator;
  }

  void addAll(List<TypeTranslator> translators) => translators.forEach((o) => add(o));

  void removeOnInput(Type type) {
    if (_translators.containsKey(type)) {
      _translators.remove(type);
      print("unregister primitive translator $type -> $R");
    }
  }

  R translate(dynamic input) {
    Type inputType = input.runtimeType;
    if (_translators.containsKey(inputType)) {
      TypeTranslator translator = _translators[inputType];
      return translator.translate(input);
    }
    throw _translationError(inputType, outputType);
  }
}
