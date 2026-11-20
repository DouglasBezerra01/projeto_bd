-- 1. UNIDADES
INSERT INTO UNIDADES (codigo, nome, endereco, municipio, telefone, horario_funcionamento, data_inauguracao) VALUES
(1, 'Unidade Central de Saúde', 'Av. Principal, 1000 - Centro', 'Recife', '(81) 3333-1000', '07:00 às 22:00', '2015-03-10'),
(2, 'Clínica Zona Sul', 'Rua das Flores, 450 - Boa Viagem', 'Recife', '(81) 3333-2000', '08:00 às 18:00', '2019-08-22');

-- 2. PROFISSIONAIS (Base para Administração, Médico, Enfermeiro e Técnico)
INSERT INTO PROFISSIONAIS (matricula, nome, cpf, data_nascimento, telefone, email, data_admissao, tipo_vinculo, codigo_unidade) VALUES
(101, 'Carlos Eduardo Silva', '111.111.111-11', '1985-04-12', '(81) 99999-1111', 'carlos.silva@clinica.com', '2018-01-15', 'CLT', 1),
(102, 'Dra. Mariana Costa', '222.222.222-22', '1980-09-25', '(81) 99999-2222', 'mariana.costa@clinica.com', '2016-05-10', 'PJ', 1),
(103, 'Dr. Roberto Almeida', '333.333.333-33', '1978-11-03', '(81) 99999-3333', 'roberto.almeida@clinica.com', '2020-02-01', 'PJ', 2),
(104, 'Fernanda Lima', '444.444.444-44', '1990-07-19', '(81) 99999-4444', 'fernanda.lima@clinica.com', '2019-11-12', 'CLT', 1),
(105, 'João Pedro Santos', '555.555.555-55', '1995-02-28', '(81) 99999-5555', 'joao.santos@clinica.com', '2021-06-20', 'CLT', 2),
(106, 'Dr. Henrique Vasconcelos', '666.666.666-66', '1982-03-14', '(81) 99999-6666', 'henrique.v@clinica.com', '2022-04-10', 'cooperado', 1);

-- 3. ADMINISTRACAO
INSERT INTO ADMINISTRACAO (matricula_profissionais, setor) VALUES
(101, 'Recepção e Agendamento');

-- 4. MEDICO
INSERT INTO MEDICO (matricula_profissionais, crm, uf_registro) VALUES
(102, '12345-PE', 'PE'),
(103, '67890-PE', 'PE'),
(106, '54321-PE', 'PE');

-- 5. ENFERMEIRO
INSERT INTO ENFERMEIRO (matricula_profissionais, corem, uf_respectivo) VALUES
(104, '98765-ENF', 'PE');

-- 6. TECNICO
INSERT INTO TECNICO (matricula_profissionais, registro_profissional, area_atuacao) VALUES
(105, 'TEC-54321', 'Radiologia e Exames de Imagem');

-- 7. ESPECIALIDADE
INSERT INTO ESPECIALIDADE (codigo, nome, conselho) VALUES
(1, 'Cardiologia', 'CRM'),
(2, 'Clínica Geral', 'CRM'),
(3, 'Ortopedia', 'CRM');

-- 8. MEDICO_ESPECIALIDADE
INSERT INTO MEDICO_ESPECIALIDADE (matricula_medico, codigo_especialidade) VALUES
(102, 1),
(102, 2),
(103, 3),
(106, 1);

-- 9. PACIENTES
INSERT INTO PACIENTES (cpf, nome, data_nascimento, sexo, nome_mae, endereco, municipio, telefone, nome_responsavel) VALUES
('777.777.777-77', 'Ana Beatriz Souza', '1992-06-15', 'Feminino', 'Maria das Graças Souza', 'Rua do Sol, 120', 'Recife', '(81) 98888-1111', 'Carlos Souza'),
('888.888.888-88', 'Marcos Vinícius Oliveira', '1975-12-08', 'Masculino', 'Helena Oliveira', 'Av. Boa Vista, 890', 'Recife', '(81) 98888-2222', 'Roberto Oliveira'),
('999.999.999-99', 'Juliana Mendes', '2001-03-30', 'Feminino', 'Cláudia Mendes', 'Rua da Aurora, 45', 'Olinda', '(81) 98888-3333', NULL),
('101.101.101-10', 'Lucas Gabriel Ferreira', '2012-05-14', 'Masculino', 'Patrícia Ferreira', 'Rua das Acácias, 78', 'Recife', '(81) 98888-4444', 'Patrícia Ferreira'),
('202.202.202-20', 'Sofia Ribeiro Lima', '2016-09-22', 'Feminino', 'Camila Ribeiro', 'Av. Conselheiro Aguiar, 310', 'Jaboatão dos Guararapes', '(81) 98888-5555', 'Ricardo Lima');

-- 10. PRONTUARIO
INSERT INTO PRONTUARIO (numero_prontuario, cpf_paciente, cns) VALUES
(1001, '777.777.777-77', '700001112223334'),
(1002, '888.888.888-88', '700004445556667'),
(1003, '999.999.999-99', '700007778889990'),
(1004, '101.101.101-10', '700009998887771'),
(1005, '202.202.202-20', '700009998887772');

