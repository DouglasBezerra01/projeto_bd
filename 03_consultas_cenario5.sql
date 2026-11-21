-- NÍVEL 1 - CONSULTAS BÁSICAS

-- Q01: Liste nome, CRM, UF do registro e data de admissão dos médicos com vínculo [cooperado], em ordem alfabética.
SELECT 
    p.nome, 
    m.crm, 
    m.uf_registro, 
    p.data_admissao
FROM MEDICO m
JOIN PROFISSIONAIS p ON m.matricula_profissionais = p.matricula
WHERE LOWER(p.tipo_vinculo) = 'cooperado'
ORDER BY p.nome ASC;

-- Q02: Quais agendamentos foram cancelados em [outubro de 2026]? Mostre data e hora marcadas, data do cancelamento e motivo.
SELECT 
    data AS data_marcada, 
    hora AS hora_marcada, 
    data_cancelamento, 
    motivo_cancelamento
FROM AGENDAMENTO
WHERE situacao = 'Cancelado'
  AND data LIKE '2026-11-%'
ORDER BY data ASC;

-- Q03: Liste código TUSS, nome, preparo e tempo estimado dos procedimentos do tipo exame que exigem preparo do paciente.
SELECT 
    codigo_TUSS, 
    nome, 
    preparo_exigido, 
    tempo_estimado
FROM PROCEDIMENTO_EXAME
WHERE tipo LIKE 'Exame%' 
  AND preparo_exigido IS NOT NULL
  AND preparo_exigido != '';

-- Q04: Quais pacientes nasceram a partir de [2010]? Mostre número de prontuário, nome, data de nascimento e município.
SELECT 
    pr.numero_prontuario, 
    pa.nome, 
    pa.data_nascimento, 
    pa.municipio
FROM PACIENTES pa
JOIN PRONTUARIO pr ON pa.cpf = pr.cpf_paciente
WHERE pa.data_nascimento >= '2010-01-01'
ORDER BY pa.data_nascimento DESC;


-- NÍVEL 2 - JUNCÕES E AGRUPAMENTOS

-- Q05: Calcule a taxa de absenteísmo de cada médico em [outubro de 2026].
SELECT 
    matricula_medico,
    COUNT(CASE WHEN situacao = 'faltou' THEN 1 END) * 100.0 / COUNT(*) AS taxa_absenteismo_percentual
FROM AGENDAMENTO
WHERE data LIKE '2026-11-%'
GROUP BY matricula_medico;

-- Q06: Quais médicos atendem a especialidade [Cardiologia] na unidade [código], com faixa de agenda vigente hoje?
SELECT 
    p.nome AS medico, 
    a.dia_semana, 
    a.hora_inicio, 
    a.hora_termino
FROM AGENDAS a
JOIN MEDICO m ON a.crm_medico = m.crm
JOIN PROFISSIONAIS p ON m.matricula_profissionais = p.matricula
JOIN MEDICO_ESPECIALIDADE me ON m.matricula_profissionais = me.matricula_medico
JOIN ESPECIALIDADE e ON me.codigo_especialidade = e.codigo
WHERE e.nome = 'Cardiologia'
  AND a.codigo_unidade = 1
  AND a.periodo_vigencia >= CURRENT_DATE;

-- Q07: Liste os pacientes que têm responsável cadastrado, com o nome do responsável.
SELECT 
    nome AS paciente, 
    nome_responsavel
FROM PACIENTES
WHERE nome_responsavel IS NOT NULL 
  AND nome_responsavel != '';

-- Q08: Quais os [10] procedimentos mais solicitados como exame em [2026]?
SELECT 
    p.nome, 
    COUNT(s.codigo_TUSS_procedimento) AS total_solicitacoes
FROM SOLICITA s
JOIN PROCEDIMENTO_EXAME p ON s.codigo_TUSS_procedimento = p.codigo_TUSS
WHERE s.data_solicitacao LIKE '2026-%'
GROUP BY p.nome
ORDER BY total_solicitacoes DESC
LIMIT 10;

-- Q09: Para cada operadora e competência, mostre o valor apresentado, o valor pago, o valor glosado e o percentual de glosa.
SELECT 
    o.razao_social AS operadora,
    g.competencia,
    SUM(g.valor_apresentado) AS total_apresentado,
    SUM(g.valor_pago) AS total_pago,
    SUM(g.valor_glosado) AS total_glosado,
    ROUND(SUM(g.valor_glosado) * 100.0 / NULLIF(SUM(g.valor_apresentado), 0), 2) AS percentual_glosa
