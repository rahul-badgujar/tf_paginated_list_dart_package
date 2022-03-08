import 'package:flutter/material.dart';
import 'package:tf_paginated_list/tf_paginated_list.dart';

void main() {
  runApp(const MyApp());
}

//
// Example
//
// This class generates Natural Numbers for given limit and offset.
// This is a simple data items source.
//
// Creating a class representing the data items source and extending TfPaginatedList with required generic type.
//
class NaturalNumbersList extends TfPaginatedList<int> {
  NaturalNumbersList({
    required int pageLength,
  }) : super(pageLength: pageLength);

  // Implement loadItems() to provide implementation for your data items loading, supporting limit and offset
  @override
  Future<List<int>> loadItems(int limit, int offset) async {
    await Future.delayed(const Duration(seconds: 2));
    // this example allows only 100 numbers
    if (offset >= 100) {
      return <int>[];
    }
    // generate integers for given range and return the list
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
  void dispose() {
    naturalNumbersList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Natural Numbers')),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 8),
        // Use stream builder to build the items in UI listening to changes in paginated list.
        child: StreamBuilder<List<int>>(
          stream: naturalNumbersList.stream,
          builder: (context, snapshot) {
            final numbersList = snapshot.data;
            // showing Circular Progress Indicator while the first page is being load.
            if (numbersList == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final numOfItems = numbersList.length;
            // Using ListView.builder() to support on-demand building of item widgets.
            return ListView.builder(
              // Providing itemsCount as 1 more than the actual size of available items.
              // This is done to initiate loading next page if the items list is scrolled till bottom.
              itemCount: numOfItems + 1,
              itemBuilder: (context, index) {
                // If this is the bottom of list of available items
                if (index == numOfItems) {
                  // Load next page.
                  naturalNumbersList.nextPage();
                  // Check if more pages can be loaded
                  if (naturalNumbersList.hasMorePagesToLoad) {
                    // Return widget indicating Next Page Loading status.
                    return const ListTile(
                      title: Text('Loading next page...'),
                    );
                  }
                  // If no more items to load,
                  // we don't show anything to end of list to indicate
                  // end of list of items available to load.
                  return const SizedBox();
                } else {
                  // For the available items, showing the Item Widget.
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
