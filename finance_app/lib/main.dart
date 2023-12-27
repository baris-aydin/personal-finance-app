import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
//import 'new_transaction_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'FinanceApp',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  double _incomeTotal = 0;
  double _expenseTotal = 0;
  Map<String, double> _expensesByCategory = {};

  double get incomeTotal => _incomeTotal;
  double get expenseTotal => _expenseTotal;
  double get balanceTotal => _incomeTotal - _expenseTotal;

  void addIncome(double amount) {
    _incomeTotal += amount;
    notifyListeners();
  }

  void addExpense(double amount, String category) {
    _expenseTotal += amount;
    _expensesByCategory.update(category, (existingAmount) => existingAmount + amount, ifAbsent: () => amount);
    notifyListeners();
  }
  Map<String, double> get expensesByCategory => _expensesByCategory;

  List<Map<String, String>> _datesList = [];

  List<Map<String, String>> get datesList => _datesList;

  void addDate(String date, String description) {
    _datesList.add({'date': date, 'description': description});
    notifyListeners();
  }

  String get biggestSpendingCategory {
    if (_expensesByCategory.isEmpty) return 'None';

    var sortedEntries = _expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.first.key;
  }

  void resetData() {
    _incomeTotal = 0;
    _expenseTotal = 0;
    _expensesByCategory.clear();
    _datesList.clear();
    notifyListeners();
  }

}


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = TransactionsPage();
        break;
      case 2:
        page = SettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
}
return Scaffold(
  body: Container(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: page,
  ),
    bottomNavigationBar: BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Transactions',
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (int index){
          setState(() {
            selectedIndex = index;
          });
        }
       ),
      );
  }
}

class HomePage extends StatelessWidget{
  final List<Map<String, dynamic>> cardData = [
    {
      'icon': Icons.receipt,
      'title': 'Expenses',
      'subtitle': 'Expense Details'
    },
    {
      'icon': Icons.paid,
      'title': 'Income',
      'subtitle': 'Income Details'
    },
    {
      'icon': Icons.account_balance,
      'title': 'Total Balance',
      'subtitle': 'Total Saving Details'
    },
    {
      'icon': Icons.bar_chart,
      'title': 'Categories',
      'subtitle': 'Spending Categories'
    },
    {
      'icon': Icons.info,
      'title': 'Information',
      'subtitle': 'Spending Tips'
    },
    {
      'icon': Icons.event,
      'title': 'Date',
      'subtitle': 'Due Dates'
    },
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: cardData.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> item = cardData[index];
        String title = cardData[index]['title'];
        IconData icon = cardData[index]['icon'];

        Widget cardContent;

        if (title == 'Date') {
          cardContent = _buildDatesCard(appState);
        } else if(title == 'Information'){
          cardContent = _buildInformationCard(appState);
        } else if (title == 'Categories') {
          cardContent = _buildCategoryCard(appState);
        } else{
          String number = '';
          if (title == 'Income') {
            number = appState.incomeTotal.toStringAsFixed(2);
          } else if (title == 'Expenses') {
            number = appState.expenseTotal.toStringAsFixed(2);
          } else if (title == 'Total Balance') {
            number = appState.balanceTotal.toStringAsFixed(2);
          }

          cardContent =  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 100),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                    Text(number, style: TextStyle(fontSize: 100)),
                  ],
                ),
              ),
            ],
          );
        }
        return Card(child: Container(padding: EdgeInsets.all(10), child: cardContent));
      },
    );
  }

  Widget _buildCategoryCard(MyAppState appState) {
  List<Widget> categoryWidgets = appState.expensesByCategory.entries.map((entry) {
    return Text("${entry.key}: \$${entry.value.toStringAsFixed(2)}", style: TextStyle(fontSize: 16));
  }).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.bar_chart, size: 40), // Bar chart icon
          SizedBox(width: 8), // Space between icon and text
          Text("Categories", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), // Title
        ],
      ),
      SizedBox(height: 10), // Space between header and category list
      ...categoryWidgets, // Category list
      ],
    );
  }

  Widget _buildDatesCard(MyAppState appState) {
    List<Widget> dateWidgets = appState.datesList.map((dateEntry) {
      return Text("${dateEntry['date']}: ${dateEntry['description']}", style: TextStyle(fontSize: 16));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event, size: 40), // Event icon
            SizedBox(width: 8), // Space between icon and text
            Text("Dates", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), // Title
          ],
        ),
        SizedBox(height: 10), // Space between header and date list
        ...dateWidgets, // Date list
      ],
    );
  }

  Widget _buildInformationCard(MyAppState appState) {
    List<Widget> infoWidgets = [
      // Header with icon and title
      Row(
        children: [
          Icon(Icons.info, size: 40), // Info icon
          SizedBox(width: 8), // Space between icon and text
          Text("Information", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), // Title
        ],
      ),
      SizedBox(height: 10), // Space between header and info list

      // Income vs Expense message
      Text(
        appState.balanceTotal >= 0 ? '- You spend less than your income.' : '- You spend more than you make.',
        style: TextStyle(
          color: appState.balanceTotal >= 0 ? Colors.green : Colors.red,
          fontSize: 36, // Larger font size for the text
        ),
      ),
      // Biggest spending category
     Text(
        '- The biggest spending category: ${appState.biggestSpendingCategory}',
        style: TextStyle(fontSize: 36), // Larger font size
      ),
      // Generic financial tips
      Text(
        '- Do not forget 50-30-20 rule, put 50% towards needs, 30% towards wants, and 20% towards savings.',
        style: TextStyle(fontSize: 36), // Larger font size
      ),
      Text('- Build up your savings', style: TextStyle(fontSize: 36)),
      Text('- Start an investment strategy', style: TextStyle(fontSize: 36)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: infoWidgets,
    );
  }

}

