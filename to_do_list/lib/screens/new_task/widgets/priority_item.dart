import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/secondary_button.dart';
import 'package:to_do_list/data/models/task_priority.dart';


class PriorityItem extends StatelessWidget {
  
  const PriorityItem({
    required this.selectedTaskPriority,
    required this.taskPriorities,
    required this.onTaskPriorityChanged,
    super.key,
  });

  
  final TaskPriority? selectedTaskPriority;

  
  final List<TaskPriority> taskPriorities;

  
  final ValueChanged<TaskPriority> onTaskPriorityChanged;

  
  @override
  Widget build(BuildContext context) {
    
    List<Widget> children = [];

    
    for (int i = 0; i < taskPriorities.length; i++) {
      
      children.add(
        
        Expanded(
          
          child: SecondaryButton(
            
            title: taskPriorities[i].title,

            
            isSelected: selectedTaskPriority == taskPriorities[i],

            
            color: taskPriorities[i].color,

            
            onTap: () {
              
              onTaskPriorityChanged.call(taskPriorities[i]);
            },
          ),
        ),
      );

      
      if (i < taskPriorities.length - 1) {
        
        children.add(const SizedBox(width: 10));
      }
    }

    
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,

      
      children: [
        
        Text(
          
          'Priority',

          
          style: TextStyle(
            
            color: Colors.white.withOpacity(0.8),

            
            fontSize: 20,
          ),
        ),

        
        const SizedBox(
          
          height: 8,
        ),

        
        Row(
          
          children: children,
        ),

        
        const SizedBox(
          
          height: 8,
        ),
      ],
    );
  }
}
