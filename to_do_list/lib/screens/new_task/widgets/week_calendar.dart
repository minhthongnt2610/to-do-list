import 'package:flutter/material.dart';

import 'calendar_item.dart';


class WeekCalendar extends StatelessWidget {
  const WeekCalendar({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  
  final DateTime? selectedDate;

  
  final List<DateTime> dates;

  
  final ValueChanged<DateTime> onDateSelected;

  
  @override
  Widget build(BuildContext context) {
    
    return GridView.builder(
      
      padding: EdgeInsets.zero,

      
      shrinkWrap: true,

      
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        
        crossAxisCount: 7,

        
        mainAxisSpacing: 0,

        
        crossAxisSpacing: 0,

        
        childAspectRatio: 58 / 70,
      ),

      
      itemCount: dates.length,

      
      physics: const NeverScrollableScrollPhysics(),

      
      itemBuilder: (context, index) {
        
        return CalendarItem(
          
          date: dates[index],

          
          isSelected: DateUtils.isSameDay(dates[index], selectedDate),

          
          onSelected: () {
            
            onDateSelected.call(dates[index]);
          },
        );
      },
    );
  }
}
