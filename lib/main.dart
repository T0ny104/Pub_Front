import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_01/models/pubs.dart';
import 'package:flutter_01/widgets/pub_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Pubs> _listPubs = [];
  late Future<String> futurePubs;

  @override
  void initState() {
    super.initState();
    // Chiamiamo la funzione passando opzionalmente il maxPrice richiesto (default 15)
    futurePubs = getPubs(_listPubs, maxPrice: 15);
  }

  Widget _buildPubs() {
    return FutureBuilder(
      future: futurePubs,
      builder: (context, projectSnap) {
        // 1. Se sta ancora caricando, mostra una rotellina di caricamento anziché lo schermo bianco
        if (projectSnap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 2. Se c'è un errore, mostra il testo dell'errore
        if (projectSnap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Errore: ${projectSnap.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // 3. Se non ci sono dati o la lista è vuota
        if (!projectSnap.hasData || _listPubs.isEmpty) {
          return const Center(
            child: Text("Nessun pub economico trovato o dati vuoti."),
          );
        }

        // 4. Se tutto è OK, mostra la lista
        return ListView.builder(
          itemCount: _listPubs.length,
          itemBuilder: (context, index) {
            return PubCard(_listPubs[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Affordable Pubs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildPubs(),
      ),
    );
  }
}

Future<String> getPubs(List<Pubs> listPubs, {int maxPrice = 15}) async {
  // Richiesta all'endpoint custom con il query parameter maxPrice
  final http.Response response = await http.get(
    Uri.parse('http://localhost:1337/api/pubs/affordable?maxPrice=$maxPrice'),
  );

  if (response.statusCode == 200) {
    listPubs.clear(); // Pulisce la lista per evitare duplicati
    
    var decodedData = jsonDecode(response.body);
    
    // Gestione della risposta (supporta sia se restituisce direttamente la lista sia se usa il wrapper 'data')
    List<dynamic> pubsListRaw = decodedData is List ? decodedData : decodedData['data'];

    for (var i = 0; i < pubsListRaw.length; i++) {
      listPubs.add(Pubs.fromJson(pubsListRaw[i]));
    }
    return "Success!";
  } else {
    throw Exception('Failed to load data: Status ${response.statusCode}');
  }
}