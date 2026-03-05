import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_do_list/screens/profile/profile_screen.dart';

import '../../../common_widgets/avatar.dart';
import '../../../constants/app_colors.dart';


class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  const HomeAppBar({
    required this.onSearchChanged,
    required this.user,
    super.key,
  });

  
  final ValueChanged<String> onSearchChanged;

  final User user;

  
  @override
  Widget build(BuildContext context) {
    
    return AppBar(
      
      backgroundColor: AppColors.hex020206,

      
      systemOverlayStyle: SystemUiOverlayStyle.light,

      
      scrolledUnderElevation: 0,

      
      title: Text(
        
        greet(),

        
        maxLines: 2,

        
        style: const TextStyle(
          
          color: Colors.white,

          
          fontSize: 24,

          
          fontWeight: FontWeight.bold,
        ),
      ),

      
      titleSpacing: 20,

      
      actions: [
        
        GestureDetector(
          child: Avatar(
            user: user,
            size: 45,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(ProfileScreen.routeName);
          },
        ),

        
        const SizedBox(
          
          width: 20,
        ),
      ],

      
      centerTitle: false,
    );
  }

  String greet() {
    var hour = DateTime.now().hour;
    var name = user.displayName ?? 'Anonymous';
    var greeting = '';
    if (hour < 12) {
      greeting = 'Good morning ☀️';
    }
    if (hour < 18) {
      greeting = 'Good afternoon 🌤️';
    } else {
      greeting = 'Good evening 🌃';
    }
    return '$greeting,\n$name 🖐️';
  }

  
  @override
  Size get preferredSize => const Size.fromHeight(70);
}
