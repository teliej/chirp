import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (query.isEmpty) return Text(text);
    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();

    if (!textLower.contains(queryLower)) return Text(text);

    final start = textLower.indexOf(queryLower);
    final end = start + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, start), style: DefaultTextStyle.of(context).style),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(text: text.substring(end), style: DefaultTextStyle.of(context).style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSort,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              onSubmitted: _onSubmitSearch,
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🕒 Recent Searches
            if (_recentSearches.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _recentSearches.map((search) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(search),
                        onPressed: () {
                          _controller.text = search;
                          _onSearchChanged(search);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 12),

            // 📜 Search Results
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _filteredItems.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('No results found', style: theme.textTheme.bodyMedium),
                        ],
                      )
                    : ListView.builder(
                        key: ValueKey(_filteredItems.length),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return ListTile(
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
