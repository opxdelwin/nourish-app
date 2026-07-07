import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  //delete this block
  Widget _buildDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final sz = MediaQuery.sizeOf(c);
    final w = sz.width;

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 65,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  return Stack(
                    children: [
                      // Fries
                      Positioned(
                        left: w * .10,
                        top: h * .16,
                        child: FoodBubble(
                          img: 'assets/images/fries.png',
                          s: w * .24,
                        ),
                      ),
                      // Taco
                      Positioned(
                        right: w * .16,
                        top: h * .06,
                        child: FoodBubble(
                          img: 'assets/images/taco.png',
                          s: w * .18,
                        ),
                      ),
                      // Rice
                      Positioned(
                        right: w * .05,
                        top: h * .24,
                        child: FoodBubble(
                          img: 'assets/images/rice.png',
                          s: w * .14,
                        ),
                      ),
                      // Pizza
                      Positioned(
                        left: w * .04,
                        top: h * .44,
                        child: FoodBubble(
                          img: 'assets/images/pizza.png',
                          s: w * .14,
                        ),
                      ),
                      // Cake
                      Positioned(
                        left: w * .37,
                        top: h * .46,
                        child: FoodBubble(
                          img: 'assets/images/cake.png',
                          s: w * .22,
                        ),
                      ),
                      // Apple
                      Positioned(
                        right: w * .10,
                        top: h * .40,
                        child: FoodBubble(
                          img: 'assets/images/apple.png',
                          s: w * .20,
                        ),
                      ),
                      // Burger
                      Positioned(
                        left: w * .04,
                        bottom: h * .06,
                        child: FoodBubble(
                          img: 'assets/images/burger.png',
                          s: w * .25,
                        ),
                      ),
                      // Pasta
                      Positioned(
                        right: w * .04,
                        bottom: h * .04,
                        child: FoodBubble(
                          img: 'assets/images/pasta.png',
                          s: w * .28,
                        ),
                      ),
                      // Chocolate
                      Positioned(
                        left: w * .45,
                        top: h * .30,
                        child: FoodBubble(
                          img: 'assets/images/chocolate.png',
                          s: w * .16,
                        ),
                      ),

                      // Decorative Dots
                      Positioned(
                        left: w * .28,
                        top: h * .08,
                        child: _buildDot(w * .04, Colors.grey.shade400),
                      ),
                      Positioned(
                        left: w * .32,
                        top: h * .12,
                        child: _buildDot(w * .03, Colors.grey.shade400),
                      ),
                      Positioned(
                        left: w * .40,
                        top: h * .10,
                        child: _buildDot(w * .02, Colors.grey.shade400),
                      ),
                      Positioned(
                        left: w * .56,
                        top: h * .24,
                        child: _buildDot(w * .025, Colors.grey.shade400),
                      ),
                      Positioned(
                        left: w * .60,
                        top: h * .26,
                        child: _buildDot(w * .035, Colors.grey.shade400),
                      ),
                      Positioned(
                        left: w * .28,
                        top: h * .32,
                        child: _buildDot(w * .025, const Color(0xff6C63FF)),
                      ),
                      Positioned(
                        left: w * .22,
                        top: h * .35,
                        child: _buildDot(w * .03, const Color(0xff6C63FF)),
                      ),
                      Positioned(
                        left: w * .28,
                        top: h * .36,
                        child: _buildDot(w * .04, Colors.grey.shade400),
                      ),
                      Positioned(
                        left: w * .41,
                        bottom: h * .18,
                        child: _buildDot(w * .03, Colors.grey.shade400),
                      ),
                      Positioned(
                        left: w * .47,
                        bottom: h * .15,
                        child: _buildDot(w * .04, Colors.grey.shade400),
                      ),
                      Positioned(
                        right: w * .28,
                        bottom: h * .24,
                        child: _buildDot(w * .04, const Color(0xff6C63FF)),
                      ),
                      Positioned(
                        right: w * .26,
                        bottom: h * .21,
                        child: _buildDot(w * .02, const Color(0xff6C63FF)),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              flex: 35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Explore, Scan and',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Eat ',
                          style: TextStyle(
                            color: Color(0xff6C63FF),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: 'Healthy!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Eat Healthy and tasty food with us.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 260,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1E1E24),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => c.go('/onboarding'),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
}
class FoodBubble extends StatelessWidget {
  final String img;
  final double s;

  const FoodBubble({
    super.key,
    required this.img,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(s * 0.2), // Adds padding inside the circle
          child: Image.asset(
            img,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Failsafe in case the assets aren't added to pubspec.yaml yet
              return Icon(Icons.fastfood, size: s * 0.4, color: Colors.grey);
            },
          ),
        ),
      ),
    );
  }
}