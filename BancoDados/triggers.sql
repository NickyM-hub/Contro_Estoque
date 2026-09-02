------------------
-- TRIGGERS
------------------

CREATE TRIGGER trg_atualizar_estoque_movimentacao
AFTER INSERT ON tb_movimentacao_estoque
FOR EACH ROW
EXECUTE FUNCTION fnc_atualizar_estoque_movimentacao();


CREATE TRIGGER trg_atualizar_status_produto
AFTER UPDATE ON tb_estoque
FOR EACH ROW
EXECUTE FUNCTION fnc_atualizar_status_produto();


CREATE TRIGGER trg_atualizar_pedido_estoque
AFTER UPDATE ON tb_pedidos
FOR EACH ROW
EXECUTE FUNCTION fnc_atualizar_pedido_estoque();


CREATE TRIGGER trg_auditoria_funcionario
AFTER UPDATE ON tb_funcionarios
FOR EACH ROW
EXECUTE FUNCTION fnc_auditoria_funcionario();


CREATE TRIGGER trg_auditoria_fornecedor
AFTER UPDATE ON tb_fornecedores
FOR EACH ROW
EXECUTE FUNCTION fnc_auditoria_fornecedor();


CREATE TRIGGER trg_alerta_estoque_baixo
AFTER UPDATE ON tb_estoque
FOR EACH ROW
EXECUTE FUNCTION fnc_alerta_estoque_baixo();


CREATE TRIGGER trg_validar_previsao_entrega
BEFORE INSERT OR UPDATE ON tb_pedidos
FOR EACH ROW
EXECUTE FUNCTION fnc_validar_previsao_entrega();


CREATE TRIGGER trg_validar_estoque_venda
BEFORE INSERT ON tb_itens_venda
FOR EACH ROW
EXECUTE FUNCTION fnc_validar_estoque_venda();