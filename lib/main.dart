
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:senfi_ce/requestspage.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(FirstPage());
}

class ApiResponse {
  Map<String, dynamic> _data;
  Object _apiError;

  ApiResponse(this._data, this._apiError);

  Map<String, dynamic> get Data => _data;
  set Data(Map<String, dynamic> data) => _data = data;

  Object get ApiError => _apiError as Object;
  set ApiError(Object error) => _apiError = error;
}

String _baseUrl = "https://api.shora.taha7900.ir/api/";
Future<ApiResponse> authenticateUser(String username, String password) async {
  ApiResponse _apiResponse = new ApiResponse(Map(), Object());

  try {
    final response = await http.post(Uri.parse('${_baseUrl}auth/login'), body: {
      'student_number': username,
      'password': password,
    });

    switch (response.statusCode) {
      case 200:
        _apiResponse.Data = json.decode(response.body);
        break;
      case 401:
        _apiResponse.ApiError = "Error";
        break;
      default:
        _apiResponse.ApiError = "Error";
        break;
    }
  } on SocketException {
    _apiResponse.ApiError = "Error";
  }
  return _apiResponse;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenfiCE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'BNazanin'
      ),
      debugShowCheckedModeBanner: false,
      home: LoginStatefulPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenfiCE',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'BNazanin'
      ),
      debugShowCheckedModeBanner: false,
      home: InnerContainer(),
    );
  }
}

class InnerContainer extends StatefulWidget {
  const InnerContainer({Key? key}) : super(key: key);

  @override
  _InnerContainerState createState() => _InnerContainerState();
}

class _InnerContainerState extends State<InnerContainer> {
  _onLayoutDone(_) async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "token") ?? "null";
    if (token != "null") Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestsPage()),);
    else Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginStatefulPage()),);
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback(_onLayoutDone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}



class LoginStatefulPage extends StatefulWidget {
  const LoginStatefulPage({Key? key}) : super(key: key);

  @override
  _LoginStatefulPageState createState() => _LoginStatefulPageState();
}

class _LoginStatefulPageState extends State<LoginStatefulPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";

  final snackBar = SnackBar(
    content: Text('صحت اطلاعات خود و اتصال اینترنت را بررسی و دوباره تلاش نمایید', textAlign: TextAlign.center,),
  );

  void loginTapped(ProgressDialog pr) async {
     if (_formKey.currentState != null) {
       final FormState form = _formKey.currentState!;
       form.save();
       pr.show(max: 100, msg: "در حال ورود");
       final _apiResponse = await authenticateUser(_username, _password);
       if (_apiResponse._data["status"] == "ok") {
         final storage = new FlutterSecureStorage();
         await storage.write(key: "token", value: _apiResponse._data["data"]["user"]["token"]);
         pr.close();
         Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => const RequestsPage()),
         );
       } else {
         pr.close();
         ScaffoldMessenger.of(context).showSnackBar(snackBar);
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context: context);
    return WillPopScope(onWillPop: () async => false, child: Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.blue[600]!,
                  Colors.blue[700]!,
                  Colors.blue[800]!
                ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(child: Text("ورود به اپلیکیشن", style: TextStyle(color: Colors.white, fontSize: 40, fontFamily: 'BNazanin')),),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 1,),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                                    ),
                                    child: TextFormField(
                                      key: Key("_username"),
                                      onSaved: (String? value) {
                                        _username = value ?? "";
                                      },
                                      validator: (value) { return null; },
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                          hintText: "شماره‌ی دانش‌جویی",
                                          hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                                          border: InputBorder.none
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                                    ),
                                    child: TextFormField(
                                      key: Key("_password"),
                                      onSaved: (String? value) {
                                        _password = value ?? "";
                                      },
                                      validator: (value) { return null; },
                                      obscureText: true,
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                          hintText: "رمز عبور",
                                          hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                                          border: InputBorder.none
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30,),
                            InkWell(
                              onTap: () {
                                loginTapped(pr);
                              },
                              child: Container(
                                height: 50,
                                margin: EdgeInsets.symmetric(horizontal: 50),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10000),
                                    color: Colors.blue[600]
                                ),
                                child: Center(
                                  child: Text("ورود", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                                ),
                              ),
                            ),

                            SizedBox(height: 50,),

                            Text("شماره‌ی دانش‌جویی خود را حتما به انگلیسی وارد کنید", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                            SizedBox(height: 20,),
                            Text("در صورت فراموشی رمز عبور و یا تمایل به ثبت‌نام، به سایت شورای صنفی رجوع کنید", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                            SizedBox(height: 50,),
                            Text("اپلیکیشن شورای صنفی دانشکده مهندسی کامپیوتر", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Colors.grey)),
                            SizedBox(height: 10,),
                            Text("توسعه‌دهندگان فنی: محمدطه جهانی‌نژاد، سید پارسا نشایی", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Colors.grey)),
                            SizedBox(height: 10,),
                            Text("مسئولیت تمامی محتوای اپلیکیشن بر عهده شورای صنفی دانشکده مهندسی کامپیوتر دانشگاه صنعتی شریف است و توسعه‌دهندگان هیچ‌گونه مسئولیتی در قبال اپلیکیشن، وب‌سایت و هرگونه محتوای درون آن یا مربوط به آن، نخواهند داشت", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey)),

                          ],
                        ),
                      ),
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    ));
  }
}
