import 'dart:async';
import 'package:flutter/material.dart';

formatTimer(_start){
    int hours =  (_start / 3600).truncate();
    int seconds = (_start % 3600).truncate();
    int minutes = (_start / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }
    else if(hours != 0){
      return "$hoursStr:$minutesStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }