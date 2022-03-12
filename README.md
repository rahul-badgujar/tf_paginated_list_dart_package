# tf_paginated_list

A list which loads the data items in paginated manner, pages by pages from the provided source of data items.

## Supported Dart Versions

**Dart SDK version ">=2.16.1 <3.0.0"**

## Installation

Add the Package

```yaml
dependencies:
  tf_paginated_list: ^1.0.0
```

## How to use

Import the package in your dart file

```dart
import 'package:tf_paginated_list/src/tf_paginated_list_base.dart';
```

### **To Create a Paginated List, loading items from a source**

```dart
// Create class representing your paginated list.
// Extend TfPaginatedList with type parameter matching to the type of items list will store.
//
// Example,
// The paginated list created below represent a paginated list of Natural Numbers.
// This class generates Natural Numbers for given limit and offset.
// This is a simple data items source.
class NaturalNumbersList extends TfPaginatedList<int> {
  NaturalNumbersList({
    required int pageLength,
  }) : super(pageLength: pageLength);

  // Implement loadItems() to provide implementation for your data items loading, supporting limit and offset
  @override
  Future<List<int>> loadItems(int limit, int offset) async {
    await Future.delayed(const Duration(seconds: 2));
    // This example allows only 100 numbers
    if (offset >= 100) {
      return <int>[];
    }
    // Generate integers for given range and return the list
    return List.generate(limit, (index) => offset + index + 1);
  }
}
```

### **To listen to the changes in paginated list as pages load**

```dart
// Creating instance and specify page length.
// Page length indicates how many items will be loaded per page.
final naturalNumbersGenerator = NaturalNumbersList(pageLength: 10);

// Do not forget to initialize
naturalNumbersGenerator.init();

// To listen to the changes in paginated list
naturalNumbersGenerator.stream.listen((event) {
    print(event);
});

// To load next page.
naturalNumbersGenerator.nextPage();

// To reload all currently loaded pages.
naturalNumbersGenerator.reload();

// To check if there are more pages can be loaded
if(naturalNumbersGenerator.hasMorePagesToLoad) {
    print('You can load more pages.');
}

// To access most recently loaded page (current page)
print(naturalNumbersGenerator.currentPageNo);

// Do not forget to dispose the instance after use
naturalNumbersGenerator.dispose();
```

### **To create an On-Demand Paginated ListView in Flutter**

```dart
// Creating the instance with required page length.
final naturalNumbersList = NaturalNumbersList(pageLength: 20);

// Initialize the instance in initState() of the widget.
@override
void initState() {
    super.initState();
    naturalNumbersList.init();
}

// Dispose the instance in dispose() of widget.
@override
void dispose() {
    naturalNumbersList.dispose();
    super.dispose();
}

/// Use stream builder to create paginated list
StreamBuilder<List<int>>(
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
```