-- 11. EVOLUCAO (seq_evolucao é AUTOINCREMENT, não precisa informar)
INSERT INTO EVOLUCAO (numero_prontuario, matricula_profissional, data_hora, peso, altura, frequencia_cardiaca, temperatura, pressao, texto_evolucao) VALUES
(1001, 104, '2026-11-10 08:30:00', 62.50, 1.65, 76, 36.50, '120/80', 'Paciente relata leve cansaço aos esforços. Sinais vitais estáveis.'),
(1002, 102, '2026-11-12 10:15:00', 84.00, 1.78, 82, 36.80, '140/90', 'Paciente hipertenso em acompanhamento regular. Orientado sobre dieta hipossódica.');

-- 12. PLANOS
INSERT INTO PLANOS (codigo, nome, tipo_acomodacao, abrangencia, prazo_carencia, cnpj_operadora) VALUES
(10, 'Saúde Total Ouro', 'Apartamento', 'Nacional', 30, '12.345.678/0001-99'),
(20, 'Plano Básico Regional', 'Enfermaria', 'Estadual', 60, '98.765.432/0001-11');

-- 13. POSSUI_PLANO
INSERT INTO POSSUI_PLANO (numero_prontuario, codigo_plano, numero_carteirinha, data_inicio, data_fim, condicao) VALUES
(1001, 10, 'CART-998877', '2024-01-01', '2027-01-01', 'Ativo'),
(1002, 20, 'CART-112233', '2023-05-15', '2026-12-31', 'Ativo');

-- 14. OPERADORES
INSERT INTO OPERADORES (cnpj, razao_social, registro_ans, contato_administrativo) VALUES
('12.345.678/0001-99', 'Operadora Saúde Brasil S.A.', 'ANS-345678', 'contato@saudebrasil.com.br'),
('98.765.432/0001-11', 'Vida Plena Assistência Médica Ltda', 'ANS-987654', 'convenios@vidaplena.com.br');

-- 15. SALAS
INSERT INTO SALAS (numero_sala, capacidade, equipamento) VALUES
(1, 3, 'Maca, Estetoscópio, Esfigmomanômetro, Computador'),
(2, 4, 'Maca ortopédica, Negatoscópio, Computador'),
(3, 2, 'Aparelho de Eletrocardiograma, Maca');

-- 16. AGENDAMENTO
INSERT INTO AGENDAMENTO (id_agendamento, data_marcacao, data, hora, canal, forma_pagamento, situacao, data_cancelamento, motivo_cancelamento, numero_sala, matricula_administracao, cpf_paciente, matricula_medico, codigo_especialidade) VALUES
(501, '2026-11-05', '2026-11-10', '09:00:00', 'WhatsApp', 'Convênio', 'Realizado', NULL, NULL, 1, 101, '777.777.777-77', 102, 1),
(502, '2026-11-08', '2026-11-12', '10:30:00', 'Presencial', 'Convênio', 'Realizado', NULL, NULL, 1, 101, '888.888.888-88', 102, 2),
(503, '2026-11-10', '2026-11-15', '14:00:00', 'Telefone', 'Particular', 'Cancelado', '2026-11-14', 'Imprevisto pessoal do paciente', 2, 101, '999.999.999-99', 103, 3),
(504, '2026-11-10', '2026-11-16', '08:30:00', 'WhatsApp', 'Convênio', 'faltou', NULL, NULL, 1, 101, '101.101.101-10', 106, 1),
(505, '2026-11-12', '2026-11-17', '15:00:00', 'Telefone', 'Particular', 'faltou', NULL, NULL, 2, 101, '202.202.202-20', 103, 3),
(506, '2026-08-25', '2026-09-01', '09:00:00', 'Presencial', 'Convênio', 'Realizado', NULL, NULL, 1, 101, '777.777.777-77', 102, 1),
(507, '2026-09-10', '2026-09-20', '09:30:00', 'WhatsApp', 'Convênio', 'Realizado', NULL, NULL, 1, 101, '777.777.777-77', 102, 2),
(508, '2026-08-01', '2026-08-10', '11:00:00', 'Presencial', 'Convênio', 'Realizado', NULL, NULL, 2, 101, '999.999.999-99', 103, 3),
(509, '2026-10-01', '2026-10-05', '10:00:00', 'WhatsApp', 'Convênio', 'Realizado', NULL, NULL, 2, 101, '777.777.777-77', 103, 3);

