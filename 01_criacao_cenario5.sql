-- 1. Tabela UNIDADES
CREATE TABLE UNIDADES (
    codigo INTEGER PRIMARY KEY,
    nome VARCHAR(100),
    endereco VARCHAR(200),
    municipio VARCHAR(100),
    telefone VARCHAR(20),
    horario_funcionamento VARCHAR(50),
    data_inauguracao DATE
);

-- 2. Tabela PROFISSIONAIS
CREATE TABLE PROFISSIONAIS (
    matricula INTEGER PRIMARY KEY,
    nome VARCHAR(100),
    cpf VARCHAR(14) UNIQUE,
    data_nascimento DATE,
    telefone VARCHAR(20),
    email VARCHAR(100),
    data_admissao DATE,
    tipo_vinculo VARCHAR(50),
    codigo_unidade INTEGER,
    FOREIGN KEY (codigo_unidade) REFERENCES UNIDADES (codigo)
);

-- 3. Tabela ADMINISTRACAO
CREATE TABLE ADMINISTRACAO (
    matricula_profissionais INTEGER PRIMARY KEY,
    setor VARCHAR(50),
    FOREIGN KEY (matricula_profissionais) REFERENCES PROFISSIONAIS (matricula)
);

-- 4. Tabela MEDICO
CREATE TABLE MEDICO (
    matricula_profissionais INTEGER PRIMARY KEY,
    crm VARCHAR(20) UNIQUE,
    uf_registro VARCHAR(2),
    FOREIGN KEY (matricula_profissionais) REFERENCES PROFISSIONAIS (matricula)
);

-- 5. Tabela ENFERMEIRO
CREATE TABLE ENFERMEIRO (
    matricula_profissionais INTEGER PRIMARY KEY,
    corem VARCHAR(20) UNIQUE,
    uf_respectivo VARCHAR(2),
    FOREIGN KEY (matricula_profissionais) REFERENCES PROFISSIONAIS (matricula)
);

-- 6. Tabela TECNICO
CREATE TABLE TECNICO (
    matricula_profissionais INTEGER PRIMARY KEY,
    registro_profissional VARCHAR(50) UNIQUE,
    area_atuacao VARCHAR(100),
    FOREIGN KEY (matricula_profissionais) REFERENCES PROFISSIONAIS (matricula)
);

-- 7. Tabela ESPECIALIDADE
CREATE TABLE ESPECIALIDADE (
    codigo INTEGER PRIMARY KEY,
    nome VARCHAR(100),
    conselho VARCHAR(50)
);

-- 8. Tabela MEDICO_ESPECIALIDADE
CREATE TABLE MEDICO_ESPECIALIDADE (
    matricula_medico INTEGER,
    codigo_especialidade INTEGER,
    PRIMARY KEY (matricula_medico, codigo_especialidade),
    FOREIGN KEY (matricula_medico) REFERENCES MEDICO (matricula_profissionais),
    FOREIGN KEY (codigo_especialidade) REFERENCES ESPECIALIDADE (codigo)
);

-- 9. Tabela PACIENTES
CREATE TABLE PACIENTES (
    cpf VARCHAR(14) PRIMARY KEY,
    nome VARCHAR(100),
    data_nascimento DATE,
    sexo VARCHAR(20),
    nome_mae VARCHAR(100),
    endereco VARCHAR(200),
    municipio VARCHAR(100),
    telefone VARCHAR(20),
    nome_responsavel VARCHAR(100)
);

-- 10. Tabela PRONTUARIO
CREATE TABLE PRONTUARIO (
    numero_prontuario INTEGER PRIMARY KEY,
    cpf_paciente VARCHAR(14),
    cns VARCHAR(20) UNIQUE,
    FOREIGN KEY (cpf_paciente) REFERENCES PACIENTES (cpf)
);

