import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({super.key});
  static const Color _primaryColor = Color(0xFF5B50A0);

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

// Available options for the radio buttons
List<String> patientType = ['Outpatient', 'Inpatient'];
List<String> sex = ['Male', 'Female'];

class _RegisterscreenState extends State<Registerscreen> {
  // Current Step of stepper
  int _currentStep = 0;

  // Options for Patient Type and sex
  String currentPatientTypeOption = patientType[0];
  String currentSexOption = sex[0];

  // Selected Date
  DateTime? selectedDate;

  // Autocomplete Textfield
  String selectedCancerType = '';

  // List of Cancer Types
  static const List<String> listItems = <String>[
    'Breast Cancer',
    'Cervical Cancer',
    'Lung Cancer',
    'Prostate Cancer',
    'Ovarian cancer'
  ];

  // Textfield Controllers and form key
  final _formKeystep = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  late final TextEditingController _fname;
  late final TextEditingController _lname;
  late final TextEditingController _mname;
  late final TextEditingController _suffix;
  late final TextEditingController _occupation;
  late final TextEditingController _citizenship;
  late final TextEditingController _currentAddress;
  late final TextEditingController _city;
  late final TextEditingController _province;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _fname = TextEditingController();
    _lname = TextEditingController();
    _mname = TextEditingController();
    _suffix = TextEditingController();
    _occupation = TextEditingController();
    _citizenship = TextEditingController();
    _currentAddress = TextEditingController();
    _city = TextEditingController();
    _province = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  // Init Supabase Client
  final supabase = Supabase.instance.client;

