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
	'Estoque baixo'
);
-- Disponível: Quando existe a quantidade do produto no estoque para a venda;

-- Estoque baixo: Quando não possui a quantidade disponível, mas há, ou ainda vai ter, 
-- previsão de reabastecimento;

-- Esgotado: Quando não possui a quantidade disponível e não a previsão de reabastecimento 
-- (para produtos que não seram mais vendidos ou produzidos);


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


------------------
-- TABELAS
------------------

-- PAISES
CREATE TABLE tb_paises (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    codigo_iso CHAR(2) UNIQUE
);


-- ESTADOS
CREATE TABLE tb_estados (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    sigla CHAR(2) NOT NULL UNIQUE,
    id_pais INTEGER REFERENCES tb_paises(id)
);


-- CIDADES
CREATE TABLE tb_cidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    id_estado INTEGER REFERENCES tb_estados(id)
);


-- ENDEREÇOS
CREATE TABLE tb_enderecos (
    id SERIAL PRIMARY KEY,
    logradouro VARCHAR(250) NOT NULL,
    numero VARCHAR(20) DEFAULT 's/n',
    complemento VARCHAR(100) DEFAULT 's/c',
    bairro VARCHAR(100),
    cep VARCHAR(20) NOT NULL,
	id_cidade INTEGER NOT NULL,
	
	FOREIGN KEY (id_cidade) REFERENCES tb_cidades(id) ON DELETE CASCADE
);


-- PAGAMENTO
CREATE TABLE tb_pagamentos(
	id SERIAL PRIMARY KEY,
	forma_pagamento FORMA_PAGAMENTO NOT NULL,
	juros NUMERIC(5,2),
	impostos NUMERIC(5,2)
);


-- FORNECEDORES
CREATE TABLE tb_fornecedores (
    cnpj VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,  -- CORRIGIDO: era VARCHAR(20), muito curto para um nome
    telefone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);


-- FUNCIONÁRIOS
CREATE TABLE tb_funcionarios (
	cpf CHAR(11) PRIMARY KEY,
	nome VARCHAR(100) NOT NULL,
	salario NUMERIC(10, 2) CHECK (salario > 0),
	telefone VARCHAR(20) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE,
	data_nascimento DATE NOT NULL,
	tipo_funcionario TIPO_FUNCIONARIO NOT NULL
);


-- CATEGORIAS PARA PRODUTOS
CREATE TABLE tb_categorias_produtos (
    id SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(100) UNIQUE NOT NULL
);


-- COR DO PRODUTO
CREATE TABLE tb_cor_produto (
    id SERIAL PRIMARY KEY,
    nome_cor VARCHAR(100) NOT NULL UNIQUE
);


-- MARCA DO PRODUTO
CREATE TABLE tb_marca_produto (
    id SERIAL PRIMARY KEY,
    nome_marca VARCHAR(100) NOT NULL UNIQUE
);


-- TAMANHO DO PRODUTO
CREATE TABLE tb_tamanho_produto (
    id SERIAL PRIMARY KEY,
    tamanho VARCHAR(50) NOT NULL UNIQUE
);


-- PRODUTOS
CREATE TABLE tb_produtos (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(20) UNIQUE NOT NULL,
    nome_produto VARCHAR(100) NOT NULL,
	id_marca INTEGER NOT NULL,
    id_tamanho INTEGER NOT NULL,
    id_cor INTEGER NOT NULL,
    caract_especial TEXT NOT NULL,
    codigo_barras VARCHAR(50) UNIQUE NOT NULL,
    status STATUS_PRODUTO NOT NULL,
    preco_produto NUMERIC(10,2) NOT NULL
    CHECK (preco_produto > 0),
    preco_custo_produto NUMERIC(10,2)
    CHECK (preco_custo_produto > 0),
    limite_min INTEGER NOT NULL
	CHECK (limite_min >= 0),
    ativo BOOLEAN DEFAULT TRUE,
	UNIQUE (nome_produto, id_marca, id_cor, id_tamanho),

	FOREIGN KEY (id_marca) REFERENCES tb_marca_produto(id),
	FOREIGN KEY (id_cor) REFERENCES tb_cor_produto(id),
	FOREIGN KEY (id_tamanho) REFERENCES tb_tamanho_produto(id)
);


-- ALERTAS
CREATE TABLE tb_alertas (
    id SERIAL PRIMARY KEY,
	mensagem TEXT NOT NULL,
    data_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status STATUS_ALERTAS DEFAULT 'Pendente',
	id_produto INTEGER NOT NULL,
	
	FOREIGN KEY (id_produto) REFERENCES tb_produtos(id) ON DELETE CASCADE
);


