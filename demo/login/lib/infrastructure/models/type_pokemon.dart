// To parse this JSON data, do
//
//     final typePokemon = typePokemonFromJson(jsonString);

// import 'dart:convert';

// TypePokemon typePokemonFromJson(String str) => TypePokemon.fromJson(json.decode(str));

// String typePokemonToJson(TypePokemon data) => json.encode(data.toJson());

class TypePokemon {
    final DamageRelations? damageRelations;
    final List<GameIndex>? gameIndices;
    final Generation? generation;
    final int? id;
    final dynamic moveDamageClass;
    final List<Generation>? moves;
    final String? name;
    final List<Name>? names;
    final List<dynamic>? pastDamageRelations;
    final List<Pokemons>? pokemon;
    final Sprites? sprites;

    TypePokemon({
        this.damageRelations,
        this.gameIndices,
        this.generation,
        this.id,
        this.moveDamageClass,
        this.moves,
        this.name,
        this.names,
        this.pastDamageRelations,
        this.pokemon,
        this.sprites,
    });

    factory TypePokemon.fromJson(Map<String, dynamic> json) => TypePokemon(
        damageRelations: json["damage_relations"] == null ? null : DamageRelations.fromJson(json["damage_relations"]),
        gameIndices: json["game_indices"] == null ? [] : List<GameIndex>.from(json["game_indices"]!.map((x) => GameIndex.fromJson(x))),
        generation: json["generation"] == null ? null : Generation.fromJson(json["generation"]),
        id: json["id"],
        moveDamageClass: json["move_damage_class"],
        moves: json["moves"] == null ? [] : List<Generation>.from(json["moves"]!.map((x) => Generation.fromJson(x))),
        name: json["name"],
        names: json["names"] == null ? [] : List<Name>.from(json["names"]!.map((x) => Name.fromJson(x))),
        pastDamageRelations: json["past_damage_relations"] == null ? [] : List<dynamic>.from(json["past_damage_relations"]!.map((x) => x)),
        pokemon: json["pokemon"] == null ? [] : List<Pokemons>.from(json["pokemon"]!.map((x) => Pokemons.fromJson(x))),
        sprites: json["sprites"] == null ? null : Sprites.fromJson(json["sprites"]),
    );

    Map<String, dynamic> toJson() => {
        "damage_relations": damageRelations?.toJson(),
        "game_indices": gameIndices == null ? [] : List<dynamic>.from(gameIndices!.map((x) => x.toJson())),
        "generation": generation?.toJson(),
        "id": id,
        "move_damage_class": moveDamageClass,
        "moves": moves == null ? [] : List<dynamic>.from(moves!.map((x) => x.toJson())),
        "name": name,
        "names": names == null ? [] : List<dynamic>.from(names!.map((x) => x.toJson())),
        "past_damage_relations": pastDamageRelations == null ? [] : List<dynamic>.from(pastDamageRelations!.map((x) => x)),
        "pokemon": pokemon == null ? [] : List<dynamic>.from(pokemon!.map((x) => x.toJson())),
        "sprites": sprites?.toJson(),
    };
}

class DamageRelations {
    final List<Generation>? doubleDamageFrom;
    final List<Generation>? doubleDamageTo;
    final List<Generation>? halfDamageFrom;
    final List<Generation>? halfDamageTo;
    final List<Generation>? noDamageFrom;
    final List<dynamic>? noDamageTo;

    DamageRelations({
        this.doubleDamageFrom,
        this.doubleDamageTo,
        this.halfDamageFrom,
        this.halfDamageTo,
        this.noDamageFrom,
        this.noDamageTo,
    });

