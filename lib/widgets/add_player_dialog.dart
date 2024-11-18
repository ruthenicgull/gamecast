import 'package:flutter/material.dart';
import '../models/match_models.dart';

class AddPlayerDialog extends StatefulWidget {
  const AddPlayerDialog({super.key});

  @override
  _AddPlayerDialogState createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _shirtNumber = 0;
  PlayerStatus _status = PlayerStatus.starting;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Player'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Player Name'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Name is required' : null,
              onSaved: (value) => _name = value ?? '',
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Shirt Number'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Shirt number is required';
                final number = int.tryParse(value!);
                return number == null || number < 0 ? 'Invalid number' : null;
              },
              onSaved: (value) => _shirtNumber = int.parse(value!),
            ),
            DropdownButtonFormField<PlayerStatus>(
              decoration: const InputDecoration(labelText: 'Player Status'),
              value: _status,
              items: PlayerStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _status =
                      value ?? PlayerStatus.starting; //PlayerStatus.starting;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final player = Player(
                playerId: '', // Will be set by Firestore
                name: _name,
                shirtNumber: _shirtNumber,
                status: _status,
              );
              Navigator.of(context).pop(player);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
