import 'package:flutter/material.dart';
import 'package:fsegs_connect/views/my_dropdown_widget.dart';

class formAdd extends StatefulWidget {
  const formAdd({super.key});

  @override
  State<formAdd> createState() => _formAddState();
}

class _formAddState extends State<formAdd> {
  final _formKey = GlobalKey<FormState>();
  String _nom = '';
  String _prenom = '';
  String? _selectedOption;
  String _specialite = '';

  bool _isChecked = false;
  bool _isChecked2 = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Center(
          child: Text('FSEGS Connect', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Center(
        child: Container(
          height: 500,
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('Bienvenue sur FSEGS Connect'),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nom'),
                  validator: (value) {
                    if (value == null || value!.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nom = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Prenom'),
                  validator: (value) {
                    if (value == null || value!.isEmpty) {
                      return 'Veuillez entrer votre prenom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _prenom = value!;
                  },
                ),
                SizedBox(height: 20),
                const Text('Veuilliez selectionner votre genre'),
                Row(
                  children: [
                    Radio(
                      value: 'Masculin',
                      groupValue: _selectedOption,
                      onChanged: (value) => {
                        setState(() {
                          _selectedOption = value!;
                        }),
                      },
                    ),
                    Text("Masculin"),
                    Radio(
                      value: 'feminin',
                      groupValue: _selectedOption,
                      onChanged: (value) => {
                        setState(() {
                          _selectedOption = value!;
                        }),
                      },
                    ),
                    Text("Feminin"),
                  ],
                ),
                SizedBox(height: 20),
                const Text("veuilliez selectionner vos matiéres"),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                    Text("Programmation Orienté Objet"),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked2,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked2 = value!;
                        });
                      },
                    ),
                    Text("Programmation mobile"),
                  ],
                ),
                SizedBox(height: 20),
                MyDropdownWidget(
                  onChanged: (value) {
                    _specialite = value;
                  },
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedOption == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez sélectionner le genre'),
                          ),
                        );
                        return;
                      }

                      if (_specialite.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez choisir une spécialité'),
                          ),
                        );
                        return;
                      }

                      _formKey.currentState!.save();

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Données du formulaire"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nom : $_nom'),
                                Text('Prénom : $_prenom'),
                                Text('Genre : $_selectedOption'),
                                Text('Spécialité : $_specialite'),
                                Text('POO : ${_isChecked ? "Oui" : "Non"}'),
                                Text('Mobile : ${_isChecked2 ? "Oui" : "Non"}'),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Soumettre'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
