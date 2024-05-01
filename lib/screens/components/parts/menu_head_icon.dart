import 'package:flutter/material.dart';

class MenuHeadIcon extends StatelessWidget {
  const MenuHeadIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/menu_head_icon.png'),
            ),
          ),
        ),
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
        ),
      ],
    );
  }
}
