part of 'players_cubit.dart';

@immutable
abstract class PlayersState {}

class PlayersLoading extends PlayersState {}
class PlayersLoaded extends PlayersState {
  final List<Player> players;
  final List<Player> selected;
  PlayersLoaded(this.players, this.selected);
}
class PlayersError extends PlayersState {
  final String message;
  PlayersError(this.message);
}class PlayersMaxLimitReached extends PlayersState {}