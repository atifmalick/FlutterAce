import 'package:client/ui/auth/login_screen.dart';
import 'package:client/utlis/utlis.dart';
import 'package:client/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
  void login(){
    setState(() {
                  loading = true;
                });
                _auth.createUserWithEmailAndPassword(email: emailController.text.toString(),
                 password: passwordController.text.toString()).then((value) {
                  setState(() {
                    loading = false;
                  });

                 }).onError((error, StackTrace){
                  setState(() {
                    loading=false;
                  });
                  Utlis().toastMessage(error.toString());
                 });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Sign Up'),
      ),
      body: Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
TextFormField(
  keyboardType: TextInputType.emailAddress,
            controller: emailController,
            decoration: const InputDecoration(hintText: 'email',
            prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: (value){
              if(value!.isEmpty){
                return 'Enter Email';
              }
              return null;
            },
        ),
     const    SizedBox(height: 20),
        TextFormField(
          keyboardType: TextInputType.text,
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'password',
            prefixIcon: Icon(Icons.lock_open),
            ),
            validator: (value){
              if(value!.isEmpty){
                return 'Enter Password';
              }
              return null;

            },
        ),

              ],
            )),
     const SizedBox(height: 50),
          
          RoundButton(
            title: 'Sign Up',
            loading: loading,
            onTap: () {
              if(_formKey.currentState!.validate()){
                 login();
              }
            },
          ),
        const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account?"),
              TextButton(onPressed: (){
                Navigator.push(context,
                MaterialPageRoute(builder: (context)=>LoginScreen()));
              }, child: Text("Login")),

            ],
          )
        ],
      ),
      ),
    );
  }
}