import 'package:flutter/material.dart';
import 'package:vu_routine/app/models/schedule_model.dart';
import 'package:vu_routine/app/utils/call.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final bool isLast;
  final bool isActive;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.isLast,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final darkText = schedule.color.computeLuminance() > .5;

    return SizedBox(
      height: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  schedule.startTime,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  schedule.endTime,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 36,
            child: Align(
              alignment: Alignment.topCenter,
              child: TimelineDot(isActive: isActive),
            ),
          ),

          Expanded(
            child: Container(
              height: 165,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: schedule.color,
                image:
                    schedule.backgroundImage == null
                        ? null
                        : DecorationImage(
                          image: AssetImage(schedule.backgroundImage!),
                          alignment: Alignment.centerRight,
                          scale: 2.5,
                          opacity: .5,
                        ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: TextStyle(
                      color: darkText ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule.subtitle,
                    style: TextStyle(
                      color: darkText ? Colors.black87 : Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    schedule.teacher,
                    style: TextStyle(
                      color: darkText ? Colors.black87 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Room : ${schedule.room}",
                    style: TextStyle(
                      color: darkText ? Colors.black54 : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => callNumber(schedule.number),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Icon(
                          Icons.call,
                          color: darkText ? Colors.black54 : Colors.white70,
                        ),
                        Text(
                          schedule.number,
                          style: TextStyle(
                            color: darkText ? Colors.black54 : Colors.white70,
                          ),
                        ),
                      ],
                    ),
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

class TimelineDot extends StatelessWidget {
  final bool isActive;

  const TimelineDot({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isActive ? Colors.green : const Color(0xff8D7BFF),
            width: 3,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CircleAvatar(
            radius: 4,
            backgroundColor: isActive ? Colors.green : const Color(0xff8D7BFF),
          ),
        ),
      );
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF8D7BFF), width: 2),
      ),
    );
  }
}