-- PEDIDOS
CREATE TABLE tb_pedidos (
    id SERIAL PRIMARY KEY,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    previsao_entrega DATE NOT NULL,
    status STATUS_PEDIDO DEFAULT 'Pendente',
    cpf_funcionario CHAR(11) NOT NULL,
    cnpj_fornecedor VARCHAR(20) NOT NULL,
	valor_total NUMERIC(10, 2) NOT NULL
	CHECK (valor_total >= 0),
	id_pagamento INTEGER NOT NULL,

	FOREIGN KEY (id_pagamento) REFERENCES tb_pagamentos(id),
    FOREIGN KEY (cpf_funcionario) REFERENCES tb_funcionarios(cpf),
    FOREIGN KEY (cnpj_fornecedor) REFERENCES tb_fornecedores(cnpj)
);


-- ITENS PEDIDO  
CREATE TABLE tb_itens_pedido (
    id SERIAL PRIMARY KEY,
    quantidade INTEGER NOT NULL
	CHECK (quantidade > 0),
    preco_unitario NUMERIC(10,2) NOT NULL
	CHECK (preco_unitario >= 0),
    id_pedido INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,

    FOREIGN KEY (id_pedido) REFERENCES tb_pedidos(id),
    FOREIGN KEY (id_produto) REFERENCES tb_produtos(id)
);


-- VENDAS
CREATE TABLE tb_vendas (
    id SERIAL PRIMARY KEY,
    cpf_funcionario CHAR(11) NOT NULL,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	valor_total NUMERIC(10, 2) NOT NULL
	CHECK (valor_total >= 0),
	id_pagamento INTEGER NOT NULL,

	FOREIGN KEY (id_pagamento) REFERENCES tb_pagamentos(id),
    FOREIGN KEY (cpf_funcionario) REFERENCES tb_funcionarios(cpf)
);


-- ITENS VENDA
CREATE TABLE tb_itens_venda (
    id SERIAL PRIMARY KEY,
    sku_vendido VARCHAR(20),
    nome_produto_vendido VARCHAR(100),
	quantidade INTEGER NOT NULL
	CHECK (quantidade > 0),
    preco_unitario NUMERIC(10,2) NOT NULL
	CHECK (preco_unitario >= 0),
    id_produto INTEGER NOT NULL,
	id_venda INTEGER NOT NULL,
	
	FOREIGN KEY (id_produto) REFERENCES tb_produtos(id),
	FOREIGN KEY (id_venda) REFERENCES tb_vendas(id)
);


-- ESTOQUE
CREATE TABLE tb_estoque (
    id SERIAL PRIMARY KEY,
    id_produto INTEGER NOT NULL UNIQUE,
    quantidade_produto INTEGER NOT NULL
	CHECK (quantidade_produto >= 0),
    unidade_medida UNI_MEDIDA,
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	id_ultimo_pedido INTEGER,

	FOREIGN KEY (id_ultimo_pedido) REFERENCES tb_pedidos(id) ON DELETE SET NULL,
    FOREIGN KEY (id_produto) REFERENCES tb_produtos(id)
);


-- MOVIMENTAÇÃO DO ESTOQUE
CREATE TABLE tb_movimentacao_estoque (
    id SERIAL PRIMARY KEY,
	observacao TEXT NOT NULL,
    tipo MOVIMENTACAO_ESTOQUE NOT NULL,
    quantidade INTEGER NOT NULL
	CHECK (quantidade > 0),
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	id_estoque INTEGER NOT NULL,
	id_produto INTEGER NOT NULL,
	cpf_funcionario CHAR(11) NOT NULL,
    id_pedido INTEGER,
    id_venda INTEGER,

	FOREIGN KEY (cpf_funcionario) REFERENCES tb_funcionarios(cpf),
	FOREIGN KEY (id_estoque) REFERENCES tb_estoque(id),
	FOREIGN KEY (id_produto) REFERENCES tb_produtos(id),	
    FOREIGN KEY (id_pedido) REFERENCES tb_pedidos(id),
    FOREIGN KEY (id_venda) REFERENCES tb_vendas(id)
);


-----------------------------
-- TABELAS ASSOCIATIVAS
-----------------------------

-- categoria_produto
CREATE TABLE categoria_produto (
	id_categoria INTEGER NOT NULL,
	id_produto INTEGER NOT NULL,

	PRIMARY KEY (id_categoria, id_produto),	

	FOREIGN KEY (id_categoria) REFERENCES tb_categorias_produtos(id) ON DELETE CASCADE,
	FOREIGN KEY (id_produto) REFERENCES tb_produtos(id) ON DELETE CASCADE
);

