import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:event_management_app/constants/colors.dart';
import 'package:event_management_app/containers/custom_headtext.dart';
import 'package:event_management_app/containers/custom_input_form.dart';
import 'package:event_management_app/database.dart';
import 'package:event_management_app/saved_data.dart';
import 'package:flutter/material.dart';

import '../auth.dart';
import '../pickers/picker_mobile.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final MobilePicker _picker = MobilePicker();
  Uint8List? _imageBytes;
  bool _isInPersonEvent = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _guestController = TextEditingController();
  final TextEditingController _sponsersController = TextEditingController();

  Storage storage = Storage(client);
  bool isUploading = false;
  String userId = "";

  @override
  void initState() {
    super.initState();
    userId = SavedData.getUserId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _dateTimeController.dispose();
    _guestController.dispose();
    _sponsersController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));

    if (pickedDate != null) {
      final TimeOfDay? pickedTime =
      await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute);
        setState(() {
          _dateTimeController.text = selectedDateTime.toString();
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final bytes = await _picker.pickImage();
    if (bytes != null) {
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return null;
    setState(() => isUploading = true);

    try {
      final inputFile = InputFile.fromBytes(
        bytes: _imageBytes!,
        filename: "event_image.jpg",
      );

      final response = await storage.createFile(
        bucketId: '68fc86bb00342c85a173',
        fileId: ID.unique(),
        file: inputFile,
        permissions: [
          Permission.read(Role.any()), // 👈 Public read access
          Permission.write(Role.user(SavedData.getUserId())), // owner can edit/delete
        ],
      );

      print("✅ File uploaded with ID: ${response.$id}");
      return response.$id;
    } catch (e) {
      print("❌ Error uploading image: $e");
      return null;
    } finally {
      setState(() => isUploading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const CustomHeadText(text: "Create Event"),
            const SizedBox(height: 25),

            // Event Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                    color: kLightGreen, borderRadius: BorderRadius.circular(8)),
                child: _imageBytes != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo_outlined, size: 42),
                    SizedBox(height: 8),
                    Text(
                      "Add Event Image",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            CustomInputForm(
                controller: _nameController,
                icon: Icons.event_outlined,
                label: "Event Name",
                hint: "Add Event Name"),
            const SizedBox(height: 8),
            CustomInputForm(
                maxLines: 4,
                controller: _descController,
                icon: Icons.description_outlined,
                label: "Description",
                hint: "Add Description"),
            const SizedBox(height: 8),
            CustomInputForm(
                controller: _locationController,
                icon: Icons.location_on_outlined,
                label: "Location",
                hint: "Enter Location of Event"),
            const SizedBox(height: 8),
            CustomInputForm(
              controller: _dateTimeController,
              icon: Icons.date_range_outlined,
              label: "Date & Time",
              hint: "Pick Date Time",
              readOnly: true,
              onTap: () => _selectDateTime(context),
            ),
            const SizedBox(height: 8),
            CustomInputForm(
                controller: _guestController,
                icon: Icons.people_outlined,
                label: "Guests",
                hint: "Enter list of guests"),
            const SizedBox(height: 8),
            CustomInputForm(
                controller: _sponsersController,
                icon: Icons.attach_money_outlined,
                label: "Sponsors",
                hint: "Enter Sponsors"),
            const SizedBox(height: 8),

            Row(
              children: [
                const Text("In Person Event", style: TextStyle(fontSize: 20)),
                const Spacer(),
                Switch(
                    activeColor: kLightGreen,
                    value: _isInPersonEvent,
                    onChanged: (val) => setState(() => _isInPersonEvent = val)),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: MaterialButton(
                color: kLightGreen,
                onPressed: () async {
                  if (_nameController.text.isEmpty ||
                      _descController.text.isEmpty ||
                      _locationController.text.isEmpty ||
                      _dateTimeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Event Name, Description, Location, Date & time are required.")));
                    return;
                  }

                  final uploadedImageId = await _uploadImage();

                  await createEvent(
                    _nameController.text,
                    _descController.text,
                    uploadedImageId ?? "",
                    _locationController.text,
                    _dateTimeController.text,
                    userId,
                    _isInPersonEvent,
                    _guestController.text,
                    _sponsersController.text,
                  );

                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Event Created!")));
                  Navigator.pop(context);
                },
                child: const Text(
                  "Create New Event",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
