import 'package:flutter/material.dart';
import 'package:to_do_list/constants/app_colors.dart';


class TertiaryButton extends StatelessWidget {
  const TertiaryButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  
  final String title;

  
  final VoidCallback onTap;

  
  @override
  Widget build(BuildContext context) {
    
    return InkWell(
      
      onTap: onTap,

      
      child: Container(
        
        height: 50,

        
        decoration:  BoxDecoration(
          
          color: AppColors.hex4F4F4F.withOpacity(0.8),

          
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),

        
        child: Center(
          
          child: Text(
            
            title,

            
            style: const TextStyle(
              
              color: Colors.white,

              
              fontSize: 16,

              
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
