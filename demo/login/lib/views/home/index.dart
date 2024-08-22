// ignore_for_file: file_names, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:login/infrastructure/models/all_pokemon.dart';
import 'package:login/infrastructure/models/pokemon.dart';
import 'package:login/infrastructure/models/type_pokemon.dart';
import 'package:login/views/index.dart';
// import 'package:login/componets/btnNavBar/index.dart';
// import 'package:login/views/index.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.person_off, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Pokemon? pokemon;
  AllPokemon? allPokemon;
  int pokemonId = 0;
  final List<Map<String, dynamic>> masterDetails = [];
  int counst = 0;
  
  @override
  void initState() {
    super.initState();
    // getPokemon();
    get();
  }

  Future<void> modal(BuildContext context) {
    String title = 'Delete Data';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: const Text("demo"),
        );
      },
    );
  }  

  Future<void> getPokemon() async {
      pokemonId++;
      String url = 'https://pokeapi.co/api/v2/pokemon/$pokemonId';
      final response = await Dio().get(url);      
      pokemon = Pokemon.fromJson(response.data);
      setState(() {});
  }
 
  Future<int> getAllResques() async {
      String url = 'https://pokeapi.co/api/v2/pokemon/';
      final res = await Dio().get(url);
      return res.data['count']; 
  }
  Future getDetailsResques(String url) async {
      if (url != '') {
        final res = await Dio().get(url);
        return res.data;
      } else {
        return [];
      }
  }  
  Future<void> get() async {
    int count = await getAllResques();
    // counst = count;
    // counst = 1020;
    counst = 150;
    if (count > 0) {
        String url = 'https://pokeapi.co/api/v2/pokemon?limit=$counst';
        // String url = 'https://pokeapi.co/api/v2/pokemon?limit=$count';
        final res = await Dio().get(url);
        allPokemon = AllPokemon.fromJson(res.data);
        var data = allPokemon!.results;
        for (var poke in data) {
          var detail = await getDetailsResques(poke.url);
          var types = await typesPokemon(detail['types'], poke.name);
          masterDetails.add(
            {'name': poke.name, 'url': poke.url, 'detail': detail, 'types': types},
          );
          setState(() {});
        }
    }    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('Home'),
      // ),
      body: 
      SafeArea(
        child:
          LisViewWidget(masterDetails: masterDetails, counst: counst),
        ),
      // Center(
      //   child: ListView(
      //       children: [
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               Text(pokemon?.name ?? 'No data'),
      //               if (pokemon != null)
      //               ...[
      //                 Image.network(pokemon!.sprites.frontDefault),
      //                 Image.network(pokemon!.sprites.backDefault),                      
      //                 Image.network(pokemon!.sprites.frontShiny),
      //                 Image.network(pokemon!.sprites.backShiny),
      //                 Image.network(pokemon!.sprites.other!.showdown.frontDefault),
      //                 Image.network(pokemon!.sprites.other!.showdown.backDefault),
      //                 Image.network(pokemon!.sprites.other!.showdown.frontShiny),
      //                 Image.network(pokemon!.sprites.other!.showdown.backShiny),                 
      //               ],
      //             ],
      //           ),
      //           Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               Text(pokemon?.name ?? 'No data'),
      //               if (pokemon != null)
      //               ...[
      //                 Image.network(pokemon!.sprites.frontDefault),
      //                 Image.network(pokemon!.sprites.backDefault),                      
      //                 Image.network(pokemon!.sprites.frontShiny),
      //                 Image.network(pokemon!.sprites.backShiny),
      //                 Image.network(pokemon!.sprites.other!.showdown.frontDefault),
      //                 Image.network(pokemon!.sprites.other!.showdown.backDefault),
      //                 Image.network(pokemon!.sprites.other!.showdown.frontShiny),
      //                 Image.network(pokemon!.sprites.other!.showdown.backShiny),                 
      //               ],
      //               ElevatedButton(
      //                 onPressed: () => context.go('/NewPageA'),
      //                 // onPressed: () => context.push('/NewPageA'),
      //                 child: const Text('NewPageA'),
      //               ),
      //               ElevatedButton(
      //                 onPressed: () => context.go('/NewPageB'),
      //                 // onPressed: () => context.push('/NewPageB'),
      //                 child: const Text('NewPageB'),
      //               ),
      //             ],
      //           ),
      //         ],
      //       )
      //   ),
      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.navigate_next),
      //   onPressed: () {
      //     getPokemon();
      //   },
      // ),
    );
  }
}

