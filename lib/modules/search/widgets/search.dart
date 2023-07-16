import 'dart:ui' as ui;

import 'package:flutter/Material.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:flutter_nop/router.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../widgets/image_text.dart';
import '../../book_info/views/info_page.dart';
import '../../home/_import.dart';

class BookSearchPage extends SearchDelegate<void> {
  BookSearchPage({
    String? hintText,
    TextStyle? textStyle,
  }) : super(
            searchFieldLabel: '搜索关键字',
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.search,
            searchFieldStyle: textStyle);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: ui.Color.fromARGB(255, 247, 247, 247),
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
      // primaryTextTheme:
      //     theme.textTheme.copyWith(bodyText2: TextStyle(color: Colors.amber)),
      // colorScheme: theme.colorScheme.copyWith(primary: Colors.white)
    );
  }

  @override
  Widget buildLeading(BuildContext context) => InkWell(
      splashFactory: InkRipple.splashFactory,
      borderRadius: BorderRadius.circular(100),
      onTap: Nav.maybePop,
      child: SizedBox(
          // color: Colors.cyan,
          height: 100,
          width: 100,
          child: Icon(Icons.arrow_back, size: 30)));
  @override
  Widget buildSuggestions(BuildContext context) {
    return wrap(context, SingleChildScrollView(child: suggestions(context)));
  }

  Widget suggestions(BuildContext context) {
    return Cs(() {
      final bloc = context.grass<SearchNotifier>();
      final isLight = !context.isDarkMode;
      bloc.searchHistory;
      final ts = context.grass<TextStyleConfig>().data;
      return Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setstate) {
              return Wrap(
                children: [
                  for (var i in bloc.searchHistory.reversed)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(3.0),
                        color: isLight
                            ? Color.fromARGB(255, 220, 220, 220)
                            : const Color.fromRGBO(40, 40, 40, 1),
                        child: InkWell(
                          onLongPress: () {
                            bloc.delete(i);
                            setstate(() {});
                          },
                          onTap: () {
                            query = i;
                            showResults(context);
                          },
                          borderRadius: BorderRadius.circular(3.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Text(i, style: ts.body2),
                          ),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ),
      );
    });
  }

  Widget wrap(BuildContext context, Widget child) {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned(
            left: 16.0,
            bottom: 16.0,
            child: Material(
              color: Colors.grey[200],
              elevation: 4.0,
              borderRadius: BorderRadius.circular(50.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(50.0),
                splashColor: Colors.grey[400],
                onTap: () {
                  close(context, null);
                },
                child: Container(
                  height: 40,
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Center(
                      child: Text(
                    '返回',
                    style: TextStyle(color: Colors.grey.shade800),
                  )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final search = context.grass<SearchNotifier>();

    return wrap(
      context,
      Cs(() {
        final searchResult = search.list?.data;
        if (searchResult == null) {
          return loadingIndicator();
        }
        final searchLength = searchResult.length;

        return SearchPage(
          length: searchLength + 1,
          onTap: (index) {
            if (index == 0) {
              return;
            }
            index--;
            final data = searchResult[index];
            final id = int.tryParse('${data.id}');
            if (id != null) BookInfoPage.push(id, ApiType.biquge);
          },
          builder: (context, index) {
            if (index == 0) {
              return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 80),
                  child: suggestions(context));
            }
            index--;
            final data = searchResult[index];
            return ImageTextLayout(
                img: data.img,
                topRightScore: '${data.bookStatus}',
                top: data.name,
                center: '${data.cName} | ${data.author}',
                bottom: data.desc ?? '');
          },
        );
      }),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    final isLight = !context.isDarkMode;

    return [
      InkWell(
        splashColor: Colors.blue[700],
        borderRadius: BorderRadius.circular(50.0),
        onTap: () {
          showResults(context);
        },
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '搜索',
            style: TextStyle(
                color: isLight ? ui.Color.fromARGB(255, 238, 238, 238) : null),
          ),
        )),
      )
    ];
  }

  @override
  void showResults(BuildContext context) {
    if (query.isEmpty) return;
    context.grass<SearchNotifier>().load(query);
    super.showResults(context);
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
    required this.length,
    required this.onTap,
    required this.builder,
  }) : super(key: key);

  final int length;
  final void Function(int index) onTap;
  final Widget Function(BuildContext context, int index) builder;
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isLight = !context.isDarkMode;
    if (widget.length == 0) {
      return const SizedBox();
    }
    return Scrollbar(
      interactive: true,
      thickness: 8,
      controller: controller,
      child: ListViewBuilder(
          primary: false,
          scrollController: controller,
          itemCount: widget.length,
          padding: const EdgeInsets.only(bottom: 60.0),
          color: isLight
              ? const Color.fromRGBO(236, 236, 236, 1)
              : Color.fromRGBO(25, 25, 25, 1),
          itemBuilder: (context, index) {
            final child = widget.builder(context, index);

            return ListItem(
              height: 108,
              bgColor: isLight ? null : Colors.grey.shade900,
              splashColor: isLight ? null : Color.fromRGBO(60, 60, 60, 1),
              onTap: () {
                widget.onTap(index);
              },
              child: child,
            );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
