import 'package:flutter/material.dart';
import 'package:to_do_list/common_widgets/primary_app_bar.dart';
import 'package:to_do_list/common_widgets/primary_button.dart';
import 'package:to_do_list/common_widgets/tertiary_button.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/auth_service.dart';
import 'package:to_do_list/data/models/task_model.dart';
import 'package:to_do_list/data/models/task_priority.dart';
import 'package:to_do_list/data/models/task_status.dart';
import 'package:to_do_list/extensions/time_of_day_extensions.dart';
import 'package:to_do_list/screens/new_task/models/new_task_screen_arguments.dart';
import 'package:to_do_list/screens/new_task/widgets/date_picker.dart';
import 'package:to_do_list/screens/new_task/widgets/input_field.dart';
import 'package:to_do_list/screens/new_task/widgets/priority_item.dart';
import 'package:to_do_list/screens/new_task/widgets/time_picker.dart';

import '../../common_widgets/confirmation_dialog.dart';
import '../../constants/app_colors.dart';
import '../../data/data_sources/remote/firebase/firestore_service.dart';
import '../../data/services/dialog_service.dart';


class NewTaskScreen extends StatefulWidget {
  static const routeName = '/new-task';

  
  const NewTaskScreen({
    required this.arguments,
    super.key,
  });

  final NewTaskScreenArguments arguments;

  
  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}


class _NewTaskScreenState extends State<NewTaskScreen> {
  
  TaskPriority? selectedTaskPriority;

  
  late DateTime selectedDate;

  
  late TimeOfDay startTime;

  
  late TimeOfDay endTime;

  
  String? name;

  
  String? description;

  
  bool _isEditing = false;

  final _firestoreService = FirestoreService();

  final _authService = AuthService();

  final _dialogService = DialogService();

