-- =====================================================
-- BANCO DE DADOS - BAAP MOBILIDADE
-- =====================================================

CREATE DATABASE baap_mobilidade;
USE baap_mobilidade;

-- =====================================================
-- TABELA: usuarios
-- =====================================================

CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL,

    email VARCHAR(150) NOT NULL UNIQUE,

    senha_hash VARCHAR(255) NOT NULL,

    telefone VARCHAR(20),

    universidade VARCHAR(120) NOT NULL,

    curso VARCHAR(100),

    ra VARCHAR(30) UNIQUE,

    foto_perfil VARCHAR(255),

    tipo_usuario ENUM('PASSAGEIRO', 'MOTORISTA', 'AMBOS')
    DEFAULT 'PASSAGEIRO',

    email_validado BOOLEAN DEFAULT FALSE,

    avaliacao_media DECIMAL(2,1) DEFAULT 0.0,

    ativo BOOLEAN DEFAULT TRUE,

    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA: caronas
-- =====================================================

CREATE TABLE caronas (
    id_carona INT PRIMARY KEY AUTO_INCREMENT,

    id_motorista INT NOT NULL,

    origem VARCHAR(255) NOT NULL,

    destino VARCHAR(255) NOT NULL,

    latitude_origem DECIMAL(10,8),

    longitude_origem DECIMAL(11,8),

    latitude_destino DECIMAL(10,8),

    longitude_destino DECIMAL(11,8),

    horario_saida DATETIME NOT NULL,

    vagas_disponiveis INT NOT NULL,

    valor DECIMAL(6,2) DEFAULT 0.00,

    descricao TEXT,

    status_carona ENUM(
        'ATIVA',
        'LOTADA',
        'EM_ANDAMENTO',
        'FINALIZADA',
        'CANCELADA'
    ) DEFAULT 'ATIVA',

    compartilhamento_tempo_real BOOLEAN DEFAULT TRUE,

    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_motorista
        FOREIGN KEY (id_motorista)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
);

-- =====================================================
-- TABELA: solicitacoes_carona
-- =====================================================

CREATE TABLE solicitacoes_carona (
    id_solicitacao INT PRIMARY KEY AUTO_INCREMENT,

    id_carona INT NOT NULL,

    id_passageiro INT NOT NULL,

    status_solicitacao ENUM(
        'PENDENTE',
        'ACEITA',
        'RECUSADA',
        'CANCELADA'
    ) DEFAULT 'PENDENTE',

    mensagem TEXT,

    data_solicitacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_carona_solicitacao
        FOREIGN KEY (id_carona)
        REFERENCES caronas(id_carona)
        ON DELETE CASCADE,

    CONSTRAINT fk_passageiro
        FOREIGN KEY (id_passageiro)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
);

-- =====================================================
-- TABELA: notificacoes
-- =====================================================

CREATE TABLE notificacoes (
    id_notificacao INT PRIMARY KEY AUTO_INCREMENT,

    id_usuario INT NOT NULL,

    titulo VARCHAR(150) NOT NULL,

    mensagem TEXT NOT NULL,

    tipo ENUM(
        'SEGURANCA',
        'CARONA',
        'SISTEMA',
        'ALERTA'
    ) DEFAULT 'SISTEMA',

    visualizada BOOLEAN DEFAULT FALSE,

    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_usuario_notificacao
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
);

-- =====================================================
-- TABELA: linhas_onibus
-- =====================================================

CREATE TABLE linhas_onibus (
    id_linha INT PRIMARY KEY AUTO_INCREMENT,

    codigo_linha VARCHAR(20) NOT NULL UNIQUE,

    nome_linha VARCHAR(120) NOT NULL,

    origem VARCHAR(255),

    destino VARCHAR(255),

    status_operacao ENUM(
        'OPERANDO',
        'ATRASADA',
        'SUSPENSA'
    ) DEFAULT 'OPERANDO'
);

-- =====================================================
-- TABELA: localizacao_onibus
-- =====================================================

CREATE TABLE localizacao_onibus (
    id_localizacao INT PRIMARY KEY AUTO_INCREMENT,

    id_linha INT NOT NULL,

    latitude DECIMAL(10,8) NOT NULL,

    longitude DECIMAL(11,8) NOT NULL,

    lotacao ENUM(
        'BAIXA',
        'MEDIA',
        'ALTA'
    ) DEFAULT 'MEDIA',

    velocidade DECIMAL(5,2),

    horario_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_linha_onibus
        FOREIGN KEY (id_linha)
        REFERENCES linhas_onibus(id_linha)
        ON DELETE CASCADE
);

-- =====================================================
-- TABELA: avaliacoes
-- =====================================================

CREATE TABLE avaliacoes (
    id_avaliacao INT PRIMARY KEY AUTO_INCREMENT,

    id_avaliador INT NOT NULL,

    id_avaliado INT NOT NULL,

    id_carona INT NOT NULL,

    nota INT NOT NULL CHECK (nota BETWEEN 1 AND 5),

    comentario TEXT,

    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_avaliador
        FOREIGN KEY (id_avaliador)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_avaliado
        FOREIGN KEY (id_avaliado)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_carona_avaliacao
        FOREIGN KEY (id_carona)
        REFERENCES caronas(id_carona)
        ON DELETE CASCADE
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX idx_email_usuario
ON usuarios(email);

CREATE INDEX idx_status_carona
ON caronas(status_carona);

CREATE INDEX idx_horario_saida
ON caronas(horario_saida);

CREATE INDEX idx_localizacao
ON localizacao_onibus(latitude, longitude);

-- =====================================================
-- INSERTS EXEMPLO
-- =====================================================

INSERT INTO usuarios (
    nome,
    email,
    senha_hash,
    universidade,
    curso,
    tipo_usuario,
    email_validado
)
VALUES
(
    'Pedro Gabriel',
    'pedro.lemos@aluno.cps.sp.gov.br',
    '$2b$10$hashbcrypt',
    'FATEC',
    'Desenvolvimento de Sistemas',
    'AMBOS',
    TRUE
);

INSERT INTO caronas (
    id_motorista,
    origem,
    destino,
    horario_saida,
    vagas_disponiveis,
    valor
)
VALUES
(
    1,
    'Americana - Centro',
    'FATEC Americana',
    '2026-05-30 18:30:00',
    3,
    8.50
);

-- =====================================================
-- VIEW PARA CONSULTA DE CARONAS ATIVAS
-- =====================================================

CREATE VIEW vw_caronas_ativas AS
SELECT
    c.id_carona,
    u.nome AS motorista,
    c.origem,
    c.destino,
    c.horario_saida,
    c.vagas_disponiveis,
    c.valor,
    c.status_carona
FROM caronas c
INNER JOIN usuarios u
ON c.id_motorista = u.id_usuario
WHERE c.status_carona = 'ATIVA';

-- =====================================================
-- PROCEDURE PARA FINALIZAR CARONA
-- =====================================================

DELIMITER $$

CREATE PROCEDURE finalizar_carona(IN p_id_carona INT)
BEGIN
    UPDATE caronas
    SET status_carona = 'FINALIZADA'
    WHERE id_carona = p_id_carona;
END $$

DELIMITER ;

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================