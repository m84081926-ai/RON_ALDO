import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization note: $e");
  }
  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.tealAccent,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _login() {
    if (_nameController.text.trim().isEmpty) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatListScreen(username: _nameController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt, size: 80, color: Colors.tealAccent),
              const SizedBox(height: 16),
              const Text(
                'A U R A',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name...',
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _login,
                child: const Text('Start Messaging', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  final String username;
  const ChatListScreen({Key? key, required: username}) : this.username = username, super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aura Chats'),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeveloperScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.tealAccent,
              child: Icon(Icons.person, color: Colors.black),
            ),
            title: const Text('Aura Global Channel', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Welcome to Aura secure messaging...'),
            trailing: const Text('12:00 PM', style: TextStyle(fontSize: 12, color: Colors.grey)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(chatName: 'Aura Global Channel', username: username),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  final String chatName;
  final String username;
  const ChatRoomScreen({Key? key, required this.chatName, required this.username}) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();

  void _sendMessage({File? mediaFile, bool isVideo = false}) {
    if (_msgController.text.trim().isEmpty && mediaFile == null) return;
    setState(() {
      _messages.add({
        'sender': widget.username,
        'text': _msgController.text.trim(),
        'file': mediaFile,
        'isVideo': isVideo,
        'time': TimeOfDay.now().format(context),
      });
      _msgController.clear();
    });
  }

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? pickedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _sendMessage(mediaFile: File(pickedFile.path), isVideo: isVideo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isMe = msg['sender'] == widget.username;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.teal.shade800 : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg['sender'], style: const TextStyle(fontSize: 10, color: Colors.tealAccent)),
                        const SizedBox(height: 4),
                        if (msg['file'] != null)
                          Container(
                            height: 150,
                            width: 150,
                            margin: const EdgeInsets.only(bottom: 6),
                            color: Colors.black26,
                            child: msg['isVideo']
                                ? const Center(child: Icon(Icons.play_circle_filled, size: 50, color: Colors.white))
                                : Image.file(msg['file'], fit: BoxFit.cover),
                          ),
                        if (msg['text'].toString().isNotEmpty)
                          Text(msg['text'], style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.tealAccent),
                  onPressed: () => _pickMedia(false),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Colors.tealAccent),
                  onPressed: () => _pickMedia(true),
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.tealAccent),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Dashboard'),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.coronavirus, size: 60, color: Colors.amber), // Crown representation symbol
            const SizedBox(height: 12),
            const Text(
              '👑 M O H A M E D 👑',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            const Text('Lead Developer & Architect', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aura System Status: Optimal & Secure!')),
                );
              },
              child: const Text('Check System Status'),
            ),
          ],
        ),
      ),
    );
  }
}
