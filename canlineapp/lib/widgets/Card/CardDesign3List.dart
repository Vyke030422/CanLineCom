import 'package:flutter/material.dart';

class CardDesign3List extends StatelessWidget {
  const CardDesign3List({super.key, required this.title, required this.ImgURL});
  final String title;
  final String ImgURL;

  static const double _borderRadius = 15.0;
  static const double _padding = 10.0;

  @override
  Widget build(BuildContext context) {
    return _buildCard();
  }

  // Method to build each card
  Widget _buildCard() {
    return Padding(
      padding: const EdgeInsets.all(_padding), // Space around each card
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        elevation: 4.0,
        child: Row(
          children: [
            _buildImage(ImgURL), // Image on the left side
            Expanded(child: _buildCardDetails(title)), // Text on the right side
          ],
        ),
      ),
    );
  }

  // Method to build the image widget
  Widget _buildImage(String imgURL) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          bottomLeft: Radius.circular(_borderRadius),
        ),
        child: Image.network(
          imgURL, // Image URL
          fit: BoxFit.cover,
          height: 145.0,
          width: 130.0, // Fixed width for the image
        ));
  }

  // Method to build the entire card details
  Widget _buildCardDetails(String title) {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Align text to the left
        children: [
          _buildExpertOpinionRow(),
          const SizedBox(height: 8.0), // Spacing between elements
          _buildTitle(title),
          const SizedBox(height: 8.0),
          _buildDate(),
        ],
      ),
    );
  }

  // Method to build the expert opinion row with text and icon
  Widget _buildExpertOpinionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      // Aligns the row items at the start
      children: [
        _buildExpertOpinionText(),
        _buildFavoriteIcon(), // Call the new widget for the icon
      ],
    );
  }

  // Widget for the expert opinion text
  Widget _buildExpertOpinionText() {
    return const Text(
      'Expert Opinion',
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  // New widget for the favorite icon
  Widget _buildFavoriteIcon() {
    return IconButton(
      icon: const Icon(Icons.favorite_border),
      onPressed: () {
        // Add functionality if needed
      },
    );
  }

  // Method to build the title
  Widget _buildTitle(String title) {
    return Text(
      title, // Title
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Method to build the date
  Widget _buildDate() {
    return const Text(
      'September 17, 2024', // Date
      style: TextStyle(
        fontSize: 12.0,
        color: Colors.grey,
      ),
    );
  }
}
