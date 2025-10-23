import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> assets = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  void fetchAssets() async {
    try {
      final data = await ApiService.getAssets();
      setState(() {
        assets = data;
        loading = false;
      });
    } catch (e) {
      print("Veri cekme hatasi: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Portfoy Varliklari")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final item = assets[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('${item['type']} • ${item['value']}'),
          );
        },
      ),
    );
  }
}
