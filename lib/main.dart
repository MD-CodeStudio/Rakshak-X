import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(EmergencyApp());
}

class EmergencyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  String searchQuery = "";
  int _selectedIndex = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> emergencies = [
    {"title": "CPR", "icon": Icons.favorite, "color": Colors.red},
    {"title": "Burns", "icon": Icons.local_fire_department, "color": Colors.orange},
    {"title": "Fractures", "icon": Icons.build, "color": Colors.blue},
    {"title": "Bleeding", "icon": Icons.bloodtype, "color": Colors.redAccent},
    {"title": "Choking", "icon": Icons.air, "color": Colors.purple},
    {"title": "Snake Bite", "icon": Icons.bug_report, "color": Colors.green},
    {"title": "Electric Shock", "icon": Icons.flash_on, "color": Colors.yellow},
    {"title": "Heart Attack", "icon": Icons.monitor_heart, "color": Colors.red},
    {"title": "Drowning", "icon": Icons.water, "color": Colors.blue},
    {"title": "Poisoning", "icon": Icons.warning, "color": Colors.greenAccent},
    {"title": "Allergic Reaction", "icon": Icons.sick, "color": Colors.pink},
    {"title": "Heat Stroke", "icon": Icons.wb_sunny, "color": Colors.orangeAccent},
    {"title": "Fainting", "icon": Icons.airline_seat_flat, "color": Colors.teal},
    {"title": "Asthma Attack", "icon": Icons.air, "color": Colors.cyan},
    {"title": "Head Injury", "icon": Icons.psychology, "color": Colors.deepPurple},
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
   // 🔹 SAVE CONTACTS
  Future<void> saveContacts(String c1, String c2) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contact1', c1);
    await prefs.setString('contact2', c2);
  }

  // 🔹 GET CONTACTS
  Future<Map<String, String>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "c1": prefs.getString('contact1') ?? "",
      "c2": prefs.getString('contact2') ?? "",
    };
  }
  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuidesScreen(emergencies: emergencies),
      ),
    );
  } else if (index == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContactScreen(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    var filteredList = emergencies
        .where((e) => e["title"]
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFF0D1117),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Emergency Guide"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          SizedBox(height: 10),

          // ✅ BUTTON TO SAVE CONTACTS
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SaveContactScreen()),
              );
            },
            child: Text("Set Emergency Contacts"),
          ),

          SizedBox(height: 10),

          // 🔥 Animated SOS Button
          ScaleTransition(
            scale: _animation,
            child: GestureDetector(
           onTap: () async {

  // 1️⃣ Get saved contacts
  final contacts = await getContacts();
  String c1 = contacts["c1"]!;
  String c2 = contacts["c2"]!;

  // 🚨 Check if contacts exist
  if (c1.isEmpty && c2.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please set emergency contacts first")),
    );
    return;
  }

  // 2️⃣ Get location
  Position? position;
  try {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      position = await Geolocator.getCurrentPosition();
    }
  } catch (e) {
    print("Location error");
  }

  // 3️⃣ Create message
  String locationMsg = position != null
      ? "https://maps.google.com/?q=${position.latitude},${position.longitude}"
      : "Location not available";

  String message = "🚨 EMERGENCY! I need help. My location: $locationMsg";

  // 4️⃣ Call FIRST contact
  if (c1.isNotEmpty) {
    final Uri callUri = Uri(scheme: 'tel', path: c1);
    await launchUrl(callUri);
  }

  // 5️⃣ Send SMS
  if (c1.isNotEmpty || c2.isNotEmpty) {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: "$c1,$c2",
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }
},

              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent, blurRadius: 20)
                  ],
                ),
                child: Center(
                  child: Text(
                    "SOS",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // 🔍 Search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search emergencies...",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF161B22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
          ),

          SizedBox(height: 15),

          // 📦 GRID
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                var item = filteredList[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(
                          title: item["title"],
                          icon: item["icon"],
                          color: item["color"],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item["icon"], color: item["color"], size: 30),
                        SizedBox(height: 10),
                        Text(
                          item["title"],
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
  currentIndex: _selectedIndex, // ✅ IMPORTANT
  onTap: _onItemTapped,         // ✅ IMPORTANT
  backgroundColor: Color(0xFF161B22),
  selectedItemColor: Colors.red,
  unselectedItemColor: Colors.grey,
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Guides"),
    BottomNavigationBarItem(icon: Icon(Icons.call), label: "Contacts"),
  ],
),
    );
  }
}

