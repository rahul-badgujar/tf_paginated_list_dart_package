import 'package:flutter/material.dart';
import 'package:tf_paginated_list/tf_paginated_list.dart';

void main() {
  runApp(const MyApp());
}

class NaturalNumbersList extends TfPaginatedList<int> {
  NaturalNumbersList({
    required int pageLength,
  }) : super(pageLength: pageLength);

  @override
  Future<List<int>> loadItems(int limit, int offset) async {
    await Future.delayed(const Duration(seconds: 2));
    // allow only 100 numbers
    if (offset >= 100) {
      return <int>[];
    }
    return List<int>.generate(limit, (index) => offset + index + 1);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final naturalNumbersList = NaturalNumbersList(pageLength: 20);

  @override
  void initState() {
    super.initState();
    naturalNumbersList.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Natural Numbers')),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 8),
        child: StreamBuilder<List<int>>(
          stream: naturalNumbersList.stream,
          builder: (context, snapshot) {
            final numbersList = snapshot.data;
            if (numbersList == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final numOfItems = numbersList.length;
            return ListView.builder(
              itemCount: numOfItems + 1,
              itemBuilder: (context, index) {
                if (index == numOfItems) {
                  // load next page
                  naturalNumbersList.nextPage();
                  // show circular progress bar here
                  if (naturalNumbersList.hasMoreItemsToLoad) {
                    return const ListTile(
                      title: Text('Loading next page...'),
                    );
                  }
                  // if no more items to load, return nothing
                  return const SizedBox();
                } else {
                  final number = numbersList[index];
                  return ListTile(
                    title: Text('$number'),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
