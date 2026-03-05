import 'package:flutter/material.dart';

import '../constants/app_colors.dart';


class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
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

        
        decoration: const BoxDecoration(
          
          gradient: LinearGradient(
            
            colors: [
              
              AppColors.hexBA83DE,

              
              AppColors.hexDE83B0,
            ],

            
            begin: Alignment.centerLeft,

            
            end: Alignment.centerRight,
          ),

          
          borderRadius: BorderRadius.all(Radius.circular(8)),
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
