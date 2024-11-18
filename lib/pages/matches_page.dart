// import 'package:flutter/material.dart';
// import 'package:gamecast/pages/add_match_page.dart';
// import 'package:gamecast/pages/match_page.dart';
// import '../widgets/match_card.dart';
// import '../services/match_service.dart';
// import 'package:gamecast/models/match_models.dart';

// class MatchesPage extends StatefulWidget {
//   const MatchesPage({super.key});

//   @override
//   _MatchesPageState createState() => _MatchesPageState();
// }

// class _MatchesPageState extends State<MatchesPage> {
//   final MatchService _matchService = MatchService();
//   DateTime selectedDate = DateTime.now();
//   List<FullMatchData> matches = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadMatches();
//   }

//   Future<void> _loadMatches() async {
//     final matchesList = await _matchService.getAllMatches();
//     setState(() {
//       matches = matchesList;
//     });
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2025),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//       _loadMatches();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Matches'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_today),
//             onPressed: () => _selectDate(context),
//           ),
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => AddMatchPage()),
//             ),
//           ),
//         ],
//       ),
//       // body: ListView.builder(
//       //     itemCount: matches.length,
//       //     itemBuilder: (context, index) {
//       //       return MatchCard(
//       //         matchData: matches[index],
//       //         onTap: () => Navigator.push(
//       //           context,
//       //           MaterialPageRoute(
//       //             builder: (context) => MatchPage(matchData: matches[index]),
//       //           ),
//       //         ),
//       //       );
//       //     }),
//       body: matches.isEmpty
//           ? const Center(
//               child: Text('No matches found'),
//             )
//           : ListView.builder(
//               itemCount: matches.length,
//               itemBuilder: (context, index) {
//                 return MatchCard(
//                   matchData: matches[index],
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           MatchPage(matchData: matches[index]),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:gamecast/pages/add_match_page.dart';
import 'package:gamecast/pages/match_page.dart';
import '../widgets/match_card.dart';
import '../services/match_service.dart';
import 'package:gamecast/models/match_models.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeTab(),
    const MyMatchesTab(),
    const PastMatchesTab(),
    const UsersTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Required when more than 3 items
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'My Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Past Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
      ),
    );
  }
}

// Home Tab - Shows ongoing matches
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final MatchService _matchService = MatchService();
  List<FullMatchData> ongoingMatches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOngoingMatches();
  }

  Future<void> _loadOngoingMatches() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Assuming you'll add a method in MatchService to get ongoing matches
      final matches = await _matchService.getOngoingMatches();
      setState(() {
        ongoingMatches = matches;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load matches: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMatchPage()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ongoingMatches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sports_soccer,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No ongoing matches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadOngoingMatches,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: ongoingMatches.length,
                  itemBuilder: (context, index) {
                    return MatchCard(
                      matchData: ongoingMatches[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MatchPage(matchData: ongoingMatches[index]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// My Matches Tab - Shows matches hosted by the current user
class MyMatchesTab extends StatefulWidget {
  const MyMatchesTab({super.key});

  @override
  _MyMatchesTabState createState() => _MyMatchesTabState();
}

class _MyMatchesTabState extends State<MyMatchesTab> {
  final MatchService _matchService = MatchService();
  List<FullMatchData> myMatches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMyMatches();
  }

  Future<void> _loadMyMatches() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Assuming you'll add a method in MatchService to get user's matches
      final matches = await _matchService.getUserMatches();
      setState(() {
        myMatches = matches;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Matches'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : myMatches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sports_soccer,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'You haven\'t hosted any matches yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadMyMatches,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: myMatches.length,
                  itemBuilder: (context, index) {
                    return MatchCard(
                      matchData: myMatches[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MatchPage(matchData: myMatches[index]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// Past Matches Tab
class PastMatchesTab extends StatefulWidget {
  const PastMatchesTab({super.key});

  @override
  _PastMatchesTabState createState() => _PastMatchesTabState();
}

class _PastMatchesTabState extends State<PastMatchesTab> {
  final MatchService _matchService = MatchService();
  List<FullMatchData> pastMatches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPastMatches();
  }

  Future<void> _loadPastMatches() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Assuming you'll add a method in MatchService to get past matches
      final matches = await _matchService.getPastMatches();
      setState(() {
        pastMatches = matches;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Matches'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pastMatches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No past matches found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadPastMatches,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: pastMatches.length,
                  itemBuilder: (context, index) {
                    return MatchCard(
                      matchData: pastMatches[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MatchPage(matchData: pastMatches[index]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// Users Tab
class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: const Center(
        child: Text('Users tab content'), // Implement your users list here
      ),
    );
  }
}
