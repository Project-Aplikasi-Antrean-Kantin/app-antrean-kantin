import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MyWidget extends StatelessWidget {
  final ScrollC = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("data"),
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: 100,
              itemScrollController: ScrollC,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('list item $index'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: IconButton(
        icon: Icon(
          Icons.favorite,
          color: Colors.pink,
          size: 24.0,
          semanticLabel: 'Text to announce in accessibility modes',
        ),
        onPressed: () {
          ScrollC.scrollTo(
              index: 40,
              duration: Duration(seconds: 1),
              curve: Curves.bounceIn);
        },
      ),
    );
  }
}
