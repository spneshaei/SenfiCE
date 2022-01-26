import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:senfi_ce/main.dart';
import 'package:http/http.dart' as http;
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class Request {
  int id;
  String body;
  int numberOfLikes;
  bool isMyFav;
  String status;
  String time;

  Request(this.id, this.body, this.numberOfLikes, this.isMyFav, this.status, this.time);
}

class _RequestsPageState extends State<RequestsPage> {
  List<dynamic> requestsList = [];

  String _baseUrl = "https://api.shora.taha7900.ir/api/";
  Future<void> populateRequests() async {
    final ProgressDialog pr = ProgressDialog(context: context);
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "token") ?? "null";
    if (token != "null") {
      pr.show(max: 100, msg: "در حال دریافت");
      ApiResponse _apiResponse = new ApiResponse(Map(), Object());
      try {
        final response = await http.get(Uri.parse('${_baseUrl}demands'), headers: {
          'Authorization': 'Bearer $token',
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

      if (_apiResponse.ApiError != "Error" && _apiResponse.Data["status"] == "ok") {
        var demands = _apiResponse.Data["data"]["demands"];
        List<Request> newRequestsList = [];
        for (int i = 0; i < demands.length; i++) {
          if (demands[i]["created_at"].split("T").length > 0) {
            var split = demands[i]["created_at"].split("T")[0];
            var request = Request(demands[i]["id"], demands[i]["body"], demands[i]["likes_count"], demands[i]["is_liked"], demands[i]["status"] == "pending" ? "در بررسی" : "بررسی شده", split);
            newRequestsList.add(request);
          }
        }
        pr.close();
        setState(() {
          requestsList = newRequestsList;
        });
      } else {
        pr.close();
      }
    }
  }

  Future<void> likeRequest(Request request) async {
    final ProgressDialog pr = ProgressDialog(context: context);
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "token") ?? "null";
    if (token != "null") {
      pr.show(max: 100, msg: "در حال اعمال");
      ApiResponse _apiResponse = new ApiResponse(Map(), Object());
      try {
        final response = await http.post(Uri.parse('${_baseUrl}demands/like/${request.id}'), headers: {
          'Authorization': 'Bearer $token',
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

      if (_apiResponse.ApiError != "Error" && _apiResponse.Data["status"] == "ok") {
        pr.close();
        setState(() {
          request.isMyFav = true;
          request.numberOfLikes += 1;
        });
      } else {
        pr.close();
      }
    }
    else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginStatefulPage()),);
    }
  }

  Future<void> unlikeRequest(Request request) async {
    final ProgressDialog pr = ProgressDialog(context: context);
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "token") ?? "null";
    if (token != "null") {
      pr.show(max: 100, msg: "در حال اعمال");
      ApiResponse _apiResponse = new ApiResponse(Map(), Object());
      try {
        final response = await http.delete(Uri.parse('${_baseUrl}demands/unlike/${request.id}'), headers: {
          'Authorization': 'Bearer $token',
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

      if (_apiResponse.ApiError != "Error" && _apiResponse.Data["status"] == "ok") {
        pr.close();
        setState(() {
          request.isMyFav = false;
          request.numberOfLikes -= 1;
          if (request.numberOfLikes < 0) request.numberOfLikes = 0;
        });
      } else {
        pr.close();
      }
    }
    else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginStatefulPage()),);
    }
  }

  Future<void> addRequest(String body) async {
    final ProgressDialog pr = ProgressDialog(context: context);
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "token") ?? "null";
    if (token != "null") {
      pr.show(max: 100, msg: "در حال ثبت");
      ApiResponse _apiResponse = new ApiResponse(Map(), Object());
      try {
        final response = await http.post(Uri.parse('${_baseUrl}demands'), headers: {
          'Authorization': 'Bearer $token',
        }, body: {
          'body': body
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

      if (_apiResponse.ApiError != "Error" && _apiResponse.Data["status"] == "ok") {
        pr.close();
        await populateRequests();
      } else {
        pr.close();
      }
    }
    else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginStatefulPage()),);
    }
  }


  _onLayoutDone(_) async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "token") ?? "null";
    if (token != "null" && requestsList.isEmpty) await populateRequests();
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback(_onLayoutDone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () async {
                      final storage = new FlutterSecureStorage();
                      await storage.write(key: "token", value: "null");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginStatefulPage()),);
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                    )),
              )
            ],
            leading: Container(),
            title: Text("درخواست‌ها", style: TextStyle(fontSize: 25))
          ),
          body: Container(
            child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: requestsList.length,
                itemBuilder: (context, index) {
                  return requestComponent(request: requestsList[index]);
                }),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
            onPressed: () async {
              String? body = await prompt(
                context,
                initialValue: '',
                isSelectedInitialValue: false,
                textOK: const Text('ثبت'),
                textCancel: const Text('لغو'),
                hintText: 'متن درخواست',
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفا یک متن صحیح وارد نمایید';
                  }
                  return null;
                },
                autoFocus: true,
                textAlign: TextAlign.right,
              );
              if (body != null) await addRequest(body);
            },
          ),
        ));
  }

  requestComponent({required Request request}) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: (request.status == "بررسی شده" ? Colors.green : Colors.yellow).withAlpha(100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ]
      ),
      child: Padding(padding: EdgeInsets.all(0), child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Flexible(child: Text(request.body, style: TextStyle(fontSize: 20), textAlign: TextAlign.right, overflow: TextOverflow.clip,))])),
          SizedBox(height: 20,),
          Container(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Flexible(child: Text(request.time, style: TextStyle(fontSize: 16), textAlign: TextAlign.right, overflow: TextOverflow.clip,))])),
          SizedBox(height: 10,),
          Container(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Flexible(child: Text("تعداد پسندیده‌ها: ${request.numberOfLikes}", style: TextStyle(fontSize: 16), textAlign: TextAlign.right, overflow: TextOverflow.clip,))])),
          Container(child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              width: 40, height: 40, child:
            GestureDetector(
              onTap: () async {
                if (request.isMyFav) await unlikeRequest(request);
                else await likeRequest(request);
              },
              child: Center(
                  child: request.isMyFav ? Icon(Icons.favorite, color: Colors.red,) : Icon(Icons.favorite_outline, color: Colors.grey.shade600,)
              ),
            ),)
          ],),),
        ],
      )),
    );
  }
}
