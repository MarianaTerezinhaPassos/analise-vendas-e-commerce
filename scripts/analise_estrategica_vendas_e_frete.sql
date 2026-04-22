-- PROJETO: Inteligência de Mercado - E-commerce Brasil
-- OBJETIVO: Analisar o funil de faturamento, concentração regional, impacto logístico e sazonalidade.
-- AUTORA: Mariana
-- DATA: 2026

-- 1. VALIDAÇÃO DE DADOS E STATUS DE PEDIDO
-- O objetivo é identificar o faturamento real (apenas pedidos entregues).

SELECT TOP(100)*
FROM olist_orders_dataset

SELECT TOP(100) *
FROM Vendas_Gerais

-- Análise da saúde do funil: Distribuição de status dos pedidos

SELECT COUNT(order_status) AS Total_ordens, order_status
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY Total_ordens DESC

-- 2. ANÁLISE GEOGRÁFICA (Market Share por Estado)
-- Identificação de polos de consumo para direcionamento de investimentos.
-- Premissa: Faturamento real (order_status = 'delivered')

SELECT 
	COUNT(customer_state) AS Compras_por_Estado,
	customer_state,
	CONCAT(COUNT(*) * 100 / (SELECT COUNT(*) FROM Vendas_Gerais), '%') AS '% Total'
FROM Vendas_Gerais
WHERE order_status = 'delivered'
GROUP BY customer_state
ORDER BY COUNT(customer_state) DESC

-- 3. EFICIÊNCIA LOGÍSTICA (Custo de Frete por Região)
-- Avaliação do "freight-to-revenue" para identificar custos e oportunidades regionais.

SELECT 
	SUM(freight_value) AS Total,
	CONCAT(SUM(freight_value) * 100 / (SELECT SUM(freight_value) FROM Vendas_Gerais), '%') AS '% Total',
	customer_state
FROM Vendas_Gerais
WHERE order_status = 'delivered'
GROUP BY customer_state
ORDER BY SUM(freight_value) DESC

-- 4. PERFORMANCE POR CATEGORIA (Ticket Médio e Volume)
-- Identificação de categorias "estrelas" vs. categorias de baixo valor agregado.

SELECT 
	product_category_name AS categoria,
	COUNT(product_id) AS qtd_vendas, -- volume de itens
	ROUND(SUM(price) / COUNT(DISTINCT order_id), 2) AS ticket_medio 
FROM Vendas_Gerais
WHERE order_status = 'delivered' -- faturamento real
GROUP BY product_category_name
ORDER BY ticket_medio DESC -- ordenar primeiro pelo valor 

-- 5. IMPACTO DO FRETE NA MARGEM POR CATEGORIA
-- Análise de sensibilidade: onde o frete compromete a rentabilidade do produto?

SELECT 
	product_category_name AS categoria,
	COUNT(product_id) AS qtd_vendas, -- volume de itens
	ROUND(SUM(price), 2) AS faturamento_total,
	ROUND(SUM(freight_value), 2) AS frete_total,
	CONCAT(ROUND((SUM(freight_value) / SUM(price) * 100), 2), '%') AS '%_frete_sobre_venda'
FROM Vendas_Gerais
WHERE order_status = 'delivered' -- faturamento real
GROUP BY product_category_name
ORDER BY (SUM(freight_value) / SUM(price)) DESC

SELECT 
	product_category_name AS categoria,
	COUNT(product_id) AS qtd_vendas, -- volume de itens
	ROUND(SUM(price), 2) AS faturamento_total,
	ROUND(SUM(freight_value), 2) AS frete_total,
	CONCAT(ROUND((SUM(freight_value) / SUM(price) * 100), 2), '%') AS '%_frete_sobre_venda'
FROM Vendas_Gerais
WHERE order_status = 'delivered' -- faturamento real
GROUP BY product_category_name
ORDER BY qtd_vendas DESC -- identificar se há correlação entre qtd vendida e valor do frete (aparentemente, não)

-- 6. ANÁLISE DE SAZONALIDADE (Histórico Mensal)
-- Identificação de picos de demanda e tendências temporais de crescimento.
SELECT 
	COUNT(order_id) AS pedidos,
	ROUND(SUM(price), 2) AS faturamento,
	MONTH(order_purchase_timestamp) AS mês,
	YEAR(order_purchase_timestamp) AS ano
FROM Vendas_Gerais
WHERE order_status = 'delivered'
GROUP BY MONTH(order_purchase_timestamp), YEAR(order_purchase_timestamp)
ORDER BY ano, mês

-- Visualização final para conferência de tipos de dados

SELECT top(10) *
FROM Vendas_Gerais