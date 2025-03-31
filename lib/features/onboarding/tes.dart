// import 'package:duri_care/core/resources/resources.dart';
// import 'package:duri_care/models/onboarding/data.dart';
// import 'package:flutter/material.dart';

// class OnboardingTest extends StatefulWidget {
//   const OnboardingTest({super.key});

//   @override
//   State<OnboardingTest> createState() => _OnboardingTestState();
// }

// class _OnboardingTestState extends State<OnboardingTest> {
//   PageController? _pageController;
//   int currentIndex = 0;
//   double percentage = 0.25;

//   @override
//   void initState() {
//     _pageController = PageController(initialPage: 0);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _pageController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               // color: AppColor.greenPrimary,
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: contentsList.length,
//                 onPageChanged: (int index){
//                   if (index >= currentIndex) {
//                     setState(() {
//                       currentIndex = index;
//                       percentage += 0.25;
//                     });
//                   } else {
//                     setState(() {
//                       currentIndex = index;
//                       percentage -= 0.25;
//                     });
//                   }
//                 },
//                 itemBuilder: (context, index) {
//                   return Column(
//                     children: [
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset(
//                             'assets/images/DURICARE-LOGO.png',
//                             width: 120,
//                           ),
//                           AppSpacing.md,
//                           Text(
//                             'DuriCare',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//           Expanded(child: Container(color: AppColor.greenSecondary)),
//         ],
//       ),
//     );
//   }
// }
