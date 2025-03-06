WITH revenue AS
    (SELECT
        strftime('%m', o.order_delivered_customer_date) AS month_no,
        CASE
            WHEN strftime('%m', o.order_delivered_customer_date) = '01' THEN 'Jan'
            WHEN strftime('%m', o.order_delivered_customer_date) = '02' THEN 'Feb'
            WHEN strftime('%m', o.order_delivered_customer_date) = '03' THEN 'Mar'
            WHEN strftime('%m', o.order_delivered_customer_date) = '04' THEN 'Apr'
            WHEN strftime('%m', o.order_delivered_customer_date) = '05' THEN 'May'
            WHEN strftime('%m', o.order_delivered_customer_date) = '06' THEN 'Jun'
            WHEN strftime('%m', o.order_delivered_customer_date) = '07' THEN 'Jul'
            WHEN strftime('%m', o.order_delivered_customer_date) = '08' THEN 'Aug'
            WHEN strftime('%m', o.order_delivered_customer_date) = '09' THEN 'Sep'
            WHEN strftime('%m', o.order_delivered_customer_date) = '10' THEN 'Oct'
            WHEN strftime('%m', o.order_delivered_customer_date) = '11' THEN 'Nov'
            WHEN strftime('%m', o.order_delivered_customer_date) = '12' THEN 'Dec'
        END AS month,
        CASE WHEN strftime('%Y', o.order_delivered_customer_date) = "2016" THEN p.payment_value ELSE 0 END as revenue2016,
        CASE WHEN strftime('%Y', o.order_delivered_customer_date) = "2017" THEN p.payment_value ELSE 0 END as revenue2017,
        CASE WHEN strftime('%Y', o.order_delivered_customer_date) = "2018" THEN p.payment_value ELSE 0 END as revenue2018
    FROM olist_orders o, olist_order_payments p
    WHERE o.order_status == 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
        AND p.order_id == o.order_id
    GROUP BY o.order_id)
SELECT month_no, month, sum(revenue2016) as Year2016, sum(revenue2017) as Year2017, sum(revenue2018) as Year2018
FROM revenue
GROUP BY month_no
ORDER BY month_no;