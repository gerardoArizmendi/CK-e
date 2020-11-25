import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

// import 'package:url_launcher/url_launcher.dart';

import 'package:blue/models/main_scope.dart';
import 'package:blue/models/auth.dart';

// import 'package:flutter_facebook_login/flutter_facebook_login.dart';

//import 'package:firebase_auth/firebase_auth.dart';
//Facebook Provider
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageSate();
  }
}

class _AuthPageSate extends State<AuthPage> with TickerProviderStateMixin {
  //Facebook sign in
  //FacebookLogin fbLogin = new FacebookLogin();

  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'terminos': false,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login; //Bandera tipo
  AnimationController _controller;
  Animation<Offset> _slideAnimation;

  bool isLoggedIn = false;

  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0.0, -1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    super.initState();
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'E-mail'),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Inserta un Email valido.';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Error, password invalido';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Confirm Password',
          ),
          obscureText: true,
          validator: (String value) {
            if (_passwordTextController.text != value &&
                _authMode == AuthMode.Signup) {
              return 'Passwords do not match.';
            }
          },
        ),
      ),
    );
  }

  Widget _buildSwitchField() {
    return SwitchListTile(
      value: _formData['terminos'],
      activeColor: Colors.blue,
      onChanged: (bool value) {
        setState(() {
          _formData['terminos'] = value;
        });
      },
      title: Text('Acepto Terminos'),
    );
  }

  void _submitForm(Function authenticate) async {
    //Los terminos necesitan estar aprovados para poder ingresar a la aplicacion
    if (!_formKey.currentState.validate() || !_formData['terminos']) {
      return;
    }
    _formKey.currentState.save();
    // print('succes Information:');
    await authenticate(_formData['email'], _formData['password'], context);
    // print('Post Authentication');
  }

  // Widget _buildTerminos() {
  //   return Row(
  //     children: <Widget>[
  //       FlatButton.icon(
  //         icon: Icon(Icons.error),
  //         onPressed: () {
  //           _launchURL();
  //         },
  //         label: Text('Terminos y condiciones'),
  //       )
  //     ],
  //   );
  // }

  // _launchURL() async {
  //   const url = 'http://distritotec.itesm.mx/terminos/';
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Hubo un error, intentalo más tarde $url';
  //   }
  // }

  Widget _loginMode() {
    return Column(
      children: <Widget>[
        _buildPasswordConfirmTextField(),
        _buildSwitchField(),
        // _buildTerminos(),
        SizedBox(
          height: 10.0,
        ),
        FlatButton(
          color: Colors.grey[100],
          child: Text(
              '${_authMode == AuthMode.Login ? 'Regístrate' : 'Iniciar Sessión'}'),
          onPressed: () {
            if (_authMode == AuthMode.Login) {
              setState(() {
                _authMode = AuthMode.Signup;
              });
              _controller.forward();
            } else {
              setState(() {
                _authMode = AuthMode.Login;
              });
              _controller.reverse();
            }
          },
        ),
        SizedBox(
          height: 10.0,
        ),
        ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                // RaisedButton(
                //   child: Text("Login with Facebook"),
                //   color: Colors.blue,
                //   onPressed: () => model.initiateFacebookLogin(context),
                // ),
                model.isLoading
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        textColor: Colors.white,
                        child: Text(_authMode == AuthMode.Login
                            ? 'Iniciar Sessión'
                            : 'Regístrate'),
                        onPressed: () {
                          _authMode == AuthMode.Login
                              ? _submitForm(model.authentication)
                              : _submitForm(model.registration);
                        }),
                RaisedButton(
                  child: Text("Login with Facebook"),
                  color: Colors.blue,
                  onPressed: () => model.initiateFacebookLogin(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${_authMode == AuthMode.Welcome ? 'Bienvenido' : 'Bickla'}'),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        // decoration: BoxDecoration(
        //     image: DecorationImage(
        //         image: AssetImage('assets/Logo∑.jpg'),
        //         fit: BoxFit.cover,
        //         colorFilter: ColorFilter.mode(
        //             Colors.black.withOpacity(0.5), BlendMode.dstATop))),
        margin: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _buildEmailTextField(),
                  _buildPasswordTextField(),
                  _loginMode(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
