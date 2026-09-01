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

