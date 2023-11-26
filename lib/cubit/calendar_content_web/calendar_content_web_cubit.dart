import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venturiautospurghi/cubit/web/web_cubit.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/utils/date_utils.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

part 'calendar_content_web_state.dart';

class CalendarContentWebCubit extends Cubit<CalendarContentWebState> {
  final ScrollController horizontalCalendar = ScrollController();
  final ScrollController horizontalHeader = ScrollController();
  final BuildContext context;
  double gridHourHeight = 100;
  final DateTime _baseFix = new DateTime(1990, 1, 1, Constants.MIN_WORKTIME, 0, 0);
  
  CalendarContentWebCubit(this.context, Account user) : super(CalendarContentWebLoading(user)) {
    this.calcWidthOpeCalendar();
    horizontalCalendar.addListener(() { horizontalHeader.animateTo(horizontalCalendar.offset, curve: Curves.easeOut,
      duration: const Duration(milliseconds: 1));
    });
    horizontalHeader.addListener(() {
      horizontalCalendar.animateTo(horizontalHeader.offset, curve: Curves.easeOut,
          duration: const Duration(milliseconds: 1));
    });

  }

  void hoverCardEnter(DateTime selectDay, int index, Event event){
    bool expandedMode = context.read<WebCubit>().state.expandedMode;
    double sizeHeghtFromTop = calcWidgetHeightInGrid(selectDay,firstWorkedMinute: _baseFix.hour*60 + _baseFix.minute, end: event.start);
    double heightEvent = calcWidgetHeightInGrid(selectDay,start: event.start, end: event.end);
    double  _posLeft = (index) * state.widthOpeCalendar + 80 - horizontalCalendar.offset;
    double _posTop = sizeHeghtFromTop + heightEvent  + 50;
    if(_posTop + 100 > MediaQuery.of(context).size.height){
      _posTop = sizeHeghtFromTop + 100;
    }
    if(_posLeft + 220 + (expandedMode?200:70) > MediaQuery.of(context).size.width){
      _posLeft = (index) * state.widthOpeCalendar - horizontalCalendar.offset ;
    }
    emit(state.assign(showHoverContainer: true, posLeft: _posLeft, posTop: _posTop, eventHover: event));
  }

  void hoverCardExit(){
    emit(state.assign(showHoverContainer: false,));
    emit(state.assign( posLeft: 0, posTop: 120));
  }

  void calcWidthOpeCalendar(){
    bool expandedMode = context.read<WebCubit>().state.expandedMode;
    if(state.user.webops.isNotEmpty){
      emit(state.assign(widthOpeCalendar: max(150, (MediaQuery.of(context).size.width- (expandedMode?200:70) - 80)/state.user.webops.length)));
    }
  }

  double calcWidgetHeightInGrid(DateTime selectDay,{ DateTime? start, DateTime? end, int? firstWorkedMinute, int? lastWorkedMinute}) {
    return DateUtils.calcWidgetHeightInGrid(selectDay, 1, this.gridHourHeight,
        start: start, end: end, firstWorkedMinute: firstWorkedMinute , lastWorkedMinute: lastWorkedMinute );
  }
}