-- 17. ATENDIMENTO
INSERT INTO ATENDIMENTO (id_atendimento, id_agendamento, hora_inicio, hora_termino, queixa_principal, teses_diagnosticas_CID, conduta, prazo_retorno) VALUES
(901, 501, '09:05:00', '09:35:00', 'Fadiga e palpitações ocasionais', 'R00.2 - Palpitações', 'Solicitado eletrocardiograma e exames laboratoriais de rotina.', 30),
(902, 502, '10:32:00', '11:00:00', 'Dor no joelho direito após caminhada', 'M25.5 - Dor articular', 'Prescrito anti-inflamatório e solicitado raio-X.', 15),
(903, 506, '09:05:00', '09:30:00', 'Acompanhamento de pressão alta', 'I10 - Hipertensão essencial', 'Ajuste de medicação e retorno em 30 dias.', 30),
(904, 507, '09:35:00', '09:55:00', 'Retorno para avaliação de pressão arterial', 'I10 - Hipertensão essencial', 'Pressão controlada. Manter medicação.', NULL),
(905, 508, '11:05:00', '11:30:00', 'Dor lombar persistente', 'M54.5 - Dor lombar baixa', 'Fisioterapia e retorno em 15 dias.', 15),
(906, 509, '10:05:00', '10:30:00', 'Dor no ombro direito', 'M75 - Lesões do ombro', 'Solicitado ultrassom.', 15);

-- 18. PROCEDIMENTO_EXAME (Inserindo exame principal antes do dependente por causa do auto-relacionamento)
INSERT INTO PROCEDIMENTO_EXAME (codigo_TUSS, nome, tipo, preparo_exigido, tempo_estimado, cod_exame_princ) VALUES
('40101010', 'Eletrocardiograma (ECG)', 'Exame Cardiológico', 'Não usar cremes no tórax no dia do exame.', '00:20:00', NULL),
('40805018', 'Radiografia de Joelho Direito', 'Exame de Imagem', 'Remover objetos metálicos da região.', '00:15:00', NULL),
('40101029', 'Teste Ergométrico', 'Exame Cardiológico', 'Usar roupas leves e tênis; evitar cafeína 3h antes.', '00:40:00', '40101010');

-- 19. SOLICITA
INSERT INTO SOLICITA (id_atendimento, codigo_TUSS_procedimento, data_solicitacao, indicacao_clinica, carater, status_exame) VALUES
(901, '40101010', '2026-11-10', 'Investigação de palpitações', 'Eletivo', 'Realizado'),
(902, '40805018', '2026-11-12', 'Avaliação de dor articular pós-esforço', 'Urgência', 'Realizado'),
(903, '40101029', '2026-09-01', 'Avaliação cardiológica de esforço', 'Eletivo', 'Solicitado');

-- 20. MEDICAMENTOS
INSERT INTO MEDICAMENTOS (codigo_medicamento, principio_ativo, nome_comercial, apresentacao, concentracao, tarja) VALUES
(301, 'Losartana Potássica', 'Aradois', 'Comprimido', '50mg', 'Tarja Vermelha'),
(302, 'Ibuprofeno', 'Alivium', 'Comprimido revestido', '600mg', 'Sem Tarja'),
(303, 'Dipirona Monoidratada', 'Novalgina', 'Solução Oral', '500mg/mL', 'Sem Tarja');

-- 21. PRESCREVE
INSERT INTO PRESCREVE (id_atendimento, codigo_medicamento, seq_item, quantidade, posologia, duracao_tratamento, via_administracao) VALUES
(901, 301, 1, 30, 'Tomar 1 comprimido pela manhã em jejum', '30 dias', 'Oral'),
(902, 302, 1, 15, 'Tomar 1 comprimido de 8 em 8 horas após as refeições', '5 dias', 'Oral'),
(902, 303, 2, 1, 'Tomar 30 gotas em caso de dor', 'Se necessário', 'Oral');

-- 22. AGENDAS
INSERT INTO AGENDAS (crm_medico, codigo_unidade, dia_semana, hora_inicio, hora_termino, periodo_vigencia, duracao_consulta) VALUES
('12345-PE', 1, 'Segunda-feira', '08:00:00', '12:00:00', '2026-12-31', '00:30:00'),
('12345-PE', 1, 'Quarta-feira', '14:00:00', '18:00:00', '2026-12-31', '00:30:00'),
('67890-PE', 2, 'Terça-feira', '09:00:00', '15:00:00', '2026-12-31', '00:30:00');

-- 23. TABELA_PRECOS
INSERT INTO TABELA_PRECOS (id_preco, codigo_TUSS_procedimento, cnpj_operadora, valor, data_vigencia) VALUES
(1, '40101010', '12.345.678/0001-99', 120.00, '2025-01-01'),
(2, '40101010', '12.345.678/0001-99', 135.00, '2025-07-01'),
(3, '40101010', '12.345.678/0001-99', 150.00, '2026-01-01'),
(4, '40101010', NULL, 200.00, '2026-01-01'),
(5, '40805018', '98.765.432/0001-11', 180.00, '2026-01-01'),
(6, '40101029', '12.345.678/0001-99', 250.00, '2026-01-01');
-- 24. GUIAS
INSERT INTO GUIAS (id_guia, id_atendimento, cnpj_operadora, id_preco, competencia, valor_apresentado, valor_pago, valor_glosado) VALUES
(1, 901, '12.345.678/0001-99', 3, '2026-11', 350.00, 300.00, 50.00),
(2, 902, '98.765.432/0001-11', 5, '2026-11', 280.00, 280.00, 0.00),
(3, 903, '12.345.678/0001-99', 6, '2026-09', 420.00, 340.00, 80.00);

