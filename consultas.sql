-- Q01: Liste nome, CRM, UF do registro e data de admissão dos médicos com vínculo [cooperado], em ordem alfabética.
-- Valor utilizado: ['cooperado']
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
-- Valor utilizado: ['2026-11'] 
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
WHERE preparo_exigido IS NOT NULL 
  AND preparo_exigido != '';

-- Q04: Quais pacientes nasceram a partir de [2010]? Mostre número de prontuário, nome, data de nascimento e município.
-- Valor utilizado: ['2010-01-01'] 
SELECT 
    pr.numero_prontuario, 
    pa.nome, 
    pa.data_nascimento, 
    pa.endereco 
FROM PACIENTES pa
JOIN PRONTUARIO pr ON pa.cpf = pr.cpf_paciente
WHERE pa.data_nascimento >= '2010-01-01'
ORDER BY pa.data_nascimento DESC;