// ignore_for_file: file_names, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:login/infrastructure/models/pokemon.dart';
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
  int pokemonId = 0;
  @override
  void initState() {
    super.initState();
    getPokemon();
  }

  Future<void> getPokemon() async {
      pokemonId++;
      String url = 'https://pokeapi.co/api/v2/pokemon/$pokemonId';
      final response = await Dio().get(url);      
      pokemon = Pokemon.fromJson(response.data);
      // print(response);
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('Home'),
      // ),
      body: Center(
        child: ListView(
            children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(pokemon?.name ?? 'No data'),
                    if (pokemon != null)
                    ...[
                      Image.network(pokemon!.sprites.frontDefault),
                      Image.network(pokemon!.sprites.backDefault),                      
                      Image.network(pokemon!.sprites.frontShiny),
                      Image.network(pokemon!.sprites.backShiny),
                      Image.network(pokemon!.sprites.other!.showdown.frontDefault),
                      Image.network(pokemon!.sprites.other!.showdown.backDefault),
                      Image.network(pokemon!.sprites.other!.showdown.frontShiny),
                      Image.network(pokemon!.sprites.other!.showdown.backShiny),                 
                    ],
                    ElevatedButton(
                      onPressed: () => context.go('/NewPageA'),
                      // onPressed: () => context.push('/NewPageA'),
                      child: const Text('NewPageA'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go('/NewPageB'),
                      // onPressed: () => context.push('/NewPageB'),
                      child: const Text('NewPageB'),
                    ),
                  ],
                ),
              ],
            )
        ),
      // bottomNavigationBar: const BtnNavBar(bottomNavigationBar),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.navigate_next),
        onPressed: () {
          getPokemon();
        },
      ),
    );
  }
}