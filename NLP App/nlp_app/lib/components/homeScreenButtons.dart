import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WhiteButton extends StatelessWidget {
  const WhiteButton({
    Key? key,
    required this.height,
    required this.width,
    required this.heading,
    required this.subHeading,
    required this.onTap,
  }) : super(key: key);

  final double height;
  final double width;
  final String heading;
  final String subHeading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height * 0.25,
        width: width * 0.42,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        color: Colors.white, // Set text color to white
                      ),
                    ),
                    Text(
                      subHeading,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white, // Set text color to white
                      ),
                    ),
                    SizedBox(),
                    Center(
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
