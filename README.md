The database is built around five core entities:

Teams: The football clubs participating in the league.
Players: The individuals who play for the teams.
Stadiums: The venues where games are played.
Games: The individual matches played between two teams on a specific date.
Goals: The scoring events that occur within a game, credited to a player and team.


The following indexes are pre-defined to improve the performance of common queries:

idx_goals_game on goals(game_id): Speeds up lookups for all goals scored in a specific game.
idx_goals_player on goals(player_id): Quickly finds all goals scored by a particular player, essential for calculating top scorers.
idx_games_date on games(game_date): Efficiently queries for games played on a specific date or within a date range.