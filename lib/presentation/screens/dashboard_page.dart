import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newapp/presentation/controllers/auth_controller.dart';
import 'package:newapp/presentation/controllers/dashboard_controller.dart';
import 'package:newapp/presentation/screens/signin_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthController authController = Get.put(AuthController());
  final DashboardController dashboardController =
      Get.put(DashboardController());

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.signOut();
              Get.offAll(() => SignInPage());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by CIN',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchTerm = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: dashboardController.fetchPenalties(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No penalties found'));
            }

            final penalties = snapshot.data!.docs
                .map((doc) => {
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>,
                    })
                .where((item) => item['cin']
                    .toLowerCase()
                    .contains(_searchTerm.toLowerCase()))
                .toList();

            return ListView.builder(
              itemCount: penalties.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Header row
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.grey[200],
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text('Index',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 3,
                                child: Text('Email',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('CIN',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Matricule',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text('Points',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text('Paid',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Signed By',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Action',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  final item = penalties[index - 1];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(flex: 1, child: Text('${index - 1}')),
                            Expanded(flex: 2, child: Text(item['name'])),
                            Expanded(flex: 3, child: Text(item['email'])),
                            Expanded(flex: 2, child: Text(item['cin'])),
                            Expanded(flex: 2, child: Text(item['matricule'])),
                            Expanded(
                                flex: 1,
                                child: item['points'] != null
                                    ? Text(item['points'].toString())
                                    : const SizedBox()),
                            Expanded(
                                flex: 1,
                                child: item['isPaid'] != null
                                    ? Text(item['isPaid'] ? 'Yes' : 'No')
                                    : const SizedBox()),
                            Expanded(
                                flex: 2,
                                child: item['whoSignedIt'] != null
                                    ? Text(item['whoSignedIt'])
                                    : const SizedBox()),
                            item['isPaid'] != null && !item['isPaid']
                                ? ElevatedButton(
                                    onPressed: () {
                                      dashboardController.switchIsPaid(
                                        item['id'],
                                        item['isPaid'],
                                        authController.userMatricule.value,
                                      );
                                    },
                                    child: const Text('Pay'),
                                  )
                                : const SizedBox(width: 70),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