-- 11. Tabela EVOLUCAO
CREATE TABLE EVOLUCAO (
    seq_evolucao INTEGER PRIMARY KEY AUTOINCREMENT,
    numero_prontuario INTEGER,
    matricula_profissional INTEGER,
    data_hora DATETIME,
    peso DECIMAL(5,2),
    altura DECIMAL(3,2),
    frequencia_cardiaca INTEGER,
    temperatura DECIMAL(4,2),
    pressao VARCHAR(10),
    texto_evolucao TEXT,
    FOREIGN KEY (numero_prontuario) REFERENCES PRONTUARIO (numero_prontuario),
    FOREIGN KEY (matricula_profissional) REFERENCES PROFISSIONAIS (matricula)
);

-- 12. Tabela PLANOS
CREATE TABLE PLANOS (
    codigo INTEGER PRIMARY KEY,
    nome VARCHAR(100),
    tipo_acomodacao VARCHAR(50),
    abrangencia VARCHAR(50),
    prazo_carencia INTEGER,
    cnpj_operadora VARCHAR(18) NOT NULL,
    FOREIGN KEY (cnpj_operadora) REFERENCES OPERADORES (cnpj)
);

-- 13. Tabela POSSUI_PLANO
CREATE TABLE POSSUI_PLANO (
    numero_prontuario INTEGER,
    codigo_plano INTEGER,
    numero_carteirinha VARCHAR(50),
    data_inicio DATE,
    data_fim DATE,
    condicao VARCHAR(50),
    PRIMARY KEY (numero_prontuario, codigo_plano),
    FOREIGN KEY (numero_prontuario) REFERENCES PRONTUARIO (numero_prontuario),
    FOREIGN KEY (codigo_plano) REFERENCES PLANOS (codigo)
);

-- 14. Tabela OPERADORES
CREATE TABLE OPERADORES (
    cnpj VARCHAR(18) PRIMARY KEY,
    razao_social VARCHAR(150),
    registro_ans VARCHAR(50),
    contato_administrativo VARCHAR(100)
);

-- 15. Tabela SALAS
CREATE TABLE SALAS (
    numero_sala INTEGER PRIMARY KEY,
    capacidade INTEGER,
    equipamento VARCHAR(200)
);

-- 16. Tabela AGENDAMENTO
CREATE TABLE AGENDAMENTO (
    id_agendamento INTEGER PRIMARY KEY,
    data_marcacao DATE,
    data DATE,
    hora TIME,
    canal VARCHAR(50),
    forma_pagamento VARCHAR(50),
    situacao VARCHAR(50),
    data_cancelamento DATE,
    motivo_cancelamento TEXT,
    numero_sala INTEGER,
    matricula_administracao INTEGER,
    cpf_paciente VARCHAR(14),
    matricula_medico INTEGER,
    codigo_especialidade INTEGER,
    FOREIGN KEY (numero_sala) REFERENCES SALAS (numero_sala),
    FOREIGN KEY (matricula_administracao) REFERENCES ADMINISTRACAO (matricula_profissionais),
    FOREIGN KEY (cpf_paciente) REFERENCES PACIENTES (cpf),
    FOREIGN KEY (matricula_medico) REFERENCES MEDICO (matricula_profissionais),
    FOREIGN KEY (codigo_especialidade) REFERENCES ESPECIALIDADES (codigo)
);

-- 17. Tabela ATENDIMENTO
CREATE TABLE ATENDIMENTO (
    id_atendimento INTEGER PRIMARY KEY,
    id_agendamento INTEGER,
    hora_inicio TIME,
    hora_termino TIME,
    queixa_principal TEXT,
    teses_diagnosticas_CID TEXT,
    conduta TEXT,
    prazo_retorno INTEGER,
    FOREIGN KEY (id_agendamento) REFERENCES AGENDAMENTO (id_agendamento)
);

