import 'package:flutter/material.dart';
import 'package:to_do_list/constants/app_colors.dart';


class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.maxLines,
    required this.initialValue,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  
  final String hintText;

  
  final ValueChanged<String> onChanged;

  
  final int maxLines;

  final String? initialValue;

  final bool obscureText;

  final TextInputType keyboardType;

  
  @override
  State<InputField> createState() => _InputFieldState();
}


class _InputFieldState extends State<InputField> {
  
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  
  @override
  Widget build(BuildContext context) {
    
    return TextFormField(
      
      controller: _controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      obscuringCharacter: '●',

      
      style: const TextStyle(
        
        color: Colors.white,

        
        fontSize: 16,
      ),

      
      maxLines: widget.maxLines,

      
      decoration: InputDecoration(
        
        hintText: widget.hintText,

        
        hintStyle: TextStyle(
          
          color: Colors.white.withOpacity(0.8),

          
          fontSize: 16,
        ),

        
        border: OutlineInputBorder(
          
          borderRadius: BorderRadius.circular(12.0),
        ),

        
        filled: true,

        
        fillColor: AppColors.hex181818,
      ),

      
      onChanged: widget.onChanged,
    );
  }
}
