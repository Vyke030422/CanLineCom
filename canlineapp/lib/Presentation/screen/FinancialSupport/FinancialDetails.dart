import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Update Constants structure
class UIConstants {
  static const Color primaryColor = Color(0xFF5B50A0);
  static const Color secondaryColor = Color(0xFFF3EBFF);
  static const Color accentColor = Color(0xffFFA133);
  static const Color textColor = Colors.black;
  static const Color bulletColor = Colors.black;

  static const double defaultSpacing = 32.0;
  static const double defaultPadding = 16.0;
  static const double imageHeight = 300.0;
  static const double mapHeight = 300.0;
  static const double mapWidth = 500.0;
  static const double mapZoom = 18.0;
  static const double iconSize = 25.0;
  static const double bulletSize = 8.0;
  static const double buttonHeight = 50.0;
  static const double borderRadius = 15.0;
}

// 2. Update Text Styles
class TextStyles {
  static final heading = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: UIConstants.primaryColor,
  );

  static final body = GoogleFonts.poppins(
    fontSize: 15,
    color: UIConstants.textColor,
  );

  static final subtitle = GoogleFonts.poppins(
    fontSize: 15,
    color: Colors.grey,
  );

  static final button = GoogleFonts.poppins(
    fontSize: 15,
    color: UIConstants.primaryColor,
    fontWeight: FontWeight.w600,
  );
}

// 3. Database Constants
class DBConstants {
  static const String institutionTable = 'Financial-Institution';
  static const String benefitsTable = 'Financial-Institution-Benefit';
  static const String benefitDetailsTable =
      'Benefit-Details-Financial-Institution';
  static const String requirementsTable = 'Financial-Institution-Requirement';
}

class FinancialDetails extends StatefulWidget {
  final String id;
  const FinancialDetails({super.key, required this.id});

  @override
  State<FinancialDetails> createState() => _FinancialDetailsState();
}

