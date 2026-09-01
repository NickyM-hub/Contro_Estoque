------------------
-- TYPES
------------------

CREATE TYPE TIPO_FUNCIONARIO AS ENUM (
    'Administrador',
    'Gerente',
    'Vendedor',
    'Estoquista',
    'Financeiro'
);


CREATE TYPE FORMA_PAGAMENTO AS ENUM (
    'Débito',
    'Crédito',
    'Pix',
    'Boleto',
    'Dinheiro'
);


CREATE TYPE STATUS_PEDIDO AS ENUM (
	'Pendente',
    'Em análise',
    'Confirmado',
    'Em separação',
    'Enviado',
    'Em rota de entrega',
    'Entregue'
);

	
CREATE TYPE STATUS_ALERTAS AS ENUM (
	'Pendente', 
	'Em análise', 
	'Resolvido', 
	'Ignorado'
);


CREATE TYPE STATUS_PRODUTO AS ENUM (
	'Disponível', 
	'Esgotado', 
	'Estoque baixo',
	'Inexistente',
	'Indísponível'
);
-- Disponível: Quando existe a quantidade do produto no estoque para a venda;

-- Indisponivel: quantidade insulficiente para a venda

-- Estoque baixo: Quando não possui a quantidade disponível, mas há, ou ainda vai ter, 
-- previsão de reabastecimento;

-- Esgotado: Quando não possui a quantidade disponível e não a previsão de reabastecimento 
-- (para produtos que não seram mais vendidos ou produzidos);

-- Inexistente: produto não encontrado no banco


CREATE TYPE UNI_MEDIDA AS ENUM (
	'Kg',
    'Gramas (G)', 
	'Unitário (UNI)',
    'Peça (PÇ)',
    'Pacote (PCT)',
    'Caixa (CX)', 
	'Litros (L)',
    'Metros (M)'
);


CREATE TYPE MOVIMENTACAO_ESTOQUE AS ENUM (
    'Entrada',
    'Saída',
    'Ajuste de Inventário'
);