import 'package:flutter/material.dart';

class ScheduleItem extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String title;
  final String subtitle;
  final String teacher;
  final String meeting;
  final Color cardColor;
  final Color textColor;

  const ScheduleItem({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.subtitle,
    required this.teacher,
    required this.meeting,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              children: [
                Text(
                  startTime,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  endTime,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF7C6EF6),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 3,
                    backgroundColor: Color(0xFF7C6EF6),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: const Color(0xFF7C6EF6),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.more_vert,
                      color: textColor.withOpacity(.6),
                    ),
                  ),

                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withOpacity(.7),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const CircleAvatar(radius: 9),
                      const SizedBox(width: 8),
                      Text(
                        teacher,
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.videocam,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        meeting,
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}