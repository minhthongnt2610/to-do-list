import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';


class HeaderItem extends StatelessWidget {
  
  const HeaderItem({
    required this.title,
    required this.onSeeAllTap,
    super.key,
  });

  
  final String title;

  final VoidCallback onSeeAllTap;

  
  @override
  Widget build(BuildContext context) {
    
    return Padding(
      
      padding: const EdgeInsets.symmetric(
        
        horizontal: 20,

        
        vertical: 16,
      ),

      
      child: Row(
        
        children: [
          
          Expanded(
            
            child: Text(
              
              title,

              
              style: const TextStyle(
                
                fontSize: 22,

                
                color: Colors.white,
              ),
            ),
          ),

          
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onSeeAllTap,
            child: const Text(
              
              'See All',

              
              style: TextStyle(
                
                fontSize: 16,

                
                color: AppColors.hexBA83DE,
              ),
            ),
          )
        ],
      ),
    );
  }
}
