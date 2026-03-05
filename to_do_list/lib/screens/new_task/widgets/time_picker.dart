import 'package:flutter/material.dart';
import 'package:to_do_list/extensions/time_of_day_extensions.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_icons.dart';


class TimePicker extends StatefulWidget {
  const TimePicker({
    super.key,
    required this.title,
    required this.time,
    required this.onTimeChanged,
  });

  
  final String title;

  
  final TimeOfDay time;

  
  final ValueChanged<TimeOfDay> onTimeChanged;

  
  @override
  State<TimePicker> createState() => _TimePickerState();
}


class _TimePickerState extends State<TimePicker> {
  
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.time.formatTimeOfDay();
  }

  
  @override
  Widget build(BuildContext context) {
    
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,

      
      children: [
        
        Text(
          
          widget.title,

          
          style: TextStyle(
            
            color: Colors.white.withOpacity(0.8),

            
            fontSize: 20,
          ),
        ),

        
        const SizedBox(
          
          height: 8,
        ),

        
        TextFormField(
          controller: controller,

          
          style: const TextStyle(
            
            color: Colors.white,

            
            fontSize: 16,
          ),

          
          readOnly: true,

          
          onTap: () async {
            
            final selectedTime = await showTimePicker(
              
              initialTime: widget.time,

              
              context: context,

              
              builder: (BuildContext context, Widget? child) {
                
                return Theme(
                  
                  data: Theme.of(context).copyWith(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),

                  
                  child: MediaQuery(
                    
                    data: MediaQuery.of(context).copyWith(
                      
                      alwaysUse24HourFormat: false,
                    ),

                    
                    child: child!,
                  ),
                );
              },
            );

            
            if (selectedTime != null) {
              
              widget.onTimeChanged.call(selectedTime);

              
              controller.text = selectedTime.formatTimeOfDay();
            }
          },

          
          decoration: InputDecoration(
            
            hintStyle: TextStyle(
              
              color: Colors.white.withOpacity(0.8),

              
              fontSize: 16,
            ),

            
            prefixIcon: SizedBox(
              
              width: 44,

              
              child: Center(
                
                child: Image.asset(
                  
                  AppIcons.clock,

                  
                  width: 24,

                  
                  height: 24,
                ),
              ),
            ),

            
            border: OutlineInputBorder(
              
              borderRadius: BorderRadius.circular(12.0),
            ),

            
            filled: true,

            
            fillColor: AppColors.hex181818,
          ),
        )
      ],
    );
  }
}
