/*Retorna o tempo de ANALYSE para o SELECT passado de parametro*/
CREATE OR REPLACE FUNCTION Time_ExecutionPlanning(select_query TEXT) RETURNS TABLE (planning_time TEXT, execution_time TEXT)
AS $$
DECLARE
  total TEXT;
BEGIN
  EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) ' || select_query INTO total;
  RETURN QUERY SELECT (total::jsonb)->0->>'Planning Time', (total::jsonb)->0->>'Execution Time';
END;
$$ LANGUAGE plpgsql;

/*Calcula a média de 10 execuções do SELECT passado de parametro e retorna o tempo de planning e o de execution*/
CREATE OR REPLACE FUNCTION media_execution_planning(sqlCodeText TEXT, QtdExecuções INTEGER) RETURNS TABLE(planning_time_avg NUMERIC, execution_time_avg NUMERIC)
AS $$
DECLARE
    totalPlanningTime NUMERIC := 0;
    totalExecutionTime NUMERIC := 0;
    planning_time_str TEXT;
    planning_time NUMERIC;
    exec_time_str TEXT;
    exec_time NUMERIC;
BEGIN
    FOR i IN 1..QtdExecuções LOOP
        SELECT * INTO planning_time_str, exec_time_str FROM Time_ExecutionPlanning(sqlCodeText);
        EXECUTE 'SELECT ' || regexp_replace(planning_time_str, '[^0-9\.]', '', 'g') INTO planning_time;
        EXECUTE 'SELECT ' || regexp_replace(exec_time_str, '[^0-9\.]', '', 'g') INTO exec_time;
        totalPlanningTime := totalPlanningTime + planning_time;
        totalExecutionTime := totalExecutionTime + exec_time;
    END LOOP;
    planning_time_avg := (totalPlanningTime/10);
    execution_time_avg := (totalExecutionTime/10);
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

--Media de tempo de execução/planejamento sem Index / Hash / Arvore B
SELECT * FROM media_execution_planning('SELECT * from jogador_brasileiro WHERE posicao = ''Atacante''', 100);

--Media de tempo de execução/planejamento com Index
CREATE INDEX ON jogador_brasileiro(posicao);
SELECT * FROM media_execution_planning('SELECT * from jogador_brasileiro WHERE posicao = ''Atacante''', 10);

--Media de tempo de execução/planejamento com Hash
CREATE INDEX ON jogador_brasileiro USING hash (posicao);
SELECT * FROM media_execution_planning('SELECT * from jogador_brasileiro WHERE posicao = ''Atacante''', 10);