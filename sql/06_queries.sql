-- Example queries over the bookmobile schema.

-- 1. Books with editions in at least three languages and no loan in any copy.
WITH multilingual AS (
    SELECT b.title, b.author, COUNT(DISTINCT e.language) AS languages
      FROM books b
      JOIN editions e ON e.title = b.title AND e.author = b.author
     GROUP BY b.title, b.author
    HAVING COUNT(DISTINCT e.language) >= 3
)
SELECT m.title, m.author, m.languages
  FROM multilingual m
 WHERE NOT EXISTS (SELECT 1
                     FROM editions e
                     JOIN copies c ON c.isbn = e.isbn
                     JOIN loans l ON l.signature = c.signature
                    WHERE e.title = m.title
                      AND e.author = m.author);

-- 2. Activity report per driver: age, years of service, years with services,
--    average stops and loans per active year, and share of loans not returned.
WITH driver_stops AS (
    SELECT passport,
           COUNT(*) AS stops,
           COUNT(DISTINCT EXTRACT(YEAR FROM task_date)) AS active_years
      FROM services
     GROUP BY passport
),
driver_loans AS (
    SELECT sv.passport,
           COUNT(*) AS loans,
           COUNT(CASE WHEN l.return_date IS NULL THEN 1 END) AS not_returned
      FROM services sv
      JOIN loans l
        ON l.town = sv.town AND l.province = sv.province AND l.stop_date = sv.task_date
     WHERE l.loan_type = 'L'
     GROUP BY sv.passport
)
SELECT d.fullname,
       TRUNC(MONTHS_BETWEEN(SYSDATE, d.birthdate) / 12) AS age,
       TRUNC(MONTHS_BETWEEN(LEAST(NVL(d.contract_end, SYSDATE), SYSDATE), d.contract_start) / 12) AS years_of_service,
       ds.active_years,
       ROUND(ds.stops / NULLIF(ds.active_years, 0), 2) AS avg_stops_per_year,
       ROUND(NVL(dl.loans, 0) / NULLIF(ds.active_years, 0), 2) AS avg_loans_per_year,
       ROUND(100 * dl.not_returned / NULLIF(dl.loans, 0), 1) AS pct_not_returned
  FROM drivers d
  LEFT JOIN driver_stops ds ON ds.passport = d.passport
  LEFT JOIN driver_loans dl ON dl.passport = d.passport
 ORDER BY d.fullname;

-- 3. The five most read books.
SELECT title, author, reads_count
  FROM books
 ORDER BY reads_count DESC, title
 FETCH FIRST 5 ROWS ONLY;

-- 4. Buses whose technical inspection (ITV) has expired.
SELECT plate, last_itv, next_itv, TRUNC(SYSDATE) - next_itv AS days_overdue
  FROM bibuses
 WHERE next_itv < TRUNC(SYSDATE)
 ORDER BY next_itv;

-- 5. Loans still out, by municipality.
SELECT l.town, l.province, COUNT(*) AS open_loans
  FROM loans l
 WHERE l.loan_type = 'L' AND l.return_date IS NULL
 GROUP BY l.town, l.province
 ORDER BY open_loans DESC, l.town;
