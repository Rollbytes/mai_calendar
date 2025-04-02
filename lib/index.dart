/// Mai Calendar Library
///
/// Export all necessary components for easy import
library mai_calendar;

// Re-export everything from main.dart
export 'main.dart';

// Export repositories
export 'src/models/base_models.dart';
export 'src/models/calendar_models.dart' hide MaiCell;
export 'src/models/db_models.dart' hide MaiCell;
export 'src/repositories/calendar_repository.dart';
export 'src/repositories/data_source.dart';
export 'src/repositories/mai_calendar_data_source.dart';
