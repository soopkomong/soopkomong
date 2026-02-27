import 'package:flutter/material.dart';
import 'package:soopkomong/presentation/collection/widgets/collection_sliding_tab.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(children: [Icon(Icons.book, size: 55), Text('도감')]),
            CollectionSlidingTab(),
          ],
        ),
      ),
    );
  }
}
