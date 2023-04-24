import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:front_end_mobile/projectConfig.dart' as config;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List routes = [];
  List buses = [];
  var routeid;

  @override
  void initState() {
    super.initState();
    getRoutes();
  }

  void getRoutes() async {
    print("getting routes");
    var response = await http.get(
      Uri.http(config.BaseUrl, "routes"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    setState(() {
      routes = jsonDecode(response.body);
    });
  }

  void getbuses(routeid) async {
    print("getting buses for the route");

    var response = await http.post(
      Uri.http(config.BaseUrl, "buses"),
      body: jsonEncode({
        "Route_id": routeid,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    setState(() {
      buses = jsonDecode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        centerTitle: true,
        title: Text('BusTracker'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          height: 15,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Material(
              elevation: 5,
              shadowColor: Colors.grey,
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 16, 10, 16),
                  border: InputBorder.none,
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: "Choose Route",
                  fillColor: Colors.white,
                ),
                value: routeid,
                onChanged: (value) {
                  setState(() {
                    print("This is value coming from dropdown : $value");
                    routeid = value;
                    getbuses(routeid);
                  });
                },
                items: routes
                    .map((ele) => DropdownMenuItem(
                        value: ele['Route_id'], child: Text(ele['Route_name'])))
                    .toList(),
              ),
            ),
          ),
        ]),
        SizedBox(height: 6),
        buses.length > 0
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: buses.length,
                itemBuilder: (context, i) {
                  return (Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                            )
                          ],
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.amber),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                          "Bus Name : ${buses[i]['Bus_name']}"))
                                ],
                              ),
                            ],
                          ),
                          Row(children: [
                            Container(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                    "Bus Number : ${buses[i]['Bus_number']}"))
                          ]),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(" Driver : ${buses[i]['Driver_name']}")
                                ],
                              ),
                              SizedBox(width: 30),
                              Column(
                                children: [
                                  Text("Route : ${buses[i]['Route_name']}")
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    Text("Timings : ${buses[i]['Time']}")
                                  ],
                                ),
                              ),
                              SizedBox(width: 60, height: 20),
                              MaterialButton(
                                color: Color(0xff2a9d8f),
                                onPressed: () {
                                  print(buses[i]['Bus_id']);
                                  Navigator.pushNamed(context, '/livelocation');
                                },
                                child: Text(
                                  "View Location",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width * 0.96));
                })
            : Container(
                height: 0,
                width: 0,
              )
      ]),
    );
  }
}
