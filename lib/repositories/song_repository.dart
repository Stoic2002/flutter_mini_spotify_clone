import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class SongRepository {
  final String baseUrl =
      'http://10.0.2.2:8000/api'; // Using 10.0.2.2 to access localhost from Android emulator

  Future<List<Song>> fetchSongs() async {
    final response = await http.get(Uri.parse('$baseUrl/songs'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      return jsonResponse.map((song) => Song.fromJson(song)).toList();
    } else {
      throw Exception('Failed to load songs');
    }
  }

  // Future<List<Song>> searchSongs(String query) async {
  //   final response =
  //       await http.get(Uri.parse('$baseUrl/songs/search?q=$query'));

  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body);
  //     return jsonResponse.map((song) => Song.fromJson(song)).toList();
  //   } else {
  //     throw Exception('Failed to search songs');
  //   }
  // }

  Future<List<Song>> searchSongs(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response =
        await http.get(Uri.parse('$baseUrl/songs/search?q=$encodedQuery'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((song) => Song.fromJson(song)).toList();
    } else {
      throw Exception('Failed to search songs: ${response.statusCode}');
    }
  }
}
