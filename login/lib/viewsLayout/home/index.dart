// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:login/global/show_toast.dart';
import 'package:login/infrastructure/models/all_pokemon.dart';
import 'package:login/infrastructure/models/pokemon.dart';
import 'package:login/methods/home/method.dart';
import 'package:login/viewsLayout/index.dart';

import '../../layout/index.dart';
// dynamic [appBar.title, body.children, bottomNavigationBar]

  Methods? methods;
  Pokemon? pokemon;
  AllPokemon? allPokemon;

class Home extends StatelessWidget {
  const Home({super.key});
  static const routeName = 'Home';
  static const fullPath = '/$routeName';

  static const List<Map<String, dynamic>> bottomNavigationBar = [
    // {'label': 'Home', 'icon': Icons.home, 'iconActive': Icons.home_filled, 'route':'/Home'},
    // {'label': 'Users', 'icon': Icons.person, 'iconActive': Icons.person_off, 'route':'/User'},
    // {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
    // {'label': 'Pluss', 'icon': Icons.plus_one, 'iconActive': Icons.plus_one_sharp, 'route':'/Pluss'},
  ];
  static const List<Map<String, dynamic>> contentCard = [
    {
      'title': 'Homes',
      'icon': Icons.home,
      'iconActive': Icons.home_filled,
      'subtitle':
          'Este es el subtitulo del card. Aqui podemos colocar descripción de este card.'
    },
    {
      'title': 'Users',
      'icon': Icons.person,
      'iconActive': Icons.person_off,
      'subtitle':
          'Este es el subtitulo del card. Aqui podemos colocar descripción de este card.'
    },
    {
      'title': 'Pluss',
      'icon': Icons.plus_one,
      'iconActive': Icons.plus_one_sharp,
      'subtitle':
          'Este es el subtitulo del card. Aqui podemos colocar descripción de este card.'
    },
    {
      'title': 'Pluss',
      'icon': Icons.plus_one,
      'iconActive': Icons.plus_one_sharp,
      'subtitle':
          'Este es el subtitulo del card. Aqui podemos colocar descripción de este card.'
    },
  ];

  static const List<Widget> bodyWidget = [
    // HomeScreen(),
  ];

  static const List<Map<String, dynamic>> listTile = [
    // {'title': 'Home', 'icon': Icons.home, 'route':'/Home'},
    // {'title': 'About', 'icon': Icons.account_box, 'route':'/About'},
    // {'title': 'Products', 'icon': Icons.grid_3x3_outlined, 'route':'/Products'},
    // {'title': 'Layout', 'icon': Icons.contact_mail, 'route':'/Layout'},
    // {'title': 'Full', 'icon': Icons.abc_rounded, 'route':'/Full'},
  ];
  static const String subtitle = 'Home';
  static const String url = '';



  Future<List<Map<String, dynamic>>> inits() async {
    final List<Map<String, dynamic>> masterDetails = [];
    String url = 'https://pokeapi.co/api/v2/pokemon/';
    int count = await Methods.getAllResques(url);
    count = 30;
    if (count > 0) {
        // print(count);
      String url = 'https://pokeapi.co/api/v2/pokemon?limit=$count';
      final res = await Dio().get(url);
      // allPokemon = AllPokemon.fromJson(res.data);
      var data = res.data.results;
      for (var poke in data) {
        var detail = await Methods.get(poke.url);
        var types = await typesPokemon(detail['types'], poke.name);
        masterDetails.add(
          {'name': poke.name, 'url': poke.url, 'detail': detail, 'types': types},
        );
      }
      return masterDetails;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
      // ShowToast.showToasts(context);
    // var rs = initsx();
    // print(rs);
    return MyHomePage(
      // bodyWidget: [HomeScreen()],
      bodyWidget: [HomeScreen(inits: inits)],
      bottomNavigationBar: bottomNavigationBar,
      listTile: listTile,
      subtitle,
      url, 
    );
  }
}
typesPokemon(data, name) async {
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

  Future initsx() async {
    final List<Map<String, dynamic>> masterDetails = [];
    String url = 'https://pokeapi.co/api/v2/pokemon/';
    int count = await Methods.getAllResques(url);
    count = 30;
    if (count > 0) {
        print(count);
      String url = 'https://pokeapi.co/api/v2/pokemon?limit=$count';
      final res = await Dio().get(url);
      allPokemon = AllPokemon.fromJson(res.data);
      var data = allPokemon!.results;
      for (var poke in data) {
        var detail = await Methods.get(poke.url);
        var types = await typesPokemon(detail['types'], poke.name);
        masterDetails.add(
          {'name': poke.name, 'url': poke.url, 'detail': detail, 'types': types},
        );
      }
      return masterDetails;
    } else {
      return [];
    }
  }
