import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/data/models/firebase/fb_task_model.dart';
import 'package:to_do_list/data/models/task_model.dart';
import 'package:to_do_list/data/models/task_status.dart';
import 'package:to_do_list/screens/all_tasks/all_tasks_screen.dart';
import 'package:to_do_list/screens/home/widgets/add_button.dart';
import 'package:to_do_list/screens/home/widgets/header_item.dart';
import 'package:to_do_list/screens/home/widgets/home_app_bar.dart';
import 'package:to_do_list/screens/home/widgets/progress_item.dart';
import 'package:to_do_list/screens/home/widgets/search_field.dart';
import 'package:to_do_list/screens/home/widgets/task_item.dart';
import '../../constants/app_colors.dart';
import '../../data/data_sources/remote/firebase/auth_service.dart';
import '../../data/data_sources/remote/firebase/firestore_service.dart';
import '../all_tasks/models/all_tasks_screen_arguments.dart';
import '../new_task/models/new_task_screen_arguments.dart';
import '../new_task/new_task_screen.dart';


class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  
  const HomeScreen({super.key});

  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  User? _user;

  final _authService = AuthService();

  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _initUser();

    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        log('User is currently signed out!');
      } else {
        final user = _authService.currentUser;
        if (!mounted) return;
        setState(() {
          _user = user;
        });
      }
    });
  }

  Future<void> _initUser() async {
    _user = _authService.currentUser;
  }

  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestoreService.getTasks(_user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final tasks = snapshot.data
            ?.map((fbTaskModel) => fbTaskModel.toTaskModel())
            .toList();
        if (tasks == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        
        final todayTasks = tasks.where((task) {
          
          return DateUtils.isSameDay(
            task.date,
            DateTime.now(),
          );
        }).toList();

        
        final tomorrowTasks = tasks.where((task) {
          
          return DateUtils.isSameDay(
            task.date,
            DateTime.now().add(
              const Duration(days: 1),
            ),
          );
        }).toList();

        
        final numberOfCompletedTodayTask = todayTasks.where((task) {
          
          return task.status == TaskStatus.complete;
        }).length;

        
        return GestureDetector(
          onTap: () {
            
            FocusScope.of(context).unfocus();
          },

          
          child: Scaffold(
            
            backgroundColor: AppColors.hex020206,

            
            appBar: HomeAppBar(
              
              onSearchChanged: (value) {
                
                log("Search text changed: $value");
              },
              user: _user!,
            ),

            
            body: SafeArea(
              child: SingleChildScrollView(
                
                child: Column(
                  
                  children: [
                    
                    Padding(
                      
                      padding: const EdgeInsets.symmetric(
                        
                        vertical: 12,

                        
                        horizontal: 20,
                      ),

                      
                      child: SearchField(
                        
                        hintText: "Search Task Here",

                        
                        onChanged: (value) {
                          
                          log("Search text changed: $value");
                        },
                      ),
                    ),

                    
                    HeaderItem(
                      title: 'Progress',
                      onSeeAllTap: () {
                        _navigateToAllTasksScreen();
                      },
                    ),

                    
                    ProgressItem(
                      
                      numberOfCompletedTask: numberOfCompletedTodayTask,

                      
                      numberOfTasks: todayTasks.length,
                    ),

                    
                    HeaderItem(
                      title: "Today's Task",
                      onSeeAllTap: () {
                        _navigateToAllTasksScreen();
                      },
                    ),

                    
                    _buildTaskListWidget(todayTasks),

                    
                    HeaderItem(
                      title: "Tomorrow's Task",
                      onSeeAllTap: () {
                        _navigateToAllTasksScreen();
                      },
                    ),

                    
                    _buildTaskListWidget(tomorrowTasks),

                    
                    const SizedBox(
                      
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),

            
            floatingActionButton: AddButton(
              
              onTap: () async {
                _navigateToNewTaskScreen();
              },
            ),

            
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        );
      },
    );
  }

  
  Future<void> _navigateToAllTasksScreen() async {
    
    
    await Navigator.of(context).pushNamed(
      
      AllTasksScreen.routeName,

      
      arguments: const AllTasksScreenArguments(),
    );
  }

  
  
  
  Future<void> _navigateToNewTaskScreen({TaskModel? taskModel}) async {
    
    
    final result = await Navigator.of(context).pushNamed(
      
      NewTaskScreen.routeName,

      
      arguments: NewTaskScreenArguments(
        taskModel: taskModel,
      ),
    ) as bool?;

    
    if (result != true) {
      return;
    }
  }

  Widget _buildTaskListWidget(List<TaskModel> taskModels) {
    if (taskModels.isEmpty) {
      return Container(
        width: double.infinity,

        
        margin: const EdgeInsets.symmetric(
          
          horizontal: 20,
        ),

        
        padding: const EdgeInsets.symmetric(
          
          horizontal: 20,

          
          vertical: 32,
        ),

        
        decoration: BoxDecoration(
          
          borderRadius: BorderRadius.circular(8),

          
          color: AppColors.hex181818,
        ),

        
        child: Text(
          'You have no task to complete.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView.builder(
        
        padding: EdgeInsets.zero,

        
        physics: const NeverScrollableScrollPhysics(),

        
        itemBuilder: (context, index) {
          final taskModel = taskModels[index];

          
          return TaskItem(
            
            taskModel: taskModel,

            
            onStatusChanged: (taskStatus) async {
              final fbTaskModel = taskModel
                  .copyWith(
                    status: taskStatus,
                  )
                  .toFbTaskModel();
              await _firestoreService.updateTask(
                userId: _user!.uid,
                taskModel: fbTaskModel,
              );
            },
            onTap: () {
              _navigateToNewTaskScreen(
                taskModel: taskModel,
              );
            },
          );
        },

        
        itemCount: taskModels.length,

        
        shrinkWrap: true,
      );
    }
  }
}
