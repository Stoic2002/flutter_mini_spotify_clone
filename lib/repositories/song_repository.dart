import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class SongRepository {
  final String baseUrl = 'https://9b4d-36-73-33-38.ngrok-free.app/api';

  Future<List<Song>> fetchSongs() async {
    final response = await http.get(Uri.parse('$baseUrl/songs'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      return jsonResponse.map((song) => Song.fromJson(song)).toList();
    } else {
      throw Exception('Failed to load songs');
    }
  }

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
