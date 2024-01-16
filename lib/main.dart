import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class Expense {
  double amount;
  String category;
  String note;
  bool isIncome;
  DateTime date; // 新增日期信息

  Expense({
    required this.amount,
    required this.category,
    required this.note,
    required this.isIncome,
    required this.date, // 添加日期信息
  });
}



class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? selectedDate;
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  List<Expense> expenses = [];
  String selectedCategory = '飲食';
  String selectedIncomeType = '工費'; // 添加這一行，並設定默認值
  bool isIncome = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }
void _addExpense() {
  String amountText = amountController.text;
  String noteText = noteController.text;
  if (amountText.isNotEmpty && selectedDate != null) {
    double expenseAmount = double.parse(amountText) * (isIncome ? 1 : -1);
    setState(() {
      expenses.add(
        Expense(
          amount: expenseAmount,
          category: selectedCategory,
          note: noteText,
          isIncome: isIncome,
          date: selectedDate!, // 賦值選擇的日期
        ),
      );
    });
    amountController.clear();
    noteController.clear();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('記帳本'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '選擇日期:',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            selectedDate != null
                ? '${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日'
                : '請選擇日期',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: Text('選擇日期'),
          ),
          SizedBox(height: 20),
          ExpenseInputSection(
            amountController: amountController,
            noteController: noteController,
            selectedCategory: selectedCategory,
            isIncome: isIncome,
            onCategoryChanged: (String newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            },
            onIncomeChanged: (bool newValue) {
              setState(() {
                isIncome = newValue;
              });
            },
            onAddExpense: _addExpense,
            selectedIncomeType: selectedIncomeType, // 將 selectedIncomeType 傳遞給子組件
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsPage(expenses: expenses),
                ),
              );
            },
            child: Text('查看統計報告'),
          ),
        ],
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  final List<Expense> expenses;

  StatisticsPage({required this.expenses});

  @override
  Widget build(BuildContext context) {
  double totalExpense = expenses.isNotEmpty
      ? expenses.where((e) => !e.isIncome).map((e) => e.amount.abs()).fold(0, (a, b) => a + b)
      : 0;

  double totalIncome = expenses.isNotEmpty
      ? expenses.where((e) => e.isIncome).map((e) => e.amount).fold(0, (a, b) => a + b)
      : 0;

  double totalBalance = totalIncome - totalExpense;

  return Scaffold(
    appBar: AppBar(
      title: Text('統計報告'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '總支出金額: \$${totalExpense.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            '總收入金額: \$${totalIncome.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            '合計: \$${totalBalance.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          Text(
            '支出詳情:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('金額: \$${expenses[index].amount.toStringAsFixed(2)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('日期: ${DateFormat('yyyy-MM-dd').format(expenses[index].date)}'),
                    Text('分類: ${expenses[index].category}'),
                  ],
                ),
                onTap: () {
                  _showExpenseDetails(context, expenses[index]);
        },
      );
    },
  ),
),

          SizedBox(height: 20),
          Text(
            '月度:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // 月度支出圓餅圖
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _generateExpensePieChartSections(),
                      borderData: FlBorderData(show: false),
                      centerSpaceRadius: 40,
                      sectionsSpace: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20), // 設定兩個圓餅圖之間的間距
              Expanded(
                flex: 1,
                child: Container(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _generateIncomePieChartSections(),
                      borderData: FlBorderData(show: false),
                      centerSpaceRadius: 40,
                      sectionsSpace: 0,
          ),
        ),
      ),
    ),
  ],
),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('返回'),
          ),
        ],
      ),
    ),
  );
}

List<PieChartSectionData> _generateExpensePieChartSections() {
  List<PieChartSectionData> sections = [];

  Map<String, double> categoryMap = {};
  for (Expense expense in expenses) {
    if (!expense.isIncome) {
      categoryMap[expense.category] ??= 0;
      categoryMap[expense.category] = categoryMap[expense.category]! + expense .amount.abs();
    }
  }

  int index = 0;
  categoryMap.forEach((category, amount) {
    sections.add(
      PieChartSectionData(
        value: amount,
        color: _getRandomColor(index),
        title: '$category\n\$${amount.toStringAsFixed(2)}',
        radius: 80,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
    index++;
  });

  return sections;
}

List<PieChartSectionData> _generateIncomePieChartSections() {
  List<PieChartSectionData> sections = [];

  Map<String, double> categoryMap = {};
  for (Expense income in expenses) {
    if (income.isIncome) {
      categoryMap[income.category] ??= 0;
      categoryMap[income.category] = categoryMap[income.category]! + income .amount;
    }
  }

  int index = 0;
  categoryMap.forEach((category, amount) {
    sections.add(
      PieChartSectionData(
        value: amount,
        color: _getRandomColor(index),
        title: '$category\n\$${amount.toStringAsFixed(2)}',
        radius: 80,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
    index++;
  });

  return sections;
}

  Color _getRandomColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
    ];

    return colors[index % colors.length];
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('支出詳情'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('金額: \$${expense.amount.toStringAsFixed(2)}'),
            Text('日期: ${DateFormat('yyyy-MM-dd').format(expense.date)}'), // 添加日期顯示
            Text('分類: ${expense.category}'),
            Text('附註: ${expense.note}'),
            Text('類型: ${expense.isIncome ? '收入' : '支出'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('關閉'),
            ),
          ],
        );
      },
    );
  } 
}

class ExpenseInputSection extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController noteController;
  final String selectedCategory;
  final bool isIncome;
  final Function(String) onCategoryChanged;
  final Function(bool) onIncomeChanged;
  final VoidCallback onAddExpense;
  final String selectedIncomeType;

  ExpenseInputSection({
    required this.amountController,
    required this.noteController,
    required this.selectedCategory,
    required this.isIncome,
    required this.onCategoryChanged,
    required this.onIncomeChanged,
    required this.onAddExpense,
    required this.selectedIncomeType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '輸入金額',
          ),
        ),
        SizedBox(height: 20),
        DropdownButton<String>(
  value: isIncome ? selectedIncomeType : selectedCategory,
  onChanged: (String? newValue) {
    if (isIncome) {
      onCategoryChanged(newValue!);
    } else {
      onCategoryChanged(newValue!);
    }
  },
  items: isIncome
      ? ['工費', '零用錢', '獎金', '臨時收入', '副業', '投資']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList()
      : ['飲食', '電信', '交通', '房租', '日用品']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
),




        SizedBox(height: 20),
        Row(
          children: [
            Text('類型:'),
            SizedBox(width: 10),
            Row(
              children: [
                Radio(
                  value: false,
                  groupValue: isIncome,
                  onChanged: (bool? newValue) {
                    onIncomeChanged(false);
                  },
                ),
                Text('支出'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isIncome,
                  onChanged: (bool? newValue) {
                    onIncomeChanged(true);
                  },
                ),
                Text('收入'),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: '輸入附註',
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: onAddExpense,
          child: Text('提交'),
        ),
      ],
    );
  }
}


      // categoryMap[income.category] ??= 0;
      // categoryMap[income.category] = categoryMap[income.category]! + income .amount;