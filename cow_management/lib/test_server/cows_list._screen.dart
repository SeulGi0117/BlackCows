import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CowListScreen extends StatefulWidget {
  const CowListScreen({Key? key}) : super(key: key);

  @override
  State<CowListScreen> createState() => _CowListScreenState();
}

class _CowListScreenState extends State<CowListScreen> {
  List<dynamic> cowList = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchCowList();
  }

  Future<void> fetchCowList() async {
    final url = Uri.parse('https://b144-182-222-162-35.ngrok-free.app/cows/');
    

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("서버 응답 본문: ${utf8.decode(response.bodyBytes)}");
        final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes)); // ← 중요!
        setState(() {
          cowList = jsonData;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = "서버 오류: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = "네트워크 오류: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 소 목록'),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
              ? Center(child: Text(errorMsg!))
              : ListView.builder(
                  itemCount: cowList.length,
                  itemBuilder: (context, index) {
                    final cow = cowList[index];
                    return ListTile(
                      leading: const Icon(Icons.pets, color: Colors.purple),
                      title: Text("소 이름 : 🐮 ${cow['name']}"),
                      subtitle: Text("번호: ${cow['number']} / 품종: ${cow['breed']} / 생일: ${cow['birthdate']}"),
                    );
                  },
                ),
    );
  }
}
