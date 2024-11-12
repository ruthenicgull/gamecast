import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamecast/components/event_card.dart';
import 'package:gamecast/components/event_form.dart';
import 'package:gamecast/models/event_model.dart';
import 'package:gamecast/models/match_model.dart';
import 'package:gamecast/components/base_scaffold.dart';

class LiveMatchRecordingPage extends StatefulWidget {
  const LiveMatchRecordingPage({super.key});

  @override
  _LiveMatchRecordingPageState createState() => _LiveMatchRecordingPageState();
}

class _LiveMatchRecordingPageState extends State<LiveMatchRecordingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _homeTeam;
  String? _awayTeam;
  DateTime? _matchDateTime;
  bool _isRecording = false;
  String? _matchId;

  Future<void> _startNewMatch() async {
    final matchDoc = await _firestore.collection('matches').add({
      'home': _homeTeam,
      'away': _awayTeam,
      'matchDateTime': _matchDateTime?.toIso8601String(),
      'events': [],
    });
    _matchId = matchDoc.id;
  }

  Future<void> _addEvent(MatchEvent event) async {
    if (_matchId != null) {
      await _firestore.collection('matches').doc(_matchId).update({
        'events': FieldValue.arrayUnion([event.toMap()]),
      });
    }
  }

  void _showAddEventDialog() {
    final match = Match(
      id: _matchId!,
      homeTeam: _homeTeam!,
      awayTeam: _awayTeam!,
      matchDateTime: _matchDateTime!,
      events: [],
    );

    showDialog(
      context: context,
      builder: (context) => EventForm(
        match: match,
        onSave: _addEvent,
      ),
    );
  }

  void _startRecording() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _startNewMatch();
      setState(() {
        _isRecording = true;
      });
    }
  }

  // Date Picker function
  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _matchDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null && selectedDate != _matchDateTime) {
      setState(() {
        _matchDateTime = selectedDate;
      });
    }
  }

  // Time Picker function
  Future<void> _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_matchDateTime ?? DateTime.now()),
    );

    if (selectedTime != null) {
      final DateTime newDateTime = DateTime(
        _matchDateTime?.year ?? DateTime.now().year,
        _matchDateTime?.month ?? DateTime.now().month,
        _matchDateTime?.day ?? DateTime.now().day,
        selectedTime.hour,
        selectedTime.minute,
      );

      setState(() {
        _matchDateTime = newDateTime;
      });
    }
  }

  Widget _buildInitialSetupForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Home Team Name'),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the home team name'
                : null,
            onSaved: (value) => _homeTeam = value,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Away Team Name'),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the away team name'
                : null,
            onSaved: (value) => _awayTeam = value,
          ),
          // Date and Time Picker
          Row(
            children: [
              Text(_matchDateTime == null
                  ? 'Select Date and Time'
                  : '${_matchDateTime!.toLocal()}'),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDate,
              ),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: _selectTime,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startRecording,
            child: const Text("Start Recording"),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('matches').doc(_matchId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(child: Text("No data available."));
        }

        final matchData = snapshot.data!.data() as Map<String, dynamic>;
        final events = (matchData['events'] as List?)
                ?.map((e) => MatchEvent.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [];

        // Check if events are empty
        if (events.isEmpty) {
          return const Center(child: Text("No events recorded yet."));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(event: event);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Live Match Recording",
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isRecording ? _buildEventList() : _buildInitialSetupForm(),
      ),
      floatingActionButton: _isRecording
          ? FloatingActionButton(
              onPressed: _showAddEventDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
