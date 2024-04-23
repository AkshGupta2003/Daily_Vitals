import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nlp_app/pages/first_page.dart';
import '../components/homeScreenButtons.dart';

class HomeScreen extends StatefulWidget {
  static String id = "HomeScreen";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var _colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                        "https://img.freepik.com/free-vector/doctor-character-background_1270-84.jpg"),
                  ),
                  GestureDetector(
                    onTap: () {
                      // _scaffoldKey.currentState?.openEndDrawer();
                    },
                    child: Image.asset(
                      "assets/images/button-removebg-preview.png",
                      height: 45,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello,",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500, fontSize: 24),
                  ),
                  SizedBox(
                    height: 3,
                    width: width,
                  ),
                  Text(
                    "Patient",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 30),
                  )
                ],
              ),
              SizedBox(
                height: 25,
              ),
              buildBlackButton(context, _colorScheme),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WhiteButton(
                    height: height,
                    width: width,
                    heading: "Blood Report",
                    subHeading:
                        "Data collection required after each blood test.",
                    onTap: () {
                      // Navigator.pushNamed(context, ShowPatientsScreen.id);
                    },
                  ),
                  WhiteButton(
                    height: height,
                    width: width,
                    heading: "Daily Vitals",
                    subHeading: "Daily submission of vital signs is required.",
                    onTap: () {
                      // Handle download functionality here
                      Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => first_page()));
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // Handle sign out functionality here
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 60, vertical: 13)),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(fontSize: 16)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                child: Text(
                  "Sign Out",
                  style: GoogleFonts.outfit(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 28.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector buildBlackButton(
      BuildContext context, ColorScheme _colorScheme) {
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, PatientFormScreen.id);
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: _colorScheme.primary,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Insights Report",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Receive tailored insights concerning your diabetes health.",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Image.asset(
                "assets/images/homepagecard.png",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
