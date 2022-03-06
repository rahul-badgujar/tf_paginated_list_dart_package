// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:tf_data_streamer/tf_data_streamer.dart';

abstract class TfPaginatedList<T> extends TfDataStreamer<List<T>> {
  int _nextPageToLoad = 1;
  int pageLength;
  List<T> availableItems = <T>[];
  bool _hasMoreToItems = true;

  TfPaginatedList({
    required this.pageLength,
  });

  @override
  void reload() {
    final reloadedItems = loadItems(pageLength, offset);
    reloadedItems.then((items) {
      availableItems = items;
      addData(availableItems);
    }, onError: (e) {
      addError(e);
    });
  }

  int get offset {
    return currentPageNo * pageLength;
  }

  bool get hasMoreItemsToLoad {
    return _hasMoreToItems;
  }

  int get currentPageNo {
    return _nextPageToLoad - 1;
  }

  Future<List<T>> loadItems(int limit, int offset);

  void nextPage() {
    final newItemsToPopulate =
        loadItems(pageLength, _nextPageToLoad * pageLength);
    newItemsToPopulate.then(
      (value) {
        // if new patrons list is empty, mark `hasMoreItems` false
        if (value.isEmpty) {
          _hasMoreToItems = false;
        }
        // append new page of patrons to list of patrons
        availableItems.addAll(value);
        // add event if streamer is open
        if (isOpen) {
          addData(availableItems);
        }
        // update the current page
        _nextPageToLoad++;
      },
      onError: (e) {
        addError(e);
      },
    );
  }
}
