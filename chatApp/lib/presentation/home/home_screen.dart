import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/services/service_locator.dart';
import '../../logic/cubits/auth/auth_cubit.dart';
import '../chat/chat_message_screen.dart';
import '../router/app_router.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/chat_list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;
  late final ChatRepository _chatRepository;
  late final String _currentUserId;

  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    _chatRepository = getIt<ChatRepository>();
    _currentUserId = getIt<AuthRepository>().currentUser?.uid ?? "";

    super.initState();
  }

  Future<void> _showContactsList(BuildContext context) async {
    // Request permission first. If denied, show an explanatory dialog
    // with steps to enable contacts permission in device settings.
    final granted = await _contactRepository.requestContactsPermission();
    if (!granted) {
      // Permission denied — show dialog to guide the user rather than silently failing.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Contacts permission required'),
          content: const Text(
            'This app needs access to your contacts to find other registered users.\n\n'
            'Please enable Contacts permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Note: opening the OS settings programmatically requires an
                // additional package (permission_handler) or platform code.
                // We avoid adding dependencies here; instruct the user instead.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Open app settings and enable Contacts permission.'),
                ));
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      return;
    }

    // Permission was granted — proceed to show the contacts bottom sheet.
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Contacts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _contactRepository.getRegisteredContacts(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final contacts = snapshot.data!;
                        if (contacts.isEmpty) {
                          return const Center(child: Text("No contacts found"));
                        }
                        return ListView.builder(
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              final contact = contacts[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  child: Text(contact["name"][0].toUpperCase()),
                                ),
                                title: Text(contact["name"]),
                                onTap: () {
                                  getIt<AppRouter>().push(
                                    ChatMessageScreen(
                                      receiverId: contact['id'],
                                      receiverName: contact['name'],
                                    ),
                                  );
                                },
                              );
                            });
                      }),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          InkWell(
            onTap: () async {
              await getIt<AuthCubit>().signOut();
              getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
            },
            child: const Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: StreamBuilder(
          stream: _chatRepository.getChatRooms(_currentUserId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                child: Text("error:${snapshot.error}"),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final chats = snapshot.data!;
            if (chats.isEmpty) {
              return const Center(
                child: Text("No recent chats"),
              );
            }
            return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ChatListTile(
                    chat: chat,
                    currentUserId: _currentUserId,
                    onTap: () {
                      final otherUserId = chat.participants
                          .firstWhere((id) => id != _currentUserId);
                      print("home screen current user id $_currentUserId");
                      final outherUserName =
                          chat.participantsName?[otherUserId] ?? "Unknown";
                      getIt<AppRouter>().push(ChatMessageScreen(
                          receiverId: otherUserId,
                          receiverName: outherUserName));
                    },
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactsList(context),
        child: const Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
    );
  }
}
