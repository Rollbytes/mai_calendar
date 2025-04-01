import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../src/repositories/calendar_repository.dart';
import 'calendar_search_event.dart';
import 'calendar_search_state.dart';

/// 行事曆搜尋 Bloc
class CalendarSearchBloc extends Bloc<CalendarSearchEvent, CalendarSearchState> {
  final CalendarRepository _calendarRepository;

  CalendarSearchBloc({required CalendarRepository calendarRepository})
      : _calendarRepository = calendarRepository,
        super(CalendarSearchState.initial()) {
    on<LoadAllCalendarEvents>(_onLoadAllCalendarEvents);
    on<SearchTextChanged>(_onSearchTextChanged);
    on<ClearSearch>(_onClearSearch);
    on<StartSearch>(_onStartSearch);
    on<SearchCompleted>(_onSearchCompleted);
    on<SearchError>(_onSearchError);
  }

  /// 處理加載所有行事曆事件
  Future<void> _onLoadAllCalendarEvents(
    LoadAllCalendarEvents event,
    Emitter<CalendarSearchState> emit,
  ) async {
    emit(state.copyWith(status: CalendarSearchStatus.loading));

    try {
      final events = await _calendarRepository.getEvents(
        start: event.startDate,
        end: event.endDate,
      );

      emit(state.copyWith(
        status: CalendarSearchStatus.loaded,
        allEvents: events,
        searchResults: events, // 初始顯示所有事件
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CalendarSearchStatus.error,
        errorMessage: '載入行事曆事件失敗: ${error.toString()}',
        error: error,
      ));
    }
  }

  /// 處理搜尋文字變更
  Future<void> _onSearchTextChanged(
    SearchTextChanged event,
    Emitter<CalendarSearchState> emit,
  ) async {
    final searchText = event.searchText.trim();
    emit(state.copyWith(
      searchText: searchText,
      isSearching: searchText.isNotEmpty,
    ));

    if (searchText.isEmpty) {
      // 如果搜尋文字為空，恢復顯示所有事件
      emit(state.copyWith(
        searchResults: state.allEvents,
        status: CalendarSearchStatus.loaded,
      ));
      return;
    }

    // 開始搜尋
    add(StartSearch());
  }

  /// 處理開始搜尋
  Future<void> _onStartSearch(
    StartSearch event,
    Emitter<CalendarSearchState> emit,
  ) async {
    if (state.searchText.isEmpty || state.allEvents == null) {
      return;
    }

    emit(state.copyWith(status: CalendarSearchStatus.loading));

    try {
      // 執行搜尋
      final searchText = state.searchText.toLowerCase();
      final allEvents = state.allEvents!;

      final results = allEvents.where((event) {
        // 在標題中搜尋
        final titleMatch = event.title.toLowerCase().contains(searchText);

        // 在備註中搜尋
        final notesMatch = event.notes.toLowerCase().contains(searchText);

        // 在位置中搜尋
        final locationMatch = event.locationPath.toLowerCase().contains(searchText);

        // 在其他欄位中搜尋，如 baseName, boardName 等
        final boardMatch = event.boardName?.toLowerCase().contains(searchText) ?? false;
        final baseMatch = event.baseName?.toLowerCase().contains(searchText) ?? false;
        final tableMatch = event.tableName?.toLowerCase().contains(searchText) ?? false;

        return titleMatch || notesMatch || locationMatch || boardMatch || baseMatch || tableMatch;
      }).toList();

      add(SearchCompleted(results));
    } catch (error) {
      add(SearchError('搜尋過程中發生錯誤', error));
    }
  }

  /// 處理搜尋完成
  void _onSearchCompleted(
    SearchCompleted event,
    Emitter<CalendarSearchState> emit,
  ) {
    emit(state.copyWith(
      status: CalendarSearchStatus.loaded,
      searchResults: event.searchResults,
    ));
  }

  /// 處理搜尋錯誤
  void _onSearchError(
    SearchError event,
    Emitter<CalendarSearchState> emit,
  ) {
    emit(state.copyWith(
      status: CalendarSearchStatus.error,
      errorMessage: event.message,
      error: event.error,
    ));
  }

  /// 處理清除搜尋
  void _onClearSearch(
    ClearSearch event,
    Emitter<CalendarSearchState> emit,
  ) {
    emit(state.copyWith(
      searchText: '',
      isSearching: false,
      searchResults: state.allEvents,
      status: CalendarSearchStatus.loaded,
    ));
  }
}
