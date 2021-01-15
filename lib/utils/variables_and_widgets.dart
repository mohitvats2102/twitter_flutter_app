import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

TextStyle myStyle(double size, [FontWeight fw, Color color]) {
  return GoogleFonts.pacifico(
    fontSize: size,
    fontWeight: fw,
    color: color,
  );
}

class EntryButton extends StatelessWidget {
  final String title;
  final void Function() onTap;

  EntryButton({this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      textColor: Colors.lightBlue,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class UserInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool hideEntry;
  final void Function(String value) onSaved;
  final String Function(String value) validate;

  UserInputField(
      {this.hintText,
      this.icon,
      this.keyboardType,
      this.hideEntry,
      this.onSaved,
      this.validate});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        onSaved: onSaved,
        validator: validate,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Color(0xff00ADEF)),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: hideEntry);
  }
}

class ChangeEntryButton extends StatelessWidget {
  final String title;
  final void Function() onTap;

  ChangeEntryButton({this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
      textColor: Colors.white,
    );
  }
}
