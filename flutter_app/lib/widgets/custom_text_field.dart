import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final IconData? prefixIcon;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      readOnly: widget.readOnly,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      style: TextStyle(
        fontSize: 15,
        color: widget.readOnly
            ? Theme.of(context).colorScheme.outline
            : Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12, left: 12),
                child: Icon(widget.prefixIcon, size: 20),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Iconsax.eye_slash : Iconsax.eye,
                  size: 20,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}
