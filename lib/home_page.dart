import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sevilla/crude_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CrudeService service = CrudeService();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('FireBase Sevilla'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => openAddDialog(context),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: service.getItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if(docs.isEmpty) {
            return const Center(child: Text("No Items Found", style: TextStyle(fontSize: 18)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var item = docs[index];
              final itemData = item.data() as Map<String, dynamic>;
              final isFavorite = itemData['favorite'] == true;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    item['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Quantity ${item['quantity']}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          item.reference.update({'favorite': !isFavorite});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => openEditDialog( context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete( context, item.id),
                      ),
                    ],
                  ),
                )
              );
            }
          );
        }
      )
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Are you sure you want to dlete this item? '),
        actions: [
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              service.deleteItem(id);
              Navigator.pop(context);
            }
          )
        ],
      )
    );
  }

  void openAddDialog(BuildContext context) {
    nameCtrl.clear();
    qtyCtrl.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Save"),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
                service.addItem(nameCtrl.text, int.parse(qtyCtrl.text));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void openEditDialog(BuildContext context, DocumentSnapshot item) {
    nameCtrl.text = item['name'];
    qtyCtrl.text = item['quantity'].toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Update'),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
                service.updateItems(item.id, nameCtrl.text, int.parse(qtyCtrl.text));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}