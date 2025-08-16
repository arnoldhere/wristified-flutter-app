import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:watchstore/components/admin/sidebar.dart';
import 'package:watchstore/models/UserModel.dart';
import 'package:watchstore/services/admin_service.dart';
import 'package:csv/csv.dart';

// Mobile/Desktop file saving
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

// Web download
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Future<List<UserModel>>? _usersFuture;
  Future<Map<String, dynamic>>? _countsFuture; // <-- for stats

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  int _rowsPerPage = 5;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _usersFuture = AdminService.fetchUsers();
    _countsFuture = AdminService.fetchCounts(context); // load counts
  }

  /// 🔹 Export CSV (Works on Web + Mobile/Desktop)
  Future<void> _exportUsersToCSV() async {
    if (_filteredUsers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No users to export")));
      return;
    }

    // Prepare CSV data
    List<List<String>> csvData = [
      ["ID", "First Name", "Last Name", "Email", "Phone", "Role"],
      ..._filteredUsers.map(
        (u) => [
          u.id.toString(),
          u.fname,
          u.lname,
          u.email,
          u.phone ?? "-",
          u.role,
        ],
      ),
    ];
    String csv = const ListToCsvConverter().convert(csvData);

    if (kIsWeb) {
      // For Web → download directly
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "users.csv")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For Mobile/Desktop → save file
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }

      final dir = await getExternalStorageDirectory();
      final path = "${dir!.path}/users.csv";
      final file = File(path);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("CSV saved at $path")));

      // Open file after saving
      await OpenFile.open(path);
    }
  }

  /// 🔹 Filters
  void _filterUsers(String query) {
    final results = _allUsers.where((user) {
      final name = "${user.fname} ${user.lname}".toLowerCase();
      final email = user.email.toLowerCase();
      return name.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredUsers = results;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth >= 900;

        return Scaffold(
          appBar: isLargeScreen
              ? null
              : AppBar(title: const Text("Admin Dashboard")),
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
                  child: Sidebar(selectedIndex: 0, onItemSelected: (index) {}),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// 🔹 Scorecards
                      FutureBuilder<Map<String, dynamic>>(
                        future: _countsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (!snapshot.hasData) {
                            return const Text("No data");
                          }
                          return Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: _buildStatsGrid(
                                isLargeScreen,
                                snapshot.data!,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      /// 🔹 Users Table Section
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
                            if (_allUsers.isEmpty) {
                              _allUsers = snapshot.data!;
                              _filteredUsers = _allUsers;
                            }

                            return Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1000,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Search + Export
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: TextField(
                                              controller: _searchController,
                                              onChanged: _filterUsers,
                                              decoration: InputDecoration(
                                                hintText: "Search users...",
                                                prefixIcon: const Icon(
                                                  Icons.search,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: _exportUsersToCSV,
                                          icon: const Icon(Icons.download),
                                          label: const Text("Export CSV"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    isLargeScreen
                                        ? _buildPaginatedTable()
                                        : _buildUsersCards(_filteredUsers),
                                  ],
                                ),
                              ),
                            );
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

  /// Scorecards
  Widget _buildStatsGrid(bool isLargeScreen, Map<String, dynamic> counts) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isLargeScreen ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2,
      children: [
        _buildStatCard(
          "Total Sales",
          "\$${counts['total_sales']}",
          Colors.green,
        ),
        _buildStatCard("Orders", "${counts['orders_count']}", Colors.blue),
        _buildStatCard("Customers", "${counts['users_count']}", Colors.purple),
        _buildStatCard("Pending", "45", Colors.orange), // example static
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

  Widget _buildPaginatedTable() {
    final start = _currentPage * _rowsPerPage;
    final end = (_currentPage + 1) * _rowsPerPage <= _filteredUsers.length
        ? (_currentPage + 1) * _rowsPerPage
        : _filteredUsers.length;

    final pageUsers = _filteredUsers.sublist(start, end);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
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
            rows: pageUsers.map((user) {
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
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 0
                  ? () => setState(() => _currentPage--)
                  : null,
            ),
            Text(
              "${_currentPage + 1} / "
              "${(_filteredUsers.length / _rowsPerPage).ceil()}",
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: end < _filteredUsers.length
                  ? () => setState(() => _currentPage++)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersCards(List<UserModel> users) {
    return Column(
      children: users.map((user) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Text(user.fname[0])),
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
