-- Liste de requêtes SQL pour le dashboard :

-- ● En excluant les commandes annulées, quelles sont les commandes récentes de moins de 3 mois que les clients ont reçues avec au moins 3 jours de retard ?
SELECT 
    o.order_id, 
    o.customer_id, 
    o.order_purchase_timestamp, 
    o.order_delivered_customer_date, 
    o.order_estimated_delivery_date
FROM 
    orders o
WHERE 
    order_status != 'canceled'
    AND order_purchase_timestamp >= date('now', '-3 months')
    AND order_delivered_customer_date > date(order_estimated_delivery_date, '+3 days');
-- > Ne retourne rien car dernière commande le 17-10-2018
SELECT MAX(order_purchase_timestamp) AS most_recent_date
FROM orders;

-- ● Qui sont les vendeurs ayant généré un chiffre d'affaires de plus de 100 000 Real sur des commandes livrées via Olist ?
SELECT 
    oi.seller_id,                                      
    SUM(oi.price * oi.order_item_id) AS total_revenue,  
    COUNT(oi.order_item_id) AS total_items_sold,      
    MIN(o.order_purchase_timestamp) AS first_order_date 
FROM 
    order_items oi                                    
JOIN 
    orders o ON oi.order_id = o.order_id              
WHERE 
    o.order_status = 'delivered'                      
    AND o.order_approved_at IS NOT NULL               
GROUP BY 
    oi.seller_id                                       
HAVING 
    total_revenue > 100000                             
ORDER BY 
    total_revenue DESC;                                
-- > 7c67e1448b00f6e969d365cea6b010ab	291135.46	1355	2017-01-26 22:44:11
--   53243585a1d6dc2643021fd1853d8905	240105.78	400	2017-08-28 18:29:21
--   4869f7a5dfa277a7dca6462dcf3b52b2	233143.81	1148	2017-03-14 10:20:54
--   4a3ca9315b744ce9f8e9374361493884	222829.32	1949	2017-01-08 09:35:14
--   da8622b14eb17ae2831f4ac5b9dab84a	196962.45	1548	2017-02-05 21:46:05
--   fa1c13f2614d7b5c4749cbc52fecda94	192478.24	579	2017-01-07 20:45:31
--   1025f0e2d44d7041d6cf58b6550e0bfa	189292.28	1420	2017-07-09 11:15:16
--   7e93a43ef30c4f03f38b393420bc753a	167329.47	322	2016-10-08 01:28:14
--   955fee9216a65b617aa5c0531780ce60	163635.28	1472	2017-07-24 11:33:53
--   1f50f920176fa81dab994f9023523100	162131.15	1926	2017-04-03 22:00:31
--   7a67c85e85bb2ce8582c35f2203ad736	141980.49	1152	2017-01-27 12:15:07
--   6560211a19b47992c3666cc44a7e94c0	130865.81	1996	2017-02-17 07:39:19
--   46dc3b2cc0980fb8ec44634e21d2718e	126697.12	523	2016-10-04 21:25:32
--   620c87c171fb2a6dd6e8bb4dec959fc6	119216.1	778	2016-10-04 13:15:46
--   7d13fca15225358621be4086e1eb0964	114999.39	571	2018-02-14 21:11:44
--   5dceca129747e92ff8ef7a997dc4f8ca	114622.88	343	2017-01-27 13:37:09
--   a1043bafd471dff536d0c462352beb48	107020.87	752	2017-02-14 10:44:33
--   cc419e0650a3c5ba77189a1882b7556a	104846.22	1719	2017-01-31 17:15:33

-- ● Qui sont les nouveaux vendeurs (moins de 3 mois d'ancienneté) qui sont déjà très engagés avec la plateforme (ayant déjà vendu plus de 30 produits) ?
SELECT 
    oi.seller_id, 
    COUNT(oi.order_item_id) AS total_items_sold, 
    MIN(o.order_purchase_timestamp) AS first_order_date
FROM 
    order_items oi
JOIN 
    orders o ON oi.order_id = o.order_id
GROUP BY 
    oi.seller_id
HAVING 
    julianday('2018-10-17') - julianday(first_order_date) < 90
    AND total_items_sold > 30;
-- > 81f89e42267213cb94da7ddc301651da	52	2018-08-08 12:45:12
--   d13e50eaa47b4cbe9eb81465865d8cfc	69	2018-08-04 09:09:37

-- ● Question : Quels sont les 5 codes postaux, enregistrant plus de 30 reviews, avec le pire review score moyen sur les 12 derniers mois ?

SELECT 
    c.customer_zip_code_prefix, 
    AVG(r.review_score) AS average_review_score, 
    COUNT(*) AS total_orders
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
JOIN 
    order_reviews r ON o.order_id = r.order_id
WHERE 
    julianday('2018-10-17') - julianday(o.order_purchase_timestamp) <= 365
GROUP BY 
    c.customer_zip_code_prefix
HAVING 
    total_orders > 30
ORDER BY 
    average_review_score ASC
LIMIT 5;
-- > 22753	2.8085106382978724	47
--   22770	3.135135135135135	37
--   22793	3.2333333333333334	90
--   21321	3.2777777777777777	36
--   22780	3.3513513513513513	37