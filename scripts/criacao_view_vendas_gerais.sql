-- OBJETIVO: Criação de View Unificada para Análise de Negócio.
-- DESCRIÇÃO: Consolida informações de Pedidos, Itens, Produtos, Clientes e Vendedores.
-- ESTRATÉGIA: Facilita o consumo de dados pelo Power BI e padroniza as métricas de preço e frete.

USE [Olist_Project]
GO

/****** Object:  View [dbo].[Vendas_Gerais]    Script Date: 15/04/2026 21:00:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Criando ou Alterando a View para consolidar a base de análise

ALTER VIEW [dbo].[Vendas_Gerais] AS
SELECT 
-- Ajuste de escala decimal para valores monetários
	(Itens.price / 100.0) AS price,
	(Itens.freight_value / 100.0) AS freight_value,
-- Dimensões Temporais e de Produto
	Pedidos.order_purchase_timestamp,
	Produtos.product_category_name,
-- Dimensões Geográficas (Crucial para análise de Market Share e Logística)
	Clientes.customer_state,
	Vendedores.seller_state,
-- Atributos de Controle e Chaves Primárias
	Pedidos.order_status,
	Pedidos.order_id,
	Produtos.product_id
FROM olist_order_items_dataset AS Itens
-- Relacionando Itens aos Detalhes dos Produtos
	JOIN olist_products_dataset AS Produtos 
		ON Itens.product_id = Produtos.product_id
-- Relacionando aos Vendedores para análise de origem
	JOIN olist_sellers_dataset AS Vendedores
		ON Vendedores.seller_id = Itens.seller_id
-- Unificando com Pedidos para obter Status e Timestamps
	JOIN olist_orders_dataset AS Pedidos
		ON Pedidos.order_id = Itens.order_id
-- Unificando com Clientes para obter localização do destino
	JOIN olist_customers_dataset AS Clientes
		ON Clientes.customer_id = Pedidos.customer_id
GO


