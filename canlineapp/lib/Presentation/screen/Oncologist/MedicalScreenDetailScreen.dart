import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicalSpeciaDetailScreens extends StatefulWidget {
  final String docid;
  const MedicalSpeciaDetailScreens({super.key, required this.docid});

  @override
  State<MedicalSpeciaDetailScreens> createState() =>
      _MedicalSpeciaDetailScreensState();
}

class _MedicalSpeciaDetailScreensState
    extends State<MedicalSpeciaDetailScreens> {
  late Future<Map<String, dynamic>> _future;
  String _selectedFilter = 'all';
  List<Map<String, dynamic>> _filteredClinics = [];
  final ValueNotifier<String> _filterNotifier = ValueNotifier<String>('all');

  @override
  void initState() {
    super.initState();
    _future = _fetchDoctorDetails();
  }

  Future<Map<String, dynamic>> _fetchDoctorDetails() async {
    if (widget.docid == null || widget.docid.isEmpty) {
      throw Exception('Invalid doctor ID');
    }
    print('Received doctor ID: ${widget.docid}');
    try {
      // Simplified ID handling - no need to parse twice
      final doctorId = int.tryParse(widget.docid);
      if (doctorId == null) {
        throw Exception('Invalid doctor ID format');
      }

      final response = await Supabase.instance.client
          .from('Doctor')
          .select()
          .eq('id', doctorId) // Use the parsed integer directly
          .single();

      if (response == null) {
        throw Exception('No data found');
      }

      // Rest of the code remains the same
      // final fileName =
      //     "${response['Doctor-Firstname']}_${response['Doctor-Lastname']}.png";
      // final imageUrl = Supabase.instance.client.storage
      //     .from('Assets')
      //     .getPublicUrl("Doctor/$fileName");

      // response['Doctor-Image-Url'] = imageUrl;
      return response;
    } catch (e) {
      throw Exception('Failed to fetch doctor details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _buildIconButton(
          Icons.arrow_back,
          () => context.go('/Medical-Specialists'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchDoctorDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return ListView(
              children: [
                _buildBackgroundImage(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header in the screen include name and specialization
                      _buildHeaderSection(data),
                      _buildDividerWithSpacing(),
                      _buildAboutSection(data),
                      _buildDividerWithSpacing(),
                      _buildClinicLocationsSection(data),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return SizedBox(
      height: 300,
      child: ClipRRect(
        child: Center(
            child: Icon(Icons.person_4_rounded, color: Colors.grey, size: 300)),
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

  Widget _buildHeaderSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildTitle('${data['Doctor-Firstname']} ${data['Doctor-Lastname']}'),
        _buildSubtitle(data['Specialization'] ?? 'Unknown Specialization'),
      ],
    );
  }

  Widget _buildDividerWithSpacing() {
    return Column(
      children: const [
        SizedBox(height: 32),
        Divider(color: Colors.black),
        SizedBox(height: 32),
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

  Widget _buildAboutSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xff5B50A0),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          data['Medical Background'] ?? 'No description available',
          style: GoogleFonts.poppins(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildClinicLocationsSection(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> clinics = [
      {
        'name': 'St. Luke\'s Medical Center',
        'type': 'Hospital',
        'address': '279 E Rodriguez Sr. Ave, Quezon City',
        'schedule': {
          'Mon-Fri': '9:00 AM - 5:00 PM',
          'Sat': '9:00 AM - 12:00 PM',
        },
        'contact': '(02) 8723-0101',
        'status': 'Primary',
      },
      {
        'name': 'Private Clinic',
        'type': 'Private Practice',
        'address': 'Unit 1204, Medical Plaza Ortigas',
        'schedule': {
          'Tue-Thu': '2:00 PM - 6:00 PM',
        },
        'contact': '(02) 8888-9999',
        'status': 'By Appointment',
      },
      {
        'name': 'Asian Hospital and Medical Center',
        'type': 'Hospital',
        'address': '2205 Civic Drive, Alabang, Muntinlupa',
        'schedule': {
          'Mon': '1:00 PM - 7:00 PM',
          'Wed': '1:00 PM - 7:00 PM',
          'Fri': '9:00 AM - 3:00 PM',
        },
        'contact': '(02) 8771-9000',
        'status': 'Secondary',
      },
      {
        'name': 'Telemedicine Consultation',
        'type': 'Virtual',
        'address': 'Online Video Consultation',
        'schedule': {
          'Tue': '10:00 AM - 12:00 PM',
          'Thu': '10:00 AM - 12:00 PM',
          'Sat': '2:00 PM - 4:00 PM',
        },
        'contact': 'Book through App',
        'status': 'Available',
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Clinic Locations',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5B50A0),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Color(0xff5B50A0)),
              onSelected: (value) {
                _filterNotifier.value = value;
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.all_inbox, size: 20),
                      SizedBox(width: 8),
                      Text('All Locations'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'hospital',
                  child: Row(
                    children: [
                      Icon(Icons.local_hospital, size: 20),
                      SizedBox(width: 8),
                      Text('Hospitals'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'private',
                  child: Row(
                    children: [
                      Icon(Icons.medical_services, size: 20),
                      SizedBox(width: 8),
                      Text('Private Clinics'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'virtual',
                  child: Row(
                    children: [
                      Icon(Icons.videocam, size: 20),
                      SizedBox(width: 8),
                      Text('Telemedicine'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<String>(
          valueListenable: _filterNotifier,
          builder: (context, filterValue, child) {
            final filteredClinics = _filterClinics(clinics, filterValue);
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredClinics.length,
              itemBuilder: (context, index) =>
                  _buildClinicCard(filteredClinics[index]),
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filterClinics(
      List<Map<String, dynamic>> clinics, String filter) {
    if (filter == 'all') {
      return clinics;
    }

    return clinics.where((clinic) {
      switch (filter) {
        case 'hospital':
          return clinic['type'] == 'Hospital';
        case 'private':
          return clinic['type'] == 'Private Practice';
        case 'virtual':
          return clinic['type'] == 'Virtual';
        default:
          return false;
      }
    }).toList();
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Clinic Header with colored background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff5B50A0).withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getClinicIcon(clinic['type']),
                    color: const Color(0xff5B50A0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff5B50A0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(clinic['status'])
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(clinic['status'])
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          clinic['status'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _getStatusColor(clinic['status']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Clinic Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address and Contact with improved layout
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.location_on,
                        clinic['address'],
                        Colors.grey.shade700,
                      ),
                      if (clinic['type'] != 'Virtual') ...[
                        const Divider(height: 16),
                        _buildInfoRow(
                          Icons.phone,
                          clinic['contact'],
                          Colors.grey.shade700,
                        ),
                      ],
                    ],
                  ),
                ),
                // Schedule Section
                if (clinic['type'] != 'Virtual') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: const Color(0xff5B50A0),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Schedule',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff5B50A0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...(clinic['schedule'] as Map<String, String>)
                            .entries
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        e.key,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        e.value,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xff5B50A0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showClinicDetails(Map<String, dynamic> clinic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              // ... Detailed clinic information
            ],
          ),
        ),
      ),
    );
  }

  IconData _getClinicIcon(String type) {
    switch (type) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Virtual':
        return Icons.videocam;
      case 'Private Practice':
        return Icons.medical_services;
      default:
        return Icons.local_hospital;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Primary':
        return Colors.green;
      case 'Secondary':
        return Colors.orange;
      case 'By Appointment':
        return Colors.blue;
      case 'Available':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<Widget> _buildScheduleRows(Map<String, String> schedule) {
    return schedule.entries
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 80,
                  child: Text(
                    '${e.key}:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  e.value,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildClinicInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
