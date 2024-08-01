import 'package:flutter/material.dart';

class CourseScreen extends StatelessWidget {
  final String courseName;
  final AssetImage courseImage;
  final String courseInfo;
  final String coursePrice;

  const CourseScreen(
      {Key? key,
        required this.courseName,
        required this.courseImage,
        required this.courseInfo,
        required this.coursePrice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.courseCardColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: MyTheme.catalogueButtonColor),
      ),
      body: Stack(
        children: [
          Column(children: [
            Expanded(
              flex: 35,
              child: Center(
                child: Image(
                  image: courseImage,
                ),
              ),
            ),
            const Spacer(
              flex: 65,
            )
          ]),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32.0))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                              color: MyTheme.grey.withOpacity(0.5),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(1.0))),
                          height: 4,
                          width: 48,
                        ),
                      ),
                      MyTheme.mediumVerticalPadding,
                      Text(courseName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(courseInfo,
                          style: TextStyle(fontSize: 16, color: MyTheme.grey)),
                      MyTheme.largeVerticalPadding,
                      Row(
                        children: [
                          Text(coursePrice,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Column(
                              children: [
                                const Text("Progress: 100%"),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(
                                      32.0, 4.0, 32.0, 8.0),
                                  height: 10,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: LinearProgressIndicator(
                                      value: 1,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          MyTheme.progressColor),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      MyTheme.mediumVerticalPadding,
                      const Text(
                        "Learn the basics of lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                        style: TextStyle(fontSize: 16),
                      ),
                      MyTheme.mediumVerticalPadding,
                      Row(
                        children: [
                          const Spacer(
                            flex: 2,
                          ),
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              // TODO: uncomment to go to Graduation Screen
                                onPressed: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => GraduationScreen(
                                  //             courseName: courseName,
                                  //           )),
                                  // );
                                },
                                child: const Text(
                                  "Graduate",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                )),
                          ),
                          const Spacer(
                            flex: 2,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MyTheme {
  static Color get backgroundColor => const Color(0xFFF7F7F7);
  static Color get grey => const Color(0xFF999999);
  static Color get catalogueCardColor =>
      const Color(0xFFBAE5D4).withOpacity(0.5);
  static Color get catalogueButtonColor => const Color(0xFF29335C);
  static Color get courseCardColor => const Color(0xFFEDF1F1);
  static Color get progressColor => const Color(0xFF36F1CD);

  static Padding get largeVerticalPadding =>
      const Padding(padding: EdgeInsets.only(top: 32.0));

  static Padding get mediumVerticalPadding =>
      const Padding(padding: EdgeInsets.only(top: 16.0));

  static Padding get smallVerticalPadding =>
      const Padding(padding: EdgeInsets.only(top: 8.0));

  static ThemeData get theme => ThemeData(
    fontFamily: 'Poppins',
    primarySwatch: Colors.blueGrey,
  ).copyWith(
    cardTheme: const CardTheme(
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(0.0),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(
            catalogueButtonColor), // Button color
        foregroundColor: MaterialStateProperty.all<Color>(
            Colors.white), // Text and icon color
      ),
    ),
  );
}
