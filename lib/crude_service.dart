import 'package:cloud_firestore/cloud_firestore.dart';

class CrudeService {  
  final CollectionReference items =
  FirebaseFirestore.instance.collection('items');

//create

  Future <void> addItem(String name, int quantity) {
    return items.add({
        'name': name,
        'quantity': quantity,
        'createdAt': Timestamp.now(),
    });
  }

//read
  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots(); 
  }

//update
  Future <void> updateItems(String id, String name, int quantity) {
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

//delete
  Future <void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}