//  DETAIL SCREEN
class DetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  DetailScreen({required this.title, required this.icon, required this.color});

  List<String> getSteps(String title) {
  switch (title) {

    case "CPR":
      return [
        "Check responsiveness",
        "Call emergency number",
        "Start chest compressions (100-120/min)",
        "Give 2 rescue breaths",
        "Repeat until help arrives",
      ];

    case "Burns":
      return [
        "Cool burn under running water (10 mins)",
        "Remove tight items",
        "Cover with clean cloth",
        "Do not apply ice or oil",
        "Seek medical help if severe",
      ];

    case "Fractures":
      return [
        "Keep injured area still",
        "Use splint if possible",
        "Apply ice to reduce swelling",
        "Do not move bone",
        "Go to hospital immediately",
      ];

    case "Bleeding":
      return [
        "Apply direct pressure",
        "Raise injured area",
        "Use clean cloth/bandage",
        "Do not remove soaked cloth",
        "Seek medical help",
      ];

    case "Choking":
      return [
        "Ask if person can speak",
        "Give 5 back blows",
        "Perform abdominal thrusts",
        "Repeat until object removed",
        "Call emergency if unconscious",
      ];

    case "Snake Bite":
      return [
        "Keep victim calm",
        "Immobilize affected area",
        "Do not suck venom",
        "Remove tight items",
        "Rush to hospital",
      ];

    case "Electric Shock":
      return [
        "Turn off power source",
        "Do not touch directly",
        "Use dry object to separate",
        "Check breathing",
        "Call emergency help",
      ];

    case "Heart Attack":
      return [
        "Call emergency immediately",
        "Make person sit and relax",
        "Give aspirin if available",
        "Loosen tight clothes",
        "Monitor breathing",
      ];

    case "Drowning":
      return [
        "Remove from water safely",
        "Check breathing",
        "Start CPR if needed",
        "Keep warm",
        "Call emergency",
      ];

    case "Poisoning":
      return [
        "Identify poison substance",
        "Do not induce vomiting",
        "Call poison control",
        "Give water if advised",
        "Go to hospital",
      ];

    case "Allergic Reaction":
      return [
        "Identify allergen",
        "Use antihistamine",
        "Use epinephrine if severe",
        "Keep airway clear",
        "Seek medical help",
      ];

    case "Heat Stroke":
      return [
        "Move to cool place",
        "Remove excess clothing",
        "Apply cool cloth",
        "Give water slowly",
        "Call emergency",
      ];

    case "Fainting":
      return [
        "Lay person flat",
        "Raise legs slightly",
        "Loosen tight clothes",
        "Check breathing",
        "Give water after recovery",
      ];

    case "Asthma Attack":
      return [
        "Help use inhaler",
        "Sit upright",
        "Stay calm",
        "Repeat inhaler if needed",
        "Call doctor if severe",
      ];

    case "Head Injury":
      return [
        "Keep person still",
        "Apply cold pack",
        "Watch for vomiting",
        "Do not shake person",
        "Seek medical help",
      ];

    default:
      return ["Stay calm", "Call for help", "Provide basic aid"];
  }
}
  @override
  Widget build(BuildContext context) {
    var steps = getSteps(title);

    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [

            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 10),
                Text(title, style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      "${index + 1}. ${steps[index]}",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
//  GUIDES SCREEN
class GuidesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> emergencies;

  GuidesScreen({required this.emergencies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        title: Text("All Guides"),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: emergencies.length,
        itemBuilder: (context, index) {
          var item = emergencies[index];

          return ListTile(
            leading: Icon(item["icon"], color: item["color"]),
            title: Text(item["title"], style: TextStyle(color: Colors.white)),
            trailing: Icon(Icons.arrow_forward, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(
                    title: item["title"],
                    icon: item["icon"],
                    color: item["color"],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SaveContactScreen extends StatefulWidget {
  @override
  _SaveContactScreenState createState() => _SaveContactScreenState();
}

class _SaveContactScreenState extends State<SaveContactScreen> {
  TextEditingController c1Controller = TextEditingController();
  TextEditingController c2Controller = TextEditingController();

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contact1', c1Controller.text);
    await prefs.setString('contact2', c2Controller.text);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Contacts Saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        title: Text("Save Contacts"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: c1Controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Contact 1",
                filled: true,
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: c2Controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Contact 2",
                filled: true,
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
             onPressed: () {
  if (c1Controller.text.isEmpty || c2Controller.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please enter both contacts")),
    );
    return;
  }
  saveContacts();
},
              child: Text("Save"),
            )

          ],
        ),
      ),
    );
  }
}

//  CONTACT SCREEN
class ContactScreen extends StatelessWidget {

  final List<Map<String, String>> contacts = [
    {"name": "Ambulance", "number": "102"},
    {"name": "Police", "number": "100"},
    {"name": "Fire Brigade", "number": "101"},
    {"name": "Women Helpline", "number": "1091"},
    {"name": "Disaster Management", "number": "108"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        title: Text("Emergency Contacts"),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          var item = contacts[index];

          return Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: ListTile(
              title: Text(item["name"]!, style: TextStyle(color: Colors.white)),
              subtitle: Text(item["number"]!, style: TextStyle(color: Colors.grey)),
              trailing: Icon(Icons.call, color: Colors.green),
              onTap: () async {
  final Uri phoneUri = Uri(scheme: 'tel', path: item["number"]);

  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Cannot make call")),
    );
  }
},
            ),
          );
        },
      ),
    );
  }
}