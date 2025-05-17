import 'dart:developer';

import 'package:app_face_auth/dbHelper/constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDataBase{
  static var db, userCollection;

  static connect() async{
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);
    userCollection = db.collection(USER_COLLECTION);
  }
}