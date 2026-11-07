import 'package:flutter/material.dart';
import 'package:vu_routine/app/models/schedule_home_model.dart';
import 'package:vu_routine/app/modules/home/views/schedule_card.dart';

class ScheduleTimeline extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final int activeScheduleIndex;

  const ScheduleTimeline({
    super.key,
    required this.schedules,
    required this.activeScheduleIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 77,
          top: 0,
          bottom: 180,
          child: Container(width: 2, color: const Color(0xff8D7BFF)),
        ),

        Column(
          children: List.generate(schedules.length, (index) {
            return ScheduleCard(
              schedule: schedules[index],
              isLast: index == schedules.length - 1,
              isActive: index == activeScheduleIndex,
            );
          }),
        ),
      ],
    );
  }
}
