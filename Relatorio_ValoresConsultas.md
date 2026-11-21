# Parâmetros usados nas consultas

As consultas estão em `03_consultas_cenario5.sql`. Os valores entre colchetes nos enunciados foram substituídos por estes exemplos:

| Consulta | Valor ou critério usado |
| --- | --- |
| Q01 | Vínculo `cooperado`. |
| Q02 | Cancelamentos ocorridos em outubro de 2026. |
| Q03 | Procedimentos do tipo exame com preparo preenchido. |
| Q04 | Pacientes nascidos a partir de 1º de janeiro de 2010. |
| Q05 | Absenteísmo em outubro de 2026. |
| Q06 | Especialidade `Cardiologia`, unidade de código `1` e agenda vigente na data de execução. |
| Q07 | Pacientes com responsável cadastrado. |
| Q08 | Dez procedimentos mais solicitados em 2026. |
| Q09 | Todas as operadoras e competências existentes. |
| Q10 | Tempo médio entre marcação e consulta, agrupado pela especialidade selecionada no agendamento. |
| Q11 | Exames com status `Solicitado`, agrupados pela especialidade selecionada no agendamento. |
| Q12 | Atendimentos com recomendação de retorno e sem novo atendimento do mesmo médico dentro do prazo. |
| Q13 | TUSS `40101010`, operadora `Operadora Saúde Brasil S.A.` e data `2026-11-20`; compara também o atendimento particular. |
| Q14 | Atendimentos realizados em 2026; pacientes com pelo menos três especialidades distintas. |

O site oferece busca e filtros de registros, mas não calcula médias, percentuais ou rankings. Para esses resultados, execute a consulta correspondente no script SQL.
