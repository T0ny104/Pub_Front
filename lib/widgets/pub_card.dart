import 'package:flutter/material.dart';
import '../../models/pubs.dart'; // Manteniamo l'import relativo per evitare errori sul nome del pacchetto

class PubCard extends StatelessWidget {
  const PubCard(this.pub, {super.key});

  final Pubs pub;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(
            'http://localhost:1337${pub.picture.url}',
          ),
        ),
        title: Text(pub.name, textAlign: TextAlign.justify),
        subtitle: Text(pub.address),
        trailing: Text(pub.avgPrice.toString()),
      ),
    );
  }
}