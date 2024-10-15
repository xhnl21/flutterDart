// To parse this JSON data, do
//
//     final pokemon = pokemonFromJson(jsonString);

import 'dart:convert';

Pokemon pokemonFromJson(String str) => Pokemon.fromJson(json.decode(str));

String pokemonToJson(Pokemon data) => json.encode(data.toJson());

class Pokemon {
    final List<Ability>? abilities;
    final int? baseExperience;
    final Cries? cries;
    final List<Species>? forms;
    final List<GameIndex>? gameIndices;
    final int? height;
    final List<HeldItem>? heldItems;
    final int id;
    final bool? isDefault;
    final String? locationAreaEncounters;
    final List<Move>? moves;
    final String? name;
    final int? order;
    final List<dynamic>? pastAbilities;
    final List<dynamic>? pastTypes;
    final Species? species;
    final Sprites? sprites;
    final List<Stat>? stats;
    final List<Type>? types;
    final int? weight;

    Pokemon({
        this.abilities,
        this.baseExperience,
        this.cries,
        this.forms,
        this.gameIndices,
        this.height,
        this.heldItems,
        required this.id,
        this.isDefault,
        this.locationAreaEncounters,
        this.moves,
        this.name,
        this.order,
        this.pastAbilities,
        this.pastTypes,
        this.species,
        this.sprites,
        this.stats,
        this.types,
        this.weight,
    });

    factory Pokemon.fromJson(Map<String, dynamic> json) => Pokemon(
        abilities: json["abilities"] == null ? [] : List<Ability>.from(json["abilities"]!.map((x) => Ability.fromJson(x))),
        baseExperience: json["base_experience"],
        cries: json["cries"] == null ? null : Cries.fromJson(json["cries"]),
        forms: json["forms"] == null ? [] : List<Species>.from(json["forms"]!.map((x) => Species.fromJson(x))),
        gameIndices: json["game_indices"] == null ? [] : List<GameIndex>.from(json["game_indices"]!.map((x) => GameIndex.fromJson(x))),
        height: json["height"],
        heldItems: json["held_items"] == null ? [] : List<HeldItem>.from(json["held_items"]!.map((x) => HeldItem.fromJson(x))),
        id: json["id"],
        isDefault: json["is_default"],
        locationAreaEncounters: json["location_area_encounters"],
        moves: json["moves"] == null ? [] : List<Move>.from(json["moves"]!.map((x) => Move.fromJson(x))),
        name: json["name"],
        order: json["order"],
        pastAbilities: json["past_abilities"] == null ? [] : List<dynamic>.from(json["past_abilities"]!.map((x) => x)),
        pastTypes: json["past_types"] == null ? [] : List<dynamic>.from(json["past_types"]!.map((x) => x)),
        species: json["species"] == null ? null : Species.fromJson(json["species"]),
        sprites: json["sprites"] == null ? null : Sprites.fromJson(json["sprites"]),
        stats: json["stats"] == null ? [] : List<Stat>.from(json["stats"]!.map((x) => Stat.fromJson(x))),
        types: json["types"] == null ? [] : List<Type>.from(json["types"]!.map((x) => Type.fromJson(x))),
        weight: json["weight"],
    );

    Map<String, dynamic> toJson() => {
        "abilities": abilities == null ? [] : List<dynamic>.from(abilities!.map((x) => x.toJson())),
        "base_experience": baseExperience,
        "cries": cries?.toJson(),
        "forms": forms == null ? [] : List<dynamic>.from(forms!.map((x) => x.toJson())),
        "game_indices": gameIndices == null ? [] : List<dynamic>.from(gameIndices!.map((x) => x.toJson())),
        "height": height,
        "held_items": heldItems == null ? [] : List<dynamic>.from(heldItems!.map((x) => x.toJson())),
        "id": id,
        "is_default": isDefault,
        "location_area_encounters": locationAreaEncounters,
        "moves": moves == null ? [] : List<dynamic>.from(moves!.map((x) => x.toJson())),
        "name": name,
        "order": order,
        "past_abilities": pastAbilities == null ? [] : List<dynamic>.from(pastAbilities!.map((x) => x)),
        "past_types": pastTypes == null ? [] : List<dynamic>.from(pastTypes!.map((x) => x)),
        "species": species?.toJson(),
        "sprites": sprites?.toJson(),
        "stats": stats == null ? [] : List<dynamic>.from(stats!.map((x) => x.toJson())),
        "types": types == null ? [] : List<dynamic>.from(types!.map((x) => x.toJson())),
        "weight": weight,
    };
}