class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep the card size minimal
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16), // Padding around buttons
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to add income page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddIncomePage()),
                      );
                    },
                    child: Text('Income'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50), // Makes the button wider and taller
                    ),
                  ),
                  SizedBox(height: 10), // Spacing between buttons
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to add expense page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddExpensePage()),
                      );
                    },
                    child: Text('Expense'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50), // Makes the button wider and taller
                    ),
                  ),
                  SizedBox(height: 10), // Spacing between buttons
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to add expense page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddDatesPage()),
                      );
                    },
                    child: Text('Dates'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50), // Makes the button wider and taller
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _resetData(context),
          child: Text('Reset Data'),
        ),
      ),
    );
  }

  void _resetData(BuildContext context) {
    // Show confirmation dialog before resetting
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Data'),
          content: Text('Are you sure you want to reset all data? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Reset'),
              onPressed: () {
                context.read<MyAppState>().resetData(); // Reset the data
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}

class AddIncomePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Income"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Income Amount",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final double amount = double.parse(_controller.text);
                context.read<MyAppState>().addIncome(amount);
                Navigator.pop(context);
              },
              child: Text('Add Income'),
            ),
          ],
        ),
      ),
    );
  }
}


class AddExpensePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'clothes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Expense"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: "Expense Amount",),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                _selectedCategory = newValue!;
              },
              items: <String>['clothes', 'eating out', 'entertainment', 'fuel', 'general', 'gifts', 'vacations', 'shopping', 'sports', 'travel']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                final double amount = double.parse(_controller.text);
                context.read<MyAppState>().addExpense(amount, _selectedCategory);
                Navigator.pop(context);
              },
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddDatesPage extends StatelessWidget {
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _submitDate(BuildContext context) {
    int month = int.parse(_monthController.text);
    int day = int.parse(_dayController.text);
    int year = int.parse(_yearController.text);
    String description = _descriptionController.text;

    // Array of month names
    List<String> monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    String formattedDate = "$day ${monthNames[month - 1]} $year"; // Format the date

    context.read<MyAppState>().addDate(formattedDate, description);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Date"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _monthController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Month (1-12)"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _dayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Day (1-31)"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Year (1-9999)"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "Enter a description for the date",
              ),
              maxLines: null,
            ),
            ElevatedButton(
              onPressed: () => _submitDate(context),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
