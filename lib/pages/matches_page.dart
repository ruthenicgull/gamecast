// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../models/match_models.dart';
// import '../services/match_service.dart';

// class RecordEventsPage extends StatefulWidget {
//   final String matchId;
//   final String homeTeamName;
//   final String awayTeamName;

//   const RecordEventsPage({
//     super.key,
//     required this.matchId,
//     required this.homeTeamName,
//     required this.awayTeamName,
//   });

//   @override
//   _RecordEventsPageState createState() => _RecordEventsPageState();
// }

// class _RecordEventsPageState extends State<RecordEventsPage> {
//   final MatchService _matchService = MatchService();
//   final TextEditingController _eventMinuteController = TextEditingController();

//   String? _selectedTeamName;
//   String? _selectedPlayer1;
//   String? _selectedPlayer2;
//   EventType _selectedEventType = EventType.goal;

//   List<Player> _homeTeamPlayers = [];
//   List<Player> _awayTeamPlayers = [];
//   Team? _homeTeam;
//   Team? _awayTeam;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     print("init state");
//     _loadTeamsAndPlayers();
//   }

//   List<Player> parsePlayers(List<dynamic> playersData) {
//     return playersData.asMap().entries.map((entry) {
//       final playerId = entry.key
//           .toString(); // Use the index or a unique identifier if available
//       final playerData = entry.value as Map<String, dynamic>;
//       return Player.fromMap(playerData, playerId);
//     }).toList();
//   }

//   Future<void> _loadTeamsAndPlayers() async {
//     print("load team and players");
//     // setState(() {
//     //   _isLoading = true;
//     // });

//     try {
//       final matchRef =
//           FirebaseFirestore.instance.collection('matches').doc(widget.matchId);

//       DocumentReference homeTeamRef = matchRef.collection('teams').doc('home');
//       DocumentReference awayTeamRef = matchRef.collection('teams').doc('away');

//       DocumentSnapshot homeSnapshot = await homeTeamRef.get();
//       DocumentSnapshot awaySnapshot = await awayTeamRef.get();

//       List<dynamic> homePlayers = homeSnapshot.get('players') ?? [];
//       List<dynamic> awayPlayers = awaySnapshot.get('players') ?? [];

//       // print("teams found");

//       // print('Home Team Players: $homePlayers');
//       // print('Away Team Players: $awayPlayers');

//       List<Player> homeTeamPlayers = homePlayers.map((playerData) {
//         return Player.fromMap(playerData,
//             playerData['name']); // Using name as playerId for this example
//       }).toList();

//       List<Player> awayTeamPlayers = awayPlayers.map((playerData) {
//         return Player.fromMap(playerData,
//             playerData['name']); // Using name as playerId for this example
//       }).toList();

//       // print("Home Team Players: $homeTeamPlayers");
//       // print("Away Team Players: $awayTeamPlayers");

//       // print(homePlayers[0]);
//       print("Trying hometeam and awayteam");

//       final homeTeam = Team(
//         teamId: homeTeamRef.id,
//         teamName: homeSnapshot.get('team_name') ?? '' as String,
//         teamType: TeamType.home,
//         players: homeTeamPlayers,
//       );

//       final awayTeam = Team(
//         teamId: awayTeamRef.id,
//         teamName: awaySnapshot.get('team_name') ?? '' as String,
//         teamType: TeamType.away,
//         players: awayTeamPlayers,
//       );

//       print("homeTeam $homeTeam");
//       print(awayTeam.teamId);

//       setState(() {
//         _homeTeam = homeTeam;
//         _awayTeam = awayTeam;
//         _homeTeamPlayers = homeTeamPlayers;
//         _awayTeamPlayers = awayTeamPlayers;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showSnackbar('Error loading players: $e', isError: true);
//     }
//   }

//   List<String> _getAvailablePlayers() {
//     if (_selectedTeamName == null) return [];
//     final players = _selectedTeamName == widget.homeTeamName
//         ? _homeTeamPlayers
//         : _awayTeamPlayers;

//     return players.map((player) => player.name).toList();
//   }

//   Future<void> _recordEvent() async {
//     print(widget.matchId);
//     print("inside recordevent");
//     if (_validateForm()) {
//       try {
//         final selectedTeam =
//             _selectedTeamName == widget.homeTeamName ? _homeTeam! : _awayTeam!;

//         final player1 = _getPlayerByName(_selectedPlayer1!);
//         final player2 = _selectedPlayer2 != null
//             ? _getPlayerByName(_selectedPlayer2!)
//             : null;

//         print(_selectedEventType);
//         // final eventType = EventType.values.firstWhere(
//         //   (e) => e.toString().split('.').last == _selectedEventType,
//         //   orElse: () =>
//         //       throw ArgumentError('Invalid event type: $_selectedEventType'),
//         // );

//         // print(eventType);

//         print("problem starts");
//         final event = MatchEvent(
//           eventType: _selectedEventType,
//           eventMinute: int.parse(_eventMinuteController.text),
//           player1Id: player1.playerId,
//           player2Id: player2?.playerId,
//           teamId: selectedTeam.teamId,
//         );

//         await _matchService.addMatchEvent(widget.matchId, event);
//         print("problem ends");
//         _resetForm();
//         _showSnackbar('Event recorded successfully');
//       } catch (e) {
//         _showSnackbar('Error recording event: $e', isError: true);
//       }
//     }
//   }

//   Player _getPlayerByName(String playerName) {
//     final players = _selectedTeamName == widget.homeTeamName
//         ? _homeTeamPlayers
//         : _awayTeamPlayers;

//     return players.firstWhere(
//       (player) => player.name == playerName,
//       orElse: () => throw Exception('Player not found'),
//     );
//   }

