import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/websocket_service.dart';

class ChatScreen extends StatefulWidget {
  final User loggedUser;
  const ChatScreen({super.key, required this.loggedUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  final TextEditingController _controller = TextEditingController();
  List<MessageResult> messages = [];
  File? _selectedImage;
  final ScrollController _scrollController = ScrollController();
  bool _isConnected = false;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _debugProfilePictures() {
    print('DEBUGGING PROFILE PICTURES:');
    print('Logged user ID: ${widget.loggedUser.id}');
    print('Logged user name: ${widget.loggedUser.name}');
    print('Logged user profile picture: ${widget.loggedUser.profilePicture}');
    
    if (widget.loggedUser.profilePicture != null) {
      print('Profile picture URL: ${ApiService.imageProfileLink(widget.loggedUser.profilePicture!)}');
    } else {
      print('No profile picture available for logged user');
    }
    
    // Check if there are any messages to debug
    if (messages.isNotEmpty) {
      final sampleMsg = messages.first;
      print('Sample message sender ID: ${sampleMsg.user.id}');
      print('Sample message sender profile picture: ${sampleMsg.user.profilePicture}');
      print('Is from logged user: ${sampleMsg.user.id == widget.loggedUser.id}');
      print('Sender profile picture URL: ${ApiService.imageProfileLink(sampleMsg.user.profilePicture)}');
    }
  }

  Future<void> _initializeChat() async {
    try {
      // Connection au WebSocket
      _webSocketService.connect();
      setState(() {
        _isConnected = true;
      });

      // Récupération des données initiales
      _webSocketService.getInitData();

      // Écoute des messages
      _webSocketService.listenMessages((type, message) {
        setState(() {
          if (type == "m") {
            messages.add(message);
          } else if (type == "d") {
            messages.removeWhere((element) => element.id == message.id);
          }
          _isLoading = false;
        });
        _scrollToBottom();
        
        // Debug profile pictures after receiving messages
        _debugProfilePictures();
      });
    } catch (e) {
      print('Erreur lors de l\'initialisation du chat: $e');
      setState(() {
        _errorMessage = 'Erreur de connexion au chat: $e';
        _isConnected = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_isConnected) {
      _webSocketService.disconnect();
    }
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && _isConnected) {
      try {
        _webSocketService.sendMessage(
          Message(
            message: _controller.text,
            senderId: widget.loggedUser.id,
            date: DateTime.now(),
          ),
        );
        _controller.clear();
        _scrollToBottom();
      } catch (e) {
        print('Erreur lors de l\'envoi du message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi du message: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime date) {
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _reconnect() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    _initializeChat();
  }

  Widget _buildUserAvatar(String? name, String? email, String? profilePicture) {
    // Helper function to ensure consistent avatar display
    bool hasProfilePic = profilePicture != null && profilePicture.isNotEmpty;
    
    // Log the avatar details for debugging
    print('Building avatar for: $name');
    print('Profile picture: $profilePicture');
    print('Has profile picture: $hasProfilePic');
    
    if (hasProfilePic) {
      print('Profile picture URL: ${ApiService.imageProfileLink(profilePicture)}');
    }
    
    return CircleAvatar(
      radius: 20,
      backgroundImage: hasProfilePic
          ? NetworkImage(
              ApiService.imageProfileLink(profilePicture),
              // Add error handling for network images
            )
          : null,
      backgroundColor: Colors.grey[300],
      onBackgroundImageError: hasProfilePic 
          ? (exception, stackTrace) {
              print('Error loading profile image: $exception');
              print('Using fallback icon instead');
            } 
          : null,
      child: !hasProfilePic
          ? Icon(Icons.person, color: Colors.grey[700])
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Chat With Users'),
            if (!_isConnected)
              Container(
                margin: EdgeInsets.only(left: 10),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        automaticallyImplyLeading: false, // Disable default back button
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Simply pop back to previous screen to avoid null checks in MainScreen
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (!_isConnected)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _reconnect,
              tooltip: 'Reconnect',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 60),
                        SizedBox(height: 20),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _reconnect,
                          child: Text('Reconnect'),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('asset/images/test.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.7, // Réduire l'opacité pour une meilleure lisibilité
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: messages.isEmpty
                            ? Center(
                                child: Text(
                                  'Aucun message. Commencez la conversation !',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: messages.length,
                                padding: EdgeInsets.all(8.0),
                                itemBuilder: (context, index) {
                                  final msg = messages[index];
                                  // Déterminer si le message est envoyé par l'utilisateur actuel
                                  bool isMe = msg.user.id == widget.loggedUser.id;
                                  
                                  // Log pour déboguer
                                  print('Message: ${msg.message}');
                                  print('Message sender ID: ${msg.user.id}');
                                  print('Logged user ID: ${widget.loggedUser.id}');
                                  print('Is me: $isMe');

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: isMe
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Avatar de l'expéditeur si ce n'est pas l'utilisateur actuel
                                        if (!isMe)
                                          GestureDetector(
                                            onTap: () {
                                              showUserInfoBottomSheet(
                                                context,
                                                msg.user.name,
                                                msg.user.email,
                                                msg.user.profilePicture,
                                              );
                                            },
                                            child: _buildUserAvatar(
                                              msg.user.name,
                                              msg.user.email,
                                              msg.user.profilePicture,
                                            ),
                                          ),
                                        
                                        if (!isMe) SizedBox(width: 8),
                                        
                                        Column(
                                          crossAxisAlignment: isMe
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isMe ? "Vous" : msg.user.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Color.fromARGB(255, 92, 88, 88),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isMe) 
                                                  Text(
                                                    _formatTime(msg.date),
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                
                                                if (isMe) const SizedBox(width: 8),
                                                
                                                GestureDetector(
                                                  onLongPress: isMe
                                                      ? () {
                                                          showMenu(
                                                            context: context,
                                                            position: RelativeRect.fromLTRB(
                                                                300, 300, 60, 0),
                                                            items: [
                                                              PopupMenuItem(
                                                                padding: EdgeInsets.zero,
                                                                child: Container(
                                                                  color: Colors.transparent,
                                                                  width: MediaQuery.of(context)
                                                                          .size
                                                                          .width *
                                                                      0.50,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment.center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons.delete,
                                                                        color: Colors.red,
                                                                        size: 20,
                                                                      ),
                                                                      SizedBox(width: 30),
                                                                      Text(
                                                                        'Delete Message',
                                                                        style: TextStyle(
                                                                          color: Colors.red,
                                                                          fontSize: 18,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  try {
                                                                    _webSocketService.deleteMessage(
                                                                        messages[index].id);
                                                                  } catch (e) {
                                                                    print('Erreur lors de la suppression: $e');
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                      SnackBar(content: Text('Erreur lors de la suppression: $e')),
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                      : null,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12.0),
                                                    constraints: BoxConstraints(
                                                      maxWidth: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.65,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(16),
                                                      color: isMe
                                                          ? Theme.of(context).primaryColor
                                                          : Colors.grey[200],
                                                    ),
                                                    child: Text(
                                                      msg.message,
                                                      textAlign: TextAlign.start,
                                                      softWrap: true,
                                                      overflow: TextOverflow.visible,
                                                      style: TextStyle(
                                                        color: isMe ? Colors.white : Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                
                                                if (!isMe) const SizedBox(width: 8),
                                                
                                                if (!isMe) 
                                                  Text(
                                                    _formatTime(msg.date),
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        
                                        if (isMe) SizedBox(width: 8),
                                        
                                        // Avatar de l'utilisateur actuel
                                        if (isMe)
                                          GestureDetector(
                                            onTap: () {
                                              showUserInfoBottomSheet(
                                                context,
                                                widget.loggedUser.name,
                                                widget.loggedUser.email,
                                                widget.loggedUser.profilePicture ?? '',
                                              );
                                            },
                                            child: _buildUserAvatar(
                                              widget.loggedUser.name,
                                              widget.loggedUser.email,
                                              widget.loggedUser.profilePicture,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        color: Colors.white.withOpacity(0.9), // Increased opacity for better visibility
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: TextField(
                                  controller: _controller,
                                  enabled: _isConnected,
                                  decoration: InputDecoration(
                                    hintText: _isConnected ? 'Type a message...' : 'Connection lost...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    hintStyle: TextStyle(color: _isConnected 
                                        ? Color.fromARGB(255, 78, 74, 74)
                                        : Colors.red),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              color: _isConnected ? Colors.blue : Colors.grey,
                              onPressed: _isConnected ? _sendMessage : null,
                              padding: const EdgeInsets.all(0),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }

  void showUserInfoBottomSheet(
      BuildContext context, String name, String email, String photoUrl) {
    print('Showing user info with photo URL: $photoUrl');
    String imageUrl = ApiService.imageProfileLink(photoUrl);
    print('Constructed image URL: $imageUrl');
    
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    backgroundColor: Colors.grey[300],
                    onBackgroundImageError: photoUrl.isNotEmpty
                        ? (exception, stackTrace) {
                            print('Error loading profile image in bottom sheet: $exception');
                          }
                        : null,
                    child: photoUrl.isEmpty
                        ? Icon(Icons.person, size: 40, color: Colors.grey[700])
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Name:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Email:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              Text(email,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}