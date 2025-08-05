import 'dart:convert';

CharacterModel? characterModelFromJson(String str) =>
    CharacterModel.fromJson(json.decode(str));

String characterModelToJson(CharacterModel? data) =>
    json.encode(data?.toJson());

class CharacterModel {
  final Info? info;
  final List<Result>? results;

  CharacterModel({
    this.info,
    this.results,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
        info: json["info"] != null ? Info.fromJson(json["info"]) : null,
        results: json["results"] != null
            ? List<Result>.from(
                json["results"].map((x) => Result.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "info": info?.toJson(),
        "results": results?.map((x) => x.toJson()).toList(),
      };
}

class Info {
  final int? count;
  final int? pages;
  final String? next;
  final dynamic prev;

  Info({
    this.count,
    this.pages,
    this.next,
    this.prev,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
        count: json["count"],
        pages: json["pages"],
        next: json["next"],
        prev: json["prev"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "pages": pages,
        "next": next,
        "prev": prev,
      };
}

class Result {
  final int? id;
  final String? name;
  final Status? status;
  final Species? species;
  final String? type;
  final Gender? gender;
  final Location? origin;
  final Location? location;
  final String? image;
  final List<String>? episode;
  final String? url;
  final DateTime? created;

  Result({
    this.id,
    this.name,
    this.status,
    this.species,
    this.type,
    this.gender,
    this.origin,
    this.location,
    this.image,
    this.episode,
    this.url,
    this.created,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        status: statusValues.map[json["status"]],
        species: speciesValues.map[json["species"]],
        type: json["type"],
        gender: genderValues.map[json["gender"]],
        origin:
            json["origin"] != null ? Location.fromJson(json["origin"]) : null,
        location: json["location"] != null
            ? Location.fromJson(json["location"])
            : null,
        image: json["image"],
        episode: json["episode"] != null
            ? List<String>.from(json["episode"].map((x) => x))
            : null,
        url: json["url"],
        created:
            json["created"] != null ? DateTime.parse(json["created"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": statusValues.reverse[status],
        "species": speciesValues.reverse[species],
        "type": type,
        "gender": genderValues.reverse[gender],
        "origin": origin?.toJson(),
        "location": location?.toJson(),
        "image": image,
        "episode": episode?.map((x) => x).toList(),
        "url": url,
        "created": created?.toIso8601String(),
      };
}

enum Gender { FEMALE, MALE, UNKNOWN }

final genderValues = EnumValues({
  "Female": Gender.FEMALE,
  "Male": Gender.MALE,
  "unknown": Gender.UNKNOWN,
});

class Location {
  final String? name;
  final String? url;

  Location({
    this.name,
    this.url,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "url": url,
      };
}

enum Species { ALIEN, HUMAN }

final speciesValues = EnumValues({
  "Alien": Species.ALIEN,
  "Human": Species.HUMAN,
});

enum Status { ALIVE, DEAD, UNKNOWN }

final statusValues = EnumValues({
  "Alive": Status.ALIVE,
  "Dead": Status.DEAD,
  "unknown": Status.UNKNOWN,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
