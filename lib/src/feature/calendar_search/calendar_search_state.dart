import 'package:equatable/equatable.dart';
import '../../../src/models/index.dart';

/// 行事曆搜尋狀態的可能狀態
enum CalendarSearchStatus {
  initial, // 初始狀態
  loading, // 加載中
  loaded, // 加載完成
  error, // 發生錯誤
}

/// 行事曆搜尋狀態類
class CalendarSearchState extends Equatable {
  // 基本狀態
  final CalendarSearchStatus status;
  final String? errorMessage;
  final Object? error;

  // 搜尋相關資料
  final String searchText;
  final List<CalendarEvent> searchResults;
  final List<CalendarEvent>? allEvents;

  // 是否正在進行搜尋
  final bool isSearching;

  /// 創建行事曆搜尋狀態
  const CalendarSearchState({
    this.status = CalendarSearchStatus.initial,
    this.errorMessage,
    this.error,
    this.searchText = '',
    this.searchResults = const [],
    this.allEvents,
    this.isSearching = false,
  });

  /// 初始狀態
  factory CalendarSearchState.initial() => const CalendarSearchState(
        status: CalendarSearchStatus.initial,
        searchText: '',
        searchResults: [],
        isSearching: false,
      );

  /// 複製狀態
  CalendarSearchState copyWith({
    CalendarSearchStatus? status,
    String? errorMessage,
    Object? error,
    String? searchText,
    List<CalendarEvent>? searchResults,
    List<CalendarEvent>? allEvents,
    bool? isSearching,
  }) {
    return CalendarSearchState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
      searchText: searchText ?? this.searchText,
      searchResults: searchResults ?? this.searchResults,
      allEvents: allEvents ?? this.allEvents,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        error,
        searchText,
        searchResults,
        allEvents,
        isSearching,
      ];
}