-- funcionario_endereco
CREATE TABLE funcionario_endereco (
	cpf_funcionario CHAR(11) NOT NULL,
	id_endereco INTEGER NOT NULL,

	PRIMARY KEY (cpf_funcionario, id_endereco), 

	FOREIGN KEY (cpf_funcionario) REFERENCES tb_funcionarios(cpf) ON DELETE CASCADE,
	FOREIGN KEY (id_endereco) REFERENCES tb_enderecos(id) ON DELETE CASCADE
);

-- fornecedor_endereco
CREATE TABLE fornecedor_endereco (
	cnpj_fornecedor VARCHAR(20) NOT NULL,
	id_endereco INTEGER NOT NULL,

	PRIMARY KEY (cnpj_fornecedor, id_endereco), 

	FOREIGN KEY (cnpj_fornecedor) REFERENCES tb_fornecedores(cnpj) ON DELETE CASCADE,
	FOREIGN KEY (id_endereco) REFERENCES tb_enderecos(id) ON DELETE CASCADE
);

-- produto_fornecedor
CREATE TABLE produto_fornecedor (
	cnpj_fornecedor VARCHAR(20) NOT NULL,
	id_produto INTEGER NOT NULL,

	PRIMARY KEY (cnpj_fornecedor, id_produto),

	FOREIGN KEY (cnpj_fornecedor) REFERENCES tb_fornecedores(cnpj) ON DELETE CASCADE,
	FOREIGN KEY (id_produto) REFERENCES tb_produtos(id) ON DELETE CASCADE
);


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


------------------
-- TRIGGERS
------------------


-- ATUALIZANDO ESTOQUE APÓS MOVIMENTAÇÃO
CREATE OR REPLACE FUNCTION fnc_atualizar_estoque_movimentacao()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo = 'Entrada' THEN
        UPDATE tb_estoque
        SET quantidade_produto = quantidade_produto + NEW.quantidade,
            ultima_atualizacao = CURRENT_TIMESTAMP
        WHERE id_produto = NEW.id_produto;

    ELSIF NEW.tipo = 'Saída' THEN
        UPDATE tb_estoque
        SET quantidade_produto = quantidade_produto - NEW.quantidade,
            ultima_atualizacao = CURRENT_TIMESTAMP
        WHERE id_produto = NEW.id_produto;

    ELSIF NEW.tipo = 'Ajuste de Inventário' THEN
        UPDATE tb_estoque
        SET quantidade_produto = NEW.quantidade,
            ultima_atualizacao = CURRENT_TIMESTAMP
        WHERE id_produto = NEW.id_produto;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_estoque_movimentacao
AFTER INSERT ON tb_movimentacao_estoque
FOR EACH ROW
EXECUTE FUNCTION fnc_atualizar_estoque_movimentacao();


-- ATUALIZANDO STATUS DO PRODUTO
CREATE OR REPLACE FUNCTION fnc_atualizar_status_produto()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantidade_produto <= 0 THEN
        UPDATE tb_produtos
        SET status = 'Esgotado'
        WHERE id = NEW.id_produto;
    ELSE
        UPDATE tb_produtos
        SET status = 'Disponível'
        WHERE id = NEW.id_produto AND status = 'Esgotado';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_status_produto
AFTER UPDATE ON tb_estoque
FOR EACH ROW
EXECUTE FUNCTION fnc_atualizar_status_produto();


-- ATUALIZANDO ÚLTIMO PEDIDO NO ESTOQUE QUANDO PEDIDO FOR CONFIRMADO
CREATE OR REPLACE FUNCTION fnc_atualizar_pedido_estoque()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Confirmado' AND OLD.status <> 'Confirmado' THEN
        UPDATE tb_estoque e
        SET id_ultimo_pedido = NEW.id,
            ultima_atualizacao = CURRENT_TIMESTAMP
        FROM tb_itens_pedido ip
        WHERE ip.id_pedido = NEW.id
          AND e.id_produto = ip.id_produto;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_pedido_estoque
AFTER UPDATE ON tb_pedidos
FOR EACH ROW
EXECUTE FUNCTION fnc_atualizar_pedido_estoque();


-- ATUALIZAÇÕES DE FUNCIONÁRIO
CREATE OR REPLACE FUNCTION fnc_auditoria_funcionario()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Funcionário % atualizado em %', OLD.cpf, CURRENT_TIMESTAMP;
    RAISE NOTICE '  Nome: % → %',    OLD.nome,             NEW.nome;
    RAISE NOTICE '  Email: % → %',   OLD.email,            NEW.email;
    RAISE NOTICE '  Tipo: % → %',    OLD.tipo_funcionario, NEW.tipo_funcionario;
    RAISE NOTICE '  Salário: % → %', OLD.salario,          NEW.salario;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_funcionario
AFTER UPDATE ON tb_funcionarios
FOR EACH ROW
EXECUTE FUNCTION fnc_auditoria_funcionario();


