// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:isolate';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Isolate Example',
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   List<int> results = [];
//   late ReceivePort receivePort;

//   void startIsolate() async {
//     results.clear();
//     receivePort = ReceivePort(); // Create a ReceivePort
//     Isolate.spawn(runIsolate, receivePort.sendPort); // Start the isolate

//     // Listen for messages from the isolate
//     receivePort.listen((data) {
//       setState(() {
//         results.add(data); // Update the UI with the result
//       });
//     });
//   }

//   @override
//   void dispose() {
//     receivePort.close(); // Close the ReceivePort when disposing
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Isolate Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: startIsolate,
//               child: Text('Start Computation'),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: results.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(results[index].toString()),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Future<void> runIsolate(SendPort sendPort) async {
//   for (int i = 0; i <= 10000; i++) {
//     sendPort.send(i); // Send the result back to the main thread
//   }
// }

// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Without Isolate Example',
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   List<int> results = [];
//   bool isLoading = false;

//   void startComputation() async {
//     setState(() {
//       isLoading = true;
//     });

//     //await Future.delayed(Duration(milliseconds: 100)); // Mimic async behavior
//     for (int i = 0; i <= 10000; i++) {
//       results.add(i);
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Without Isolate Example'),
//       ),
//       body: Center(
//         child: isLoading
//             ? CircularProgressIndicator() // Show loader while data is being fetched
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   ElevatedButton(
//                     onPressed: startComputation,
//                     child: Text('Start Computation'),
//                   ),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: results.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(results[index].toString()),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:isolate';

class ApiService {
  // Method that fetches users in a background Isolate
  static Future<List<dynamic>> fetchUsersInIsolate() async {
    // Create a ReceivePort to communicate with the isolate
    final receivePort = ReceivePort();

    // Spawn the isolate, passing the SendPort of the ReceivePort
    await Isolate.spawn(_fetchUsersIsolate, receivePort.sendPort);

    // Receive the user data from the isolate
    final userList = await receivePort.first as List<dynamic>;

    return userList;
  }

  // The function to run inside the isolate
  static void _fetchUsersIsolate(SendPort sendPort) async {
    try {
      Dio dio = Dio();
      final response = await dio.get('https://dummyjson.com/users');
      if (response.statusCode == 200) {
        // Send the fetched data back to the main thread
        sendPort.send(response.data['users']);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      sendPort.send([]); // Send an empty list in case of an error
    }
  }
}

// Import the ApiService file

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  Future<List<dynamic>> _fetchUsersFuture() async {
    return ApiService.fetchUsersInIsolate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchUsersFuture(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final users = snapshot.data!;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['firstName']),
                  subtitle: Text(user['email']),
                );
              },
            );
          } else {
            return const Center(child: Text('No users found.'));
          }
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MyHomePage(),
  ));
}
