SELECT
  "Player",
  "Tm",
  COUNT(*) AS match_played,
  SUM("MP") AS total_mp,
  SUM("FG") AS total_fg,
  SUM("FGA") AS total_fg_attempt,
  -- Pourcentage de FG calculé à partir des totaux (pondéré par tentatives)
  ROUND(CASE WHEN SUM("FGA") = 0 THEN NULL
             ELSE SUM("FG")::numeric / NULLIF(SUM("FGA"),0)
        END, 4) AS fg_pct_weighted,
  -- Moyenne des pourcentages FG enregistrés par match (non pondérée)
  AVG("FG%") AS avg_fg_percentage,
  SUM("3P") AS total_3p,
  SUM("3PA") AS total_3p_attempt,
  ROUND(CASE WHEN SUM("3PA") = 0 THEN NULL
             ELSE SUM("3P")::numeric / NULLIF(SUM("3PA"),0)
        END, 4) AS threep_pct_weighted,
  AVG("3P%") AS avg_3p_percentage,
  SUM("FT") AS total_ft,
  SUM("FTA") AS total_ft_attempt,
  ROUND(CASE WHEN SUM("FTA") = 0 THEN NULL
             ELSE SUM("FT")::numeric / NULLIF(SUM("FTA"),0)
        END, 4) AS ft_pct_weighted,
  AVG("FT%") AS avg_ft_percentage,
  SUM("ORB") AS total_orb,
  SUM("DRB") AS total_drb,
  SUM("TRB") AS total_trb,
  SUM("AST") AS total_ast,
  SUM("STL") AS total_stl,
  SUM("BLK") AS total_blk,
  SUM("TOV") AS total_tov,
  SUM("PF") AS total_pf,
  SUM("PTS") AS total_pts
FROM public.nba_stats_2024_2025
GROUP BY "Player", "Tm"
-- Optionnel : ne conserver que les joueurs avec >= 5 matchs
-- HAVING COUNT(*) >= 5
ORDER BY total_pts DESC;
SELECT
  "Player",
  "Tm",
  COUNT(*) AS match_played,
  ROUND(SUM("MP")::NUMERIC,2) AS total_mp,
  SUM("FG") AS total_fg,
  SUM("FGA") AS total_fg_attempt,
  -- Pourcentage de FG calculé à partir des totaux (pondéré)
  ROUND(
    CASE WHEN SUM("FGA") = 0 THEN NULL
         ELSE SUM("FG")::numeric / NULLIF(SUM("FGA"),0)
    END
  , 2) AS fg_pct_weighted,
  -- Moyenne des pourcentages FG enregistrés par match (arrondie)
  ROUND(AVG("FG%")::numeric, 2) AS avg_fg_percentage,
  SUM("3P") AS total_3p,
  SUM("3PA") AS total_3p_attempt,
  ROUND(
    CASE WHEN SUM("3PA") = 0 THEN NULL
         ELSE SUM("3P")::numeric / NULLIF(SUM("3PA"),0)
    END
  , 2) AS threep_pct_weighted,
  ROUND(AVG("3P%")::numeric, 2) AS avg_3p_percentage,
  SUM("FT") AS total_ft,
  SUM("FTA") AS total_ft_attempt,
  ROUND(
    CASE WHEN SUM("FTA") = 0 THEN NULL
         ELSE SUM("FT")::numeric / NULLIF(SUM("FTA"),0)
    END
  , 2) AS ft_pct_weighted,
  ROUND(AVG("FT%")::numeric, 2) AS avg_ft_percentage,
  SUM("ORB") AS total_orb,
  SUM("DRB") AS total_drb,
  SUM("TRB") AS total_trb,
  SUM("AST") AS total_ast,
  SUM("STL") AS total_stl,
  SUM("BLK") AS total_blk,
  SUM("TOV") AS total_tov,
  SUM("PF") AS total_pf,
  SUM("PTS") AS total_pts
FROM public.nba_stats_2024_2025
GROUP BY "Player", "Tm"
ORDER BY total_pts DESC;
