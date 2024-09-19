import 'package:flutter/material.dart';

class Carddesign2list extends StatelessWidget {
  const Carddesign2list({super.key});

  // Define constants for reuse
  static const double _borderRadius = 15.0;
  static const double _padding = 10.0;
  static const double _opacity = 0.2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260.0, // Fixed height for the carousel
      child: PageView.builder(
        controller: PageController(
            viewportFraction: 0.9), // Shows adjacent cards on screen edge
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Number of cards
        itemBuilder: (context, index) => _buildCard(),
      ),
    );
  }

  // Method to build the card widget
  Widget _buildCard() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 10.0), // Space between cards
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        elevation: 4.0, // Optional: Adds a shadow effect
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_borderRadius),
          child: Stack(
            children: [
              _buildImage(),
              _buildOverlay(),
              _buildPositionedText(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the image widget
  Widget _buildImage() {
    return Image.asset(
      'lib/assets/images/jpeg/spmc.jpg',
      fit: BoxFit.cover, // Ensures the image fits properly
      height: 300.0,
      width: double.infinity,
    );
  }

  // Method to build the semi-transparent overlay
  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(_opacity), // Overlay with 20% opacity
      ),
    );
  }

  // Method to build the positioned text widget
  Widget _buildPositionedText() {
    return Positioned(
      bottom: _padding, // Adjust text position
      left: _padding,
      right: _padding,
      child: _buildTextContainer(),
    );
  }

  // Method to build the text container
  Widget _buildTextContainer() {
    return Container(
      padding: const EdgeInsets.all(_padding), // Padding around text
      child: const Text(
        'Southern Philippines Medical Center',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.white, // White text for contrast
        ),
      ),
    );
  }
}
