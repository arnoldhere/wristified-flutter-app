import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchstore/components/admin/sidebar.dart';
import 'package:watchstore/models/UserModel.dart';
import 'package:watchstore/providers/auth_provider.dart';
import 'package:watchstore/services/admin_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Future<List<UserModel>>? _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = AdminService.fetchUsers();
  }

  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth >= 900;

        return Scaffold(
          key: _scaffoldKey,
          appBar: isLargeScreen
              ? null
              : AppBar(
                  title: const Text("Admin Dashboard"),
                  leading: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
          drawer: isLargeScreen
              ? null
              : Drawer(
                  child: Sidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) {
                      setState(() => _selectedIndex = index);
                      Navigator.pop(context); // close drawer on tap
                    },
                  ),
                ),
          body: Row(
            children: [
              if (isLargeScreen)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: const Border(
                      right: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Sidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsGrid(isLargeScreen),
                      const SizedBox(height: 20),
                      FutureBuilder<List<UserModel>>(
                        future: _usersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text("No users found"));
                          } else {
                            return isLargeScreen
                                ? _buildUsersTable(snapshot.data!)
                                : _buildUsersCards(snapshot.data!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Stats Cards Grid
  Widget _buildStatsGrid(bool isLargeScreen) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isLargeScreen ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2,
      children: [
        _buildStatCard("Total Sales", "\$12,500", Colors.green),
        _buildStatCard("Orders", "320", Colors.blue),
        _buildStatCard("Pending", "45", Colors.orange),
        _buildStatCard("Customers", "210", Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Users Table (Desktop)
  Widget _buildUsersTable(List<UserModel> users) {
    return DataTable(
      headingRowColor: MaterialStateColor.resolveWith(
        (states) => Colors.indigo.shade50,
      ),
      columns: const [
        DataColumn(label: Text("ID")),
        DataColumn(label: Text("Name")),
        DataColumn(label: Text("Email")),
        DataColumn(label: Text("Phone")),
        DataColumn(label: Text("Role")),
      ],
      rows: users.map((user) {
        return DataRow(
          cells: [
            DataCell(Text(user.id.toString())),
            DataCell(Text("${user.fname} ${user.lname}")),
            DataCell(Text(user.email)),
            DataCell(Text(user.phone ?? "-")),
            DataCell(Text(user.role)),
          ],
        );
      }).toList(),
    );
  }

  /// Users Cards (Mobile)
  Widget _buildUsersCards(List<UserModel> users) {
    return Column(
      children: users.map((user) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.fname[0]), // First letter
            ),
            title: Text("${user.fname} ${user.lname}"),
            subtitle: Text(user.email),
            trailing: Chip(
              label: Text(user.role),
              backgroundColor: Colors.blue.shade100,
            ),
          ),
        );
      }).toList(),
    );
  }
}
