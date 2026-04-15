-- =============================================================
-- SigaEdu - Script Principal
-- DDL, DCL e DML
-- =============================================================


-- =============================================================
-- SCHEMAS
-- =============================================================

CREATE SCHEMA IF NOT EXISTS academico;
CREATE SCHEMA IF NOT EXISTS seguranca;


-- =============================================================
-- DDL - Criação das tabelas
-- =============================================================

CREATE TABLE seguranca.operador_pedagogico (
    matricula_operador  VARCHAR(10)  NOT NULL,
    nome_operador       VARCHAR(100) NOT NULL,
    ativo               BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_operador PRIMARY KEY (matricula_operador)
);

CREATE TABLE academico.aluno (
    id_aluno            INT          NOT NULL,
    nome                VARCHAR(100) NOT NULL,
    email               VARCHAR(100) NOT NULL,
    endereco            VARCHAR(150),
    data_ingresso       DATE         NOT NULL,
    matricula_operador  VARCHAR(10)  NOT NULL,
    ativo               BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_aluno    PRIMARY KEY (id_aluno),
    CONSTRAINT fk_aluno_op FOREIGN KEY (matricula_operador)
        REFERENCES seguranca.operador_pedagogico (matricula_operador)
);

CREATE TABLE academico.docente (
    id_docente   SERIAL       NOT NULL,
    nome_docente VARCHAR(100) NOT NULL,
    ativo        BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_docente PRIMARY KEY (id_docente)
);

CREATE TABLE academico.disciplina (
    cod_disciplina  VARCHAR(10)  NOT NULL,
    nome_disciplina VARCHAR(100) NOT NULL,
    carga_horaria   INT          NOT NULL,
    id_docente      INT          NOT NULL,
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_disciplina     PRIMARY KEY (cod_disciplina),
    CONSTRAINT fk_disc_docente   FOREIGN KEY (id_docente)
        REFERENCES academico.docente (id_docente)
);

CREATE TABLE academico.matricula (
    id              SERIAL       NOT NULL,
    id_aluno        INT          NOT NULL,
    cod_disciplina  VARCHAR(10)  NOT NULL,
    ciclo_calendario VARCHAR(10) NOT NULL,
    score_final     NUMERIC(4,1),
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_matricula      PRIMARY KEY (id),
    CONSTRAINT fk_mat_aluno      FOREIGN KEY (id_aluno)
        REFERENCES academico.aluno (id_aluno),
    CONSTRAINT fk_mat_disciplina FOREIGN KEY (cod_disciplina)
        REFERENCES academico.disciplina (cod_disciplina)
);


-- =============================================================
-- DCL - Roles e permissões
-- =============================================================

-- Criar roles
CREATE ROLE professor_role;
CREATE ROLE coordenador_role;

-- coordenador_role: acesso total aos dois schemas
GRANT USAGE ON SCHEMA academico  TO coordenador_role;
GRANT USAGE ON SCHEMA seguranca  TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA seguranca TO coordenador_role;

-- professor_role: acesso de leitura ao schema academico (exceto coluna email)
GRANT USAGE ON SCHEMA academico TO professor_role;

GRANT SELECT ON academico.disciplina  TO professor_role;
GRANT SELECT ON academico.docente     TO professor_role;

-- Na tabela matricula: apenas leitura + update na coluna score_final
GRANT SELECT ON academico.matricula TO professor_role;
GRANT UPDATE (score_final) ON academico.matricula TO professor_role;

-- Na tabela aluno: leitura de todas as colunas EXCETO email (coluna a coluna)
GRANT SELECT (id_aluno, nome, endereco, data_ingresso, matricula_operador, ativo)
    ON academico.aluno TO professor_role;


-- =============================================================
-- DML - Inserção dos dados da planilha legada
-- =============================================================

-- Operadores pedagógicos
INSERT INTO seguranca.operador_pedagogico (matricula_operador, nome_operador) VALUES
    ('OP9001', 'Operador 9001'),
    ('OP9002', 'Operador 9002'),
    ('OP9003', 'Operador 9003'),
    ('OP9004', 'Operador 9004'),
    ('OP8999', 'Operador 8999'),
    ('OP9000', 'Operador 9000');

-- Docentes
INSERT INTO academico.docente (nome_docente) VALUES
    ('Prof. Carlos Mendes'),    -- id 1
    ('Profa. Juliana Castro'),  -- id 2
    ('Prof. Eduardo Pires'),    -- id 3
    ('Prof. Renato Alves'),     -- id 4
    ('Profa. Marina Lopes'),    -- id 5
    ('Prof. Ricardo Faria');    -- id 6

-- Disciplinas
INSERT INTO academico.disciplina (cod_disciplina, nome_disciplina, carga_horaria, id_docente) VALUES
    ('ADS101', 'Banco de Dados',          80, 1),
    ('ADS102', 'Engenharia de Software',  80, 2),
    ('ADS103', 'Algoritmos',              60, 4),
    ('ADS104', 'Redes de Computadores',   60, 5),
    ('ADS105', 'Sistemas Operacionais',   60, 3),
    ('ADS106', 'Estruturas de Dados',     80, 6);