    factory DamageRelations.fromJson(Map<String, dynamic> json) => DamageRelations(
        doubleDamageFrom: json["double_damage_from"] == null ? [] : List<Generation>.from(json["double_damage_from"]!.map((x) => Generation.fromJson(x))),
        doubleDamageTo: json["double_damage_to"] == null ? [] : List<Generation>.from(json["double_damage_to"]!.map((x) => Generation.fromJson(x))),
        halfDamageFrom: json["half_damage_from"] == null ? [] : List<Generation>.from(json["half_damage_from"]!.map((x) => Generation.fromJson(x))),
        halfDamageTo: json["half_damage_to"] == null ? [] : List<Generation>.from(json["half_damage_to"]!.map((x) => Generation.fromJson(x))),
        noDamageFrom: json["no_damage_from"] == null ? [] : List<Generation>.from(json["no_damage_from"]!.map((x) => Generation.fromJson(x))),
        noDamageTo: json["no_damage_to"] == null ? [] : List<dynamic>.from(json["no_damage_to"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "double_damage_from": doubleDamageFrom == null ? [] : List<dynamic>.from(doubleDamageFrom!.map((x) => x.toJson())),
        "double_damage_to": doubleDamageTo == null ? [] : List<dynamic>.from(doubleDamageTo!.map((x) => x.toJson())),
        "half_damage_from": halfDamageFrom == null ? [] : List<dynamic>.from(halfDamageFrom!.map((x) => x.toJson())),
        "half_damage_to": halfDamageTo == null ? [] : List<dynamic>.from(halfDamageTo!.map((x) => x.toJson())),
        "no_damage_from": noDamageFrom == null ? [] : List<dynamic>.from(noDamageFrom!.map((x) => x.toJson())),
        "no_damage_to": noDamageTo == null ? [] : List<dynamic>.from(noDamageTo!.map((x) => x)),
    };
}

class Generation {
    final String? name;
    final String? url;

    Generation({
        this.name,
        this.url,
    });

    factory Generation.fromJson(Map<String, dynamic> json) => Generation(
        name: json["name"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
    };
}

class GameIndex {
    final int? gameIndex;
    final Generation? generation;

    GameIndex({
        this.gameIndex,
        this.generation,
    });

    factory GameIndex.fromJson(Map<String, dynamic> json) => GameIndex(
        gameIndex: json["game_index"],
        generation: json["generation"] == null ? null : Generation.fromJson(json["generation"]),
    );

    Map<String, dynamic> toJson() => {
        "game_index": gameIndex,
        "generation": generation?.toJson(),
    };
}

class Name {
    final Generation? language;
    final String? name;

    Name({
        this.language,
        this.name,
    });

    factory Name.fromJson(Map<String, dynamic> json) => Name(
        language: json["language"] == null ? null : Generation.fromJson(json["language"]),
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "language": language?.toJson(),
        "name": name,
    };
}

class Pokemons {
    final Generation? pokemon;
    final int? slot;

    Pokemons({
        this.pokemon,
        this.slot,
    });

    factory Pokemons.fromJson(Map<String, dynamic> json) => Pokemons(
        pokemon: json["pokemon"] == null ? null : Generation.fromJson(json["pokemon"]),
        slot: json["slot"],
    );

    Map<String, dynamic> toJson() => {
        "pokemon": pokemon?.toJson(),
        "slot": slot,
    };
}

class Sprites {
    final GenerationIii? generationIii;
    final GenerationIv? generationIv;
    final GenerationIx? generationIx;
    final GenerationV? generationV;
    final Map<String, GenerationVi>? generationVi;
    final GenerationVii? generationVii;
    final GenerationViii? generationViii;

    Sprites({
        this.generationIii,
        this.generationIv,
        this.generationIx,
        this.generationV,
        this.generationVi,
        this.generationVii,
        this.generationViii,
    });

    factory Sprites.fromJson(Map<String, dynamic> json) => Sprites(
        generationIii: json["generation-iii"] == null ? null : GenerationIii.fromJson(json["generation-iii"]),
        generationIv: json["generation-iv"] == null ? null : GenerationIv.fromJson(json["generation-iv"]),
        generationIx: json["generation-ix"] == null ? null : GenerationIx.fromJson(json["generation-ix"]),
        generationV: json["generation-v"] == null ? null : GenerationV.fromJson(json["generation-v"]),
        generationVi: Map.from(json["generation-vi"]!).map((k, v) => MapEntry<String, GenerationVi>(k, GenerationVi.fromJson(v))),
        generationVii: json["generation-vii"] == null ? null : GenerationVii.fromJson(json["generation-vii"]),
        generationViii: json["generation-viii"] == null ? null : GenerationViii.fromJson(json["generation-viii"]),
    );

    Map<String, dynamic> toJson() => {
        "generation-iii": generationIii?.toJson(),
        "generation-iv": generationIv?.toJson(),
        "generation-ix": generationIx?.toJson(),
        "generation-v": generationV?.toJson(),
        "generation-vi": Map.from(generationVi!).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "generation-vii": generationVii?.toJson(),
        "generation-viii": generationViii?.toJson(),
    };
}

class GenerationIii {
    final GenerationVi? colosseum;
    final GenerationVi? emerald;
    final GenerationVi? fireredLeafgreen;
    final GenerationVi? rubySaphire;
    final GenerationVi? xd;

    GenerationIii({
        this.colosseum,
        this.emerald,
        this.fireredLeafgreen,
        this.rubySaphire,
        this.xd,
    });

    factory GenerationIii.fromJson(Map<String, dynamic> json) => GenerationIii(
        colosseum: json["colosseum"] == null ? null : GenerationVi.fromJson(json["colosseum"]),
        emerald: json["emerald"] == null ? null : GenerationVi.fromJson(json["emerald"]),
        fireredLeafgreen: json["firered-leafgreen"] == null ? null : GenerationVi.fromJson(json["firered-leafgreen"]),
        rubySaphire: json["ruby-saphire"] == null ? null : GenerationVi.fromJson(json["ruby-saphire"]),
        xd: json["xd"] == null ? null : GenerationVi.fromJson(json["xd"]),
    );

    Map<String, dynamic> toJson() => {
        "colosseum": colosseum?.toJson(),
        "emerald": emerald?.toJson(),
        "firered-leafgreen": fireredLeafgreen?.toJson(),
        "ruby-saphire": rubySaphire?.toJson(),
        "xd": xd?.toJson(),
    };
}

class GenerationVi {
    final String? nameIcon;

    GenerationVi({
        this.nameIcon,
    });

    factory GenerationVi.fromJson(Map<String, dynamic> json) => GenerationVi(
        nameIcon: json["name_icon"],
    );

    Map<String, dynamic> toJson() => {
        "name_icon": nameIcon,
    };
}

class GenerationIv {
    final GenerationVi? diamondPearl;
    final GenerationVi? heartgoldSoulsilver;
    final GenerationVi? platinum;

    GenerationIv({
        this.diamondPearl,
        this.heartgoldSoulsilver,
        this.platinum,
    });

    factory GenerationIv.fromJson(Map<String, dynamic> json) => GenerationIv(
        diamondPearl: json["diamond-pearl"] == null ? null : GenerationVi.fromJson(json["diamond-pearl"]),
        heartgoldSoulsilver: json["heartgold-soulsilver"] == null ? null : GenerationVi.fromJson(json["heartgold-soulsilver"]),
        platinum: json["platinum"] == null ? null : GenerationVi.fromJson(json["platinum"]),
    );

    Map<String, dynamic> toJson() => {
        "diamond-pearl": diamondPearl?.toJson(),
        "heartgold-soulsilver": heartgoldSoulsilver?.toJson(),
        "platinum": platinum?.toJson(),
    };
}

class GenerationIx {
    final GenerationVi? scarletViolet;

    GenerationIx({
        this.scarletViolet,
    });

    factory GenerationIx.fromJson(Map<String, dynamic> json) => GenerationIx(
        scarletViolet: json["scarlet-violet"] == null ? null : GenerationVi.fromJson(json["scarlet-violet"]),
    );

    Map<String, dynamic> toJson() => {
        "scarlet-violet": scarletViolet?.toJson(),
    };
}

class GenerationV {
    final GenerationVi? black2White2;
    final GenerationVi? blackWhite;

    GenerationV({
        this.black2White2,
        this.blackWhite,
    });

    factory GenerationV.fromJson(Map<String, dynamic> json) => GenerationV(
        black2White2: json["black-2-white-2"] == null ? null : GenerationVi.fromJson(json["black-2-white-2"]),
        blackWhite: json["black-white"] == null ? null : GenerationVi.fromJson(json["black-white"]),
    );

    Map<String, dynamic> toJson() => {
        "black-2-white-2": black2White2?.toJson(),
        "black-white": blackWhite?.toJson(),
    };
}

class GenerationVii {
    final GenerationVi? letsGoPikachuLetsGoEevee;
    final GenerationVi? sunMoon;
    final GenerationVi? ultraSunUltraMoon;

    GenerationVii({
        this.letsGoPikachuLetsGoEevee,
        this.sunMoon,
        this.ultraSunUltraMoon,
    });

    factory GenerationVii.fromJson(Map<String, dynamic> json) => GenerationVii(
        letsGoPikachuLetsGoEevee: json["lets-go-pikachu-lets-go-eevee"] == null ? null : GenerationVi.fromJson(json["lets-go-pikachu-lets-go-eevee"]),
        sunMoon: json["sun-moon"] == null ? null : GenerationVi.fromJson(json["sun-moon"]),
        ultraSunUltraMoon: json["ultra-sun-ultra-moon"] == null ? null : GenerationVi.fromJson(json["ultra-sun-ultra-moon"]),
    );

    Map<String, dynamic> toJson() => {
        "lets-go-pikachu-lets-go-eevee": letsGoPikachuLetsGoEevee?.toJson(),
        "sun-moon": sunMoon?.toJson(),
        "ultra-sun-ultra-moon": ultraSunUltraMoon?.toJson(),
    };
}

class GenerationViii {
    final GenerationVi? brilliantDiamondAndShiningPearl;
    final GenerationVi? legendsArceus;
    final GenerationVi? swordShield;

    GenerationViii({
        this.brilliantDiamondAndShiningPearl,
        this.legendsArceus,
        this.swordShield,
    });

    factory GenerationViii.fromJson(Map<String, dynamic> json) => GenerationViii(
        brilliantDiamondAndShiningPearl: json["brilliant-diamond-and-shining-pearl"] == null ? null : GenerationVi.fromJson(json["brilliant-diamond-and-shining-pearl"]),
        legendsArceus: json["legends-arceus"] == null ? null : GenerationVi.fromJson(json["legends-arceus"]),
        swordShield: json["sword-shield"] == null ? null : GenerationVi.fromJson(json["sword-shield"]),
    );

    Map<String, dynamic> toJson() => {
        "brilliant-diamond-and-shining-pearl": brilliantDiamondAndShiningPearl?.toJson(),
        "legends-arceus": legendsArceus?.toJson(),
        "sword-shield": swordShield?.toJson(),
    };
}
