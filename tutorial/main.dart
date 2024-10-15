void main() {
//   mapsMapas();
//   listIterablesSets();
//   functionType();
//   classFuntionA();
//   classFuntionB();
//   classFuntionC();
//   classFuntionD();
//   classFuntionE();
//   abstractClassA();
//   functionMixin();
  functionStreams().listen((value) {
    print('Stream value: $value');
  });
}

Stream<int> functionStreams() {
  return Stream.periodic(const Duration(seconds: 1), (value) {
//     print('desde periodic $value');
    return value;
  }).take(5);
}

functionMixin() {
  final flipper = Delfin();
  flipper.nadar(); // Output: estoy nadando

  final batman = Murcielago();
  batman.volar(); // Output: estoy volando
  batman.caminar(); // Output: estoy caminando

  final garfield = Gato();
  garfield.caminar(); // Output: estoy caminando

  final paloma = Paloma();
  paloma.volar(); // Output: estoy volando
  paloma.caminar(); // Output: estoy caminando

  final pato = Pato();
  pato.volar(); // Output: estoy volando
  pato.caminar(); // Output: estoy caminando
  pato.nadar(); // Output: estoy nadando

  final tiburon = Tiburon();
  tiburon.nadar(); // Output: estoy nadando

  final pezVolador = PezVolador();
  pezVolador.volar(); // Output: estoy volando
  pezVolador.nadar(); // Output: estoy nadando
}

abstract class Animal {}

abstract class Mamifero extends Animal {}

abstract class Ave extends Animal {}

abstract class Pez extends Animal {}

mixin Volador {
  void volar() => print('estoy volando');
}

mixin Caminante {
  void caminar() => print('estoy caminando');
}

mixin Nadador {
  void nadar() => print('estoy nadando');
}

class Delfin extends Mamifero with Nadador {}

class Murcielago extends Mamifero with Volador, Caminante {}

class Gato extends Mamifero with Caminante {}

class Paloma extends Ave with Volador, Caminante {}

class Pato extends Ave with Volador, Caminante, Nadador {}

class Tiburon extends Pez with Nadador {}

class PezVolador extends Pez with Volador, Nadador {}

abstractClassA() {
  final windPlant = WindPlant(initialEnergy: 100);

  print(windPlant);
  print('wind: ${chargePhone(windPlant)}');

  final nuclearPlant = NuclearPlant(energyLeft: 100);
  print('nuclear: ${chargePhone(nuclearPlant)}');
}

double chargePhone(EnergyPlant plant) {
  if (plant.energyLeft < 10) {
    throw Exception('Not enough energy');
  }
  return plant.energyLeft - 10;
}

enum PlantType { nuclear, wind, water }

abstract class EnergyPlant {
  double energyLeft;
  final PlantType type;
  EnergyPlant({required this.energyLeft, required this.type});
  void consumeEnergy(double amount);
}

// extends o implements
class WindPlant extends EnergyPlant {
  WindPlant({required double initialEnergy})
      : super(energyLeft: initialEnergy, type: PlantType.wind);
  @override
  void consumeEnergy(double amount) {
    energyLeft -= amount;
  }
}

class NuclearPlant implements EnergyPlant {
  @override
  double energyLeft;

  @override
  final PlantType type = PlantType.nuclear;

  NuclearPlant({required this.energyLeft});

  @override
  void consumeEnergy(double amount) {
    energyLeft -= (amount * 0.5);
  }
}

classFuntionE() {
  final mySquare = SquareE(side: 10);
  print('areaDa: ${mySquare.area}');
}

class SquareE {
//   assert, son validaciones especificas
  double _side;
  SquareE({required side})
      : assert(side >= 0, 'class::SquareD = side must be side >= 0'),
        _side = side;

  double get area {
    return _side * _side;
  }

  set side(double value) {
    print('setting new value $value');
    if (value < 0) throw 'value must be >=0';

    _side = value;
  }

  double calculateArea() {
    return _side * _side;
  }

  double calculateAreaFlecha() => _side * _side;
}

classFuntionD() {
//   getters and setters
  final mySquare = SquareD(side: 10);
  mySquare.side = 5;
  print('areaDa: ${mySquare.area}');
  print('areaD: ${mySquare.calculateArea()}');
  print('areaDFlecha: ${mySquare.calculateAreaFlecha()}');
}

class SquareD {
  double _side;
  SquareD({required side}) : _side = side;

  double get area {
    return _side * _side;
  }

  set side(double value) {
    print('setting new value $value');
    if (value < 0) throw 'value must be >=0';

    _side = value;
  }

  double calculateArea() {
    return _side * _side;
  }

  double calculateAreaFlecha() => _side * _side;
}