class _FinancialDetailsState extends State<FinancialDetails> {
  late Future<Map<String, dynamic>> _future;
  GoogleMapController? mapController; // Make controller nullable
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _future = _fetchInstitutionDetails();
  }

  Future<Map<String, dynamic>> _fetchInstitutionDetails() async {
    final response = await Supabase.instance.client
        .from('Financial-Institution')
        .select()
        .eq('Financial_Institution_ID', widget.id)
        .single();

    final fileName = "${response['Financial_Institution_Name']}.png";
    final imageUrl = Supabase.instance.client.storage
        .from('Assets')
        .getPublicUrl("Financial-Institution/$fileName");

    final benefits = await Supabase.instance.client
        .from('Financial-Institution-Benefit')
        .select()
        .eq('Financial-Institution-ID', widget.id);

    response['Financial-Institution-Benefits-Details'] = benefits;
    response['Financial-Institution-Image-Url'] = imageUrl;
    return response;
  }

  Future<void> _refreshContent() async {
    setState(() {}); // This triggers a rebuild of the widget
  }

  // Check Internet Connection using dart:io
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: _buildIconButton(
          Icons.arrow_back,
          () => GoRouter.of(context).pop('/Financial-Institution'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
          future: _checkInternetConnection(),
          builder: (context, networkSnapshot) {
            if (networkSnapshot.data == false) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Internet Connection',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your network and try again',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshContent,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return FutureBuilder<Map<String, dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return ListView(
                    children: [
                      _buildBackgroundImage(
                          data['Financial-Institution-Image-Url']),
                      _buildDetailsSection(data),
                    ],
                  );
                } else {
                  return const Center(child: Text('No data found'));
                }
              },
            );
          }),
    );
  }

  Widget _buildBackgroundImage(String imageUrl) {
    return SizedBox(
      height: 300,
      child: ClipRRect(
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : const Center(child: Text('Image not available')),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 20,
        color: const Color(0xff5B50A0),
      ),
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(data),
          _buildDividerWithSpacing(),
          _buildSchedule(data),
          _buildAboutSection(data),
          _buildDividerWithSpacing(),
          _buildLocationSection(data),
          _buildDividerWithSpacing(),
          _buildBenefitsSection(data),
          _buildDividerWithSpacing(),
          _buildContactSection(data),
          _buildDividerWithSpacing(),
          _buildReportSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildTitle(data['Financial_Institution_Name'] ?? 'Unknown Name'),
        const SizedBox(height: 10),
        _buildSubtitle(data['Financial_Institution_Type'] ?? 'Unknown Type'),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDividerWithSpacing() {
    return Column(
      children: const [
        SizedBox(height: 20),
        Divider(color: Colors.black),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xff5B50A0),
        ),
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.green,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSchedule(Map<String, dynamic> data) {
    final scheduleData = data['Financial_Insitution_opening_hours'];

    if (scheduleData is! Map<String, dynamic>) {
      return Text(
        'Invalid schedule format',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.red,
        ),
      );
    }

    // Convert Map to List of maps where each entry contains "day" and "hours"
    final List<Map<String, String>> schedule = scheduleData.entries
        .map((entry) => {"day": entry.key, "hours": entry.value.toString()})
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operating hours',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xff5B50A0),
          ),
        ),
        if (schedule.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final item = schedule[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      child: Text(
                        "${item['day']}:",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "${item['hours']}",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        else
          Text(
            'No available schedule',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Disclaimer: The schedule may differ depending on the number of people arriving. It is best to arrive early.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAboutSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDividerWithSpacing(),
        Text(
          'About Us',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xff5B50A0),
          ),
        ),
        const SizedBox(height: 0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReadMoreText(
              data['Financial_Institution_Desc'] ?? 'No description available',
              trimLines: 6,
              colorClickableText: const Color(0xff5B50A0),
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Show more',
              trimExpandedText: 'Show less',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Widget _buildLocationSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Where are we?',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xff5B50A0),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data['Financial_Institution_Address'] ?? '',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          width: 500,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            liteModeEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                data['Financial_Institution_Address_Lat'] ?? 0.0,
                data['Financial_Institution_Address_Long'] ?? 0.0,
              ),
              zoom: 18.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId(data['Financial_Institution_Name']),
                icon: BitmapDescriptor.defaultMarker,
                position: LatLng(
                  data['Financial_Institution_Address_Lat'] ?? 0.0,
                  data['Financial_Institution_Address_Long'] ?? 0.0,
                ),
              ),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection(Map<String, dynamic> data) {
    final benefits = data['Financial-Institution-Benefits-Details'];
    final benefitsList = benefits != null && benefits is List
        ? List<String>.from(benefits.map((benefit) =>
            benefit['Financial-Institution-Benefits-Name']?.toString() ??
            'Unnamed Benefit'))
        : <String>['No benefits available'];

    return _buildSectionWithList(
      title: 'Benefits & Requirements for Cancer Patients',
      items: benefitsList,
      buttonText: 'View More',
      onButtonPressed: () => GoRouter.of(context).goNamed(
        "benefits",
        pathParameters: {
          'fid': data['Financial_Institution_ID']?.toString() ?? '',
        },
      ),
    );
  }

  Widget _buildSectionWithList({
    required String title,
    required List<String> items,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xff5B50A0),
            )),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...items.map((item) => _buildBulletItem(item)),
              const SizedBox(height: 25),
              _buildShowAllButton(buttonText, onButtonPressed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowAllButton(String text, VoidCallback onPressed) {
    return Center(
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xff5B50A0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Us',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xff5B50A0),
            )),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.phone_outlined, color: Colors.black, size: 25),
            const SizedBox(width: 10),
            Text(
              data['Financial_Institution_Contact_Number'] ??
                  'No contact available',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Widget _buildFAQSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Frequently Asked Questions',
  //           style: GoogleFonts.poppins(
  //             fontSize: 20,
  //             fontWeight: FontWeight.w600,
  //             color: const Color(0xff5B50A0),
  //           )),
  //       const SizedBox(height: 16),
  //       _buildFAQItem(
  //         question: 'What are the operating hours?',
  //         answer: 'We are open 24 hours a day, 7 days a week.',
  //       ),
  //       _buildFAQItem(
  //         question: 'How can I contact you?',
  //         answer: 'You can contact us at the phone number provided above.',
  //       ),
  //       _buildFAQItem(
  //         question: 'What benefits do you offer?',
  //         answer:
  //             'We offer inpatient, outpatient, and Z benefits for catastrophic illnesses.',
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildFAQItem({required String question, required String answer}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           question,
  //           style: GoogleFonts.poppins(
  //             fontSize: 15,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.black,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           answer,
  //           style: GoogleFonts.poppins(
  //             fontSize: 15,
  //             color: Colors.grey,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showSnackBar('This feature is not available right now'),
          child: Row(
            children: [
              const Icon(Icons.flag_outlined, color: Colors.black, size: 25),
              const SizedBox(width: 10),
              Text(
                'Report Listing',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'if bugs and inaccuracy occurred',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: const Color(0xffFFA133),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    // Add null check before disposing
    mapController?.dispose();
    super.dispose();
  }
}
