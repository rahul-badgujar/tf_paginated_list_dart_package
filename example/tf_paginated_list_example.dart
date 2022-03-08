import 'dart:async';

import 'package:tf_paginated_list/src/tf_paginated_list_base.dart';

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
    return List.generate(limit, (index) => offset + index + 1);
  }
}

void main() {
  // Create instance
  final naturalNumbersGenerator = NaturalNumbersList(pageLength: 10);
  // Do not forget to initialize
  naturalNumbersGenerator.init();
  // Listen to the changes in paginated list
  naturalNumbersGenerator.stream.listen((event) {
    print(event);
  });
  Timer.periodic(Duration(seconds: 2), (timer) {
    // Load next page periodically.
    naturalNumbersGenerator.nextPage();
  });

  // Note: Do not forget to dispose the instance created like
  //  naturalNumbersGenerator.dispose()

  // Also see flutter_example to see how to use this package with Flutter.
  // This can be used in flutter to create Lazily Loading Lists.
}
