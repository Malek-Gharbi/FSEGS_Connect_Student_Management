import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroPageData> _pages = [
    IntroPageData(
      image: 'assets/images/descppage.png',
      title: 'Tout savoir sur\nta scolarité !',
      description: 'Suis tes notes, absences et\ndocuments facilement.',
      color: const Color(0xFFE4EDCB),
    ),
    IntroPageData(
      image: 'assets/images/descpage2.png',
      title: 'Ton emploi du\ntemps, toujours\nà jour!',
      description: 'Planifie ta semaine et garde\nle contrôle.',
      color: const Color(0xFFA8DDE8),
    ),
    IntroPageData(
      image: 'assets/images/descpage3_1.png',
      title: 'Reste connecté à la\nFSEGS Connect !',
      description: 'Reçois toutes les infos et annonces\nimportantes sans stress.',
      color: const Color(0xFFF4C2C2),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onSkipOrNext() async {
    if (_currentPage == _pages.length - 1) {
      // Dernière page, aller à l'authentification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_launch', false);
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pages[_currentPage].color,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _onSkipOrNext,
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Terminer' : 'Passer',
                    style: const TextStyle(
                      color: Color(0xFF1D9BB1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Indicators and Next button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF1D9BB1)
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onSkipOrNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9BB1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Commencer' : 'Suivant',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(IntroPageData pageData) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Image
          Expanded(
            child: Container(
              width: 300,
              height: 300,
              child:Image.asset(
              pageData.image,
              fit: BoxFit.contain,
            ),),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            pageData.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10537F),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          // Description
          Text(
            pageData.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF10537F),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPageData {
  final String image;
  final String title;
  final String description;
  final Color color;

  IntroPageData({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });
}
