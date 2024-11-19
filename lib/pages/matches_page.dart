import 'package:flutter/material.dart';
import 'package:gamecast/pages/add_match_page.dart';
import 'package:gamecast/pages/match_page.dart';
import '../widgets/match_card.dart';
import '../services/match_service.dart';
import 'package:gamecast/models/match_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/EventBasedPredictor.dart';

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
            icon: Icon(Icons.sports_soccer),
            label: 'Live',
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
            icon: Icon(Icons.person),
            label: 'User',
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

//71 to 179
// class _HomeTabState extends State<HomeTab> {
//   final MatchService _matchService = MatchService();
//   List<FullMatchData> ongoingMatches = [];
//   Map<String, MatchPrediction> predictions = {};
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadOngoingMatches();
//   }

//   Future<void> _loadOngoingMatches() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final matches = await _matchService.getOngoingMatches();
//       // Calculate predictions for each match
//       final matchPredictions = <String, MatchPrediction>{};
//       for (var match in matches) {
//         matchPredictions[match.match.matchId] =
//             EventBasedPredictor.predictMatch(match);
//       }

//       setState(() {
//         ongoingMatches = matches;
//         predictions = matchPredictions;
//       });
//     } catch (e) {
//       print('Failed to load ongoing matches: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load matches: $e'),
//           duration: const Duration(seconds: 5),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Matches'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const AddMatchPage()),
//             ),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ongoingMatches.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.sports_soccer,
//                         size: 64,
//                         color: Colors.grey,
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'No ongoing matches',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextButton(
//                         onPressed: _loadOngoingMatches,
//                         child: const Text('Refresh'),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: ongoingMatches.length,
//                   itemBuilder: (context, index) {
//                     final match = ongoingMatches[index];
//                     return MatchCard(
//                       matchData: match,
//                       prediction: predictions[match.match.matchId],
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => MatchPage(matchData: match),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

class _HomeTabState extends State<HomeTab> {
  final MatchService _matchService = MatchService();
  List<FullMatchData> ongoingMatches = [];
  Map<String, MatchPrediction> predictions = {};
  bool _isLoading = false;
  bool _isDataLoaded = false; // To track if data is already loaded

  @override
  void initState() {
    super.initState();
    _loadOngoingMatches(); // Load data initially
  }

  Future<void> _loadOngoingMatches({bool forceRefresh = false}) async {
    // Skip loading if data is already loaded and refresh is not forced
    if (_isDataLoaded && !forceRefresh) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final matches = await _matchService.getOngoingMatches();

      // Calculate predictions for each match
      final matchPredictions = <String, MatchPrediction>{};
      for (var match in matches) {
        matchPredictions[match.match.matchId] =
            EventBasedPredictor.predictMatch(match);
      }

      setState(() {
        ongoingMatches = matches;
        predictions = matchPredictions;
        _isDataLoaded = true; // Mark data as loaded
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
        centerTitle: true, // This centers the title
        title: const Text(
          'Live Matches',
          style: TextStyle(
            fontSize: 20, // Set your desired font size
            fontWeight: FontWeight.bold, // Apply bold styling
            color: Colors.black, // Set the text color
          ),
        ),
      ),
      body: _isLoading && ongoingMatches.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadOngoingMatches(forceRefresh: true),
              child: ongoingMatches.isEmpty
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
                            onPressed: () =>
                                _loadOngoingMatches(forceRefresh: true),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: ongoingMatches.length,
                      itemBuilder: (context, index) {
                        final match = ongoingMatches[index];
                        return MatchCard(
                          matchData: match,
                          prediction: predictions[match.match.matchId],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchPage(matchData: match),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMatchPage()),
        ),
        child: const Icon(Icons.add),
        tooltip: 'Add Match',
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

  Future<void> _refreshMatches() async {
    // Trigger the refresh logic when the user pulls down
    await _loadMyMatches(); // Same as the initial load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // This centers the title
        title: const Text(
          'My Matches',
          style: TextStyle(
            fontSize: 20, // Set your desired font size
            fontWeight: FontWeight.bold, // Apply bold styling
            color: Colors.black, // Set the text color
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMatches, // Call the refresh logic
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : myMatches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sports_soccer,
                          size: 64,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'You haven\'t hosted any matches yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadMyMatches,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Refresh',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0), // Padding for ListView
                    child: ListView.builder(
                      itemCount: myMatches.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: MatchCard(
                            matchData: myMatches[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MatchPage(matchData: myMatches[index]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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

  Future<void> _refreshMatches() async {
    // Trigger the refresh logic when the user pulls down
    await _loadPastMatches(); // Same as the initial load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // This centers the title
        title: const Text(
          'Past Matches',
          style: TextStyle(
            fontSize: 20, // Set your desired font size
            fontWeight: FontWeight.bold, // Apply bold styling
            color: Colors.black, // Set the text color
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMatches, // Call the refresh logic
        child: _isLoading
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
                        ElevatedButton(
                          onPressed: _loadPastMatches,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Refresh',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0), // Padding for ListView
                    child: ListView.builder(
                      itemCount: pastMatches.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: MatchCard(
                            matchData: pastMatches[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MatchPage(matchData: pastMatches[index]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
