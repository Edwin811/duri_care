// import 'package:flutter/material.dart';

// /// A mixin to help manage TextEditingController lifecycle
// mixin TextControllerMixin {
//   /// List to track all text controllers
//   final List<TextEditingController> _controllers = [];

//   /// Register a TextEditingController to be automatically disposed
//   TextEditingController registerController([String? initialValue]) {
//     final controller = TextEditingController(text: initialValue);
//     _controllers.add(controller);
//     return controller;
//   }

//   /// Dispose all registered controllers
//   void disposeControllers() {
//     for (final controller in _controllers) {
//       controller.dispose();
//     }
//     _controllers.clear();
//   }

//   /// Clear the text of all registered controllers
//   void clearControllers() {
//     for (final controller in _controllers) {
//       controller.clear();
//     }
//   }
// }

// /// A widget that manages TextEditingController lifecycle automatically
// class ControllerLifecycleManager extends StatefulWidget {
//   final Widget child;
//   final List<TextEditingController> controllers;
//   final VoidCallback? onDispose;

//   const ControllerLifecycleManager({
//     Key? key,
//     required this.child,
//     required this.controllers,
//     this.onDispose,
//   }) : super(key: key);

//   @override
//   State<ControllerLifecycleManager> createState() =>
//       _ControllerLifecycleManagerState();
// }

// class _ControllerLifecycleManagerState
//     extends State<ControllerLifecycleManager> {
//   @override
//   void dispose() {
//     for (final controller in widget.controllers) {
//       controller.dispose();
//     }
//     widget.onDispose?.call();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