-- 18. Tabela PROCEDIMENTO_EXAME
CREATE TABLE PROCEDIMENTO_EXAME (
    codigo_TUSS VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(150),
    tipo VARCHAR(50),
    preparo_exigido TEXT,
    tempo_estimado TIME,
    cod_exame_princ VARCHAR(20),
    FOREIGN KEY (cod_exame_princ) REFERENCES PROCEDIMENTO_EXAME (codigo_TUSS
);

-- 19. Tabela SOLICITA
CREATE TABLE SOLICITA (
    id_atendimento INTEGER,
    codigo_TUSS_procedimento VARCHAR(20),
    data_solicitacao DATE,
    indicacao_clinica TEXT,
    carater VARCHAR(50),
    status_exame VARCHAR(20) DEFAULT 'Solicitado',
    PRIMARY KEY (id_atendimento, codigo_TUSS_procedimento),
    FOREIGN KEY (id_atendimento) REFERENCES ATENDIMENTO (id_atendimento),
    FOREIGN KEY (codigo_TUSS_procedimento) REFERENCES PROCEDIMENTO_EXAME (codigo_TUSS)
);

-- 20. Tabela MEDICAMENTOS
CREATE TABLE MEDICAMENTOS (
    codigo_medicamento INTEGER PRIMARY KEY,
    principio_ativo VARCHAR(150),
    nome_comercial VARCHAR(150),
    apresentacao VARCHAR(100),
    concentracao VARCHAR(50),
    tarja VARCHAR(50)
);

-- 21. Tabela PRESCREVE
CREATE TABLE PRESCREVE (
    id_atendimento INTEGER,
    codigo_medicamento INTEGER,
    seq_item INTEGER,
    quantidade INTEGER,
    posologia TEXT,
    duracao_tratamento VARCHAR(50),
    via_administracao VARCHAR(50),
    PRIMARY KEY (id_atendimento, codigo_medicamento, seq_item),
    FOREIGN KEY (id_atendimento) REFERENCES ATENDIMENTO (id_atendimento),
    FOREIGN KEY (codigo_medicamento) REFERENCES MEDICAMENTOS (codigo_medicamento)
);

-- 22. Tabela AGENDAS
CREATE TABLE AGENDAS (
    crm_medico VARCHAR(20),
    codigo_unidade INTEGER,
    dia_semana VARCHAR(20),
    hora_inicio TIME,
    hora_termino TIME,
    periodo_vigencia DATE,
    duracao_consulta TIME,
    PRIMARY KEY (crm_medico, codigo_unidade, dia_semana, hora_inicio),
    FOREIGN KEY (crm_medico) REFERENCES MEDICO (crm),
    FOREIGN KEY (codigo_unidade) REFERENCES UNIDADES (codigo)
);

-- 23. Tabela GUIAS
CREATE TABLE GUIAS (
    id_guia INTEGER PRIMARY KEY,
    id_atendimento INTEGER NOT NULL,
    cnpj_operadora VARCHAR(18) NOT NULL,
    competencia VARCHAR(7) NOT NULL,
    valor_apresentado DECIMAL(10, 2) NOT NULL,
    valor_pago DECIMAL(10, 2) NOT NULL,
    valor_glosado DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_atendimento) REFERENCES ATENDIMENTO (id_atendimento),
    FOREIGN KEY (cnpj_operadora) REFERENCES OPERADORES (cnpj)
);

-- 24. Tabela TABELA_PRECO
CREATE TABLE TABELA_PRECOS (
    id_preco INTEGER PRIMARY KEY,
    id_atendimento INTEGER NOT NULL,
    cnpj_operadora VARCHAR(18) NOT NULL,
    id_precos INTEGER NOT NULL,
    competencia VARCHAR(7) NOT NULL,
    valor_apresentado DECIMAL(10, 2) NOT NULL,
    valor_pago DECIMAL(10, 2) NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    data_vigencia DATE NOT NULL,
    FOREIGN KEY (id_atendimento) REFERENCES ATENDIMENTO (id_atendimento),
    FOREIGN KEY (cnpj_operadora) REFERENCES OPERADORES (cnpj),
    FOREIGN KEY (id_precos) REFERENCES TABELA_PRECOS (id_preco)
);
