import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/AnalysisScreen.dart';
import 'package:flutter_application_1/screens/news_screen.dart';
import 'package:flutter_application_1/screens/health_assistant_screen.dart'; // Ajoutez cet import
import 'package:provider/provider.dart';
import 'package:flutter_application_1/viewmodels/news_viewmodel.dart';

class AcceuilPage extends StatelessWidget {
  const AcceuilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher des articles ...',
                          fillColor: Colors.grey[200],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Utilisation de MaterialPageRoute au lieu de la navigation nommée
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HealthAssistantScreen(),
                          ),
                        );
                      } catch (e) {
                        print('Erreur de navigation: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.health_and_safety, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Assistant Santé',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnalysisScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: const Text('Analyse fausses informations',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Wrap NewsScreen with ChangeNotifierProvider to fix the provider issue
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => NewsViewModel(),
                            child: NewsScreen(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'File d actualité médicale',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Color.fromARGB(255, 89, 81, 81)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Les fausses informations peuvent être mortelles. Ne partagez pas avant de vérifier.',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                const Text('Historique',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          // Replace Image.asset with a placeholder Container
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          const Text('Rapport médical'),
                          const Text('Il y a 2 jours',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          // Replace Image.asset with a placeholder Container
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          const Text('Rapport médical'),
                          const Text('Il y a 4 jours',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Utilisation de MaterialPageRoute au lieu de la navigation nommée
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HealthAssistantScreen(),
              ),
            );
          } catch (e) {
            print('Erreur de navigation FAB: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur FAB: $e')),
            );
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.medical_services, color: Colors.white),
        tooltip: 'Assistant Santé',
      ),
    );
  }
}