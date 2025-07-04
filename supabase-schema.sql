-- Schema do Supabase para Sigilosas VIP
-- Adaptado de MySQL para PostgreSQL

-- Remover tabelas existentes
DROP TABLE IF EXISTS acompanhante_servico CASCADE;
DROP TABLE IF EXISTS acompanhante_tag CASCADE;
DROP TABLE IF EXISTS avaliacoes CASCADE;
DROP TABLE IF EXISTS visualizacoes CASCADE;
DROP TABLE IF EXISTS fotos CASCADE;
DROP TABLE IF EXISTS documentos_acompanhante CASCADE;
DROP TABLE IF EXISTS videos_verificacao CASCADE;
DROP TABLE IF EXISTS acompanhantes CASCADE;
DROP TABLE IF EXISTS servicos CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS cidades CASCADE;
DROP TABLE IF EXISTS configuracoes CASCADE;

-- Remover tipos existentes
DROP TYPE IF EXISTS status_enum CASCADE;
DROP TYPE IF EXISTS genero_enum CASCADE;
DROP TYPE IF EXISTS etnia_enum CASCADE;
DROP TYPE IF EXISTS cor_olhos_enum CASCADE;
DROP TYPE IF EXISTS estilo_cabelo_enum CASCADE;
DROP TYPE IF EXISTS tamanho_cabelo_enum CASCADE;
DROP TYPE IF EXISTS foto_tipo_enum CASCADE;
DROP TYPE IF EXISTS documento_tipo_enum CASCADE;
DROP TYPE IF EXISTS dia_semana_enum CASCADE;

-- Criar tipos enumerados
CREATE TYPE status_enum AS ENUM ('pendente', 'aprovado', 'rejeitado', 'bloqueado');
CREATE TYPE genero_enum AS ENUM ('feminino', 'masculino', 'trans', 'outro');
CREATE TYPE etnia_enum AS ENUM ('branca', 'negra', 'parda', 'asiatica', 'indigena', 'outra');
CREATE TYPE cor_olhos_enum AS ENUM ('castanhos', 'azuis', 'verdes', 'pretos', 'outros');
CREATE TYPE estilo_cabelo_enum AS ENUM ('liso', 'ondulado', 'cacheado', 'crespo');
CREATE TYPE tamanho_cabelo_enum AS ENUM ('curto', 'medio', 'longo');
CREATE TYPE foto_tipo_enum AS ENUM ('perfil', 'galeria', 'verificacao');
CREATE TYPE documento_tipo_enum AS ENUM ('rg', 'cnh', 'selfie');
CREATE TYPE dia_semana_enum AS ENUM ('segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo');

-- Criar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tabela de cidades
CREATE TABLE cidades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(nome, estado)
);

-- Tabela principal de acompanhantes
CREATE TABLE acompanhantes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefone VARCHAR(15) NOT NULL UNIQUE,
    idade SMALLINT CHECK (idade >= 18),
    cidade_id UUID REFERENCES cidades(id),
    genero genero_enum NOT NULL,
    descricao TEXT,
    status status_enum DEFAULT 'pendente',
    verificado BOOLEAN DEFAULT false,
    destaque BOOLEAN DEFAULT false,
    etnia etnia_enum,
    altura DECIMAL(3,2),
    peso DECIMAL(5,2),
    cor_olhos cor_olhos_enum,
    estilo_cabelo estilo_cabelo_enum,
    tamanho_cabelo tamanho_cabelo_enum,
    silicone BOOLEAN DEFAULT false,
    tatuagens BOOLEAN DEFAULT false,
    piercings BOOLEAN DEFAULT false,
    fumante BOOLEAN DEFAULT false,
    idiomas TEXT,
    endereco TEXT,
    horario_atendimento TEXT,
    formas_pagamento TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de fotos
CREATE TABLE fotos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    acompanhante_id UUID REFERENCES acompanhantes(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    tipo foto_tipo_enum NOT NULL,
    ordem SMALLINT,
    ativa BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(acompanhante_id, ordem)
);

