WITH months AS (
    -- Generamos una tabla con los números de mes (01 a 12) y sus nombres abreviados
    SELECT '01' AS month_no, 'Jan' AS month UNION ALL
    SELECT '02', 'Feb' UNION ALL
    SELECT '03', 'Mar' UNION ALL
    SELECT '04', 'Apr' UNION ALL
    SELECT '05', 'May' UNION ALL
    SELECT '06', 'Jun' UNION ALL
    SELECT '07', 'Jul' UNION ALL
    SELECT '08', 'Aug' UNION ALL
    SELECT '09', 'Sep' UNION ALL
    SELECT '10', 'Oct' UNION ALL
    SELECT '11', 'Nov' UNION ALL
    SELECT '12', 'Dec'
),
revenue_data AS (
    -- Obtenemos los datos de ingresos por mes y año
    SELECT
        strftime('%m', o.order_purchase_timestamp) AS month_no, -- Mes (01 a 12)
        strftime('%Y', o.order_purchase_timestamp) AS year,     -- Año (2016, 2017, 2018)
        SUM(p.payment_value) AS revenue                         -- Ingresos por mes y año
    FROM olist_orders o
    JOIN olist_order_payments p ON o.order_id = p.order_id
    WHERE 
        o.order_status = 'delivered' AND -- Solo órdenes entregadas
        year IN ('2016', '2017', '2018') -- Filtramos por los años 2016, 2017 y 2018
    GROUP BY month_no, year
),
revenue_agg AS (
    -- Agregamos los ingresos por mes y año, usando COALESCE para manejar valores nulos
    SELECT
        month_no,
        COALESCE(SUM(CASE WHEN year = '2016' THEN revenue END), 0.00) AS Year2016,
        COALESCE(SUM(CASE WHEN year = '2017' THEN revenue END), 0.00) AS Year2017,
        COALESCE(SUM(CASE WHEN year = '2018' THEN revenue END), 0.00) AS Year2018
    FROM revenue_data
    GROUP BY month_no
)
-- Unimos los meses con los datos de ingresos y ordenamos por número de mes
SELECT
    m.month_no,
    m.month,
    r.Year2016 AS Year2016,  
    r.Year2017 AS Year2017,
    r.Year2018 AS Year2018
FROM months m
LEFT JOIN revenue_agg r ON m.month_no = r.month_no
ORDER BY m.month_no;