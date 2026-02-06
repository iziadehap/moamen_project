import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddOrderScreen extends StatelessWidget {
  const AddOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Order')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location Coords (Lat,Lng)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate add
                  Get.back();
                  Get.snackbar('Success', 'Order added successfully!');
                },
                child: const Text('Save Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
