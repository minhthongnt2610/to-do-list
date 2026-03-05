import 'package:flutter/material.dart';
import 'package:to_do_list/extensions/date_time_extensions.dart';
import 'package:to_do_list/screens/new_task/widgets/week_calendar.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_icons.dart';


class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    required this.date,
    required this.selectedDate,
    required this.onDateChanged,
  });

  
  final DateTime date;

  
  final DateTime selectedDate;

  
  final ValueChanged<DateTime> onDateChanged;

  
  @override
  State<DatePicker> createState() => _DatePickerState();
}


class _DatePickerState extends State<DatePicker> {
  
  DateTime _date = DateTime.now();

  
  List<DateTime> _dates = [];

  
  DateTime? _selectedDate;

  
  final _initialPage = 520;

  
  late PageController _pageController;

  
  late int _currentPage;

  
  @override
  void initState() {
    super.initState();

    
    _pageController = PageController(initialPage: _initialPage);

    
    _date = widget.date;
    _dates = [_date.previousWeek, _date, _date.nextWeek];
    _currentPage = _initialPage;
    _selectedDate = widget.selectedDate;
  }

  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        const SizedBox(
          
          height: 16,
        ),

        
        Row(
          
          children: [
            
            GestureDetector(
              
              behavior: HitTestBehavior.translucent,

              
              onTap: () {
                
                setState(() {
                  
                  _currentPage--;

                  
                  _pageController.animateToPage(
                    
                    _currentPage,

                    
                    duration: const Duration(milliseconds: 300),

                    
                    curve: Curves.easeInOut,
                  );
                });
              },

              
              child: SizedBox(
                
                height: 44,

                
                width: 44,

                
                child: Center(
                  
                  child: Image.asset(
                    
                    AppIcons.leftArrow,

                    
                    height: 17,
                  ),
                ),
              ),
            ),

            
            Expanded(
              
              child: Text(
                
                '${_date.startOfWeek.displayDateString()} - ${_date.endOfWeek.displayDateString()}',

                
                style: const TextStyle(
                  
                  fontSize: 20,

                  
                  color: AppColors.hexBA83DE,
                ),

                
                textAlign: TextAlign.center,
              ),
            ),

            
            GestureDetector(
              
              behavior: HitTestBehavior.translucent,

              
              onTap: () {
                
                setState(() {
                  
                  _currentPage++;

                  
                  _pageController.animateToPage(
                    
                    _currentPage,

                    
                    duration: const Duration(milliseconds: 300),

                    
                    curve: Curves.easeInOut,
                  );
                });
              },

              
              child: SizedBox(
                
                height: 44,

                
                width: 44,

                
                child: Center(
                  
                  child: Image.asset(
                    
                    AppIcons.rightArrow,

                    
                    height: 17,
                  ),
                ),
              ),
            )
          ],
        ),

        
        const SizedBox(
          
          height: 32,
        ),

        
        SizedBox(
          
          height: ((MediaQuery.of(context).size.width - 6 * 2) / 7) / (58 / 70),

          
          child: PageView.builder(
            
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              
              return WeekCalendar(
                
                dates: _dates[index % _dates.length].daysPerWeek,

                
                selectedDate: _selectedDate,

                
                onDateSelected: (date) {
                  
                  setState(() {
                    _selectedDate = date;
                    widget.onDateChanged.call(date);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  
  void _onPageChanged(int index) {
    
    final page = index % _dates.length;

    
    if (page == 0) {
      setState(() {
        
        _date = _dates[0];

        
        _dates[2] = _date.previousWeek;

        
        _dates[1] = _date.nextWeek;

        
        _currentPage = index;
      });

      
    } else if (page == 2) {
      setState(() {
        
        _date = _dates[2];
        
        _dates[0] = _date.nextWeek;
        
        _dates[1] = _date.previousWeek;
        
        _currentPage = index;
      });
      
    } else if (page == 1) {
      setState(() {
        
        _date = _dates[1];
        
        _dates[0] = _date.previousWeek;
        
        _dates[2] = _date.nextWeek;
        
        _currentPage = index;
      });
    }
  }
}