  @override
  void initState() {
    super.initState();

    
    final taskModel = widget.arguments.taskModel;
    if (taskModel != null) {
      
      selectedDate = taskModel.date;
      startTime = taskModel.startTime;
      endTime = taskModel.endTime;
      name = taskModel.name;
      description = taskModel.description;
      selectedTaskPriority = taskModel.priority;
      _isEditing = true;
    } else {
      
      selectedDate = DateTime.now();
      startTime = TimeOfDay.now();
      endTime = startTime.replacing(hour: startTime.hour + 1);
    }
  }

  
  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () {
        
        FocusScope.of(context).unfocus();
      },

      
      child: Scaffold(
        
        backgroundColor: AppColors.hex020206,

        
        appBar: PrimaryAppBar(
          
          title: _isEditing ? 'Edit Task' : 'Create New Task',

          
          onBack: () {
            
            Navigator.of(context).pop();
          },
        ),

        
        body: SingleChildScrollView(
          
          child: Padding(
            
            padding: const EdgeInsets.symmetric(horizontal: 6),

            
            child: Column(
              
              crossAxisAlignment: CrossAxisAlignment.start,

              
              children: [
                DatePicker(
                  date: selectedDate,
                  selectedDate: selectedDate,
                  onDateChanged: (date) {
                    
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      const SizedBox(
                        
                        height: 24,
                      ),

                      
                      const Text(
                        
                        "Schedule",

                        
                        style: TextStyle(
                          
                          color: Colors.white,

                          
                          fontSize: 22,
                        ),
                      ),

                      
                      const SizedBox(
                        
                        height: 16,
                      ),

                      
                      InputField(
                        initialValue: name,
                        hintText: "Name",
                        maxLines: 1,
                        onChanged: (value) {
                          
                          setState(() {
                            name = value;
                          });
                        },
                      ),

                      
                      const SizedBox(
                        
                        height: 16,
                      ),

                      
                      InputField(
                        hintText: "Description",
                        initialValue: description,
                        maxLines: 4,
                        onChanged: (value) {
                          
                          setState(() {
                            description = value;
                          });
                        },
                      ),

                      
                      const SizedBox(
                        
                        height: 16,
                      ),

                      
                      Row(
                        
                        children: [
                          
                          Expanded(
                            
                            child: TimePicker(
                              
                              title: 'Start Time',

                              
                              onTimeChanged: (time) {
                                
                                setState(() {
                                  startTime = time;
                                });
                              },

                              
                              time: startTime,
                            ),
                          ),

                          
                          const SizedBox(
                            
                            width: 11,
                          ),

                          
                          Expanded(
                            
                            child: TimePicker(
                              
                              time: endTime,

                              
                              title: 'End Time',

                              
                              onTimeChanged: (time) {
                                
                                setState(() {
                                  endTime = time;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      
                      const SizedBox(
                        
                        height: 16,
                      ),

                      
                      PriorityItem(
                        
                        selectedTaskPriority: selectedTaskPriority,

                        
                        taskPriorities: TaskPriority.values,

                        
                        onTaskPriorityChanged: (taskPriority) {
                          
                          setState(() {
                            selectedTaskPriority = taskPriority;
                          });
                        },
                      ),

                      
                      const SizedBox(
                        
                        height: 16,
                      ),

                      if (_isEditing)
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                
                                title: 'Edit Task',

                                
                                onTap: () async {
                                  await _editTask();
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: TertiaryButton(
                                title: 'Delete Task',
                                onTap: () async {
                                  await _deleteTask();
                                },
                              ),
                            )
                          ],
                        ),

                      if (!_isEditing)

                        
                        PrimaryButton(
                          
                          title: 'Create Task',

                          
                          onTap: () async {
                            await _addTask();
                          },
                        ),

                      
                      const SizedBox(
                        
                        height: 16,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addTask() async {
    final error = await _validateTask();
    if (error != null) {
      if (!mounted) {
        return;
      }
      await _dialogService.showErrorDialog(context: context, error: error);
      return;
    }
    final newTaskModel = TaskModel(
      id: null,
      name: name ?? '',
      description: description ?? '',
      startTime: startTime,
      endTime: endTime,
      date: selectedDate,
      priority: selectedTaskPriority ?? TaskPriority.medium,
      status: TaskStatus.incomplete,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
    await _firestoreService.addTask(
      userId: _authService.currentUser!.uid,
      taskModel: newTaskModel.toFbTaskModel(),
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _editTask() async {
    final error = await _validateTask();
    if (error != null) {
      if (!mounted) {
        return;
      }
      await _dialogService.showErrorDialog(context: context, error: error);
      return;
    }
    final editTaskModel = TaskModel(
      id: widget.arguments.taskModel!.id,
      name: name ?? '',
      description: description ?? '',
      startTime: startTime,
      endTime: endTime,
      date: selectedDate,
      priority: selectedTaskPriority ?? TaskPriority.medium,
      status: TaskStatus.incomplete,
      createdAt: widget.arguments.taskModel!.createdAt,
      updatedAt: DateTime.now(),
    );
    await _firestoreService.updateTask(
      userId: _authService.currentUser!.uid,
      taskModel: editTaskModel.toFbTaskModel(),
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<bool?> _showDeleteTaskConfirmationDialog({
    required BuildContext context,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Delete Task',
          content: 'Are you sure you want to delete this task?',
          confirmButtonTitle: 'Delete',
          cancelButtonTitle: 'Cancel',
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
          onCancel: () {
            Navigator.of(context).pop(false);
          },
        );
      },
    );
  }

  Future<void> _deleteTask() async {
    final isDeleted = await _showDeleteTaskConfirmationDialog(
      context: context,
    );
    if (isDeleted == null || !isDeleted) {
      return;
    }
    await _firestoreService.deleteTask(
      userId: _authService.currentUser!.uid,
      taskId: widget.arguments.taskModel!.id!.toString(),
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<String?> _validateTask() async {
    if (name == null || name!.isEmpty) {
      return "Name cannot be empty";
    }
    if (description == null || description!.isEmpty) {
      return "Description cannot be empty";
    }

    if (startTime
            .toDateTime(DateTime.now())
            .isAfter(endTime.toDateTime(DateTime.now())) ||
        startTime == endTime) {
      return "Start time must be before end time";
    }

    if (selectedTaskPriority == null) {
      return "Priority cannot be empty";
    }

    return null;
  }
}