-- Alunos
INSERT INTO academico.aluno (id_aluno, nome, email, endereco, data_ingresso, matricula_operador) VALUES
    (2026001, 'Ana Beatriz Lima',    'ana.lima@aluno.edu.br',          'Braganca Paulista/SP', '2026-01-20', 'OP9001'),
    (2026002, 'Bruno Henrique Souza','bruno.souza@aluno.edu.br',       'Atibaia/SP',           '2026-01-21', 'OP9002'),
    (2026003, 'Camila Ferreira',     'camila.ferreira@aluno.edu.br',   'Jundiai/SP',           '2026-01-22', 'OP9001'),
    (2026004, 'Diego Martins',       'diego.martins@aluno.edu.br',     'Campinas/SP',          '2026-01-23', 'OP9003'),
    (2026005, 'Eduarda Nunes',       'eduarda.nunes@aluno.edu.br',     'Itatiba/SP',           '2026-01-24', 'OP9002'),
    (2026006, 'Felipe Araujo',       'felipe.araujo@aluno.edu.br',     'Louveira/SP',          '2026-01-25', 'OP9004'),
    (2025010, 'Gabriela Torres',     'gabriela.torres@aluno.edu.br',   'Nazare Paulista/SP',   '2025-08-05', 'OP8999'),
    (2025011, 'Helena Rocha',        'helena.rocha@aluno.edu.br',      'Piracaia/SP',          '2025-08-06', 'OP8999'),
    (2025012, 'Igor Santana',        'igor.santana@aluno.edu.br',      'Jarinu/SP',            '2025-08-07', 'OP9000');

-- Matrículas
INSERT INTO academico.matricula (id_aluno, cod_disciplina, ciclo_calendario, score_final) VALUES
    (2026001, 'ADS101', '2026/1', 9.1),
    (2026001, 'ADS102', '2026/1', 8.4),
    (2026001, 'ADS105', '2026/1', 8.9),
    (2026002, 'ADS101', '2026/1', 7.3),
    (2026002, 'ADS103', '2026/1', 6.8),
    (2026002, 'ADS104', '2026/1', 7.0),
    (2026003, 'ADS101', '2026/1', 5.9),
    (2026003, 'ADS102', '2026/1', 7.5),
    (2026003, 'ADS106', '2026/1', 6.1),
    (2026004, 'ADS103', '2026/1', 4.7),
    (2026004, 'ADS104', '2026/1', 6.2),
    (2026004, 'ADS105', '2026/1', 5.8),
    (2026005, 'ADS102', '2026/1', 9.5),
    (2026005, 'ADS104', '2026/1', 8.1),
    (2026005, 'ADS106', '2026/1', 8.7),
    (2026006, 'ADS101', '2026/1', 6.4),
    (2026006, 'ADS103', '2026/1', 5.6),
    (2026006, 'ADS105', '2026/1', 6.9),
    (2025010, 'ADS101', '2025/2', 6.4),
    (2025010, 'ADS102', '2025/2', 7.1),
    (2025011, 'ADS103', '2025/2', 8.8),
    (2025011, 'ADS104', '2025/2', 7.9),
    (2025012, 'ADS105', '2025/2', 5.5),
    (2025012, 'ADS106', '2025/2', 6.3);


-- =============================================================
-- CONSULTAS E RELATÓRIOS
-- =============================================================

-- 1. Listagem de Matriculados no ciclo 2026/1
SELECT
    a.nome              AS aluno,
    d.nome_disciplina   AS disciplina,
    m.ciclo_calendario  AS ciclo
FROM academico.matricula m
JOIN academico.aluno     a ON a.id_aluno       = m.id_aluno
JOIN academico.disciplina d ON d.cod_disciplina = m.cod_disciplina
WHERE m.ciclo_calendario = '2026/1'
ORDER BY a.nome, d.nome_disciplina;


-- 2. Baixo Desempenho — alunos cuja média final seja inferior a 6.0
SELECT
    a.nome                       AS aluno,
    ROUND(AVG(m.score_final), 2) AS media
FROM academico.matricula m
JOIN academico.aluno     a ON a.id_aluno = m.id_aluno
GROUP BY a.nome
HAVING AVG(m.score_final) < 6.0
ORDER BY media;


-- 3. Alocação de Docentes — incluindo quem não tem turmas vinculadas
SELECT
    doc.nome_docente            AS docente,
    d.nome_disciplina           AS disciplina
FROM academico.docente   doc
LEFT JOIN academico.disciplina d ON d.id_docente = doc.id_docente
ORDER BY doc.nome_docente;


-- 4. Destaque Acadêmico — aluno com maior nota em Banco de Dados
SELECT
    a.nome        AS aluno,
    m.score_final AS nota
FROM academico.matricula  m
JOIN academico.aluno      a ON a.id_aluno        = m.id_aluno
JOIN academico.disciplina d ON d.cod_disciplina  = m.cod_disciplina
WHERE d.nome_disciplina = 'Banco de Dados'
  AND m.score_final = (
      SELECT MAX(m2.score_final)
      FROM academico.matricula  m2
      JOIN academico.disciplina d2 ON d2.cod_disciplina = m2.cod_disciplina
      WHERE d2.nome_disciplina = 'Banco de Dados'
  );
