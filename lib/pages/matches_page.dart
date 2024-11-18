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