classFuntionC() {
  final mySquare = Square(side: 10);
  print('area: ${mySquare.calculateArea()}');
  print('areaFlecha: ${mySquare.calculateAreaFlecha()}');
}

class Square {
  double side;
  Square({required this.side});
  double calculateArea() {
    return side * side;
  }

  double calculateAreaFlecha() => side * side;
}

classFuntionB() {
  final Map<String, dynamic> rawJson = {
    'name': 'Petter Parker',
    'power': 'arana',
    'isAlive': true
  };
  final iornman = HeroB.fromJson(rawJson);
  print(iornman);

  final HeroB iroman =
      HeroB(name: 'Tiny Strak', power: 'Money', isAlive: false);

  print(iroman);
  print(iroman.name);
  print(iroman.power);
  print(iroman.isAlive);
}

class HeroB {
  String name;
  String power;
  bool isAlive;

  HeroB({required this.name, required this.power, required this.isAlive});

  HeroB.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? 'No name found',
        power = json['power'] ?? 'No power found',
        isAlive = json['isAlive'] ?? 'No isAlive found';

  @override
  String toString() {
    return '$name - $power, isAlive: ${isAlive ? 'YES!' : 'Nope'}';
  }
}

classFuntionA() {
//   primera y segunda forma
//   final Hero wolverin = Hero('Logan', 'Regeneracion');
//  tercera forma
  final HeroA wolverin = HeroA(name: 'Logan', power: 'Regeneracion');

  print(wolverin);
  print(wolverin.name);
  print(wolverin.power);

  final HeroA spiderman = HeroA(name: 'Petter');
  print(spiderman);
  print(spiderman.name);
  print(spiderman.power);
}

class HeroA {
  String name;
  String power;
//   primera forma
//   Hero(String pName, String pPower)
//       : name = pName,
//         power = pPower;

//   segunda forma
//   Hero(this.name, this.power);

//   tercera forma
  HeroA({required this.name, this.power = 'Sin poder'});

  @override
  String toString() {
    return '$name - $power';
  }
}

functionType() {
  print(demoString());
  print(demoStringFlecha());
  print(addSuma(10, 21));
  print(addSumaFlecha(10, 22));
  print(addSumaOptional(10, 23));
  print(addSumaFlechaOptional(10, 24));
  print(addSumaOptionalMoreParams(10, 24, 1));
  print(addSumaFlechaOptionalMoreParams(10, 24, 2));
  print(greetPerson(name: 'Xavier', msg: 'Hola,'));
  print(greetPersonFlecha(name: 'Humberto', msg: 'Hola,'));
}

String greetPersonFlecha({required String name, String msg = 'Hola'}) =>
    '$msg $name';

String greetPerson({required String name, String msg = 'Hola'}) {
  return '$msg $name';
}

int addSumaFlechaOptionalMoreParams(int a, [int b = 0, int c = 0]) => a + b + c;

int addSumaOptionalMoreParams(int a, [int b = 0, int c = 0]) {
  return a + b + c;
}

int addSumaFlechaOptional(int a, [int b = 0]) => a + b;

int addSumaOptional(int a, [int b = 0]) {
  return a + b;
}

int addSumaFlecha(int a, int b) => a + b;

int addSuma(int a, int b) {
  return a + b;
}

String demoStringFlecha() => 'Hola Mundo';

String demoString() {
  return 'Hola Mundo';
}

listIterablesSets() {
  //  List, iterables y Sets
  final numeros = [1, 2, 3, 4, 5, 5, 5, 5, 6, 7, 8, 8, 8, 9];
  print('lista original: $numeros');
  print('length: $numeros.length');
  print('index 0: $numeros[0]');
  print('first: $numeros.first');
  print('last: $numeros.last');
  print('reversed: $numeros.reversed');

  final reversedNumbers = numeros.reversed;
  print('iterables: $reversedNumbers');
  print('list: ${reversedNumbers.toList()}');
  print('set: ${reversedNumbers.toSet()}');

  final numberThanFive = numeros.where((int num) {
    return num > 5;
  });
  print('>5 iterables: $numberThanFive');
  print('>5 set: ${numberThanFive.toSet()}');
}

mapsMapas() {
//   Maps
  final Map<String, Object> pokemon = {
    'name': 'charizard',
    'hp': 100,
    'isAlive': true,
    'abilities': <String>['impostor'],
    'sprite': <int, String>{
      1: 'front/charizard',
      2: 'back/charizard',
    },
  };

  print(pokemon);
  print(pokemon['sprite'].runtimeType);

  if (pokemon['sprite'] is Map<int, String>) {
    final spriteMap = pokemon['sprite'] as Map<int, String>;
    print(spriteMap);
    print(spriteMap[1]);
  }
}
