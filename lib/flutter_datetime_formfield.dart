library flutter_datetime_formfield;

import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A date time pick form field widget.
class DateTimeFormField extends StatelessWidget {
  /// The initial date time, default value is null.
  final DateTime initialValue;

  /// Save value function of form field.
  final FormFieldSetter<DateTime> onSaved;

  /// Validate function of form field.
  final FormFieldValidator<DateTime> validator;

  /// Whether validate every time, default value is false.
  final bool autovalidate;
  final bool enabled;

  /// The label of form field, default value is 'Date Time'.
  final String label;

  /// The format of displaying date time in form field, default value is 'DateFormat("EE, MMM d, yyyy h:mma")' in date and time mode,
  /// 'DateFormat("EEE, MMM d, yyyy")' in date only mode,
  /// 'DateFormat("h:mm a") in time only mode.
  final DateFormat formatter;

  /// Only show and edit date, default value is false.
  final bool onlyDate;

  /// Only show and edit time, default value is false. [onlyDate] and [onlyTime] cannot be set to true at the same time.
  final bool onlyTime;

  /// The first date time of picking, default value is 'DateTime(1970)'.
  final DateTime firstDate;

  /// The last date time of picking, default value is 'DateTime(2100)'.
  final DateTime lastDate;

  /// Whether the iOS date picker should use 24-hour format or not, default is false
  final bool use24hFormat;

  /// If initialValue is null, the date time that is used to initialize the
  /// date picker, default value is DateTime.now().
  /// So if current value is not null, then selection interface will start with
  /// current value, otherwise it will look at initialSelectionValue, and if
  /// this is null, then it will start with DateTime.now()
  final DateTime initialSelectionValue;

  /// Text that appears in the form field when the value is null, default is
  /// 'Please pick a date/time'
  final String nullText;

  /// Whether it is possible to clear the current value and set it to null,
  /// default is false.
  final bool clearable;

  /// Create a DateTimeFormField.
  /// The [onlyDate] and [onlyTime] arguments can not be set to true at the same time.
  DateTimeFormField({
    @required this.initialValue,
    @required String label,
    DateFormat formatter,
    this.onSaved,
    this.validator,
    this.autovalidate: false,
    this.enabled: true,
    this.onlyDate: false,
    this.onlyTime: false,
    DateTime firstDate,
    DateTime lastDate,
    this.use24hFormat: false,
    DateTime initialSelectionValue,
    String nullText,
    bool clearable,
  })  : assert(!onlyDate || !onlyTime),
        label = label ?? "Date Time",
        formatter = formatter ??
            (onlyDate
                ? DateFormat("EEE, MMM d, yyyy")
                : (onlyTime
                    ? DateFormat("h:mm a")
                    : DateFormat("EE, MMM d, yyyy h:mma"))),
        firstDate = firstDate ?? DateTime(1970),
        lastDate = lastDate ?? DateTime(2100),
        initialSelectionValue = initialSelectionValue ?? DateTime.now(),
        nullText = nullText ?? 'Please pick a date/time',
        clearable = clearable ?? false;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      validator: validator,
      autovalidate: autovalidate,
      initialValue: initialValue,
      onSaved: onSaved,
      enabled: enabled,
      builder: (FormFieldState state) {
        return InkWell(
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: state.errorText,
              suffixIcon: clearable
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        state.didChange(null);
                      },
                    )
                  : null,
            ),
            child: Text(
                state.value != null ? formatter.format(state.value) : nullText),
          ),
          onTap: () async {
            DateTime date;
            TimeOfDay time = TimeOfDay(hour: 0, minute: 0);
            if (onlyDate) {
              if (Platform.isAndroid) {
                date = await showDatePicker(
                  context: context,
                  initialDate: state.value ?? initialSelectionValue,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );
                if (date != null) {
                  state.didChange(date);
                }
              } else {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext builder) {
                    return Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (DateTime dateTime) =>
                            state.didChange(dateTime),
                        initialDateTime: state.value ?? initialSelectionValue,
                        minimumYear: firstDate.year,
                        maximumYear: lastDate.year,
                      ),
                    );
                  },
                );
              }
            } else if (onlyTime) {
              if (Platform.isAndroid) {
                time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                      state.value ?? initialSelectionValue),
                );
                if (time != null) {
                  state.didChange(DateTime(
                    initialValue.year,
                    initialValue.month,
                    initialValue.day,
                    time.hour,
                    time.minute,
                  ));
                }
              } else {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext builder) {
                    return Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        onDateTimeChanged: (DateTime dateTime) =>
                            state.didChange(dateTime),
                        initialDateTime: state.value ?? initialSelectionValue,
                        use24hFormat: use24hFormat,
                        minuteInterval: 1,
                      ),
                    );
                  },
                );
              }
            } else {
              if (Platform.isAndroid) {
                date = await showDatePicker(
                  context: context,
                  initialDate: state.value ?? initialSelectionValue,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );
                if (date != null) {
                  time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                        state.value ?? initialSelectionValue),
                  );
                  if (time != null) {
                    state.didChange(DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ));
                  }
                }
              } else {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext builder) {
                    return Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        onDateTimeChanged: (DateTime dateTime) =>
                            state.didChange(dateTime),
                        initialDateTime: state.value ?? initialSelectionValue,
                        use24hFormat: false,
                        minuteInterval: 1,
                      ),
                    );
                  },
                );
              }
            }
          },
        );
      },
    );
  }
}
