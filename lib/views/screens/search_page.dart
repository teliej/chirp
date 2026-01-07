import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  // final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<String> _allItems = [
    'Apple', 'Banana', 'Grapes', 'Mango', 'Orange', 'Pineapple', 'Strawberry'
  ];
  List<String> _filteredItems = [];
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  void _onSearchChanged(String query) {
    final results = _allItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredItems = results;
    });
  }

  void _clearSearch() {
    _controller.clear();
    _onSearchChanged('');
  }

  void _onSubmitSearch(String query) {
    _saveRecentSearch(query);
    _onSearchChanged(query);
  }

  void _openFilterSort() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter & Sort Options', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Sort Alphabetically'),
              onTap: () {
                setState(() {
                  _allItems.sort();
                  _onSearchChanged(_controller.text);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset'),
              onTap: () {
                setState(() {
                  _allItems = [
                    'Apple', 'Banana', 'Grapes', 'Mango', 'Orange', 'Pineapple', 'Strawberry'
                  ];
                  _onSearchChanged(_controller.text);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlightSearchText(String text, String query) {
    final theme = Theme.of(context);

    if (query.isEmpty) {
      return Text(text,  style: theme.textTheme.bodyMedium);
    } 

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();

    if (!textLower.contains(queryLower)) {
      return Text(text,  style: theme.textTheme.bodyMedium);
    }

    final start = textLower.indexOf(queryLower);
    final end = start + query.length;

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium, // 👈 base style applied here
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue, // 👈 keep your highlight color
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // keep transparent, content goes behind
          statusBarIconBrightness:
              theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness:
              theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ),
      );
    });


    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Back button (fixed size)
                IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.textTheme.bodyMedium?.color),
                  onPressed: () => Navigator.pop(context),
                ),

                // 🔍 Search Bar (takes remaining space)
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSubmitSearch,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                      labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      prefixIcon: Icon(Icons.search, color: theme.textTheme.bodyMedium?.color),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: theme.textTheme.bodyMedium?.color),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Filter button (fixed size)
                IconButton(
                  icon: Icon(Icons.filter_list, color: theme.textTheme.bodyMedium?.color),
                  onPressed: _openFilterSort,
                ),
              ],
            ),


            const SizedBox(height: 12),

            // 🕒 Recent Searches
            if (_recentSearches.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Recently",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(.5)),

                )
              ),

              const SizedBox(height: 5),

              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 20),
                  children: _recentSearches.map((search) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ActionChip(
                        label: Text(
                          search, 
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 12),
                        ),
                        backgroundColor: theme.inputDecorationTheme.fillColor,
                        onPressed: () {
                          _controller.text = search;
                          _onSearchChanged(search);
                        },
                        side: BorderSide(color: Colors.transparent),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // sugestions
            if (_recentSearches.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Suggestions",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(.5)),
                )
              ),
              
            const SizedBox(height: 5),
            // 📜 Search Results
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _filteredItems.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Icon(Icons.search_off, size: 90, color: theme.textTheme.bodyMedium?.color),
                          ),
                          const SizedBox(height: 10),
                          Text('No results found', style: theme.textTheme.bodyMedium),
                        ],
                      )
                    : ListView.builder(
                        key: ValueKey(_filteredItems.length),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return ListTile(
                            onTap: ()=> _onSubmitSearch(item),
                            dense: true,
                            minTileHeight: 20,
                            // contentPadding: const EdgeInsets.symmetric(vertical: 5),
                            title: _highlightSearchText(item, _controller.text),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
