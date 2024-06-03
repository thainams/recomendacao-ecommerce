/*Criando uma tabela temporária para agilizar a consulta*/

CREATE TEMPORARY TABLE base AS 
	SELECT
		bp.product_id,
		bp.product_name,
		bd.department_id,
		bd.department,
		btdp.aisle_id,
		btdp.aisle,
		bc.user_id,
		bc.order_dow,
		bc.order_hour_of_day
	FROM 
		base_produtos bp
	JOIN base_compras bc 
		ON bp.product_id = bc.product_id 
	JOIN base_departamentos bd 
		ON bp.department_id = bd.department_id
	JOIN base_tipo_de_produto btdp 	
		ON bp.aisle_id =btdp.aisle_id 

/*Distribuição das vendas por departamento de produtos*/

/*SELECT * FROM base*/

WITH vendas_departamento AS (
	SELECT 
		department,
		COUNT(user_id) AS freq_absoluta,
		ROUND(CAST(COUNT(user_id) AS FLOAT)/(SELECT COUNT(*) FROM base)*100,1) AS freq_relativa
	FROM
		base
	GROUP BY
		department
	ORDER BY 
		freq_relativa ASC
)

SELECT 
	department,
	freq_absoluta,
	freq_relativa,
	ROUND(SUM(freq_relativa) OVER (ORDER BY freq_relativa ASC), 0) AS freq_acumulada
FROM 
	vendas_departamento 

/*Distribuição das vendas por dia da semana*/
	
/*SELECT * FROM base*/
	
WITH vendas_semana AS (
	SELECT
		order_dow,
		CASE 
			WHEN order_dow = 0 THEN 'domingo'
			WHEN order_dow = 1 THEN 'segunda'
			WHEN order_dow = 2 THEN 'terca'
			WHEN order_dow = 3 THEN 'quarta'
			WHEN order_dow = 4 THEN 'quinta'
			WHEN order_dow = 5 THEN 'sexta'
			WHEN order_dow = 6 THEN 'sabado'
		END AS dia_semana,
		COUNT(user_id) AS freq_absoluta,
		ROUND(CAST(COUNT(user_id) AS FLOAT)/(SELECT COUNT(*) FROM base)*100,2) AS freq_relativa
	FROM
		base
	GROUP BY
		order_dow
	ORDER BY 
		freq_relativa ASC
)

SELECT
	order_dow,
	dia_semana,
	freq_absoluta,
	freq_relativa,
	ROUND(SUM(freq_relativa) OVER (ORDER BY freq_relativa ASC), 0) AS freq_acumulada
FROM 
	vendas_semana

/*Distribuição das vendas por hora do dia*/
	
WITH vendas_hora AS (
	SELECT
		order_hour_of_day AS hora_do_dia,
		COUNT(user_id) AS freq_absoluta,
		ROUND(CAST(COUNT(user_id) AS FLOAT)/(SELECT COUNT(*) FROM base)*100,2) AS freq_relativa
	FROM
		base
	GROUP BY
		order_hour_of_day 
	ORDER BY 
		freq_relativa ASC
)

SELECT
	hora_do_dia,
	freq_absoluta,
	freq_relativa,
	ROUND(SUM(freq_relativa) OVER (ORDER BY freq_relativa ASC), 0) AS freq_acumulada
FROM 
	vendas_hora

/*Distribuição das vendas de departamentos por período*/
	
WITH vendas_departm_hora AS (
    SELECT
        department AS departamento,
        order_hour_of_day AS hora_do_dia,
        COUNT(user_id) AS freq_absoluta,
        ROUND(CAST(COUNT(user_id) AS FLOAT) / (SELECT COUNT(*) FROM base WHERE department = base.department) * 100, 2) AS freq_relativa
    FROM
        base
    GROUP BY
        department,
        order_hour_of_day 
    ORDER BY 
        department, order_hour_of_day
)

SELECT
    departamento,
    hora_do_dia,
    freq_absoluta,
    freq_relativa,
    ROUND(SUM(freq_relativa) OVER (PARTITION BY departamento ORDER BY hora_do_dia), 1) AS freq_acumulada
FROM 
    vendas_departm_hora
ORDER BY
    departamento, hora_do_dia;
  
/*Distribuição das vendas de departamentos por dia da semana*/

WITH vendas_departm_semana AS (
    SELECT
    	order_dow,
		CASE 
			WHEN order_dow = 0 THEN 'domingo'
			WHEN order_dow = 1 THEN 'segunda'
			WHEN order_dow = 2 THEN 'terca'
			WHEN order_dow = 3 THEN 'quarta'
			WHEN order_dow = 4 THEN 'quinta'
			WHEN order_dow = 5 THEN 'sexta'
			WHEN order_dow = 6 THEN 'sabado'
		END AS dia_semana,
        department AS departamento,
        COUNT(user_id) AS freq_absoluta,
        ROUND(CAST(COUNT(user_id) AS FLOAT) / (SELECT COUNT(*) FROM base WHERE department = base.department) * 100, 2) AS freq_relativa
    FROM
        base
    GROUP BY
        department,
        dia_semana
    ORDER BY 
        department, 
        dia_semana
)