class Ability {
    final Species? ability;
    final bool? isHidden;
    final int? slot;

    Ability({
        this.ability,
        this.isHidden,
        this.slot,
    });

    factory Ability.fromJson(Map<String, dynamic> json) => Ability(
        ability: json["ability"] == null ? null : Species.fromJson(json["ability"]),
        isHidden: json["is_hidden"],
        slot: json["slot"],
    );

    Map<String, dynamic> toJson() => {
        "ability": ability?.toJson(),
        "is_hidden": isHidden,
        "slot": slot,
    };
}

class Species {
    final String? name;
    final String? url;

    Species({
        this.name,
        this.url,
    });

    factory Species.fromJson(Map<String, dynamic> json) => Species(
        name: json["name"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
    };
}

class Cries {
    final String? latest;
    final String? legacy;

    Cries({
        this.latest,
        this.legacy,
    });

    factory Cries.fromJson(Map<String, dynamic> json) => Cries(
        latest: json["latest"],
        legacy: json["legacy"],
    );

    Map<String, dynamic> toJson() => {
        "latest": latest,
        "legacy": legacy,
    };
}

class GameIndex {
    final int? gameIndex;
    final Species? version;

    GameIndex({
        this.gameIndex,
        this.version,
    });

    factory GameIndex.fromJson(Map<String, dynamic> json) => GameIndex(
        gameIndex: json["game_index"],
        version: json["version"] == null ? null : Species.fromJson(json["version"]),
    );

    Map<String, dynamic> toJson() => {
        "game_index": gameIndex,
        "version": version?.toJson(),
    };
}

class HeldItem {
    final Species? item;
    final List<VersionDetail>? versionDetails;

    HeldItem({
        this.item,
        this.versionDetails,
    });

