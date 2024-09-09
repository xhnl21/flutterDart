class Global {
  final String? type;
  final int? number;
  Global({
      this.type,
      this.number,
  });
  static Map<String, int> getTypesPokemonSelectedColor(String type) {
    if (type == "grass") {
      return {'A':255, 'R':157, 'G':208, 'B':145};
    } else if (type == "poison") {
      return {'A':255, 'R':200, 'G':158, 'B':229};
    } else if (type == "fire") {
      return {'A':255, 'R':242, 'G':144, 'B':145};
    } else if (type == "flying") {
      return {'A':255, 'R':192, 'G':220, 'B':247};
    } else if (type == "water") {
      return {'A':255, 'R':145, 'G':191, 'B':247};
    } else if (type == "bug") {
      return {'A':255, 'R':200, 'G':208, 'B':136};
    } else if (type == "normal") {
      return {'A':255, 'R':207, 'G':207, 'B':207};
    } else if (type == "ground") {
      return {'A':255, 'R':200, 'G':167, 'B':140};
    } else if (type == "electric") {
      return {'A':255, 'R':252, 'G':223, 'B':127};
    } else if (type == "fairy") {
      return {'A':255, 'R':246, 'G':183, 'B':247};
    } else if (type == "fighting") {
      return {'A':255, 'R':255, 'G':191, 'B':127};
    } else if (type == "psychic") {
      return {'A':255, 'R':246, 'G':158, 'B':188};
    } else if (type == "rock") {
      return {'A':255, 'R':215, 'G':212, 'B':192};
    } else if (type == "ice") {
      return {'A':255, 'R':157, 'G':235, 'B':255};
    } else if (type == "ghost") {
      return {'A':255, 'R':183, 'G':158, 'B':183};
    } else if (type == "dragon") {
      return {'A':255, 'R':166, 'G':175, 'B':240};
    } else if (type == "steel") {
      return {'A':255, 'R':175, 'G':208, 'B':219};
    }  else if (type == "dark") {
      return {'A':255, 'R':158, 'G':158, 'B':157};
    } else {
      return {'A':255, 'R':85, 'G':34, 'B':119};
    }
  }

  static String numberPokemon([int number = 0]) {
    if (number < 10) {
      return '00000$number';
      // 0001
    } else if (number < 100) {
      return '0000$number';
      // 0010
    } else if (number < 1000) {
      return '00$number';
      // 0100
    } else if (number < 10000) {
      return '0$number';
      // 0100
    } else if (number < 100000) {
      return '$number';
      // 0100
    } else {
      return '00000';
    }
  }
}