//   bool _validateForm() {
//     if (_selectedTeamName == null) {
//       _showSnackbar('Please select a team', isError: true);
//       return false;
//     }
//     if (_selectedEventType == null) {
//       _showSnackbar('Please select an event type', isError: true);
//       return false;
//     }
//     if (_eventMinuteController.text.isEmpty) {
//       _showSnackbar('Please enter the event minute', isError: true);
//       return false;
//     }
//     if (_selectedPlayer1 == null) {
//       _showSnackbar('Please select the primary player', isError: true);
//       return false;
//     }
//     if (_selectedEventType == EventType.substitution &&
//         _selectedPlayer2 == null) {
//       _showSnackbar('Please select the substitute player', isError: true);
//       return false;
//     }
//     return true;
//   }

//   void _showSnackbar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   void _resetForm() {
//     setState(() {
//       _selectedTeamName = null;
//       _selectedPlayer1 = null;
//       _selectedPlayer2 = null;
//       _selectedEventType = EventType.goal;
//       _eventMinuteController.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Record Match Events'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildDropdown<String>(
//               label: 'Team',
//               value: _selectedTeamName,
//               items: [widget.homeTeamName, widget.awayTeamName],
//               onChanged: (value) => setState(() {
//                 _selectedTeamName = value;
//                 _selectedPlayer1 = null;
//                 _selectedPlayer2 = null;
//               }),
//             ),
//             _buildEventTypeDropdown(),
//             TextFormField(
//               controller: _eventMinuteController,
//               decoration: const InputDecoration(labelText: 'Minute'),
//               keyboardType: TextInputType.number,
//             ),
//             if (_selectedTeamName != null)
//               _buildDropdown<String>(
//                 label: 'Primary Player',
//                 value: _selectedPlayer1,
//                 items: _getAvailablePlayers(),
//                 onChanged: (value) => setState(() {
//                   _selectedPlayer1 = value;
//                 }),
//               ),
//             if (_selectedTeamName != null &&
//                 _selectedEventType == EventType.substitution)
//               _buildDropdown<String>(
//                 label: 'Substitute Player',
//                 value: _selectedPlayer2,
//                 items: _getAvailablePlayers(),
//                 onChanged: (value) => setState(() {
//                   _selectedPlayer2 = value;
//                 }),
//               ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _recordEvent,
//               child: const Text('Record Event'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown<T>({
//     required String label,
//     required T? value,
//     required List<T> items,
//     required void Function(T?) onChanged,
//   }) {
//     return DropdownButtonFormField<T>(
//       decoration: InputDecoration(labelText: label),
//       value: value,
//       items: items
//           .map((item) => DropdownMenuItem<T>(
//                 value: item,
//                 child: Text(item.toString()),
//               ))
//           .toList(),
//       onChanged: onChanged,
//     );
//   }

//   Widget _buildEventTypeDropdown() {
//     Map<EventType, String> eventTypeNames = {
//       EventType.goal: 'Goal',
//       EventType.yellowCard: 'Yellow Card',
//       EventType.redCard: 'Red Card',
//       EventType.substitution: 'Substitution',
//       EventType.foul: 'Foul',
//     };

//     return DropdownButtonFormField<EventType>(
//       decoration: const InputDecoration(labelText: 'Event Type'),
//       value: _selectedEventType,
//       items: EventType.values.map((type) {
//         return DropdownMenuItem<EventType>(
//           value: type,
//           child: Text(eventTypeNames[type] ?? ''),
//         );
//       }).toList(),
//       onChanged: (value) => setState(() {
//         _selectedEventType = value!;
//       }),
//     );
//   }

//   @override
//   void dispose() {
//     _eventMinuteController.dispose();
//     super.dispose();
//   }
// }

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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      final matches = await _matchService.getOngoingMatches();
      print('Fetched ${matches.length} ongoing matches');
      setState(() {
        ongoingMatches = matches;
      });
    } catch (e) {
      print('Failed to load ongoing matches: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load matches: $e'),
          duration: const Duration(seconds: 5),
        ),
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

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  bool _isLoading = true;
  bool _isNameEditing = false;
  bool _isEmailEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _fetchCurrentUserData();
  }

  Future<void> _fetchCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _nameController.text = doc['name'];
            _emailController.text = doc['email'];
            _isLoading = false;
          });
        } else {
          throw Exception('User data not found in Firestore.');
        }
      } else {
        throw Exception('No user is currently signed in.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    }
  }

  Future<void> _updateUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'email': _emailController.text,
        });
        setState(() {
          _isNameEditing = false;
          _isEmailEditing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      }
    } catch (e) {
      print('Error updating user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        // Navigate to login screen or home screen
        Navigator.of(context).pushReplacementNamed(
            '/login'); // Adjust this route name according to your app's routing
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to logout')),
        );
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required Function() onEditPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter your ${label.toLowerCase()}',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 48, 16),
              ),
              enabled: isEditing,
            ),
            Positioned(
              right: 8,
              child: IconButton(
                icon: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  color: Colors.grey,
                ),
                onPressed: onEditPressed,
                tooltip: isEditing ? 'Save' : 'Edit ${label.toLowerCase()}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: 'Name',
                    controller: _nameController,
                    isEditing: _isNameEditing,
                    onEditPressed: () {
                      if (_isNameEditing) {
                        _updateUserData();
                      } else {
                        setState(() {
                          _isNameEditing = true;
                          _isEmailEditing = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    isEditing: _isEmailEditing,
                    onEditPressed: () {
                      if (_isEmailEditing) {
                        _updateUserData();
                      } else {
                        setState(() {
                          _isEmailEditing = true;
                          _isNameEditing = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