    factory HeldItem.fromJson(Map<String, dynamic> json) => HeldItem(
        item: json["item"] == null ? null : Species.fromJson(json["item"]),
        versionDetails: json["version_details"] == null ? [] : List<VersionDetail>.from(json["version_details"]!.map((x) => VersionDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "item": item?.toJson(),
        "version_details": versionDetails == null ? [] : List<dynamic>.from(versionDetails!.map((x) => x.toJson())),
    };
}

class VersionDetail {
    final int? rarity;
    final Species? version;

    VersionDetail({
        this.rarity,
        this.version,
    });

    factory VersionDetail.fromJson(Map<String, dynamic> json) => VersionDetail(
        rarity: json["rarity"],
        version: json["version"] == null ? null : Species.fromJson(json["version"]),
    );

    Map<String, dynamic> toJson() => {
        "rarity": rarity,
        "version": version?.toJson(),
    };
}

class Move {
    final Species? move;
    final List<VersionGroupDetail>? versionGroupDetails;

    Move({
        this.move,
        this.versionGroupDetails,
    });

    factory Move.fromJson(Map<String, dynamic> json) => Move(
        move: json["move"] == null ? null : Species.fromJson(json["move"]),
        versionGroupDetails: json["version_group_details"] == null ? [] : List<VersionGroupDetail>.from(json["version_group_details"]!.map((x) => VersionGroupDetail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "move": move?.toJson(),
        "version_group_details": versionGroupDetails == null ? [] : List<dynamic>.from(versionGroupDetails!.map((x) => x.toJson())),
    };
}

class VersionGroupDetail {
    final int? levelLearnedAt;
    final Species? moveLearnMethod;
    final Species? versionGroup;

    VersionGroupDetail({
        this.levelLearnedAt,
        this.moveLearnMethod,
        this.versionGroup,
    });

    factory VersionGroupDetail.fromJson(Map<String, dynamic> json) => VersionGroupDetail(
        levelLearnedAt: json["level_learned_at"],
        moveLearnMethod: json["move_learn_method"] == null ? null : Species.fromJson(json["move_learn_method"]),
        versionGroup: json["version_group"] == null ? null : Species.fromJson(json["version_group"]),
    );

    Map<String, dynamic> toJson() => {
        "level_learned_at": levelLearnedAt,
        "move_learn_method": moveLearnMethod?.toJson(),
        "version_group": versionGroup?.toJson(),
    };
}

class GenerationV {
    final Sprites? blackWhite;

    GenerationV({
        this.blackWhite,
    });

    factory GenerationV.fromJson(Map<String, dynamic> json) => GenerationV(
        blackWhite: json["black-white"] == null ? null : Sprites.fromJson(json["black-white"]),
    );

    Map<String, dynamic> toJson() => {
        "black-white": blackWhite?.toJson(),
    };
}

class GenerationIv {
    final Sprites? diamondPearl;
    final Sprites? heartgoldSoulsilver;
    final Sprites? platinum;

    GenerationIv({
        this.diamondPearl,
        this.heartgoldSoulsilver,
        this.platinum,
    });

    factory GenerationIv.fromJson(Map<String, dynamic> json) => GenerationIv(
        diamondPearl: json["diamond-pearl"] == null ? null : Sprites.fromJson(json["diamond-pearl"]),
        heartgoldSoulsilver: json["heartgold-soulsilver"] == null ? null : Sprites.fromJson(json["heartgold-soulsilver"]),
        platinum: json["platinum"] == null ? null : Sprites.fromJson(json["platinum"]),
    );

    Map<String, dynamic> toJson() => {
        "diamond-pearl": diamondPearl?.toJson(),
        "heartgold-soulsilver": heartgoldSoulsilver?.toJson(),
        "platinum": platinum?.toJson(),
    };
}

class Versions {
    final GenerationI? generationI;
    final GenerationIi? generationIi;
    final GenerationIii? generationIii;
    final GenerationIv? generationIv;
    final GenerationV? generationV;
    final Map<String, Home>? generationVi;
    final GenerationVii? generationVii;
    final GenerationViii? generationViii;

    Versions({
        this.generationI,
        this.generationIi,
        this.generationIii,
        this.generationIv,
        this.generationV,
        this.generationVi,
        this.generationVii,
        this.generationViii,
    });

    factory Versions.fromJson(Map<String, dynamic> json) => Versions(
        generationI: json["generation-i"] == null ? null : GenerationI.fromJson(json["generation-i"]),
        generationIi: json["generation-ii"] == null ? null : GenerationIi.fromJson(json["generation-ii"]),
        generationIii: json["generation-iii"] == null ? null : GenerationIii.fromJson(json["generation-iii"]),
        generationIv: json["generation-iv"] == null ? null : GenerationIv.fromJson(json["generation-iv"]),
        generationV: json["generation-v"] == null ? null : GenerationV.fromJson(json["generation-v"]),
        generationVi: Map.from(json["generation-vi"]!).map((k, v) => MapEntry<String, Home>(k, Home.fromJson(v))),
        generationVii: json["generation-vii"] == null ? null : GenerationVii.fromJson(json["generation-vii"]),
        generationViii: json["generation-viii"] == null ? null : GenerationViii.fromJson(json["generation-viii"]),
    );

    Map<String, dynamic> toJson() => {
        "generation-i": generationI?.toJson(),
        "generation-ii": generationIi?.toJson(),
        "generation-iii": generationIii?.toJson(),
        "generation-iv": generationIv?.toJson(),
        "generation-v": generationV?.toJson(),
        "generation-vi": Map.from(generationVi!).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "generation-vii": generationVii?.toJson(),
        "generation-viii": generationViii?.toJson(),
    };
}

class Other {
    final DreamWorld? dreamWorld;
    final Home? home;
    final OfficialArtwork? officialArtwork;
    final Sprites? showdown;

    Other({
        this.dreamWorld,
        this.home,
        this.officialArtwork,
        this.showdown,
    });

    factory Other.fromJson(Map<String, dynamic> json) => Other(
        dreamWorld: json["dream_world"] == null ? null : DreamWorld.fromJson(json["dream_world"]),
        home: json["home"] == null ? null : Home.fromJson(json["home"]),
        officialArtwork: json["official-artwork"] == null ? null : OfficialArtwork.fromJson(json["official-artwork"]),
        showdown: json["showdown"] == null ? null : Sprites.fromJson(json["showdown"]),
    );

    Map<String, dynamic> toJson() => {
        "dream_world": dreamWorld?.toJson(),
        "home": home?.toJson(),
        "official-artwork": officialArtwork?.toJson(),
        "showdown": showdown?.toJson(),
    };
}

class Sprites {
    final String? backDefault;
    final dynamic backFemale;
    final String? backShiny;
    final dynamic backShinyFemale;
    final String? frontDefault;
    final dynamic frontFemale;
    final String? frontShiny;
    final dynamic frontShinyFemale;
    final Other? other;
    final Versions? versions;
    final Sprites? animated;

    Sprites({
        this.backDefault,
        this.backFemale,
        this.backShiny,
        this.backShinyFemale,
        this.frontDefault,
        this.frontFemale,
        this.frontShiny,
        this.frontShinyFemale,
        this.other,
        this.versions,
        this.animated,
    });

    factory Sprites.fromJson(Map<String, dynamic> json) => Sprites(
        backDefault: json["back_default"],
        backFemale: json["back_female"],
        backShiny: json["back_shiny"],
        backShinyFemale: json["back_shiny_female"],
        frontDefault: json["front_default"] ?? '',
        frontFemale: json["front_female"],
        frontShiny: json["front_shiny"],
        frontShinyFemale: json["front_shiny_female"],
        other: json["other"] == null ? null : Other.fromJson(json["other"]),
        versions: json["versions"] == null ? null : Versions.fromJson(json["versions"]),
        animated: json["animated"] == null ? null : Sprites.fromJson(json["animated"]),
    );

    Map<String, dynamic> toJson() => {
        "back_default": backDefault,
        "back_female": backFemale,
        "back_shiny": backShiny,
        "back_shiny_female": backShinyFemale,
        "front_default": frontDefault,
        "front_female": frontFemale,
        "front_shiny": frontShiny,
        "front_shiny_female": frontShinyFemale,
        "other": other?.toJson(),
        "versions": versions?.toJson(),
        "animated": animated?.toJson(),
    };
}

class GenerationI {
    final RedBlue? redBlue;
    final RedBlue? yellow;

    GenerationI({
        this.redBlue,
        this.yellow,
    });

    factory GenerationI.fromJson(Map<String, dynamic> json) => GenerationI(
        redBlue: json["red-blue"] == null ? null : RedBlue.fromJson(json["red-blue"]),
        yellow: json["yellow"] == null ? null : RedBlue.fromJson(json["yellow"]),
    );

    Map<String, dynamic> toJson() => {
        "red-blue": redBlue?.toJson(),
        "yellow": yellow?.toJson(),
    };
}

class RedBlue {
    final String? backDefault;
    final String? backGray;
    final String? backTransparent;
    final String? frontDefault;
    final String? frontGray;
    final String? frontTransparent;

    RedBlue({
        this.backDefault,
        this.backGray,
        this.backTransparent,
        this.frontDefault,
        this.frontGray,
        this.frontTransparent,
    });

    factory RedBlue.fromJson(Map<String, dynamic> json) => RedBlue(
        backDefault: json["back_default"],
        backGray: json["back_gray"],
        backTransparent: json["back_transparent"],
        frontDefault: json["front_default"] ?? 'no data 2',
        frontGray: json["front_gray"],
        frontTransparent: json["front_transparent"],
    );

    Map<String, dynamic> toJson() => {
        "back_default": backDefault,
        "back_gray": backGray,
        "back_transparent": backTransparent,
        "front_default": frontDefault,
        "front_gray": frontGray,
        "front_transparent": frontTransparent,
    };
}

class GenerationIi {
    final Crystal? crystal;
    final Gold? gold;
    final Gold? silver;

    GenerationIi({
        this.crystal,
        this.gold,
        this.silver,
    });

    factory GenerationIi.fromJson(Map<String, dynamic> json) => GenerationIi(
        crystal: json["crystal"] == null ? null : Crystal.fromJson(json["crystal"]),
        gold: json["gold"] == null ? null : Gold.fromJson(json["gold"]),
        silver: json["silver"] == null ? null : Gold.fromJson(json["silver"]),
    );

    Map<String, dynamic> toJson() => {
        "crystal": crystal?.toJson(),
        "gold": gold?.toJson(),
        "silver": silver?.toJson(),
    };
}

class Crystal {
    final String? backDefault;
    final String? backShiny;
    final String? backShinyTransparent;
    final String? backTransparent;
    final String? frontDefault;
    final String? frontShiny;
    final String? frontShinyTransparent;
    final String? frontTransparent;

    Crystal({
        this.backDefault,
        this.backShiny,
        this.backShinyTransparent,
        this.backTransparent,
        this.frontDefault,
        this.frontShiny,
        this.frontShinyTransparent,
        this.frontTransparent,
    });

    factory Crystal.fromJson(Map<String, dynamic> json) => Crystal(
        backDefault: json["back_default"],
        backShiny: json["back_shiny"],
        backShinyTransparent: json["back_shiny_transparent"],
        backTransparent: json["back_transparent"],
        frontDefault: json["front_default"] ?? 'no data 3',
        frontShiny: json["front_shiny"],
        frontShinyTransparent: json["front_shiny_transparent"],
        frontTransparent: json["front_transparent"],
    );

    Map<String, dynamic> toJson() => {
        "back_default": backDefault,
        "back_shiny": backShiny,
        "back_shiny_transparent": backShinyTransparent,
        "back_transparent": backTransparent,
        "front_default": frontDefault,
        "front_shiny": frontShiny,
        "front_shiny_transparent": frontShinyTransparent,
        "front_transparent": frontTransparent,
    };
}

class Gold {
    final String? backDefault;
    final String? backShiny;
    final String? frontDefault;
    final String? frontShiny;
    final String? frontTransparent;

    Gold({
        this.backDefault,
        this.backShiny,
        this.frontDefault,
        this.frontShiny,
        this.frontTransparent,
    });

    factory Gold.fromJson(Map<String, dynamic> json) => Gold(
        backDefault: json["back_default"],
        backShiny: json["back_shiny"],
        frontDefault: json["front_default"] ?? 'no data 4',
        frontShiny: json["front_shiny"],
        frontTransparent: json["front_transparent"],
    );

    Map<String, dynamic> toJson() => {
        "back_default": backDefault,
        "back_shiny": backShiny,
        "front_default": frontDefault,
        "front_shiny": frontShiny,
        "front_transparent": frontTransparent,
    };
}

class GenerationIii {
    final OfficialArtwork? emerald;
    final Gold? fireredLeafgreen;
    final Gold? rubySapphire;

    GenerationIii({
        this.emerald,
        this.fireredLeafgreen,
        this.rubySapphire,
    });

    factory GenerationIii.fromJson(Map<String, dynamic> json) => GenerationIii(
        emerald: json["emerald"] == null ? null : OfficialArtwork.fromJson(json["emerald"]),
        fireredLeafgreen: json["firered-leafgreen"] == null ? null : Gold.fromJson(json["firered-leafgreen"]),
        rubySapphire: json["ruby-sapphire"] == null ? null : Gold.fromJson(json["ruby-sapphire"]),
    );

    Map<String, dynamic> toJson() => {
        "emerald": emerald?.toJson(),
        "firered-leafgreen": fireredLeafgreen?.toJson(),
        "ruby-sapphire": rubySapphire?.toJson(),
    };
}

class OfficialArtwork {
    final String? frontDefault;
    final String? frontShiny;

    OfficialArtwork({
        this.frontDefault,
        this.frontShiny,
    });

    factory OfficialArtwork.fromJson(Map<String, dynamic> json) => OfficialArtwork(
        frontDefault: json["front_default"] ?? 'no data 5',
        frontShiny: json["front_shiny"],
    );

    Map<String, dynamic> toJson() => {
        "front_default": frontDefault,
        "front_shiny": frontShiny,
    };
}

class Home {
    final String? frontDefault;
    final dynamic frontFemale;
    final String? frontShiny;
    final dynamic frontShinyFemale;

    Home({
        this.frontDefault,
        this.frontFemale,
        this.frontShiny,
        this.frontShinyFemale,
    });

    factory Home.fromJson(Map<String, dynamic> json) => Home(
        frontDefault: json["front_default"] ?? 'no data 6',
        frontFemale: json["front_female"],
        frontShiny: json["front_shiny"],
        frontShinyFemale: json["front_shiny_female"],
    );

    Map<String, dynamic> toJson() => {
        "front_default": frontDefault,
        "front_female": frontFemale,
        "front_shiny": frontShiny,
        "front_shiny_female": frontShinyFemale,
    };
}

class GenerationVii {
    final DreamWorld? icons;
    final Home? ultraSunUltraMoon;

    GenerationVii({
        this.icons,
        this.ultraSunUltraMoon,
    });

    factory GenerationVii.fromJson(Map<String, dynamic> json) => GenerationVii(
        icons: json["icons"] == null ? null : DreamWorld.fromJson(json["icons"]),
        ultraSunUltraMoon: json["ultra-sun-ultra-moon"] == null ? null : Home.fromJson(json["ultra-sun-ultra-moon"]),
    );

    Map<String, dynamic> toJson() => {
        "icons": icons?.toJson(),
        "ultra-sun-ultra-moon": ultraSunUltraMoon?.toJson(),
    };
}

class DreamWorld {
    final String? frontDefault;
    final dynamic frontFemale;

    DreamWorld({
        this.frontDefault,
        this.frontFemale,
    });

    factory DreamWorld.fromJson(Map<String, dynamic> json) => DreamWorld(
        frontDefault: json["front_default"] ?? 'no data 7',
        frontFemale: json["front_female"],
    );

    Map<String, dynamic> toJson() => {
        "front_default": frontDefault,
        "front_female": frontFemale,
    };
}

class GenerationViii {
    final DreamWorld? icons;

    GenerationViii({
        this.icons,
    });

    factory GenerationViii.fromJson(Map<String, dynamic> json) => GenerationViii(
        icons: json["icons"] == null ? null : DreamWorld.fromJson(json["icons"]),
    );

    Map<String, dynamic> toJson() => {
        "icons": icons?.toJson(),
    };
}

class Stat {
    final int? baseStat;
    final int? effort;
    final Species? stat;

    Stat({
        this.baseStat,
        this.effort,
        this.stat,
    });

    factory Stat.fromJson(Map<String, dynamic> json) => Stat(
        baseStat: json["base_stat"],
        effort: json["effort"],
        stat: json["stat"] == null ? null : Species.fromJson(json["stat"]),
    );

    Map<String, dynamic> toJson() => {
        "base_stat": baseStat,
        "effort": effort,
        "stat": stat?.toJson(),
    };
}

class Type {
    final int? slot;
    final Species? type;

    Type({
        this.slot,
        this.type,
    });

    factory Type.fromJson(Map<String, dynamic> json) => Type(
        slot: json["slot"],
        type: json["type"] == null ? null : Species.fromJson(json["type"]),
    );

    Map<String, dynamic> toJson() => {
        "slot": slot,
        "type": type?.toJson(),
    };
}
