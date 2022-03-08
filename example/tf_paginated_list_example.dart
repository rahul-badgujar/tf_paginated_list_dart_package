import 'dart:async';

import 'package:tf_paginated_list/src/tf_paginated_list_base.dart';

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
    return List.generate(limit, (index) => offset + index + 1);
  }
}

void main() {
  final naturalNumbersGenerator = NaturalNumbersList(pageLength: 10);
  naturalNumbersGenerator.init();
  naturalNumbersGenerator.stream.listen((event) {
    print(event);
  });
  Timer.periodic(Duration(seconds: 2), (timer) {
    naturalNumbersGenerator.nextPage();
  });
}
