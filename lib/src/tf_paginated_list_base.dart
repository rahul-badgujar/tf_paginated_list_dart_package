// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:tf_data_streamer/tf_data_streamer.dart';

///
/// TfPaginatedList
///
/// A list which the loads data items in paginated matter, pages by pages from the provided source of data items.
///
abstract class TfPaginatedList<T> extends TfDataStreamer<List<T>> {
  // The very next page to loa
  int _nextPageToLoad = 1;
  // The length of items in one page.
  final int _pageLength;
  // The list of the items loaded for the loaded pages.
  List<T> _loadedItems = <T>[];
  // Flag to represent if the source has more items to load or not.
  bool _hasMoreToItems = true;

  TfPaginatedList({
    required int pageLength,
  }) : _pageLength = pageLength;

  ///
  /// Reloads the all the already loaded pages and items in those pages.
  ///
  @override
  void reload() {
    // Reload again the whole offset of items available.
    final reloadedItems = loadItems(_pageLength, currentPageNo * _pageLength);
    reloadedItems.then((items) {
      _loadedItems = items;
      addData(_loadedItems);
    }, onError: (e) {
      addError(e);
    });
  }

  ///
  /// Length of page i.e., number of items loaded for one page.
  ///
  int get pageLength {
    return _pageLength;
  }

  ///
  /// Returns `true` if there are more pages to load, otherwise returns `false`.
  ///
  bool get hasMorePagesToLoad {
    return _hasMoreToItems;
  }

  /// The page number of most recently loaded page.
  ///
  /// Note: Page Numbering starts from 0.
  int get currentPageNo {
    return _nextPageToLoad - 1;
  }

  ///
  /// Add your implementation for the source of data items here. \
  /// The source is supposed to support traditional pagination paramers viz., `limit` and `offset`.
  ///
  /// `limit`: The limit of items to be loaded, essentially the page length. \
  /// `offset`: Offset to start loading page from.
  ///
  Future<List<T>> loadItems(int limit, int offset);

  ///
  /// Load the next page.
  ///
  void nextPage() {
    final newItemsToPopulate =
        loadItems(_pageLength, _nextPageToLoad * _pageLength);
    newItemsToPopulate.then(
      (value) {
        // if new list of new items loaded is empty
        if (value.isEmpty) {
          // there are essentially no more items to load
          _hasMoreToItems = false;
        }
        // append new page items to loaded items
        _loadedItems.addAll(value);
        // add event if streamer is open
        if (isOpen) {
          addData(_loadedItems);
        }
        // update the next page
        _nextPageToLoad++;
      },
      onError: (e) {
        addError(e);
      },
    );
  }
}
