import 'package:cancerline_companion/Presentation/screen/FinancialSupport/PartylistDetails.dart';
import 'package:cancerline_companion/Presentation/screen/Oncologist/MedicalScreenDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Presentation/screen/BarrelFileScreen.dart';
import '../Layouts/BarrelFileLayouts.dart';

const Color _primaryColor = Color(0xFF5B50A0);
final GoRouter linkrouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Login Screen
    GoRoute(
      path: '/',
      builder: (context, state) => LoginScreen(),
    ),
    // Registration Screen
    GoRoute(
      path: '/RegisterScreen',
      builder: (context, state) => const RegisterScreen(),
    ),
    // Main app shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        final userId = state.pathParameters['userID'];
        return ScaffoldLayoutWidget(
          userid: userId,
          bodyWidget: child,
          actionsWidget: [
            // Your existing actions widgets
          ],
        );
      },
      routes: [
        // Home route
        GoRoute(
          name: 'userID',
          path: '/HomeScreen/:userID',
          builder: (context, state) => const HomeScreen(),
          routes: [
            // Journal route
            GoRoute(
              path: 'journal',
              builder: (context, state) => const JournalScreen(),
            ),
            // Resources route
            GoRoute(
              path: 'resources',
              builder: (context, state) {
                final userId = state.pathParameters['userID']!;
                return ResourcesScreen(
                    userid: userId); // Removed ScaffoldLayoutWidget wrapper
              },
            ),
            // Profile route
            GoRoute(
              path: 'profile',
              builder: (context, state) {
                final userId = state.pathParameters['userID']!;
                return ProfileScreen(userid: userId);
              },
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      name: 'blogid',
      path: '/:userID/blog/:blogid',
      builder: (context, state) => MoreinfoBlogsscreen(
        id: state.pathParameters['blogid']!,
        userid: state.pathParameters[
            'userID']!, // Changed to match the parameter name in path
      ),
    ),
    GoRoute(
      name: 'eventid',
      path: '/:userID/event/:eventid',
      builder: (context, state) => MoreinfoEventsscreen(
        id: state.pathParameters['eventid']!,
        userid: state.pathParameters['userID']!,
      ),
    ),

    // Health Institution Screens
    GoRoute(
      path: '/Health-Institution',
      builder: (context, state) {
        final userId = state.pathParameters['userID'] ?? 'default';
        return ScaffoldLayoutWidget(
          userid: userId,
          bodyWidget: HealthInstitutionScreen(userid: userId),
          showNavBar: false,
          leadingWidget: BackButton(
            color: _primaryColor,
            onPressed: () => GoRouter.of(context).go('/HomeScreen/$userId'),
          ),
        );
      },
      routes: [
        GoRoute(
          name: 'hid',
          path: ':hid',
          builder: (context, state) =>
              MoreInfoInstitutionScreen(id: state.pathParameters['hid']!),
        ),
      ],
    ),

    // // Blogs Screen
    // GoRoute(
    //   path: '/Blog',
    //   builder: (context, state) {
    //     final userId = state.pathParameters['userID'] ?? 'default';
    //     return ScaffoldLayoutWidget(
    //       userid: userId,
    //       bodyWidget: const BlogsScreen(),
    //       showNavBar: false,
    //       leadingWidget: BackButton(
    //         color: _primaryColor,
    //         onPressed: () => GoRouter.of(context).go('/HomeScreen/$userId'),
    //       ),
    //     );
    //   },

    // ),
    // Financial Support Screen
    GoRoute(
      path: '/Financial-Institution',
      builder: (context, state) {
        final userId = state.pathParameters['userID'] ?? 'default';
        return ScaffoldLayoutWidget(
          userid: userId,
          bodyWidget: const FinancialSupportScreen(),
          showNavBar: false,
          leadingWidget: BackButton(
            color: _primaryColor,
            onPressed: () => GoRouter.of(context).go('/HomeScreen/$userId'),
          ),
        );
      },
      routes: [
        GoRoute(
          name: 'fid',
          path: ':fid',
          builder: (context, state) =>
              FinancialDetails(id: state.pathParameters['fid']!),
          routes: [
            GoRoute(
              name: 'benefits',
              path: 'benefits', // ❌ Removed leading '/'
              builder: (context, state) =>
                  Benefitsdetails(fid: state.pathParameters['fid']!),
            ),
          ],
        ),
        GoRoute(
          name: 'partylist',
          path: 'partylist/:fid',
          builder: (context, state) => PartylistDetails(
            partylistid: state.pathParameters['fid']!,
          ),
        ),
      ],
    ),

    // Doctors Screen
    GoRoute(
        path: '/Medical-Specialists',
        builder: (context, state) {
          final userId = state.pathParameters['userID'] ?? 'default';
          return ScaffoldLayoutWidget(
            userid: userId,
            bodyWidget: const MedicalSpecialistScreens(),
            showNavBar: false,
            leadingWidget: BackButton(
              color: _primaryColor,
              onPressed: () => GoRouter.of(context).go('/HomeScreen/$userId'),
            ),
          );
        },
        routes: [
          GoRoute(
            name: ':docid',
            path: ':docid',
            builder: (context, state) => MedicalSpeciaDetailScreens(
              docid: state.pathParameters['docid']!,
            ),
          ),
        ]),
    // Support Groups
    GoRoute(
      path: '/Support-Groups',
      builder: (context, state) {
        final userId = state.pathParameters['userID'] ?? 'default';
        return ScaffoldLayoutWidget(
          userid: userId,
          bodyWidget: const Supportgroupslistscreen(),
          showNavBar: false,
          leadingWidget: BackButton(
            color: _primaryColor,
            onPressed: () => GoRouter.of(context).go('/HomeScreen/$userId'),
          ),
        );
      },
      routes: [
        GoRoute(
          path: ':groupid',
          name: 'groupid',
          builder: (context, state) => Supportgroupdetailsscreen(
            groupId: state.pathParameters['groupid']!,
          ),
        ),
      ],
    ),
    GoRoute(path: '/Settings', builder: (context, state) => const Settings()),
  ],
);
