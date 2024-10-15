// ignore_for_file: file_names, avoid_print

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:login/global/index.dart';
import 'package:login/infrastructure/models/all_pokemon.dart';
import 'package:login/infrastructure/models/pokemon.dart';
import 'package:login/infrastructure/models/type_pokemon.dart';
import '../../methods/home/method.dart';

import 'package:login/views/index.dart';

// import 'package:login/global/connectivity_service.dart';
// import 'package:login/componets/btnNavBar/index.dart';
// import 'package:login/views/index.dart';

class HomeScreen extends StatefulWidget {
  final Function? inits;

  const HomeScreen({super.key, this.inits});

  static const List<Map<String, dynamic>> bottomNavigationBar = [
    {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.person_off, 'route':'/Home'},
    {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Global? global;
  Methods? methods;
  Pokemon? pokemon;
  AllPokemon? allPokemon;
  int pokemonId = 0;
  final List<Map<String, dynamic>> masterDetails = [];
  final List<Map<String, dynamic>> masterDetailsx = [];
  int counst = 0;
  double progressValue = 0.0;
  double increment = 1.0;
  @override
  void initState() {
    super.initState();
    // getPokemon();
    init();
    // _initData();
  }
  // void _initData() async {
  //   if (widget.inits != null) {
  //     final data = await widget.inits!();
  //     setState(() {
  //       masterDetails.addAll(data as Iterable<Map<String, dynamic>>);
  //     });
  //     print('class::HomeScreen, method::_initData, linea::55');
  //     var count = masterDetails.length;
  //     if (count > 0) {
  //       var rs = (increment / count);
  //       for (var i = 0; i < count; i++) {
  //         setState(() {
  //           progressValue += rs;
  //         });
  //         counst += 1;
  //       }
  //       // print('ddd $counst');
  //       // print(count);
  //     } 
  //   }
  // }

  Future<void> getPokemon() async {
      pokemonId++;
      String url = 'https://pokeapi.co/api/v2/pokemon/$pokemonId';
      final response = await Dio().get(url);      
      pokemon = Pokemon.fromJson(response.data);
      setState(() {});
  }
  
  Future<void> init() async {
    String url = 'https://pokeapi.co/api/v2/pokemon/';
    int count = await Methods.getAllResques(url);
    counst = count;
    // counst = 1020;
    counst = 30;
    if (count > 0) {
        var rs = (increment / counst);
        String url = 'https://pokeapi.co/api/v2/pokemon?limit=$counst';
        // String url = 'https://pokeapi.co/api/v2/pokemon?limit=$count';
        final res = await Dio().get(url);
        allPokemon = AllPokemon.fromJson(res.data);
        var data = allPokemon!.results;
        for (var poke in data) {
          // print(poke.url);
          var detail = await Methods.get(poke.url);
          var types = await typesPokemons(detail['types'], poke.name);
          masterDetails.add(
            {'name': poke.name, 'url': poke.url, 'detail': detail, 'types': types},
          );
          setState(() {
            progressValue += rs;
          });
        }
    }    
  }

  @override
  Widget build(BuildContext context) {
    // Widget dataBody;
    // if (masterDetails.isNotEmpty) {
    //   dataBody = LisViewWidget(masterDetails: masterDetails, counst: counst, progressValue:progressValue);
    // } else {
    //   dataBody = const NoDataWidget();   
    // }
    
    Widget dataBody = LisViewWidget(masterDetails: masterDetails, counst: counst, progressValue:progressValue);
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('Home'),
      // ),
      body: 
      SafeArea(
          child:
            dataBody,
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

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Dialog(
            child: 
            Padding(
              padding: EdgeInsets.all(0.0),
              child: 
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0),
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(0.0),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    elevation: 0,
                    child: Text('Data no found'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class LisViewWidget extends StatelessWidget {
  const LisViewWidget({
    super.key,
    required this.masterDetails,
    required this.counst, 
    required this.progressValue,
  });

  final List<Map<String, dynamic>> masterDetails;
  final int counst;
  final double progressValue;

  @override
  Widget build(BuildContext context) {
  
    if (masterDetails.isEmpty) {
      return const NoDataWidget();
    }  
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
            child: CardWidgetCustoms(card: card, counst: counst, masterDetails: masterDetails),
          );
        }                
      );
    } else {    
      var i = masterDetails.length;
      var sum = i - 1; 
      final card = masterDetails[sum];
      Color pokemonColor = getColorFromType(card['types'][0]['name']);
      return Center(
        child: 
            Dialog(
              child: 
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: 
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Card(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                          bottomLeft: Radius.circular(0.0),
                          bottomRight: Radius.circular(0.0),
                        ),
                      ),
                      color: pokemonColor,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      elevation: 0,
                      child: CardWidgetCustoms(card: card, counst: counst, masterDetails: masterDetails),
                    ),
                    // const CircularProgressIndicator(),
                    LinearProgressIndicator(
                      backgroundColor: const Color.fromARGB(0, 233, 160, 3),
                      value: progressValue,
                      // semanticsLabel: 'Linear progress indicator',
                      borderRadius:const BorderRadius.only(
                          topLeft: Radius.circular(0.0),
                          topRight: Radius.circular(0.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                    ),
                  ],
                ),
              ),
            ),
      );   
    }
  }
}

