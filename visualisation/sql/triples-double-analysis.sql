SELECT
  "Tm",
  COUNT(*) AS row_count,
  ROUND(SUM("MP")::numeric, 2)       AS total_mp,
  ROUND(SUM("FG")::numeric, 2)       AS total_fg,
  ROUND(SUM("FGA")::numeric, 2)      AS total_fg_attempt,
  ROUND(
    CASE WHEN SUM("FGA") = 0 THEN NULL
         ELSE SUM("FG")::numeric / NULLIF(SUM("FGA"),0)
    END
  , 2)                                AS fg_pct_weighted,
  ROUND(AVG("FG%")::numeric, 2)      AS avg_fg_percentage,
  ROUND(SUM("3P")::numeric, 2)       AS total_3p,
  ROUND(SUM("3PA")::numeric, 2)      AS total_3p_attempt,
  ROUND(
    CASE WHEN SUM("3PA") = 0 THEN NULL
         ELSE SUM("3P")::numeric / NULLIF(SUM("3PA"),0)
    END
  , 2)                                AS threep_pct_weighted,
  ROUND(AVG("3P%")::numeric, 2)      AS avg_3p_percentage,
  ROUND(SUM("FT")::numeric, 2)       AS total_ft,
  ROUND(SUM("FTA")::numeric, 2)      AS total_ft_attempt,
  ROUND(
    CASE WHEN SUM("FTA") = 0 THEN NULL
         ELSE SUM("FT")::numeric / NULLIF(SUM("FTA"),0)
    END
  , 2)                                AS ft_pct_weighted,
  ROUND(AVG("FT%")::numeric, 2)      AS avg_ft_percentage,
  ROUND(SUM("ORB")::numeric, 2)      AS total_orb,
  ROUND(SUM("DRB")::numeric, 2)      AS total_drb,
  ROUND(SUM("TRB")::numeric, 2)      AS total_trb,
  ROUND(SUM("AST")::numeric, 2)      AS total_ast,
  ROUND(SUM("STL")::numeric, 2)      AS total_stl,
  ROUND(SUM("BLK")::numeric, 2)      AS total_blk,
  ROUND(SUM("TOV")::numeric, 2)      AS total_tov,
  ROUND(SUM("PF")::numeric, 2)       AS total_pf,
  ROUND(SUM("PTS")::numeric, 2)      AS total_pts
FROM public.nba_stats_2024_2025
GROUP BY "Tm"
ORDER BY total_pts DESC;
