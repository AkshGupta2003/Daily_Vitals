import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nlp_app/CustomListTitle.dart';
import 'package:nlp_app/bloodSugar.dart';
import 'package:nlp_app/insulin.dart';
import 'package:nlp_app/mealIntake.dart';
import 'package:nlp_app/physicalActivity.dart';

class first_page extends StatefulWidget {
  const first_page({super.key});

  @override
  State<first_page> createState() => _first_pageState();
}

class _first_pageState extends State<first_page> {
  
  void openBloodSugarEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return BloodSugarEntryBottomSheet();
      },
    );
  }

  void openInsulinEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return InsulinEntryBottomSheet();
        // return BloodSugarEntryBottomSheet();
      },
    );
  }

  void openMealIntakeEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return MealIntakeEntryBottomSheet();
        // return BloodSugarEntryBottomSheet();
      },
    );
  }

  void openActivityEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return ActivityEntryBottomSheet();
        // return BloodSugarEntryBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: 
      AppBar(
        title: Text(
          "Data Entry",
          style: GoogleFonts.inter(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 35, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CustomListTile(
                  // leadingIcon: Image.asset('assets/images/sugar.png'),
                  heading: 'Blood Sugar',
                  subheading: 'Keep Track of Your Blood Sugar Readings',
                  trailingIcon: Icons.add_box_rounded,
                  onTap: openBloodSugarEntryDialog,
                ),
                CustomListTile(
                  // leadingIcon: Image.asset('assets/images/insulin.png'),
                  heading: 'Insulin Taken',
                  subheading: 'Keep a Record of Your Insulin Intake',
                  trailingIcon: Icons.add_box_rounded,
                  onTap: openInsulinEntryDialog,
                ),
                CustomListTile(
                  // leadingIcon: Image.asset('assets/images/meal.png'),
                  heading: 'Meal Intake',
                  subheading: 'Keep Track of Your Daily Meal Intake',
                  trailingIcon: Icons.add_box_rounded,
                  onTap: openMealIntakeEntryDialog,
                ),
                CustomListTile(
                  // leadingIcon: Image.asset('assets/images/physical_activity.png'),
                  heading: 'Physical Activity',
                  subheading: 'Record Your physical activity',
                  trailingIcon: Icons.add_box_rounded,
                  onTap: openActivityEntryDialog,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
