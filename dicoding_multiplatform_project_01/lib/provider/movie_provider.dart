import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class MovieProvider with ChangeNotifier {
  List<dynamic> _movies = [];
  String _palmResponse = "";

  List<dynamic> get movies => _movies;
  String get palmResponse => _palmResponse;

  Future<void> fetchMovies() async {
    const url = 'https://api.themoviedb.org/3/movie/popular?api_key=c134d59a441925eab703b8f8aab26c39';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    _movies = json['results'];

    notifyListeners();
  }

  Future<void> getMovieDetail(String title) async {
    print(title);
    var url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBcuicJmHn_Ep4ktUIbGT-fK7InK2wuYEs');
    var header = {'Content-Type': 'application/json'};
    var body = json.encode({
      "contents": [
        {
          "parts": [
            {
              "text": "Give details about movie $title. "
                  "Give the answer in a object "
                  "{title,releaseDate,directedBy,starring,minimumAge,runningTime,shortOverview}."
                  "releaseDate format is like January 1, 2024 minimumAge as integer, runningTime as integer and Starring as String like name 1, "
                  "name 2, name 3 not array, and shortOverview in 4 sentences"
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.9,
        "topK": 1,
        "topP": 1,
        "maxOutputTokens": 2048,
        "stopSequences": []
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ]
    });

    try {
      var response = await http.post(url, headers: header, body: body);
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        var text = decodedResponse['candidates'][0]['content']['parts'][0]['text'];
        print('--------------------');
        print(text);
        print('--------------------');
        _palmResponse = text;

      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
    notifyListeners();
  }
}
