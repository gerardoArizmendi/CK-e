import 'package:flutter/material.dart';
import 'dart:io';
import 'package:blue/models/main_scope.dart';
import 'package:blue/helpers_POD/ensure_visible.dart';
import 'package:blue/helpers_POD/image_ensure.dart';
import 'package:blue/models/user.dart';
import 'package:scoped_model/scoped_model.dart';

class PerfilEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PerfilEditPageState();
  }
}

class _PerfilEditPageState extends State<PerfilEditPage> {
  bool newUser = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'nombre': null,
    'username': null,
    'bio': null,
    'cultvio': null,
    'direccion': null,
    'image': null,
    'userImage': null
  };
  final _nombreFocusNode = FocusNode();
  final _nombreTextController = TextEditingController();
  final _bioTextController = TextEditingController();
  final _bioFocuNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _usernameTextController = TextEditingController();
  final _direccionFocusNode = FocusNode();
  final _direccionTextController = TextEditingController();

  void _setImage(File image) {
    _formData['image'] = image;
  }

  Widget _buildPageContent(MainModel _model) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    final User perfil = _model.authUser;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              SizedBox(height: 20.0),
              _buildNombreTextField(perfil),
              SizedBox(height: 10.0),
              _buildBioTextField(perfil),
              SizedBox(height: 10.0),
              _buildUsernameTextField(perfil),
              SizedBox(height: 10.0),
              _buildDireccionTextField(perfil),
              SizedBox(height: 10.0),
              // LocationInput(_setLocation, perfil),
              //SizedBox(height: 10.0),
              SizedBox(height: 10.0),
              _buildSubmitButton(perfil),
              // GestureDetector(
              //   onTap: _submitForm,
              //   child: Container(
              //     color: Colors.green,
              //     padding: EdgeInsets.all(5.0),
              //     child: Text('My Button'),
              //   ),
              // )
              ImageInput(perfil, _setImage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNombreTextField(User perfil) {
    print("Nombre Text Field: ");
    if (perfil == null && _nombreTextController.text.trim() == '') {
      _nombreTextController.text = '';
      newUser = true;
    } else if (perfil != null && _nombreTextController.text.trim() == '') {
      _nombreTextController.text = perfil.nombre;
    } else if (perfil != null && _nombreTextController.text.trim() != '') {
      _nombreTextController.text = _nombreTextController.text;
    } else if (perfil == null && _nombreTextController.text.trim() != '') {
      _nombreTextController.text = _nombreTextController.text;
    } else {
      _nombreTextController.text = '';
    }
    return EnsureVisibleWhenFocused(
        focusNode: _nombreFocusNode,
        child: TextFormField(
          focusNode: _nombreFocusNode,
          decoration: InputDecoration(
              labelText: 'tu nombre',
              border: new OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0))),
          controller: _nombreTextController,
          // initialValue: perfil == null ? '' : perfil.title,
          validator: (String value) {
            // if (value.trim().length <= 0) {
            if (value.isEmpty || value.length < 5) {
              return 'Tu nombre requiere ser +5 caracteres.';
            } else {
              return '';
            }
          },
          onSaved: (String value) {
            _formData['nombre'] = value;
          },
        ));
  }

  Widget _buildBioTextField(User perfil) {
    if (perfil == null && _bioTextController.text.trim() == '') {
      _bioTextController.text = '';
    } else if (perfil != null && _bioTextController.text.trim() == '') {
      _bioTextController.text = perfil.bio;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _bioFocuNode,
      child: TextFormField(
        focusNode: _bioFocuNode,
        maxLines: 4,
        decoration: InputDecoration(
            labelText: 'Bio: ¿a que te dedicas?',
            border: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0))),
        // initialValue: perfil == null ? '' : perfil.description,
        controller: _bioTextController,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 10) {
            return 'Tu bio requiere ser +5 caracteres.';
          } else {
            return '';
          }
        },
        onSaved: (String value) {
          _formData['bio'] = value;
        },
      ),
    );
  }

  Widget _buildUsernameTextField(User perfil) {
    if (perfil == null && _usernameTextController.text.trim() == '') {
      _usernameTextController.text = '';
    } else if (perfil != null && _usernameTextController.text.trim() == '') {
      _usernameTextController.text = perfil.username;
    } else if (perfil != null && _usernameTextController.text.trim() != '') {
      _usernameTextController.text = _usernameTextController.text;
    } else if (perfil == null && _usernameTextController.text.trim() != '') {
      _usernameTextController.text = _usernameTextController.text;
    } else {
      _usernameTextController.text = '';
    }
    return EnsureVisibleWhenFocused(
      focusNode: _usernameFocusNode,
      child: TextFormField(
        focusNode: _usernameFocusNode,
        decoration: InputDecoration(
            labelText: 'username',
            border: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0))),
        controller: _usernameTextController,
        // initialValue: perfil == null ? '' : perfil.title,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 5) {
            return 'Tu nombre requiere ser +5 caracteres.';
          } else {
            return '';
          }
        },
        onSaved: (String value) {
          _formData['username'] = value;
        },
      ),
    );
  }

  Widget _buildDireccionTextField(User perfil) {
    if (perfil == null && _direccionTextController.text.trim() == '') {
      _direccionTextController.text = '';
    } else if (perfil != null && _direccionTextController.text.trim() == '') {
      _direccionTextController.text = perfil.direccion;
    } else if (perfil != null && _direccionTextController.text.trim() != '') {
      _direccionTextController.text = _direccionTextController.text;
    } else if (perfil == null && _direccionTextController.text.trim() != '') {
      _direccionTextController.text = _direccionTextController.text;
    } else {
      _direccionTextController.text = '';
    }
    return EnsureVisibleWhenFocused(
      focusNode: _direccionFocusNode,
      child: TextFormField(
        focusNode: _direccionFocusNode,
        decoration: InputDecoration(
            labelText: 'Direccion (codigo Postal)',
            border: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0))),
        controller: _direccionTextController,
        // initialValue: perfil == null ? '' : perfil.title,
        validator: (String value) {
          // if (value.trim().length <= 0) {
          if (value.isEmpty || value.length < 5) {
            return 'Su 1º cultivo requiere ser +5 caracteres.';
          } else {
            return '';
          }
        },
        onSaved: (String value) {
          _formData['direccion'] = value;
        },
      ),
    );
  }

  Widget _buildSubmitButton(User perfil) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text('Guardar'),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  if (_formData['image'] == null && perfil.imageUrl != null) {
                    _formData['userImage'] = perfil.imageUrl;
                  }
                  if (_nombreTextController.text.length < 1 ||
                      _bioTextController.text.length < 1) {
                  } else {
                    _submitForm(model.updateUser);
                  }
                  // model.userAuthFetch();
                });
      },
    );
  }

  void _submitForm(Function updatePerfil) {
    _formKey.currentState.save();
    updatePerfil(
      _nombreTextController.text,
      _bioTextController.text,
      _usernameTextController.text,
      _direccionTextController.text,
      _formData['image'],
    );
    Navigator.pop(context);
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Edita tu perfil"),
          ),
          body: Center(
              child: Container(
            child: _buildPageContent(model),
            padding: EdgeInsets.all(20),
          )));
    });
  }
}
