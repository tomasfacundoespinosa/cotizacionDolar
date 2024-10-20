import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('dollarBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotización del Dólar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Montserrat',
      ),
      home: const MyHomePage(title: 'Cotización del Dólar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ApiService apiService = ApiService();
  List<dynamic>? dollarData;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchDollarData();
  }

  Future<void> fetchDollarData() async {
    final List<dynamic> data = await apiService.fetchDollarData();
    var box = Hive.box('dollarBox');

    for (var element in data) {
      if (element.containsKey('venta') && element.containsKey('nombre')) {
        final tipoDolar = element['nombre'];
        final valorDolar = element['venta'];
        box.put(tipoDolar, valorDolar);
      }
    }

    setState(() {
      dollarData = data;
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020, 1),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      var box = Hive.box('dollarBox');
      var dataForDate = box.keys.where((key) => key.toString().startsWith(formattedDate)).toList();

      if (dataForDate.isNotEmpty) {
        setState(() {
          selectedDate = formattedDate;
          dollarData = dataForDate.map((key) => box.get(key)).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontraron cotizaciones para esa fecha.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('dollarBox');
    var dollarTypes = ['Oficial', 'Blue', 'Bolsa', 'Contado con liquidación', 'Mayorista', 'Cripto'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 22)),
        backgroundColor: Color.fromARGB(255, 114, 163, 253),
        elevation: 0,
      ),
      body: dollarData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blueAccent, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              'Cotización del dólar - $selectedDate',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2 / 1,
                      ),
                      itemCount: dollarTypes.length,
                      itemBuilder: (context, index) {
                        final tipoDolar = dollarTypes[index];
                        final valorDolar = box.get(tipoDolar) ?? 'N/A';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tipoDolar.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$$valorDolar',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectDate(context),
        tooltip: 'Buscar por fecha',
        backgroundColor: Color.fromARGB(255, 114, 163, 253),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(Icons.calendar_today, color: Colors.white, size: 30),
      ),
    );
  }
}
