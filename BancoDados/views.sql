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