class CardWidgetCustoms extends StatelessWidget {
  const CardWidgetCustoms({
    super.key,
    required this.card,
    required this.masterDetails,
    required this.counst,      
  });
  final Map<String, dynamic> card;
  final int counst;
  final List<Map<String, dynamic>> masterDetails;  
  @override
  Widget build(BuildContext context) {
    var data = Pokemon.fromJson(card['detail']);
    var img = data.sprites?.other?.showdown?.frontDefault;   
    var id = Global.numberPokemon(data.id);
    var types = card["types"];
    var background= card['types'][0]['name'];
    return Column(
      children: <Widget>[
        Row(
          children: [
            ImgContent(img: img, background:background),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:<Widget>[
                  Text(card['name'], textAlign: TextAlign.left),
                  Row(
                    children: [
                        Image.asset('assets/images/hastag.png', width: 12, height: 12,), Text( id, textAlign: TextAlign.left)
                    ]
                  )
                ]
              ),
            ),            
            Container(
              margin: const EdgeInsets.only(left: 9.0),
              child: ImgContentType(types, card['name']),
            ),
            DetailWidget(id:data.id, counst: counst, masterDetails: masterDetails),
          ],
        ),
      ],
    );
  }
}

class DetailWidget extends StatelessWidget {
  const DetailWidget({
    super.key,
    required this.id,
    required this.masterDetails,
    required this.counst,     
  });
  final int id;
  final int counst;
  final List<Map<String, dynamic>> masterDetails;
  @override
  Widget build(BuildContext context) {
    if (counst == masterDetails.length) {
      return Container(
        margin: const EdgeInsets.only(
              right: 9.0,
              left: 9.0
            ),
        child: IconButton(
              onPressed: () {
                context.go('/HomeDetails/$id');
              },
              icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                ),
            ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(
              right: 9.0,
              left: 9.0
            ),
        child: const Text('')
      );
    }
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
  var urlBackground = 'assets/background/$background.jpg';
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
          child: Image.asset('assets/images/notFound.png', width: 50, height: 50,),
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
      print(img);
      print('isNotEmpty');
      if (img != null) {
        listTiles.add(
          Container(
            margin: const EdgeInsets.only(left: 3.0),
            child: Image.network(img, width: 50, height: 50,),          
          )        
        );      
      } else {
        listTiles.add(
          Container(
            margin: const EdgeInsets.only(left: 3.0),
            child: Image.asset('assets/images/notFound.png', width: 50, height: 50,),
          )
        );         
      }
    }
    return Row(
      children: listTiles,
    ); 
  }
}



typesPokemons(data, name) async {
  List<Map<String, dynamic>> md = [];
  for (var i = 0; i < data.length; i++) {
    var url = data[i]['type']['url'];
    var detail = await Methods.get(url);
    md.add({
      'name': data[i]['type']['name'],
      'url': url,
      'detail': detail,
    });
  }
  return md;
}

// Función para obtener los valores RGB y convertirlos en un Color
Color getColorFromType(String type) {
  Map<String, int> colorMap = Global.getTypesPokemonSelectedColor(type);
  return Color.fromARGB(
    colorMap['A']!,
    colorMap['R']!,
    colorMap['G']!,
    colorMap['B']!,
  );
}