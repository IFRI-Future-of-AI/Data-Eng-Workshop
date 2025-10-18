SELECT
  "Player",
  "Tm"           AS team,
  "Opp"          AS opponent,
  "Res",
  "Date",
  "MP",
  "FG",
  "FGA",
  "FG%",
  "3P",
  "3PA",
  "3P%",
  "FT",
  "FTA",
  "FT%",
  "ORB",
  "DRB",
  "TRB",
  "AST",
  "STL",
  "BLK",
  "TOV",
  "PF",
  "PTS",
  "GmSc",
  -- nombre de catégories >= 10 (PTS, TRB, AST, STL, BLK)
  (
    (CASE WHEN "PTS" >= 10 THEN 1 ELSE 0 END)
  + (CASE WHEN "TRB" >= 10 THEN 1 ELSE 0 END)
  + (CASE WHEN "AST" >= 10 THEN 1 ELSE 0 END)
  + (CASE WHEN "STL" >= 10 THEN 1 ELSE 0 END)
  + (CASE WHEN "BLK" >= 10 THEN 1 ELSE 0 END)
  ) AS categories_ge_10,
  -- liste des catégories qui sont >= 10
  CONCAT_WS(', ',
    CASE WHEN "PTS" >= 10 THEN 'PTS' END,
    CASE WHEN "TRB" >= 10 THEN 'TRB' END,
    CASE WHEN "AST" >= 10 THEN 'AST' END,
    CASE WHEN "STL" >= 10 THEN 'STL' END,
    CASE WHEN "BLK" >= 10 THEN 'BLK' END
  ) AS categories_list
FROM public.nba_stats_2024_2025
WHERE
  (
    (CASE WHEN "PTS" >= 10 THEN 1 ELSE 0 END)
  + (CASE WHEN "TRB" >= 10 THEN 1 ELSE 0 END)
  + (CASE WHEN "AST" >= 10 THEN 1 ELSE 0 END)
  + (CASE WHEN "STL" >= 10 THEN 1 ELSE 0 END)
  + (CASE WHEN "BLK" >= 10 THEN 1 ELSE 0 END)
  ) >= 3
ORDER BY "Player", "Date" DESC
