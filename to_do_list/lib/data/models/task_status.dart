import 'package:to_do_list/constants/app_icons.dart';


enum TaskStatus {
  
  incomplete,

  
  complete,
}


extension TaskStatusExtension on TaskStatus {
  
  String get icon {
    
    switch (this) {
      
      case TaskStatus.complete:
        return AppIcons.check;

      
      case TaskStatus.incomplete:
        return AppIcons.uncheck;
    }
  }
}
