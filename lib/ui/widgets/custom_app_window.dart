import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class CustomAppWindow extends StatelessWidget {
  CustomAppWindow({super.key, required this.isExitable});
  final bool isExitable;

  final buttonColors = WindowButtonColors(
      iconNormal: const Color.fromARGB(255, 255, 255, 255),
      mouseOver: const Color.fromARGB(255, 246, 12, 12),
      mouseDown: const Color.fromARGB(255, 128, 6, 6),
      iconMouseOver: const Color.fromARGB(255, 128, 6, 6),
      iconMouseDown: const Color(0xFFFFD500));

  final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: const Color.fromARGB(255, 255, 255, 255),
      iconMouseOver: Colors.white);

  @override
  Widget build(BuildContext context) {
    return MoveWindow(
      child: WindowBorder(
        color: Colors.transparent,
        width: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                isExitable
                    ? Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2),
                            child: IconButton(
                              icon:
                                  const Icon(FluentIcons.arrow_left_12_filled),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 90,
                          ),
                        ],
                      )
                    : const SizedBox(
                        width: 138,
                      ),
                const Spacer(flex: 2),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.asset("assets/images/app_icon.ico", scale: 1.5),
                ),
                const Spacer(flex: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MinimizeWindowButton(
                      colors: buttonColors,
                    ),
                    MaximizeWindowButton(
                      colors: buttonColors,
                    ),
                    CloseWindowButton(
                      colors: closeButtonColors,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
