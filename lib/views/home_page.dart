import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

import 'tabs_widgets/feed_tab.dart';
import 'tabs_widgets/chat_tab.dart';
import 'tabs_widgets/profile_tab.dart';
import 'tabs_widgets/notifications_tab.dart';
import 'tabs_widgets/create_post_page.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}




class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  int _lastIndex = 0; // to track previous tab


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != 2 && !_tabController.indexIsChanging) {
        _lastIndex = _tabController.index;
      }
      setState(() {}); // Rebuild to update FAB visibility
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  final List<String> tabName = ['Chirp', 'Chat', 'Post','Notification', 'Profile'];


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


    floatAction(int pageIndex){
      switch (pageIndex) {
        case 0:
          return FloatingActionButton(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            // backgroundColor: theme.colorScheme.primary,
            backgroundColor: Provider.of<ThemeProvider>(context, listen: false).isDarkMode 
              ? Colors.grey[700]
              : Colors.grey[500],
              // : theme.textTheme.bodyMedium?.color,
            child: 
              Provider.of<ThemeProvider>(context, listen: false).isDarkMode 
                ? Icon(
                    Icons.light_mode,
                    size: 22, color: theme.textTheme.bodyLarge?.color)
                : Icon(
                    Icons.dark_mode,
                    size: 22, color: theme.textTheme.bodyLarge?.color)
          );
        case 1:
          return FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Start a new message')),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.message,
                  size: 22, color: theme.colorScheme.onPrimary),
            );
        case 3:
          return FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search notifications comming soon!')),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.search,
                  size: 22, color: theme.colorScheme.onPrimary),
            );
        default:
          return null;
      }
    }


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // extendBody: true,
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
        Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
              surfaceTintColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
              // backgroundColor: Colors.transparent,
              title: Text(tabName[_tabController.index],
                style: TextStyle(fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color),
              ),
              actions: [
                IconButton(
                  onPressed: (){
                      Navigator.pushNamed(context, '/search');
                  },
                  icon: Icon(Icons.search))
              ],
            ),
            body: FeedTab(),
          ),

        Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
              surfaceTintColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
              // backgroundColor: Colors.transparent,
              title: Text(tabName[_tabController.index],
                style: TextStyle(fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color),
              ),
              actions: [
                PopupMenuButton<String>(
                  color: theme.scaffoldBackgroundColor,
                  constraints: BoxConstraints(
                    minWidth: 100,
                    maxWidth: 180,
                    minHeight: 0,
                    maxHeight: 400,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'Toggle Theme') {
                      // Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      'New Group',
                      'New broadcast',
                      'Linked devices',
                      'Starred',
                      'Read all',
                      'Settings',
                      'Toggle Theme'
                    ].map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: ChatsTab(),
          ),

        Container(),

        Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
              surfaceTintColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
              // backgroundColor: Colors.transparent,
              title: Text(tabName[_tabController.index],
                style: TextStyle(fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color),
              ),
            ),
            body: NotificationTab(),
          ),

        Scaffold(
            body: ProfileTab(),
          ),
        ],
      ),

      floatingActionButton: floatAction(_tabController.index),

      bottomNavigationBar: SizedBox(
        height: 60,
        child: Material(
          color: theme.scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            indicator: DotIndicator(color: theme.colorScheme.primary),
            // indicatorSize: TabBarIndicatorSize.label,
            // unselectedLabelColor: theme.unselectedWidgetColor,
            dividerColor: Colors.transparent,
            unselectedLabelColor: theme.textTheme.bodyLarge?.color,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            onTap: (index) {
              if (index == 2) {
                _tabController.index = _lastIndex;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreatePostPage()),
                );
              }
            },
            tabs: [
              Icon(Icons.home),
              Icon(Icons.chat),
              // Icon(Icons.add_box_outlined),
              Icon(Icons.add_circle_outline_outlined, size: 40),

              // Icon(Icons.add_circle_outline, color: theme.primaryColor, size: 40,),
              // Stack(
              //   clipBehavior: Clip.none,
              //   alignment: Alignment.center,
              //   children: [
              //     SizedBox(),
              //     Positioned(
              //       bottom: -15,
              //       child: Icon(Icons.add_circle_outline, color: theme.primaryColor, size: 40,),
              //     ),
              //   ]
              // ),
              
              Icon(Icons.notifications_active),
              Icon(Icons.person),
            ],
          ),
        ),
      )
    );
  }
}


    // tabs: const [
    //   Tab(icon: Icon(Icons.home), text: "Home"),
    //   Tab(icon: Icon(Icons.chat), text: "Chat"),
    //   Tab(icon: Icon(Icons.add_circle_outline), text: "Create"),
    //   Tab(icon: Icon(Icons.notifications_active_outlined), text: "Notify"),
    //   Tab(icon: Icon(Icons.people), text: "Communities"),
    // ],



  //   Text(
  //   "Communities",
  //   overflow: TextOverflow.ellipsis,  // … if too long
  //   maxLines: 1,
  //   style: TextStyle(fontSize: 12),   // shrink text a bit
  // ),






class DotIndicator extends Decoration {
  final Color? color;
  const DotIndicator({this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DotPainter(color: color);
  }
}

class _DotPainter extends BoxPainter {
  final Color? color;
  _DotPainter({this.color});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final Paint paint = Paint()
      ..color = color ?? Colors.blueAccent
      ..style = PaintingStyle.fill;

    final Offset circleOffset = Offset(
      config.size!.width / 2 + offset.dx,
      config.size!.height - 6,
    );

    canvas.drawCircle(circleOffset, 4, paint);
  }
}
