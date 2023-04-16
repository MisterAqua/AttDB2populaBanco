CREATE TABLE Equipe (
  id INTEGER CONSTRAINT pk_equipe PRIMARY KEY,
  nome VARCHAR(32)
);

CREATE TABLE campeonato (
  id INTEGER CONSTRAINT pk_campeonato PRIMARY KEY,
  nome VARCHAR(32)
);

CREATE TABLE jogador_brasileiro (
  id INTEGER,
  cpf VARCHAR(16),
  nome VARCHAR(32),
  posicao VARCHAR(16),
  id_equipe INTEGER,
  salario NUMERIC(9,2),
  CONSTRAINT pk_jogador_brasileiro PRIMARY KEY (id),
  CONSTRAINT un_jogador_brasileiro_cpf UNIQUE (cpf),
  CONSTRAINT fk_jogador_brasileiro_id_eq FOREIGN KEY(id_equipe)
    REFERENCES equipe(id),
  CONSTRAINT ck_jogador_brasileiro_posicao 
    CHECK (posicao IN ('Goleiro', 'Lateral', 'Zagueiro', 'Meio-Campo', 'Atacante'))
);

CREATE TABLE jogador_estrangeiro (
  id INTEGER,
  passaporte VARCHAR(16),
  nome VARCHAR(32),
  posicao VARCHAR(16),
  id_equipe INTEGER,
  pais_origem VARCHAR(16),
  salario NUMERIC(9,2),
  CONSTRAINT pk_jogador_estrangeiro PRIMARY KEY (id),
  CONSTRAINT ck_jogador_estrangeiro_passap UNIQUE (passaporte),
  CONSTRAINT fk_jogador_estrangeiro_id_eq FOREIGN KEY(id_equipe)
    REFERENCES Equipe(id)
);

CREATE TABLE equipe_campeonato (
  id_equipe INTEGER,
  id_campeonato INTEGER,
  posicao NUMERIC,
  CONSTRAINT pk_equipe_campeonato PRIMARY KEY (id_equipe, id_campeonato),
  CONSTRAINT fk_equipe_campeonato_id_equipe FOREIGN KEY (id_equipe)
    REFERENCES equipe(id),
  CONSTRAINT fk_equipe_campeonato_idCamp FOREIGN KEY (id_campeonato)
    REFERENCES campeonato(id),
  CONSTRAINT ck_equipe_campeonato_posicao CHECK (posicao > 0)
);

CREATE TABLE cidade (
  id INTEGER,
  nome VARCHAR(32),
  CONSTRAINT pk_cidade PRIMARY KEY (id),
  CONSTRAINT un_cidade_nome UNIQUE (nome)
);

CREATE TABLE tecnico (
  id INTEGER,
  cpf VARCHAR(16),
  nome VARCHAR(32),
  id_equipe INTEGER,
  data_nasc DATE,
  CONSTRAINT pk_tecnico PRIMARY KEY (id),
  CONSTRAINT fk_tecnico_id_equipe FOREIGN KEY (id_equipe) 
    REFERENCES Equipe (id)
);
 
CREATE TABLE paises_tecnicos (
  id_tecnico INTEGER,
  pais VARCHAR(32),
  CONSTRAINT pk_paises_tecnicos PRIMARY KEY (id_tecnico, pais),
  CONSTRAINT fk_paises_tecnicos_id_tecnico FOREIGN KEY (id_tecnico)
    REFERENCES Tecnico(id)
);

CREATE TABLE jogo (
  id INTEGER,
  data_jogo DATE,
  id_equipe_casa INTEGER,
  id_equipe_fora INTEGER,
  gols_equipe_casa INTEGER,
  gols_equipe_fora INTEGER,
  id_cidade INTEGER,
  estadio VARCHAR(32),
  id_campeonato INTEGER,
  CONSTRAINT pk_jogo PRIMARY KEY (id),
  CONSTRAINT fk_jogo_equipe_casa FOREIGN KEY (id_equipe_casa)
    REFERENCES equipe (id),
  CONSTRAINT fk_jogo_equipe_fora FOREIGN KEY (id_equipe_fora)
    REFERENCES equipe (id),
  CONSTRAINT fk_jogo_cidade FOREIGN KEY (id_cidade)
    REFERENCES cidade (id),
  CONSTRAINT fk_jogo_campeonato FOREIGN KEY (id_campeonato)
    REFERENCES campeonato (id)
);

CREATE OR REPLACE VIEW ListaAtacantesBrasileiros AS
	SELECT * FROM jogador_brasileiro
		WHERE posicao like 'Atacante';
	
CREATE OR REPLACE VIEW Jogadores AS
	SELECT nome, posicao, id_equipe, pais_origem, salario
		FROM jogador_estrangeiro
	UNION
	SELECT nome, posicao, id_equipe, 'Brasil', salario
		FROM jogador_brasileiro;
		
CREATE OR REPLACE VIEW ListaAtacantesBrasileiros AS
	SELECT * FROM jogador_brasileiro
		WHERE posicao like 'Atacante'
		WITH LOCAL CHECK OPTION;
		
ALTER VIEW listaatacantesbrasileiros RENAME TO listaatacantesbrasileirosstop;
DROP VIEW listaatacantesbrasileirosstop;
	


/*CREATE OR REPLACE VIEW MediaPorPosicao (posicao, mediaSalario) AS
	SELECT j.posicao, AVG(j.salario) 
		FROM jogadores*/
		
  CREATE TABLE funcionarios
  (
    codigo integer NOT NULL,
    nome_func character varying(100) NOT NULL,
    data_entrada date,
    profissao character varying(100) NOT NULL,
    salario real,
    CONSTRAINT funcionarios_pkey PRIMARY KEY (codigo)
  );

  CREATE MATERIALIZED VIEW view_materializada_funcionario AS SELECT * FROM funcionarios WITH NO DATA;

  REFRESH MATERIALIZED VIEW view_materializada_funcionario;

  --SELECT * FROM view_materializada_funcionario;
  
  DROP MATERIALIZED VIEW view_materializada_funcionario;
  
  ----------------------------
  
CREATE TEMPORARY TABLE temp_resultados (exec_time numeric);

CREATE OR REPLACE FUNCTION media_execution_time() RETURNS numeric AS $$
DECLARE
    total numeric;
BEGIN
    SELECT AVG(exec_time) INTO total FROM temp_resultados;
    RETURN total;
END;
$$ LANGUAGE plpgsql;
  
/*CREATE OR REPLACE FUNCTION media_execution_time(sql_command text) RETURNS numeric AS $$
DECLARE
    total numeric;
BEGIN
    CREATE TEMPORARY TABLE temp_resultados (exec_time numeric);
    FOR i IN 1..10 LOOP
        INSERT INTO temp_resultados SELECT (EXPLAIN ANALYZE EXECUTE sql_command).total_time;
    END LOOP;
    SELECT AVG(exec_time) INTO total FROM temp_resultados;
    DROP TABLE temp_resultados;
    RETURN total;
END;
$$ LANGUAGE plpgsql;*/