  // Sign Up Function
  Future<void> signup() async {
    try {
      await supabase.auth.signUp(
        password: _password.text.trim(),
        email: _email.text.trim(),
        data: {
          'firstname': _fname.text.trim(),
          'lastname': _lname.text.trim(),
          'middlename': _mname.text.trim(),
          'suffix': _suffix.text.trim(),
          'sex': currentSexOption,
          'occupation': _occupation.text.trim(),
          'citizenship': _citizenship.text.trim(),
          'current_address': _currentAddress.text.trim(),
          'city': _city.text.trim(),
          'province': _province.text.trim(),
          'patient_type': currentPatientTypeOption,
          'date_of_birth': selectedDate?.toIso8601String() ?? '',
          'cancer_type': selectedCancerType,
        },
      );

      if (!mounted) return;
      context.go('/');
    } on AuthException catch (e) {
      debugPrint('Error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected Error: $e')),
      );
    }
  }

  // Handle Step Continue
  void _handleStepContinue() {
    final isLastStep = _currentStep == getSteps().length - 1;

    bool isValid = _formKeystep[_currentStep].currentState?.validate() ?? false;

    // Additional validation for Step 4 (Medical Information)
    if (_currentStep == 3) {
      // Example: Make Date of Birth required
      if (selectedDate == null) {
        isValid = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select your Date of Birth')),
        );
        return;
      }

      // Add more custom validations if needed
    }

    if (isValid) {
      if (isLastStep) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Registered Successfully! You may proceed to login')),
        );
        signup();
      } else {
        setState(() {
          _currentStep += 1;
        });
        debugPrint('Next Step');
      }
    } else {
      // If the form is invalid, display a snackbar or handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please provide the missing credentials to proceed')),
      );
    }
  }

  // Handle Step Cancel
  void _handleStepCancel() {
    setState(() {
      if (_currentStep == 0) {
        context.go('/');
      } else {
        _currentStep -= 1;
      }
    });
  }

  // Build Stepper Controls
  Widget _buildStepperControls(ControlsDetails details) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      child: Row(
        children: [
          if (_currentStep < 3)
            Expanded(
              child: ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Registerscreen._primaryColor),
                  ),
                  backgroundColor: Registerscreen._primaryColor,
                ),
                child: Text(
                  'Next',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          const SizedBox(width: 12),
          if (_currentStep >= 0 && _currentStep < 3)
            Expanded(
              child: ElevatedButton(
                onPressed: details.onStepCancel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  backgroundColor: Colors.grey,
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          const SizedBox(width: 12),
          if (_currentStep == 3)
            Expanded(
              child: ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Registerscreen._primaryColor),
                  ),
                  backgroundColor: Registerscreen._primaryColor,
                ),
                child: Text(
                  'Finish',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0), // Set the height here
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Create an Account',
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: Registerscreen._primaryColor,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          // Make the entire body scrollable
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // Change mainAxisSize to max to take full height
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Static warning message about the required fields
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    border: Border.all(color: Colors.yellow[700]!),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.yellow[700],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Please fill out all required fields (*), Put none if not applicable.',
                          style: GoogleFonts.poppins(
                            color: Colors.yellow[700],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Use a ConstrainedBox to limit the Stepper's height
                ConstrainedBox(
                  constraints: BoxConstraints(
                    // Adjust the maxHeight as needed
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Stepper(
                    steps: getSteps(),
                    elevation: 0,
                    connectorThickness: 1,
                    // type: StepperType.horizontal,
                    currentStep: _currentStep,
                    onStepContinue: _handleStepContinue,
                    onStepCancel: _handleStepCancel,
                    onStepTapped: null,
                    controlsBuilder: (context, details) =>
                        _buildStepperControls(details),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Step> getSteps() {
    return [
      // Step 1 of registration process (Basic Personal Information)
      Step(
        isActive: _currentStep >= 0,
        title: const Text('Step 1'),
        subtitle: const Text('Personal Information'),
        content: Form(
          key: _formKeystep[0],
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextfield('First Name*', _fname),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: _buildTextfield('Suffix', _suffix),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextfield('Middle Name', _mname),
              const SizedBox(height: 20),
              _buildTextfield('Last Name*', _lname),
              const SizedBox(height: 20),
              _buildTextfield('Occupation*', _occupation),
            ],
          ),
        ),
      ),

      // Step 2 of registration process (Address)
      Step(
        isActive: _currentStep >= 1,
        label: null,
        subtitle: const Text('Address'),
        title: const Text('Step 2'),
        content: Form(
          key: _formKeystep[1],
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              _buildTextfield('Citizenship*', _citizenship),
              const SizedBox(height: 20),
              _buildTextfield('Current Address*', _currentAddress),
              const SizedBox(height: 20),
              _buildTextfield('City*', _city),
              const SizedBox(height: 20),
              _buildTextfield('Province*', _province),
            ],
          ),
        ),
      ),

      // Step 3 of registration process (Account Information)
      Step(
        isActive: _currentStep >= 2,
        label: null,
        subtitle: const Text('Account Information'),
        title: const Text('Step 3'),
        content: Form(
          key: _formKeystep[2],
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              _buildTextfield('Email Address*', _email),
              const SizedBox(height: 20),
              _buildTextfield('Password*', _password),
            ],
          ),
        ),
      ),

      // Step 4 of registration process (Basic Medical Information)
      Step(
        isActive: _currentStep >= 3,
        label: null,
        subtitle: const Text('Medical Information'),
        title: const Text('Step 4'),
        content: Form(
          key: _formKeystep[3],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              // Patient Type
              Text(
                'Patient Type*',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Registerscreen._primaryColor,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      contentPadding: EdgeInsets.zero, // Align with the label
                      title: Text(
                        'Outpatient',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      value: patientType[0],
                      groupValue: currentPatientTypeOption,
                      onChanged: (value) {
                        setState(() {
                          currentPatientTypeOption = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      contentPadding: EdgeInsets.zero, // Align with the label
                      title: Text(
                        'Inpatient',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      value: patientType[1],
                      groupValue: currentPatientTypeOption,
                      onChanged: (value) {
                        setState(() {
                          currentPatientTypeOption = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Date of Birth
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: selectedDate == null
                        ? Colors.red
                        : Registerscreen._primaryColor,
                  ),
                  fixedSize: Size(double.infinity, 50), // Make it responsive
                ),
                onPressed: () async {
                  final DateTime? dateTime = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (dateTime != null) {
                    setState(() {
                      selectedDate = dateTime;
                    });
                  }
                },
                child: Text(
                  selectedDate == null
                      ? 'Select Date of Birth*'
                      : 'Date of Birth: ${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}',
                  style: GoogleFonts.poppins(
                      color: selectedDate == null
                          ? Colors.red
                          : Registerscreen._primaryColor,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.start,
                ),
              ),
              // Display error message if Date of Birth is not selected
              if (_currentStep == 3 && selectedDate == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text(
                    'Date of Birth is required',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              // Sex
              Text(
                'Sex*',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Registerscreen._primaryColor,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      contentPadding: EdgeInsets.zero, // Align with the label
                      title: Text(
                        'Male',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      value: sex[0],
                      groupValue: currentSexOption,
                      onChanged: (value) {
                        setState(() {
                          currentSexOption = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      contentPadding: EdgeInsets.zero, // Align with the label
                      title: Text(
                        'Female',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      value: sex[1],
                      groupValue: currentSexOption,
                      onChanged: (value) {
                        setState(() {
                          currentSexOption = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Type of Cancer
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return listItems.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  selectedCancerType = selection;
                  debugPrint('You selected $selectedCancerType');
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type of Cancer*',
                      hintStyle: TextStyle(
                          color: Registerscreen
                              ._primaryColor), // Your placeholder text here
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                    ),
                    onSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 2.0,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxHeight: 200.0, maxWidth: 320),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildTextfield(String labelText, TextEditingController controller) {
    return TextFormField(
      validator: (value) => value!.isEmpty ? 'Enter your $labelText' : null,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Registerscreen._primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Registerscreen._primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Registerscreen._primaryColor),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fname.dispose();
    _lname.dispose();
    _mname.dispose();
    _suffix.dispose();
    _occupation.dispose();
    _citizenship.dispose();
    _currentAddress.dispose();
    _city.dispose();
    _province.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