class LisViewWidget extends StatelessWidget {
  const LisViewWidget({
    super.key,
    required this.masterDetails,
    required this.counst,
  });

  final List<Map<String, dynamic>> masterDetails;
  final int counst;

  @override
  Widget build(BuildContext context) {
    if (counst == masterDetails.length) {
      return ListView.builder(
        itemCount: masterDetails.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final card = masterDetails[index];
          Color pokemonColor = getColorFromType(card['types'][0]['name']);
          return Card(
            color: pokemonColor,
            margin: const EdgeInsets.all(15),
            elevation: 10,
            child: CardWidgetCustoms(card: card),
          );
        }                
      );
    } else {
      // _HomeScreenState().modal(context);
      return const Center(
        child: CircularProgressIndicator(),
      );   
    }
  }
}

class CardWidgetCustoms extends StatelessWidget {
  const CardWidgetCustoms({
    super.key,
    required this.card,
  });
  final Map<String, dynamic> card;
  @override
  Widget build(BuildContext context) {
    var data = Pokemon.fromJson(card['detail']);
    var img = data.sprites?.other?.showdown?.frontDefault;   
    var id = numberPokemon(data.id);
    var types = card["types"];
    var background= card['types'][0]['name'];
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            ImgContent(img: img, background:background),
            Column(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.start,
              children:<Widget>[                            
                Text(card['name'], textAlign: TextAlign.left),
                Text(id, textAlign: TextAlign.left)
              ]
            ),
            ImgContentType(types, card['name']),
          ],
        ),
      ],
    );
  }
}

class ImgContent extends StatelessWidget {
  const ImgContent({
    super.key,
    this.img, 
    this.background,
  });

  final String? img;
  final String? background;
  @override
  Widget build(BuildContext context) {
  var urlBackground = 'background/$background.jpg';
    if (img != '') {
        return Container(
            margin: const EdgeInsets.only(right: 9.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              image: DecorationImage(
                image: AssetImage(urlBackground),
                // NetworkImage(
                //   'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
                // ),
                fit: BoxFit.cover,
              ),
            ),
            child: Image.network(
              img!, // Asegúrate de que img no sea nulo en tiempo de ejecución
              width: 50,
              height: 50,
            ),
          ); 
    } else {
        return Container(
          margin: const EdgeInsets.only(right: 9.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            color: Colors.redAccent,
          ),
          child: Image.asset('images/notFound.png', width: 50, height: 50,),
        );
    }
  }
}

class ImgContentType extends StatelessWidget {
  final List<Map<String, dynamic>> type;
  final String card;
  const ImgContentType(this.type, this.card,{
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final listTiles = <Widget>[];
    for (final item in type) {
      final types = TypePokemon.fromJson(item['detail']);
      final img = types.sprites?.generationViii?.swordShield?.nameIcon;
      listTiles.add(
        Image.network(img!, width: 50, height: 50,),
      );
    }
    return Row(
      children: listTiles,
    ); 
  }
}

String numberPokemon([int number = 0]) {
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
    return '0000';
  }
}

typesPokemon(data, name) async {
  Map<String, Object> colorType = getTypesPokemonSelectedColor(data[0]['type']['name']);
  // print(colorType);
  List<Map<String, dynamic>> md = [];
  for (var i = 0; i < data.length; i++) {
    var url = data[i]['type']['url'];
    // Usamos await para obtener los datos del Future
    var detail = await getTypesPokemon(url);
    md.add({
      'name': data[i]['type']['name'],
      'url': url,
      'detail': detail,
      'color': colorType,
    });
  }
  return md;
}

getTypesPokemon(String url) async {
    final response = await Dio().get(url);
    return response.data;
}

// Función para obtener los valores RGB y convertirlos en un Color
Color getColorFromType(String type) {
  Map<String, int> colorMap = getTypesPokemonSelectedColor(type);
  return Color.fromARGB(
    colorMap['A']!,
    colorMap['R']!,
    colorMap['G']!,
    colorMap['B']!,
  );
}

Map<String, int> getTypesPokemonSelectedColor(String type) {
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