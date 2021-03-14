import 'package:flutter/material.dart';
import 'package:venturiautospurghi/plugins/table_calendar/table_calendar.dart';
import 'package:venturiautospurghi/utils/theme.dart';

class TableCalendarWithBuilders extends StatelessWidget {
  late CalendarController _calendarController;
  
  TableCalendarWithBuilders(){
    _calendarController = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("CALENDARIO", style: title_rev,),
          backgroundColor: black,
        ),
        body: TableCalendar(
          rowHeight: 85,
          locale: 'it_IT',
          calendarController: _calendarController,
          initialCalendarFormat: CalendarFormat.month,
          formatAnimation: FormatAnimation.slide,
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableGestures: AvailableGestures.none,
          availableCalendarFormats: {CalendarFormat.month: ''},
          onDaySelected: (date, events) {
            Navigator.of(context).pop(date.toLocal().toString());
          },
          builders: CalendarBuilders(
            todayDayBuilder: (context, date, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                decoration: BoxDecoration(
                  color: grey_light,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Center(child: Text(
                    '${date.day}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333), fontSize: 18)
                ),
                ),
              );
            },
          ),
          headerStyle: HeaderStyle(
            leftChevronIcon: Icon(Icons.arrow_back_ios, color: black,),
            rightChevronIcon: Icon(Icons.arrow_forward_ios, color: black,),
          ),
        )
    );
  }

}
