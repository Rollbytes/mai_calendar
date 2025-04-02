/// Mai Calendar Library
///
/// A calendar management library providing scheduling features
library mai_calendar;

import 'package:flutter/material.dart';

// Export core components
export 'src/calendar_bloc/calendar_bloc.dart';
export 'src/calendar_bloc/calendar_event.dart';
export 'src/calendar_bloc/calendar_state.dart';

// Export main widgets
export 'src/widgets/mai_calendar_widget.dart';
export 'src/widgets/mai_calendar_editor.dart';
export 'src/widgets/mai_calendar_events_of_day_view.dart';
export 'src/widgets/mai_calendar_appointment_builder.dart';
export 'src/widgets/mai_calendar_appointment_detail_view.dart';

// Export features
export 'src/feature/supabase_events/supabase_events_provider.dart';
export 'src/feature/sf_calendar_date_picker/sf_calendar_date_picker.dart';
export 'src/feature/time_selector/time_selector.dart';
export 'src/feature/space_selector/space_selector.dart';
export 'src/feature/calendar_search/calendar_search_bloc.dart';
export 'src/feature/calendar_search/calendar_search_result_view.dart';
export 'src/feature/calendar_sort/calendar_sort_bloc.dart';
export 'src/feature/sf_calendar_date_picker/sf_calendar_date_picker_cubit.dart';
export 'src/feature/sf_calendar_date_picker/sf_calendar_date_picker_state.dart';

// Export models without conflict
export 'src/models/base_models.dart';
export 'src/models/index.dart';

// Re-export specific types from models
export 'src/models/calendar_models.dart' hide MaiCell;
export 'src/models/db_models.dart' hide MaiCell;

/// MaiCalendar library main class
class MaiCalendar {
  /// Initialize the MaiCalendar library
  static void initialize() {
    // Initialization logic can be added here
  }

  /// Factory methods for creating cells are removed to avoid constructor issues
  /// Users should directly import specific models when needed
}
