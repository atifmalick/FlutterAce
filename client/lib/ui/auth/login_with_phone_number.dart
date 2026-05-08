import 'package:client/ui/auth/verify_code.dart';
import 'package:client/utlis/utlis.dart';
import 'package:client/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class LoginWithPhoneNumber extends StatefulWidget {
  const LoginWithPhoneNumber({super.key});

  @override
  State<LoginWithPhoneNumber> createState() => _LoginWithPhoneNumberState();
}

class _LoginWithPhoneNumberState extends State<LoginWithPhoneNumber> {
  
bool loading =false;
final phoneNumberController = TextEditingController();
final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 80,),
        
            TextFormField(
              keyboardType: TextInputType.number,
              controller: phoneNumberController,
              decoration: InputDecoration(
                hintText: '+1 3128634510'
                
              ),
            ),
            SizedBox(height: 60,),
            RoundButton(title: 'login',loading: loading, onTap: (){
              setState(() {
                loading=true;
              });
              auth.verifyPhoneNumber(
                phoneNumber: phoneNumberController.text,
                verificationCompleted: (_){
                  setState(() {
                    loading=false;
                  });

                },
               verificationFailed: (e){
                setState(() {
                    loading=false;
                  });
               Utlis().toastMessage(e.toString());
               }, 
               codeSent: (String verificationId, int? token){
                setState(() {
                    loading=false;
                  });
                Navigator.push(context, MaterialPageRoute(builder: (context)=>VerifyCodeScreen(verificationId: verificationId,)));
               },
                codeAutoRetrievalTimeout: (e){
                  setState(() {
                    loading=false;
                  });
                  Utlis().toastMessage(e.toString());

                });

            })
          ],
        ),
      ),
    );
  }
}