FROM GUIAS g
JOIN OPERADORES o ON g.cnpj_operadora = o.cnpj
GROUP BY o.razao_social, g.competencia;


-- NÍVEL 3 - CONSULTAS AVANÇADAS

-- Q10: Qual o tempo médio, em dias, entre a data da marcação e a data da consulta, por especialidade?
SELECT 
    e.nome AS especialidade,
    ROUND(AVG(JULIANDAY(a.data) - JULIANDAY(a.data_marcacao)), 1) AS tempo_medio_dias
FROM AGENDAMENTO a
JOIN ESPECIALIDADE e ON me.codigo_especialidade = e.codigo
WHERE a.situacao = 'Realizado'
GROUP BY e.nome;


-- Q11: Quais exames foram solicitados e nunca realizados? Mostre a quantidade agrupada pela especialidade do médico solicitante.
SELECT 
    e.nome AS especialidade_solicitante,
    COUNT(s.codigo_TUSS_procedimento) AS exames_nao_realizados
FROM SOLICITA s
JOIN ATENDIMENTO at ON s.id_atendimento = at.id_atendimento
JOIN AGENDAMENTO a ON at.id_agendamento = a.id_agendamento
JOIN ESPECIALIDADE e ON me.codigo_especialidade = e.codigo
WHERE s.status_exame = 'Solicitado'
GROUP BY e.nome;


-- Q12: Quais pacientes receberam recomendação de retorno e não tiveram novo atendimento com o mesmo médico dentro do prazo indicado?
SELECT DISTINCT
    p.nome AS paciente,
    m_prof.nome AS medico,
    a1.data AS data_atendimento_original,
    at1.prazo_retorno,
    DATE(a1.data, '+' || at1.prazo_retorno || ' days') AS data_limite_retorno
FROM ATENDIMENTO at1
JOIN AGENDAMENTO a1 ON at1.id_agendamento = a1.id_agendamento
JOIN PACIENTES p ON a1.cpf_paciente = p.cpf
JOIN PROFISSIONAIS m_prof ON a1.matricula_medico = m_prof.matricula
WHERE at1.prazo_retorno IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM ATENDIMENTO at2
      JOIN AGENDAMENTO a2 ON at2.id_agendamento = a2.id_agendamento
      WHERE a2.cpf_paciente = a1.cpf_paciente
        AND a2.matricula_medico = a1.matricula_medico
        AND a2.data > a1.data
        AND a2.data <= DATE(a1.data, '+' || at1.prazo_retorno || ' days')
  );


-- Q13: Qual seria o valor cobrado pelo procedimento ['40101010'] da operadora ['Operadora Saúde Brasil S.A.'] na data ['2026-11-20']? E no atendimento particular, na mesma data?
SELECT 
    COALESCE(o.razao_social, 'Atendimento Particular') AS plano,
    tp.valor,
    tp.data_vigencia
FROM TABELA_PRECOS tp
LEFT JOIN OPERADORES o ON tp.cnpj_operadora = o.cnpj
WHERE tp.codigo_TUSS_procedimento = '40101010'
  AND (o.razao_social = 'Operadora Saúde Brasil S.A.' OR tp.cnpj_operadora IS NULL)
  AND tp.data_vigencia = (
      SELECT MAX(data_vigencia)
      FROM TABELA_PRECOS tp2
      WHERE tp2.codigo_TUSS_procedimento = tp.codigo_TUSS_procedimento
        AND COALESCE(tp2.cnpj_operadora, '') = COALESCE(tp.cnpj_operadora, '') 
        AND tp2.data_vigencia <= '2026-11-20'
  );


-- Q14: Quais pacientes foram atendidos em três ou mais especialidades diferentes em [2026]?
SELECT 
    p.nome,
    COUNT(DISTINCT a.codigo_especialidade) AS qtd_especialidades_diferentes
FROM PACIENTES p
JOIN AGENDAMENTO a ON p.cpf = a.cpf_paciente
JOIN ATENDIMENTO at ON a.id_agendamento = at.id_agendamento
WHERE a.data LIKE '2026-%'
GROUP BY p.cpf, p.nome
HAVING COUNT(DISTINCT a.codigo_especialidade) >= 3;