-- Tabela de documentos
CREATE TABLE documentos_acompanhante (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    acompanhante_id UUID REFERENCES acompanhantes(id) ON DELETE CASCADE,
    tipo documento_tipo_enum NOT NULL,
    url TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    verificado BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de vídeos de verificação
CREATE TABLE videos_verificacao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    acompanhante_id UUID REFERENCES acompanhantes(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    verificado BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de serviços
CREATE TABLE servicos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de relação acompanhante-serviço
CREATE TABLE acompanhante_servico (
    acompanhante_id UUID REFERENCES acompanhantes(id) ON DELETE CASCADE,
    servico_id UUID REFERENCES servicos(id) ON DELETE CASCADE,
    valor DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (acompanhante_id, servico_id)
);

-- Tabela de tags
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de relação acompanhante-tag
CREATE TABLE acompanhante_tag (
    acompanhante_id UUID REFERENCES acompanhantes(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (acompanhante_id, tag_id)
);

-- Tabela de avaliações
CREATE TABLE avaliacoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    acompanhante_id UUID REFERENCES acompanhantes(id) ON DELETE CASCADE,
    nota SMALLINT CHECK (nota >= 1 AND nota <= 5),
    comentario TEXT,
    ip_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de visualizações
CREATE TABLE visualizacoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    acompanhante_id UUID REFERENCES acompanhantes(id) ON DELETE CASCADE,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de configurações
CREATE TABLE configuracoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chave VARCHAR(50) NOT NULL UNIQUE,
    valor TEXT,
    descricao TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_acompanhantes_cidade ON acompanhantes(cidade_id);
CREATE INDEX idx_acompanhantes_status ON acompanhantes(status);
CREATE INDEX idx_acompanhantes_verificado ON acompanhantes(verificado);
CREATE INDEX idx_acompanhantes_destaque ON acompanhantes(destaque);
CREATE INDEX idx_fotos_acompanhante ON fotos(acompanhante_id);
CREATE INDEX idx_avaliacoes_acompanhante ON avaliacoes(acompanhante_id);
CREATE INDEX idx_visualizacoes_acompanhante ON visualizacoes(acompanhante_id);

-- Triggers para updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_acompanhantes_updated_at
    BEFORE UPDATE ON acompanhantes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_cidades_updated_at
    BEFORE UPDATE ON cidades
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_servicos_updated_at
    BEFORE UPDATE ON servicos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_configuracoes_updated_at
    BEFORE UPDATE ON configuracoes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Políticas de segurança RLS
ALTER TABLE acompanhantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE fotos ENABLE ROW LEVEL SECURITY;
ALTER TABLE documentos_acompanhante ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos_verificacao ENABLE ROW LEVEL SECURITY;
ALTER TABLE avaliacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE visualizacoes ENABLE ROW LEVEL SECURITY;

-- Política para acompanhantes
CREATE POLICY "Público pode ver acompanhantes aprovados"
    ON acompanhantes
    FOR SELECT
    USING (status = 'aprovado');

CREATE POLICY "Acompanhantes podem editar seus próprios dados"
    ON acompanhantes
    FOR ALL
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Admin pode fazer tudo"
    ON acompanhantes
    FOR ALL
    USING (auth.role() = 'admin');

-- Política para fotos
CREATE POLICY "Público pode ver fotos de acompanhantes aprovados"
    ON fotos
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM acompanhantes
            WHERE acompanhantes.id = fotos.acompanhante_id
            AND status = 'aprovado'
        )
    );

-- Função para limpeza de arquivos órfãos
CREATE OR REPLACE FUNCTION cleanup_orphaned_files()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Limpar fotos órfãs do storage
    DELETE FROM storage.objects
    WHERE bucket_id = 'images'
    AND path NOT IN (
        SELECT storage_path FROM fotos WHERE ativa = true
        UNION
        SELECT storage_path FROM documentos_acompanhante
        UNION
        SELECT storage_path FROM videos_verificacao
    );
END;
$$; 