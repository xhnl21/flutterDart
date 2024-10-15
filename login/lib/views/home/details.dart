// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
// import 'package:login/global/connectivity_service.dart';
import 'package:login/infrastructure/models/pokemon.dart';

class HomeDetailsView extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function()? inits;
  const HomeDetailsView({super.key, 
  this.inits
  });
  @override
  StateHomeDetailsView createState() => StateHomeDetailsView();
}

class StateHomeDetailsView extends State<HomeDetailsView> { 
  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    if (widget.inits != null) {
      final data = await widget.inits!();
      print('class::HomeDetailsView, method::_initData, linea::35');
      var dat = Pokemon.fromJson(data[0]);

      var img = dat.sprites?.other?.showdown?.frontDefault; 
      print(img); 
      // var abilityA = dat.abilities![0].ability?.name;
      // print(abilityA);
      // var abilityB = dat.abilities![1].ability?.name;
      // print(abilityB);      
      // var heigth = dat.height;
      // print(heigth);
      // var weight = dat.weight;
      // print(weight); 
      // var baseExperience = dat.baseExperience;
      // print(baseExperience);  
      // var a = dat.stats?[0].baseStat;
      // var b = dat.stats?[0].effort;
      // var c = dat.stats![0].stat?.name;
      // print(a);
      // print(b);
      // print(c);
      // var types = dat.types![0].type?.name;
      // print(types);        
      // var url = dat.types![0].type?.url;
      // print(url);              
    }
  }

  // final String _chartData = '''{
  //   title: {
  //     text: 'Combination chart'
  //   },    
  //   xAxis: {
  //     categories: ['Apples', 'Oranges', 'Pears', 'Bananas', 'Plums']
  //   },
  //   labels: {
  //     items: [{
  //       html: 'Total fruit consumption',
  //       style: {
  //         left: '50px',
  //         top: '18px',
  //         color: ( // theme
  //             Highcharts.defaultOptions.title.style &&
  //             Highcharts.defaultOptions.title.style.color
  //         ) || 'black'
  //       }
  //     }]
  //   },
  //   series: [
  //     {
  //       type: 'column',
  //       name: 'Jane',
  //       data: [3, 2, 1, 3, 3]
  //     }, {
  //       type: 'column',
  //       name: 'John',
  //       data: [2, 4, 5, 7, 6]
  //     }, {
  //       type: 'column',
  //       name: 'Joe',
  //       data: [4, 3, 3, 5, 0]
  //     }, {
  //       type: 'spline',
  //       name: 'Average',
  //       data: [3, 2.67, 3, 6.33, 3.33],
  //       marker: {
  //         lineWidth: 2,
  //         lineColor: Highcharts.getOptions().colors[3],
  //         fillColor: 'white'
  //       }
  //     }, {
  //       type: 'pie',
  //       name: 'Total consumption',
  //       data: [{
  //           name: 'Jane',
  //           y: 13,
  //           color: Highcharts.getOptions().colors[0] // Jane's color
  //         }, {
  //           name: 'John',
  //           y: 23,
  //           color: Highcharts.getOptions().colors[1] // John's color
  //         }, {
  //           name: 'Joe',
  //           y: 19,
  //           color: Highcharts.getOptions().colors[2] // Joe's color
  //       }],
  //       center: [100, 80],
  //       size: 100,
  //       showInLegend: false,
  //       dataLabels: {
  //         enabled: false
  //       }
  //     }]
  // }''';
  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final conn = ConnectivityService.connectionStatusServise();
    //   if (conn[0]['status'] > 0) {
    //       showToast(context, conn[0]['msj']);
    //   }
    // });
    return const Scaffold(
      // drawer: const MenuWidget(),
      // appBar: AppBar(
      //   title: const Text('User'),
      // ),      
      // body: Text('demo'),

      body: 
       Text('demo'),
    );
  }
}

// void showToast(BuildContext context, String message) {
//   // print(message);
//   final scaffold = ScaffoldMessenger.of(context);
//   scaffold.showSnackBar(
//     SnackBar(
//       content: Text(message),
//       backgroundColor: Colors.red,
//     ),
//   );
// } 
