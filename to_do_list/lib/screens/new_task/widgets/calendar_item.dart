import 'package:flutter/material.dart';
import 'package:to_do_list/extensions/date_time_extensions.dart';

import '../../../constants/app_colors.dart';


class CalendarItem extends StatelessWidget {
  const CalendarItem({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onSelected,
  });

  
  final bool isSelected;

  
  final DateTime date;

  
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      
      onTap: () {
        
        onSelected.call();
      },
      
      behavior: HitTestBehavior.translucent,
      
      child: Stack(
        
        fit: StackFit.expand,
        
        alignment: Alignment.bottomCenter,
        
        children: [
          
          Positioned(
            
            top: 0,
            right: 0,
            left: 0,
            bottom: 3,
            
            child: Container(
              
              decoration: BoxDecoration(
                
                borderRadius: BorderRadius.circular(10),
                
                border: Border.all(
                  
                  color: isSelected ? AppColors.hexBA83DE : Colors.transparent,
                  
                  width: 2,
                ),
              ),
              
              child: Column(
                
                mainAxisAlignment: MainAxisAlignment.center,
                
                children: [
                  
                  Text(
                    
                    date.displayWeekdayString(),
                    
                    style: TextStyle(
                      
                      fontSize: 15,
                      
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(
                    
                    height: 6,
                  ),
                  
                  Text(
                    
                    date.displayDayString(),
                    
                    style: TextStyle(
                      
                      fontSize: 15,
                      
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isSelected)
            
            Positioned(
              
              bottom: 0,
              
              child: Container(
                
                width: 8,
                
                height: 8,
                
                decoration: BoxDecoration(
                  
                  color: AppColors.hexBA83DE,
                  
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
