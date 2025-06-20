-- Criar função para executar SQL dinâmico
CREATE OR REPLACE FUNCTION execute_sql(sql text)
RETURNS void AS $$
BEGIN
  EXECUTE sql;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dar permissão para o service_role executar a função
GRANT EXECUTE ON FUNCTION execute_sql(text) TO service_role; 