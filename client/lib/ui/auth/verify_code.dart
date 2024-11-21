import 'package:client/ui/posts/post_screen.dart';
import 'package:client/utlis/utlis.dart';
import 'package:client/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class VerifyCodeScreen extends StatefulWidget {
  final verificationId;
  const VerifyCodeScreen({super.key, required this.verificationId});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  bool loading =false;
final verifyNumberController = TextEditingController();
final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 80,),
        
            TextFormField(
              keyboardType: TextInputType.number,
              controller: verifyNumberController,
              decoration: InputDecoration(
                hintText: '6 digit code'
                
              ),
            ),
            SizedBox(height: 60,),
            RoundButton(title: 'Verify',loading: loading, onTap: () async {
              setState(() {
                loading =true;
              });
              final credential= PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: verifyNumberController.text.toString());
              try{
               await auth.signInWithCredential(credential);
               Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreen()));
              }
              catch(e){
                setState(() {
                  loading=false;
                });
                Utlis().toastMessage(e.toString());



              }
  }),

            
          ],
        ),
      ),
    );
  }

}