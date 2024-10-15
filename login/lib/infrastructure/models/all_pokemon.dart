// To parse this JSON data, do
//
//     final allPokemon = allPokemonFromJson(jsonString);

// import 'dart:convert';

// AllPokemon allPokemonFromJson(String str) => AllPokemon.fromJson(json.decode(str));

// String allPokemonToJson(AllPokemon data) => json.encode(data.toJson());

class AllPokemon {
    final int count;
    final dynamic next;
    final dynamic previous;
    final List<Result> results;

    AllPokemon({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    factory AllPokemon.fromJson(Map<String, dynamic> json) => AllPokemon(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class Result {
    final String name;
    final String url;

    Result({
        required this.name,
        required this.url,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        name: json["name"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
    };
}
