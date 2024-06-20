import 'package:bucketlistapp/add_bucket_list.dart';
import 'package:bucketlistapp/view_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<dynamic> bucketList = [];
  bool isLoading = false;
  bool isError = false;
  Future<void> getData() async {
    isLoading = true;
    setState(() {});
    try {
      Response response = await Dio().get(
          "https://flutterapitest123-43caf-default-rtdb.firebaseio.com/bucketList.json");
      bucketList = (response.data is List) ? response.data : [];
      isLoading = false;
      isError = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      isError = true;
      setState(() {});
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Invalid Url"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close'))
              ],
            );
          });
    }
  }

  Widget errorWidget({required String errorText}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning),
          Text(errorText),
          ElevatedButton(onPressed: getData, child: Text("Try Again"))
        ],
      ),
    );
  }

  Widget viewBucketListWidget() {
    return RefreshIndicator(
      onRefresh: getData,
      child: ListView.builder(
          itemCount: bucketList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ViewItem(
                    title: bucketList[index]['item'],
                    image: bucketList[index]['image'],
                  );
                }));
              },
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(bucketList[index]['image'] ?? ""),
              ),
              title: Text(bucketList[index]['item'] ?? ''),
              trailing: Text(bucketList[index]['cost'].toString() ?? ''),
            );
          }),
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigator.pushNamed(context, "/add");
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddBucketList();
            }));
          },
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          title: Text("Bucket List"),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[200],
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(onTap: getData, child: Icon(Icons.refresh)),
            )
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : isError
                ? errorWidget(errorText: "Error connecting")
                : bucketList.isEmpty
                    ? Center(child: Text("No data found"))
                    : viewBucketListWidget());
  }
}
