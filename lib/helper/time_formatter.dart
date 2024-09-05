/*

E.g
if the input timestamp represents : July 24 , 2024, 13:00

the function will return the string : "2024-07-23 14:30"

 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimeStamp(Timestamp timestamp){
  DateTime dateTime = timestamp.toDate();
  return DateFormat('yyyy-MM-dd').format(dateTime);
}