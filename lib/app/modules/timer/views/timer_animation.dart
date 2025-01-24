import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/timer_model.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/timer/controllers/timer_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

import '../../../utils/utils.dart';
import '../../settings/controllers/theme_controller.dart';
import 'dart:math' show min;

class TimerAnimatedCard extends StatefulWidget {
  final TimerModel timer;
  final int index;

  const TimerAnimatedCard({
    super.key,
    required this.index,
    required this.timer,
  });
  @override
  _TimerAnimatedCardState createState() => _TimerAnimatedCardState();
}

class _TimerAnimatedCardState extends State<TimerAnimatedCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TimerController controller = Get.find<TimerController>();
  ThemeController themeController = Get.find<ThemeController>();

  Timer? _timerCounter;
  void startTimer() {
    _timerCounter = Timer.periodic(Duration(seconds: 1), (timer) {
      print('${widget.timer.timerName}');
      if (widget.timer.timeElapsed < widget.timer.timerValue) {
        setState(() {
          widget.timer.timeElapsed += 1000;
          IsarDb.updateTimerTick(widget.timer);
        });
      } else {
        stopTimer();
        controller.startRinger(widget.timer.timerId);
      }
    });
  }

  void stopTimer() {
    _timerCounter!.cancel();
  }

  @override
  void initState() {
    super.initState();
    if (Utils.getDifferenceMillisFromNow(
                widget.timer.startedOn, widget.timer.timerValue) <=
            0 &&
        widget.timer.isPaused == 0) {
      widget.timer.isPaused = 1;
      widget.timer.timeElapsed = 0;
      IsarDb.updateTimerPauseStatus(widget.timer);
    } else if (Utils.getDifferenceMillisFromNow(
                widget.timer.startedOn, widget.timer.timerValue) <
            widget.timer.timerValue &&
        widget.timer.isPaused == 0) {
      widget.timer.timeElapsed = widget.timer.timerValue -
          Utils.getDifferenceMillisFromNow(
              widget.timer.startedOn, widget.timer.timerValue);
      IsarDb.updateTimerPauseStatus(widget.timer);
    }
    if (widget.timer.isPaused == 0) {
      startTimer();
    }
  }

  @override
  void dispose() {
    _timerCounter!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10.0.w,
      ),
      child: Container(
        height: 0.3.sh,
        width: 1.sw,
        child: Obx(
          () => Card(
            margin: EdgeInsets.all(5.r),
            color: widget.timer.timeElapsed < widget.timer.timerValue
                ? themeController.secondaryBackgroundColor.value
                : themeController.secondaryColor.value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                18.r,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  AnimatedContainer(
                    decoration: BoxDecoration(
                      color: kprimaryDisabledTextColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    duration: Duration(milliseconds: 1000),
                    height: 0.3.sh,
                    width: 1.sw *
                        ((widget.timer.timeElapsed) /
                            (widget.timer.timerValue)),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 25.w,
                        right: 20.w,
                        top: 20.h,
                        bottom: 20.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.timer.timerName,
                                      overflow: TextOverflow.ellipsis,
                                      // Set overflow property here
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall!.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: kprimaryColor,
                                          fontSize: 18.sp),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: EdgeInsets.only(right: 16.0.w),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (_timerCounter != null &&
                                                widget.timer.isPaused == 0) {
                                              stopTimer();
                                            }
                                            widget.timer.timeElapsed = 0;
                                            IsarDb.updateTimerTick(
                                                widget.timer);
                                            if (_timerCounter != null &&
                                                widget.timer.isPaused == 0) {
                                              widget.timer.startedOn =
                                                  DateTime.now().toString();
                                              IsarDb.updateTimerTick(
                                                      widget.timer)
                                                  .then(
                                                      (value) => startTimer());
                                            }
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: themeController
                                                  .primaryBackgroundColor.value,
                                              borderRadius:
                                                  BorderRadius.circular(20.r)),
                                          child: Padding(
                                            padding: EdgeInsets.all(4.0.r),
                                            child: Icon(
                                              Icons.refresh,
                                              size: 18.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller
                                            .stopRinger(widget.timer.timerId);
                                        controller
                                            .deleteTimer(widget.timer.timerId);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: themeController
                                                .primaryBackgroundColor.value,
                                            borderRadius:
                                                BorderRadius.circular(20.r)),
                                        child: Padding(
                                          padding: EdgeInsets.all(4.0.r),
                                          child: Icon(
                                            Icons.close,
                                            size: 18.r,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 13.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(
                                        () => AnimatedContainer(
                                          duration: Duration(seconds: 1),
                                          child: Text(
                                            '${Utils.formatMilliseconds(widget.timer.timerValue - widget.timer.timeElapsed)}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.displayLarge!.copyWith(
                                                color: themeController
                                                    .primaryTextColor.value,
                                                fontSize: 30.0.sp),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.all(14.r),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                widget.timer.isPaused == 0
                                                    ? stopTimer()
                                                    : startTimer();
                                                widget.timer.isPaused =
                                                    widget.timer.isPaused == 0
                                                        ? 1
                                                        : 0;
                                                IsarDb.updateTimerPauseStatus(
                                                    widget.timer);
                                              });
                                              if (widget.timer.timeElapsed >=
                                                  widget.timer.timerValue) {
                                                controller.stopRinger(
                                                    widget.timer.timerId);
                                                setState(() {
                                                  widget.timer.timeElapsed = 0;
                                                  IsarDb.updateTimerTick(
                                                          widget.timer)
                                                      .then((value) => IsarDb
                                                          .updateTimerPauseStatus(
                                                              widget.timer));
                                                  widget.timer.isPaused = 1;
                                                });
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: kprimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          80.r)),
                                              width: 80.w,
                                              height: 80.h,
                                              child: Icon(
                                                widget.timer.isPaused == 0
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                size: 30.r,
                                                color:
                                                    ksecondaryBackgroundColor,
                                              ),
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
