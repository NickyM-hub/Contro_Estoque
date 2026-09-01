-----------------------
-- PROCEDURES
-----------------------

-- REGISTRANDO PAGAMENTO
CREATE OR REPLACE PROCEDURE prc_registrar_pagamento (
    p_forma_pagamento FORMA_PAGAMENTO,
    p_juros 	NUMERIC(5,2),
    p_impostos 	NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN 
    INSERT INTO tb_pagamentos (forma_pagamento, juros, impostos) 
    VALUES (p_forma_pagamento, p_juros, p_impostos);

    RAISE NOTICE 'Registro feito com sucesso';

EXCEPTION
    WHEN others THEN 
        RAISE NOTICE 'Erro ao registrar forma de pagamento: %', SQLERRM;
END;
$$;


-- CADASTRANDO FORNECEDOR
CREATE OR REPLACE PROCEDURE prc_cadastar_fornecedor(
	p_cnpj 		VARCHAR(20),
	p_nome 		VARCHAR(150),
	p_telefone 	VARCHAR(20),
	p_email 	VARCHAR(100)	
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_fornecedores (cnpj, nome, telefone, email) 
    VALUES (p_cnpj, p_nome, p_telefone, p_email);

    RAISE NOTICE 'Fornecedor cadastrado com sucesso';

EXCEPTION
    WHEN others THEN 
        RAISE NOTICE 'Erro ao cadastrar fornecedor: %', SQLERRM;

END;
$$;


-- CADASTRANDO FUNCIONARIO
CREATE OR REPLACE PROCEDURE prc_cadastrar_funcionario(
	p_cpf 				CHAR(11),
	p_nome 				VARCHAR(100),
	p_salario 			NUMERIC(10,2),
	p_telefone 			VARCHAR(20),
	p_email 			VARCHAR(100),
	p_data_nascimento 	DATE,
	p_tipo_funcionario 	TIPO_FUNCIONARIO
)
LANGUAGE plpgsql
AS $$
BEGIN

	INSERT INTO tb_funcionarios (cpf, nome, salario, telefone, email, data_nascimento, tipo_funcionario)
	VALUES (p_cpf, p_nome, p_salario, p_telefone, p_email, p_data_nascimento, p_tipo_funcionario);
	RAISE NOTICE 'Funcionário cadastrado com sucesso';

EXCEPTION
	WHEN others THEN
		RAISE EXCEPTION 'Erro ao cadastrar funcionário: %', SQLERRM;

END;
$$;


-- CADASTRANDO CATEGORIA DO PRODUTO
CREATE OR REPLACE PROCEDURE prc_cadastrar_categoria_produto(
    p_nome_categoria VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_categorias_produtos (nome_categoria)
    VALUES (p_nome_categoria);
END;
$$;


-- CADASTRANDO COR DO PRODUTO
CREATE OR REPLACE PROCEDURE prc_cadastrar_cor_produto(
    p_nome_cor VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_cor_produto (nome_cor)
    VALUES (p_nome_cor);
END;
$$;


-- CADASTRANDO MARCA DO PRODUTO
CREATE OR REPLACE PROCEDURE prc_cadastrar_marca_produto(
    p_nome_marca VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_marca_produto (nome_marca)
    VALUES (p_nome_marca);
END;
$$;


-- CADASTRANDO TAMANHO DO PRODUTO
CREATE OR REPLACE PROCEDURE prc_cadastrar_tamanho_produto(
    p_tamanho VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_tamanho_produto (tamanho)
    VALUES (p_tamanho);
END;
$$;


-- CRIANDO PRODUTO
CREATE OR REPLACE PROCEDURE prc_cadastrar_produto(
    p_sku               VARCHAR(20),
    p_nome_produto      VARCHAR(100),
    p_id_marca          INTEGER,
    p_id_tamanho        INTEGER,
    p_id_cor            INTEGER,
    p_caract_especial   TEXT,
    p_codigo_barras     VARCHAR(50),
    p_status            STATUS_PRODUTO,
    p_preco_produto     NUMERIC(10,2),
    p_preco_custo       NUMERIC(10,2),
    p_limite_min        INTEGER,
    p_ativo             BOOLEAN DEFAULT TRUE
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_produtos (
        sku,
        nome_produto,
        id_marca,
        id_tamanho,
        id_cor,
        caract_especial,
        codigo_barras,
        status,
        preco_produto,
        preco_custo_produto,
        limite_min,
        ativo
    )
    VALUES (
        p_sku,
        p_nome_produto,
        p_id_marca,
        p_id_tamanho,
        p_id_cor,
        p_caract_especial,
        p_codigo_barras,
        p_status,
        p_preco_produto,
        p_preco_custo,
        p_limite_min,
        p_ativo
    );
	RAISE NOTICE 'Produto cadastrado com sucesso';

EXCEPTION
	WHEN others THEN
		RAISE EXCEPTION 'Erro ao cadastrar Produto: %', SQLERRM;
		
END;
$$;


-- REGISTRANDO ALERTA
CREATE OR REPLACE PROCEDURE prc_registrar_alerta(
    p_mensagem    TEXT,
    p_id_produto  INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_alertas (mensagem, id_produto)
    VALUES (p_mensagem, p_id_produto);
END;
$$;


-- REGISTRANDO PEDIDO
CREATE OR REPLACE PROCEDURE prc_registrar_pedido(
    p_previsao_entrega  DATE,
    p_cpf_funcionario   CHAR(11),
    p_cnpj_fornecedor   VARCHAR(20),
    p_valor_total       NUMERIC(10,2),
    p_id_pagamento      INTEGER,
    p_status            STATUS_PEDIDO DEFAULT 'Pendente'
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_pedidos (
        previsao_entrega,
        cpf_funcionario,
        cnpj_fornecedor,
        valor_total,
        id_pagamento,
        status
    )
    VALUES (
        p_previsao_entrega,
        p_cpf_funcionario,
        p_cnpj_fornecedor,
        p_valor_total,
        p_id_pagamento,
        p_status
    );
	RAISE NOTICE 'Pedido registrado com sucesso';

EXCEPTION
	WHEN others THEN
		RAISE EXCEPTION 'Erro ao registrar Pedido: %', SQLERRM;
END;
$$;


-- CADASTRANDO ITEM DO PEDIDO
CREATE OR REPLACE PROCEDURE prc_cadastrar_item_pedido(
    p_quantidade      INTEGER,
    p_preco_unitario  NUMERIC(10,2),
    p_id_pedido       INTEGER,
    p_id_produto      INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_itens_pedido (quantidade, preco_unitario, id_pedido)
    VALUES (p_quantidade, p_preco_unitario, p_id_pedido, p_id_produto);
END;
$$;


-- REGISTRANDO VENDA
CREATE OR REPLACE PROCEDURE prc_registrar_venda(
    p_cpf_funcionario  CHAR(11),
    p_valor_total      NUMERIC(10,2),
    p_id_pagamento     INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_vendas (cpf_funcionario, valor_total, id_pagamento)
    VALUES (p_cpf_funcionario, p_valor_total, p_id_pagamento);
	RAISE NOTICE 'Venda registrada com sucesso';

EXCEPTION
	WHEN others THEN
		RAISE EXCEPTION 'Erro ao registrar Venda: %', SQLERRM;
END;
$$;


-- CADASTRANDO ITEM DA VENDA
CREATE OR REPLACE PROCEDURE prc_cadastrar_item_venda(
    p_sku_vendido           VARCHAR(20),
    p_nome_produto_vendido  VARCHAR(100),
    p_quantidade            INTEGER,
    p_preco_unitario        NUMERIC(10,2),
    p_id_produto            INTEGER,
    p_id_venda              INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_itens_venda (
        sku_vendido,
        nome_produto_vendido,
        quantidade,
        preco_unitario,
        id_produto,
        id_venda
    )
    VALUES (
        p_sku_vendido,
        p_nome_produto_vendido,
        p_quantidade,
        p_preco_unitario,
        p_id_produto,
        p_id_venda
    );
END;
$$;


-- REGISTRANDO ESTOQUE
CREATE OR REPLACE PROCEDURE prc_registrar_estoque(
    p_id_produto          INTEGER,
    p_quantidade_produto  INTEGER,
    p_unidade_medida      UNI_MEDIDA    DEFAULT NULL,
    p_id_ultimo_pedido    INTEGER       DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_estoque (id_produto, quantidade_produto, unidade_medida, id_ultimo_pedido)
    VALUES (p_id_produto, p_quantidade_produto, p_unidade_medida, p_id_ultimo_pedido);
	RAISE NOTICE 'Produto adicionado ao Estoque';

EXCEPTION
	WHEN others THEN
		RAISE EXCEPTION 'Erro ao adicionar Produto: %', SQLERRM;
END;
$$;


-- REGISTRANDO MOVIMENTAÇÕES DO ESTOQUE
CREATE OR REPLACE PROCEDURE prc_cadastrar_movimentacao_estoque(
    p_observacao       TEXT,
    p_tipo             MOVIMENTACAO_ESTOQUE,
    p_quantidade       INTEGER,
    p_id_estoque       INTEGER,
    p_id_produto       INTEGER,
    p_cpf_funcionario  CHAR(11),
    p_id_pedido        INTEGER DEFAULT NULL,
    p_id_venda         INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO tb_movimentacao_estoque (
        observacao,
        tipo,
        quantidade,
        id_estoque,
        id_produto,
        cpf_funcionario,
        id_pedido,
        id_venda
    )
    VALUES (
   		p_observacao,
   		p_tipo,
   		p_quantidade,
   		p_id_estoque,
   		p_id_produto,
   		p_cpf_funcionario,
   		p_id_pedido,
   		p_id_venda
	);
END;
$$;
