import 'package:appwrite/models.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:event_management_app/auth.dart';
import 'package:event_management_app/constants/colors.dart';
import 'package:event_management_app/containers/event_container.dart';
import 'package:event_management_app/database.dart';
import 'package:event_management_app/saved_data.dart';
import 'package:event_management_app/views/create_event_page.dart';
import 'package:event_management_app/views/popular_item.dart';
import 'package:event_management_app/views/profile_page.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String userName = "User";
  List<Document> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userName = SavedData.getUserName().split(" ")[0];
    refresh();
  }

  void refresh() {
    getAllEvents().then((value) {
      setState(() {
        events = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
              refresh();
            },
            icon: Icon(
              Icons.account_circle,
              color: kLightGreen,
              size: 30,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi $userName 👋",
                    style: TextStyle(
                      color: kLightGreen,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Explore events around you",
                    style: TextStyle(
                      color: kLightGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // ✅ Safe Carousel
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (events.isEmpty)
                    const SizedBox(
                      height: 150,
                      child: Center(
                        child: Text(
                          "No events available",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    cs.CarouselSlider(
                      options: cs.CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.99,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: events
                          .take(4) // ✅ show max 4 items safely
                          .map((event) => EventContainer(data: event))
                          .toList(),
                    ),

                  const SizedBox(height: 16),
                  Text(
                    "Popular Events",
                    style: TextStyle(
                      color: kLightGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Safe Popular Events Section
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                color: const Color(0xFF2E2E2E),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  children: [
                    if (events.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No popular events yet",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    else
                      for (int i = 0;
                      i < events.length && i < 5;
                      i++) ...[
                        PopularItem(
                          eventData: events[i],
                          index: i + 1,
                        ),
                        const Divider(),
                      ],
                  ],
                ),
              ),
            ]),
          ),

          // ✅ "All Events" Section
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.only(bottom: 2, top: 8, left: 6, right: 6),
              child: Text(
                "All Events",
                style: TextStyle(
                  color: kLightGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ✅ All Events List
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => EventContainer(data: events[index]),
              childCount: events.length,
            ),
          ),
        ],
      ),

      // ✅ Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventPage()),
          );
          refresh();
        },
        backgroundColor: kLightGreen,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}
