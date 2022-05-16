import 'package:firebase_database/firebase_database.dart';

import 'enums.dart';

class Pair {
  String key;
  String value;

  Pair(this.key, this.value);
}

extension ValueFromPair on Map<FirebaseField, Pair> {
  String getValue(FirebaseField field) {
    return this[field]?.value ?? "";
  }

  bool isAllRequiredFieldsExists() {
    var isAllFieldsExists = true;
    for (var key in keys) {
      if(this[key]?.value.isEmpty ?? true) {
        isAllFieldsExists = false;
        break;
      } else {
        // print("AAA $key = ${this[key]?.value}");
      }
    }
    return isAllFieldsExists;
  }

}

extension MapFirebaseData on FirebaseDatabase {
  Future<Map<FirebaseField, Pair>> mapProvidedData(Map<FirebaseField, Pair> firebaseFields) async {

    await ref().once().then((data) {
      if (data.snapshot.value == null) {
        throw StateError("Error loading JSON");
      }
      var snapshot = data.snapshot.value as Map;
      for (var key in firebaseFields.keys) {
        if (snapshot.containsKey(firebaseFields[key]?.key)) {
          firebaseFields[key]?.value = snapshot[firebaseFields[key]?.key];
        }
      }
    });

    return firebaseFields;
  }
}