-- ATUALIZAÇÕES DE FORNECEDOR
CREATE OR REPLACE FUNCTION fnc_auditoria_fornecedor()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Fornecedor % atualizado em %', OLD.cnpj, CURRENT_TIMESTAMP;
    RAISE NOTICE '  Nome: % → %',     OLD.nome,      NEW.nome;
    RAISE NOTICE '  Email: % → %',    OLD.email,     NEW.email;
    RAISE NOTICE '  Telefone: % → %', OLD.telefone,  NEW.telefone;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_fornecedor
AFTER UPDATE ON tb_fornecedores
FOR EACH ROW
EXECUTE FUNCTION fnc_auditoria_fornecedor();

-- PRINCIPAL!!!!!!!!!!!!!!!!!!!!!!!1
-- ALERTAR QUANDO PRODUTO ESTIVER ABAIXO DO LIMITE MÍNIMO
CREATE OR REPLACE FUNCTION fnc_alerta_estoque_baixo()
RETURNS TRIGGER AS $$
DECLARE
    v_limite_min   INTEGER;
    v_nome_produto VARCHAR(100);
BEGIN
    SELECT p.limite_min, p.nome_produto INTO v_limite_min, v_nome_produto
    FROM tb_produtos p WHERE p.id = NEW.id_produto;

    IF NEW.quantidade_produto <= v_limite_min THEN
        INSERT INTO tb_alertas (mensagem, id_produto)
        VALUES (
            'ALERTA: Produto "' || v_nome_produto || '" está abaixo do limite mínimo. ' ||
            'Quantidade atual: ' || NEW.quantidade_produto || ' | Limite mínimo: ' || v_limite_min,
            NEW.id_produto
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_alerta_estoque_baixo
AFTER UPDATE ON tb_estoque
FOR EACH ROW
EXECUTE FUNCTION fnc_alerta_estoque_baixo();


-- VERIFICAR PRAZO MÍNIMO DE 4 DIAS NA PREVISÃO DE ENTREGA DO PEDIDO
CREATE OR REPLACE FUNCTION fnc_validar_previsao_entrega()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.previsao_entrega < CURRENT_DATE + INTERVAL '4 days' THEN
        RAISE EXCEPTION 'A previsão de entrega deve ter no mínimo 4 dias.'
		RAISE EXCEPTION 'Data mínima permitida: %',
            (CURRENT_DATE + INTERVAL '4 days')::DATE;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_previsao_entrega
BEFORE INSERT OR UPDATE ON tb_pedidos
FOR EACH ROW
EXECUTE FUNCTION fnc_validar_previsao_entrega();


-- IMPEDIR VENDA SE QUANTIDADE EM ESTOQUE FOR INSUFICIENTE
CREATE OR REPLACE FUNCTION fnc_validar_estoque_venda()
RETURNS TRIGGER AS $$
DECLARE
    v_quantidade_estoque INTEGER;
    v_nome_produto       VARCHAR(100);
BEGIN
    SELECT e.quantidade_produto, p.nome_produto
    INTO v_quantidade_estoque, v_nome_produto
    FROM tb_estoque e
    JOIN tb_produtos p ON p.id = e.id_produto
    WHERE e.id_produto = NEW.id_produto;

    IF v_quantidade_estoque IS NULL THEN
        RAISE EXCEPTION 'Produto (id: %) não encontrado no estoque.', NEW.id_produto;
    END IF;

    IF NEW.quantidade > v_quantidade_estoque THEN
        RAISE EXCEPTION 'Estoque insuficiente para o produto "%". Disponível: % | Solicitado: %',
            v_nome_produto, v_quantidade_estoque, NEW.quantidade;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_estoque_venda
BEFORE INSERT ON tb_itens_venda
FOR EACH ROW
EXECUTE FUNCTION fnc_validar_estoque_venda();


----------------
-- VIEWS
----------------

-- PRODUTOS ABAIXO DO LIMITE MÍNIMO
CREATE OR REPLACE VIEW vw_produtos_abaixo_limite AS
SELECT
    p.id                    AS id_produto,
    p.sku,
    p.nome_produto,
    m.nome_marca            AS marca,
    c.nome_cor              AS cor,
    t.tamanho,
    p.status,
    p.limite_min            AS limite_minimo,
    e.quantidade_produto    AS quantidade_atual,
    (p.limite_min - e.quantidade_produto) AS diferenca,
    e.ultima_atualizacao
FROM tb_produtos p
JOIN tb_estoque e         ON e.id_produto    = p.id
JOIN tb_marca_produto m   ON m.id            = p.id_marca
JOIN tb_cor_produto c     ON c.id            = p.id_cor
JOIN tb_tamanho_produto t ON t.id            = p.id_tamanho
WHERE e.quantidade_produto <= p.limite_min
  AND p.ativo = TRUE
ORDER BY diferenca DESC;