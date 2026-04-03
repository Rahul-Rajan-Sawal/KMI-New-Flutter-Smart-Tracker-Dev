import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bottom_nav/Activities/login_activity.dart';
import 'package:flutter_bottom_nav/Drawer/my_drawer_header.dart';
import 'package:flutter_bottom_nav/common/common_popup.dart';
import 'package:flutter_bottom_nav/core/static_variables.dart';
import 'package:flutter_bottom_nav/fragments/calendar_screen.dart';
import 'package:flutter_bottom_nav/fragments/create_lead_screen.dart';
import 'package:flutter_bottom_nav/fragments/dashboard_screen.dart';
import 'package:flutter_bottom_nav/fragments/search_lead_screen.dart';
import 'package:flutter_bottom_nav/fragments/setting_screen.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class MainScreen extends StatefulWidget {
final String user;
const MainScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}



class _MainScreenState extends State<MainScreen> {


void _printDBPath()async{
  final path = await getDatabasesPath();
  print("Database Path: " + path);
}

late final List<Widget>_pages;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  int _selectedIndex = 2;
  int _selectedDrawerIndex=0;




final List<Map<String,dynamic>>_drawerItems =[
  {"icon":Icons.schedule,"title" : "Schedule"},
  {"icon":Icons.notifications,"title" : "Notifications"},
  {"icon":Icons.person,"title" : "Add Customer Contact"},
  {"icon":Icons.face,"title" : "Add Agent Customer Details"},
  {"icon":Icons.construction,"title" : "Settings"},
  {"icon":Icons.loop_sharp,"title" : "Sync Data"},
  {"icon":Icons.delete_outline,"title" : "Clear App Data"},
  {"icon":Icons.contact_support,"title" : "About"},
  {"icon":Icons.power,"title" : "Logout"},

];

@override
  void initState() {
      super.initState();

      _printDBPath();
     _pages = const [
    SearchFragment(),
    CalendarScreen(),
    DashboardScreen(),
    CreateLeadScreen(),
    SettingScreen(),
  ];
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDrawerItemTap(int index){
    Navigator.pop(context);
    if(_drawerItems[index]["title"]=="Logout"){
      popUp();
      return; 
      }
    
      setState(() {
      _selectedDrawerIndex = index;
    });
   
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    //double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        popUp();
        return false;
      },
      child: Scaffold(
         
        key: _scaffoldKey,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading:IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),

          title: Column(
            children: [
              Image.asset(
                'assets/indusind_logo.png',
                height: screenHeight * 0.07,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),

        drawer: Drawer(
          child: Column(
            children: [
              MyHeaderDrawer(
                user:widget.user,
                username:StaticVariables.mUserName,
                designation :StaticVariables.mDesignation,
              ),
              Expanded(child: _buildDrawerList()),
            ],
          ),
        ),


//Commented by changes by Rahul
        // body: Column(
        //   children: [
        //     Expanded(
        //       child: IndexedStack(index: _selectedIndex, children: _pages),
        //     ),
        //   ],
        // ),

        body:SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),

        bottomNavigationBar: Stack(
          clipBehavior: Clip.none,
          children: [

            //Removed by RAhul for bottom nav
            // Positioned(
            //   bottom: 45, // controls overlap height
            //   left: 0,
            //   right: 0,
            //   child: Image.asset(
            //     'assets/page_footer.png',
            //     height: 40,
            //     fit: BoxFit.fill,
            //   ),
            // ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4A86FF),
                      Color(0xFF00C6FF)
                    ]
                  )
                ),
              )),

              
            CurvedNavigationBar(
              index: _selectedIndex,
              height: 65,
              color:Colors.white,
              backgroundColor: Colors.transparent,
              buttonBackgroundColor: Colors.white,
              animationDuration: const Duration(microseconds: 300),

              items: [
                  Icon(Icons.search, color: Colors.black),
                  Icon(Icons.calendar_today, color: Colors.black),
                  Icon(Icons.dashboard, color: Colors.black),
                  Icon(Icons.create, color: Colors.black),
                  Icon(Icons.settings, color: Colors.black),
                  
              ],

              onTap: _onItemTapped,

              ),

              Positioned(
                bottom: 1,
                left: 0,
                right: 0,

                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Bottomlabel(text:"Search"),
                      _Bottomlabel(text:"Calendar"),
                      _Bottomlabel(text:"Dashboard"),
                      _Bottomlabel(text:"Create lead"),
                      _Bottomlabel(text:"Settings"),

                    ],
                  ),
                )
              ),

            // ClipRRect(
            //   borderRadius: const BorderRadius.only(
            //     topLeft: Radius.circular(20),
            //     topRight: Radius.circular(20),
            //   ),
            //   child: BottomNavigationBar(
            //     type: BottomNavigationBarType.fixed,
            //     currentIndex: _selectedIndex,
            //     backgroundColor: Color(0xFF17479e),
            //     selectedItemColor: Colors.white,
            //     unselectedItemColor: Colors.white70,
            //     onTap: _onItemTapped,
            //     items: const [
            //       BottomNavigationBarItem(
            //         icon: Icon(Icons.search),
            //         label: 'Search Lead',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(Icons.calendar_month),
            //         label: 'Calendar',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(Icons.dashboard),
            //         label: 'Dashboard',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(Icons.add),
            //         label: 'Create Lead',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(Icons.settings),
            //         label: 'Setting',
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }


//Drawer LIst Builder
Widget _buildDrawerList(){
  return ListView.builder(
    itemCount: _drawerItems.length,
    itemBuilder: (context, index){
        final item = _drawerItems[index];

        return ListTile(
          leading: Icon(item["icon"],
          color: _selectedDrawerIndex == index ? Colors.blue:Colors.black),
          title: Text(
            item["title"],
            style: TextStyle(
              color: _selectedDrawerIndex == index ? Colors.blue :Colors.black,
            ),
          ),
          selected: _selectedDrawerIndex == index,
          onTap: () => _onDrawerItemTap(index),
        );
    },
  
  );
}

  void popUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CommonPopup(
          title: "Logout",
          message: "Are you sure you want to logout?",
          onNo: () {
            Navigator.of(dialogContext).pop(); // close dialog
          },
          onYes: () {
            Navigator.of(dialogContext).pop(); // close dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginActivity()),
            );
          },
        );
      },
    );
  }



  
}

class _Bottomlabel extends StatelessWidget{
  final String text;

  const _Bottomlabel({required this.text});
  


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      child: Text(
        text,
        textAlign: TextAlign.center,
      style:const TextStyle(
        fontSize: 11,
        color: Colors.black,
      ),

      ),
    );
  }}
