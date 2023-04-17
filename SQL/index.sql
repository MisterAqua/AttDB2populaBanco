-- selecionar o nome de todas as equipes que possuem jogadores com salário maior do que a média salarial dos jogadores de todas as equipes cadastradas
EXPLAIN ANALYSE SELECT e.nome
FROM equipe e
JOIN jogador_brasileiro j ON j.id_equipe = e.id
WHERE j.salario > (SELECT AVG(salario) FROM jogador_brasileiro);

CREATE INDEX jogador_salario_idx ON jogador_brasileiro (salario);
CREATE INDEX jogador_brasileiro_id_equipe_idx ON jogador_brasileiro (id_equipe);
SELECT pg_size_pretty(pg_relation_size('jogador_salario_idx'));
SELECT pg_size_pretty(pg_relation_size('jogador_brasileiro_id_equipe_idx'));

-- Selecionar o nome do campeonato, a posição do jogador e a média salarial dos jogadores de cada posição:
EXPLAIN ANALYSE SELECT campeonato.nome, jogador_brasileiro.posicao, AVG(jogador_brasileiro.salario) as media_salario
FROM campeonato
LEFT JOIN equipe ON campeonato.id = equipe.id
LEFT JOIN jogador_brasileiro ON equipe.id = jogador_brasileiro.id_equipe
GROUP BY campeonato.nome, jogador_brasileiro.posicao;

CREATE INDEX jogador_brasileiro_id_posicao_idx ON jogador_brasileiro (id, posicao);
SELECT pg_size_pretty(pg_relation_size('jogador_brasileiro_id_posicao_idx'));

-- Selecionar o nome do jogador, nome da equipe e nome do campeonato em que o jogador está jogando atualmente, ordenados pelo nome da equipe em ordem crescente
EXPLAIN ANALYSE SELECT j.nome AS nome_jogador, e.nome AS nome_equipe, c.nome AS nome_campeonato
FROM jogador_brasileiro j
JOIN equipe e ON j.id_equipe = e.id
JOIN campeonato c ON e.id = c.id
ORDER BY e.nome ASC;

CREATE INDEX equipe_nome_idx ON equipe (nome);