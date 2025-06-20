-- Criar função para executar SQL dinâmico
CREATE OR REPLACE FUNCTION execute_sql(sql text)
RETURNS void AS $$
BEGIN
  EXECUTE sql;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 