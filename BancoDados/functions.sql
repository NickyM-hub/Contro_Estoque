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


-- ATUALIZANDO STATUS DO PEDIDO
CREATE OR REPLACE FUNCTION fnc_atualizar_status_produto()
RETURNS TRIGGER AS $$
DECLARE
    v_limite_min       INTEGER;
    v_ativo            BOOLEAN;
    v_tem_pedido_ativo BOOLEAN;
BEGIN
    SELECT p.limite_min, p.ativo
    INTO v_limite_min, v_ativo
    FROM tb_produtos p
    WHERE p.id = NEW.id_produto;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto (id: %) não encontrado no banco.', NEW.id_produto;
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM tb_pedidos p
        JOIN tb_itens_pedido ip ON ip.id_pedido = p.id
        WHERE ip.id_produto = NEW.id_produto 
		AND p.status NOT IN ('Entregue')
    ) INTO v_tem_pedido_ativo;

    IF NOT v_ativo AND NEW.quantidade_produto = 0 AND NOT v_tem_pedido_ativo THEN
        UPDATE tb_produtos SET status = 'Esgotado'       
		WHERE id = NEW.id_produto;

    ELSIF NEW.quantidade_produto = 0 AND v_tem_pedido_ativo THEN
        UPDATE tb_produtos SET status = 'Indisponível'   
		WHERE id = NEW.id_produto;

    ELSIF NEW.quantidade_produto < v_limite_min THEN
        UPDATE tb_produtos SET status = 'Estoque Baixo'  
		WHERE id = NEW.id_produto;

    ELSE
        UPDATE tb_produtos SET status = 'Disponível'     
		WHERE id = NEW.id_produto;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


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
