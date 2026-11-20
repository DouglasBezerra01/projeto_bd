-- Q01
-- Valor utilizado: ['PJ'] 
SELECT 
    p.nome, 
    m.crm, 
    m.uf_registro, 
    p.data_admissao
FROM MEDICO m
JOIN PROFISSIONAIS p ON m.matricula_profissionais = p.matricula
WHERE p.tipo_vinculo = 'PJ'
ORDER BY p.nome ASC;


-- Q02
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


-- Q03
-- Filtra procedimentos que possuem alguma instrução no campo preparo_exigido
SELECT 
    codigo_TUSS, 
    nome, 
    preparo_exigido, 
    tempo_estimado
FROM PROCEDIMENTO_EXAME
WHERE preparo_exigido IS NOT NULL 
  AND preparo_exigido != '';


-- Q04
-- Valor utilizado: ['2000-01-01'] 
SELECT 
    pr.numero_prontuario, 
    pa.nome, 
    pa.data_nascimento, 
    pa.endereco -- Lembre-se de trocar por pa.municipio após atualizar o DDL
FROM PACIENTES pa
JOIN PRONTUARIO pr ON pa.cpf = pr.cpf_paciente
WHERE pa.data_nascimento >= '2000-01-01'
ORDER BY pa.data_nascimento DESC;