SELECT
    departamento,
    dia_semana,
    freq_absoluta,
    freq_relativa,
    ROUND(SUM(freq_relativa) OVER (PARTITION BY departamento ORDER BY dia_semana), 1) AS freq_acumulada
FROM 
    vendas_departm_semana
ORDER BY
    departamento, 
   	dia_semana;   

 /*Ranking TOP 5 Produtos mais vendidos por departamento (com frequência relativa e acumulada)*/

WITH vendas_agrupadas AS (
    SELECT
        department AS departamento,
        product_name AS produto,
        COUNT(user_id) AS total_vendas_produto,
        ROUND(CAST(COUNT(user_id) AS FLOAT) / (SELECT COUNT(*) FROM base WHERE department = base.department) * 100,2) AS freq_relativa
    FROM
        base
    GROUP BY
        department, product_name
),
ranking AS (
    SELECT
        departamento,
        produto,
        total_vendas_produto,
        freq_relativa,
        RANK() OVER (PARTITION BY departamento ORDER BY total_vendas_produto DESC) AS rank
    FROM
        vendas_agrupadas
)
-- Filtramos os Top 5 de cada departamento
SELECT
    r.departamento,
    r.produto,
    r.freq_relativa,
    -- Calcula a frequência acumulada
    (SELECT SUM(freq_relativa)
     FROM ranking AS r2
     WHERE r2.departamento = r.departamento AND r2.rank <= r.rank) AS freq_acumulada,
    r.rank AS rank_top_5
FROM
    ranking AS r
WHERE
    r.rank <= 5
ORDER BY
    r.departamento, r.rank;
   
 
 SELECT
 	aisle,
 	order_hour_of_day 
 FROM 
 	base 
 GROUP BY
 	aisle,
 	order_hour_of_day
 	
/*Existe alguma concentração de tipo de produto por hora do dia em que é vendido? 
 * Ex: Pizza se compra a noite? Itens de café na parte da manhã?*/

 	
 WITH concentr_produto AS (
    SELECT
        department AS departamento,
        CASE
            WHEN order_hour_of_day BETWEEN 0 AND 12 THEN 'manhã'
            WHEN order_hour_of_day BETWEEN 13 AND 17 THEN 'tarde'
            ELSE 'noite'
        END AS periodo_dia,
        COUNT(user_id) AS freq_absoluta,
        ROUND(CAST(COUNT(user_id) AS FLOAT) / (SELECT COUNT(*) FROM base)*100,2) AS freq_relativa,
        ROUND(CAST(COUNT(user_id) AS FLOAT) / (SELECT COUNT(*) FROM base WHERE department = c.department)*100,2) AS freq_relativa_departamento
    FROM
        base c
    GROUP BY
        department,
        periodo_dia
    ORDER BY
        department,
        periodo_dia
)

SELECT
    departamento,
    periodo_dia,
    freq_absoluta,
    freq_relativa,
    freq_relativa_departamento,
    ROUND(SUM(freq_relativa) OVER (ORDER BY departamento, periodo_dia, freq_relativa DESC), 0) AS freq_acumulada
FROM 
    concentr_produto
ORDER BY
    departamento,
    periodo_dia,
    freq_relativa_departamento DESC,
    freq_relativa DESC


--Filtrando pelo período do dia para ver qual a concentração de vendas  

	
 WITH concentr_produto AS (
    SELECT
        department AS departamento,
        CASE
            WHEN order_hour_of_day BETWEEN 0 AND 12 THEN 'manhã'
            WHEN order_hour_of_day BETWEEN 13 AND 17 THEN 'tarde'
            ELSE 'noite'
        END AS periodo_dia,
        COUNT(user_id) AS freq_absoluta,
        ROUND(CAST(COUNT(user_id) AS FLOAT) / (SELECT COUNT(*) FROM base)*100,2) AS freq_relativa,
        ROUND(CAST(COUNT(user_id) AS FLOAT) / (SELECT COUNT(*) FROM base WHERE department = c.department)*100,2) AS freq_relativa_departamento
    FROM
        base c
    GROUP BY
        department,
        periodo_dia
    ORDER BY
        department,
        periodo_dia
)

SELECT
    departamento,
    freq_relativa
FROM 
    concentr_produto
WHERE
	periodo_dia = 'noite'
ORDER BY
	freq_relativa DESC

--Criando uma base de dados nova para fazer a análise de recomendação de produtos

CREATE TEMPORARY TABLE base_v2 AS 
	SELECT
		bp.product_id AS id_produto,
		bp.product_name AS produto,
		bc.user_id AS id_cliente
	FROM 
		base_produtos bp
	JOIN base_compras bc 
		ON bp.product_id = bc.product_id
		

 