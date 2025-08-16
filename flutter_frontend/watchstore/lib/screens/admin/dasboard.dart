import 'package:flutter/material.dart';
import 'package:watchstore/components/admin/sidebar.dart';
import 'package:watchstore/models/UserModel.dart';
import 'package:watchstore/services/admin_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Future<List<UserModel>>? _usersFuture;

  // For search & pagination
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  int _rowsPerPage = 5; // pagination: rows per page
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _usersFuture = AdminService.fetchUsers();
  }

  /// Filters the user list based on search query
  void _filterUsers(String query) {
    final results = _allUsers.where((user) {
      final name = "${user.fname} ${user.lname}".toLowerCase();
      final email = user.email.toLowerCase();
      return name.contains(query.toLowerCase()) ||
          email.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredUsers = results;
      _currentPage = 0; // reset to first page on search
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
              // Sidebar for large screens
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
              // Main content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// 🔹 Scorecards (centered at top)
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: _buildStatsGrid(isLargeScreen),
                        ),
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
                            // store data once fetched
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
                                    /// Search bar
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: _filterUsers,
                                        decoration: InputDecoration(
                                          hintText: "Search users...",
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    /// Users Table (desktop) with pagination
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

  /// 🔹 Scorecards Grid
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

  /// 🔹 Single Stat Card
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

  /// 🔹 Paginated Users Table
  Widget _buildPaginatedTable() {
    // Slice the filteredUsers list based on pagination
    final start = _currentPage * _rowsPerPage;
    final end = (_currentPage + 1) * _rowsPerPage <= _filteredUsers.length
        ? (_currentPage + 1) * _rowsPerPage
        : _filteredUsers.length;

    final pageUsers = _filteredUsers.sublist(start, end);

    return Column(
      children: [
        // Table
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

        // Pagination controls
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

  /// 🔹 Mobile: User Cards
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
