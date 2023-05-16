import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:testgetdata/http/login.dart';
import 'package:testgetdata/views/tenant.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var showPassword = true;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(showPassword);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextFormField(
            cursorColor: Colors.redAccent,
            controller: email,
            decoration: InputDecoration(
              label: Text('Email'),
              hintText: 'Masukkan Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harap isi nama terlebih dahulu';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            obscureText: showPassword,
            controller: password,
            decoration: InputDecoration(
              suffixIcon: showPassword
                  ? IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () => setState(() {
                        showPassword = !showPassword;
                      }),
                    )
                  : IconButton(
                      icon: const Icon(Icons.remove_red_eye_outlined),
                      onPressed: () => setState(() {
                        showPassword = !showPassword;
                      }),
                    ),
              label: Text('Password'),
              hintText: 'Masukkan Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Harap isi nama terlebih dahulu';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (email.text.isEmpty || password.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Harap isi data terlebih dahulu")),
                );
              } else {
                LoginFuture(email.text, password.text).then((value) {
                  print(value);
                  if (value != 'gagal')
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return Tenant();
                    }));
                  else
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Email or password cannot find in own records")),
                  );
                });
              }
            },
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueAccent),
              child: Center(
                  child: Text("Login",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15))),
            ),
          )
        ]),
      ),
    );
  }
}
