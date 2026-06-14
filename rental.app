class AppLocalization {
  final String languageCode;
  AppLocalization(this.languageCode);

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Property Management',
      'admin_panel': 'Admin Dashboard',
      'collect_rent': 'Collect Rent',
      'expense_ledger': 'Expense Ledger',
      'add_contract': 'Create Contract',
      'branch': 'Branch',
      'payment_method': 'Payment Method',
    },
    'ar': {
      'title': 'إدارة العقارات',
      'admin_panel': 'لوحة التحكم للمشرف',
      'collect_rent': 'تحصيل الإيجار',
      'expense_ledger': 'دفتر المصروفات',
      'add_contract': 'إنشاء عقد',
      'branch': 'الفرع',
      'payment_method': 'طريقة الدفع',
    },
    'bn': {
      'title': 'প্রপার্টি ম্যানেজমেন্ট',
      'admin_panel': 'অ্যাডমিন ড্যাশবোর্ড',
      'collect_rent': 'ভাড়া সংগ্রহ',
      'expense_ledger': 'খরচের হিসাব',
      'add_contract': 'চুক্তিপত্র তৈরি',
      'branch': 'ব্রাঞ্চ',
      'payment_method': 'পেমেন্ট পদ্ধতি',
    }
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}
enum UserRole { admin, staff }

class UserSession {
  final String userId;
  final String name;
  final UserRole role;

  UserSession({required this.userId, required this.name, required this.role});

  // Authorization check for Admin-only actions
  bool canManageBranches() {
    return role == UserRole.admin;
  }

  bool canDeleteTransactions() {
    return role == UserRole.admin;
  }
}
import 'package:flutter/material.dart';

void main() => runApp(const RentalManagementApp());

class RentalManagementApp extends StatefulWidget {
  const RentalManagementApp({Key? key}) : super(key: key);

  @override
  State<RentalManagementApp> createState() => _RentalManagementAppState();
}

class _RentalManagementAppState extends State<RentalManagementApp> {
  String _currentLang = 'en'; // Global language state: en, ar, bn

  void _changeLanguage(String langCode) {
    setState(() {
      _currentLang = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Basic text direction configuration based on Arabic language
    TextDirection direction = _currentLang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: direction,
        child: HomeScreen(currentLang: _currentLang, onLangChange: _changeLanguage),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String currentLang;
  final Function(String) onLangChange;

  const HomeScreen({Key? key, required this.currentLang, required this.onLangChange}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock Active Session: 1 Admin, 4-5 regular users
  final UserSession currentUser = UserSession(userId: "U001", name: "Tariq", role: UserRole.admin);

  // In-memory runtime lists simulating database collections
  final List<String> branches = ["Makkah Main", "Jeddah Corniche"];
  final List<Map<String, dynamic>> clients = [];
  final List<Map<String, dynamic>> collectionLedger = [];
  final List<Map<String, dynamic>> expenseLedger = [];

  // Form Controllers
  final _clientNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _expenseController = TextEditingController();
  
  String selectedBranch = "Makkah Main";
  String selectedUnitType = "Room"; // Room or Shop
  String selectedCycle = "Monthly"; // Monthly or Yearly
  String selectedPaymentMethod = "Cash"; // Cash, Bank, Mada/Card

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization(widget.currentLang);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('title')),
        backgroundColor: Colors.indigo,
        actions: [
          DropdownButton<String>(
            value: widget.currentLang,
            dropdownColor: Colors.indigo,
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'en', child: Text("EN")),
              DropdownMenuItem(value: 'ar', child: Text("AR")),
              DropdownMenuItem(value: 'bn', child: Text("BN")),
            ],
            onChanged: (val) {
              if (val != null) widget.onLangChange(val);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Status Card
            Card(
              color: Colors.indigo.shade50,
              child: ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.indigo),
                title: Text("${currentUser.name} (${currentUser.role == UserRole.admin ? loc.translate('admin_panel') : 'Staff User'})"),
                subtitle: Text("Access Level Verified"),
              ),
            ),
            const SizedBox(height: 20),

            // Branch & Unit Setup Section
            Text(loc.translate('branch') + " Setup", style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            DropdownButtonFormField<String>(
              value: selectedBranch,
              items: branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) => setState(() => selectedBranch = val!),
              decoration: const InputDecoration(labelText: "Select Operational Branch"),
            ),
            
            const SizedBox(height: 20),

            // Contract Creator with Template Elements
            Text(loc.translate('add_contract'), style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            TextField(
              controller: _clientNameController,
              decoration: const InputDecoration(labelText: "Client Full Name / Company Details"),
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedUnitType,
                    items: ["Room", "Shop"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => selectedUnitType = val!),
                    decoration: const InputDecoration(labelText: "Unit Type"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCycle,
                    items: ["Monthly", "Yearly"].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => selectedCycle = val!),
                    decoration: const InputDecoration(labelText: "Rent Cycle"),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: selectedPaymentMethod,
              items: ["Cash", "Bank Transfer", "Online/Mada"].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => selectedPaymentMethod = val!),
              decoration: InputDecoration(labelText: loc.translate('payment_method')),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Rent Amount (SAR)"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (_clientNameController.text.isEmpty || _amountController.text.isEmpty) return;
                setState(() {
                  // Execute logic: Add transaction data structure mapping the text variables
                  collectionLedger.add({
                    'client': _clientNameController.text,
                    'branch': selectedBranch,
                    'type': selectedUnitType,
                    'cycle': selectedCycle,
                    'method': selectedPaymentMethod,
                    'amount': double.parse(_amountController.text),
                    'date': DateTime.now().toString().substring(0, 10)
                  });
                  _clientNameController.clear();
                  _amountController.clear();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text(loc.translate('collect_rent')),
            ),

            const SizedBox(height: 30),

            // Expense Ledger Form Section
            Text(loc.translate('expense_ledger'), style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            TextField(
              controller: _expenseController,
              decoration: const InputDecoration(labelText: "Expense Description (e.g. Maintenance, Utility Bills)"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_expenseController.text.isEmpty) return;
                setState(() {
                  expenseLedger.add({
                    'description': _expenseController.text,
                    'branch': selectedBranch,
                    'date': DateTime.now().toString().substring(0, 10)
                  });
                  _expenseController.clear();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text("Record Expense"),
            ),

            const SizedBox(height: 30),

            // Live Output Analytics View For Management Real-time monitoring
            Text("Collection Records Dashboard", style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: collectionLedger.length,
              itemBuilder: (context, index) {
                final item = collectionLedger[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text("${item['client']} (${item['type']})"),
                    subtitle: Text("${item['branch']} • ${item['cycle']} • ${item['method']}"),
                    trailing: Text("${item['amount']} SAR\n${item['date']}", textAlign: TextAlign.end),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
String generateContractTemplate({
  required String clientName,
  required String branch,
  required String unitType,
  required String cycle,
  required double amount,
  required String method,
}) {
  return """
  COMMERCIAL LEASE AGREEMENT / عقد إيجار عقاري
  -------------------------------------------
  Branch/الفرع Location: $branch
  Lesse/المستأجر Name: $clientName
  Property Asset Assigned: $unitType
  Payment Cycle Frequency: $cycle Basis
  Agreed Value Rate: $amount SAR
  Permitted Channel Mode: $method
  
  Terms: The tenant agrees to process payments timely according to statement parameters executed by authorized account administrators.
  """;
}
