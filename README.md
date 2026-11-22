# Projeto - Banco de Dados

Repositório do projeto da disciplina de Banco de Dados — Cenário 5: clínica médica.
@Alanemartins
@DouglasBezerra01
@ViniciusHenrykyy

## Executar usando o SQLite (by alexcvzz)

1. Crie o arquivo `clinica.db`.
2. Pressione `Ctrl + Shift + P`, digite `SQLite: Open Database` e selecione o arquivo `clinica.db`.
3. Abra `01_criacao_cenario5.sql` e execute-o com `Ctrl + Shift + Q`.
4. Repita o passo anterior para `02_insercao_cenario5.sql` e `03_consultas_cenario5.sql`.

## Executar o Website

O site consulta os registros diretamente do banco SQLite por meio de uma API local.
Com Python 3 instalado e o arquivo `clinica.db` na raiz do projeto, execute:

```powershell
python server.py
```

Depois, acesse http://127.0.0.1:8001. Mantenha o servidor em execução enquanto usa o site. A API abre o banco em modo somente leitura e não requer dependências externas.

No site, abra **Filtros** para escolher o tipo de registro; Guias e Tabela de preços também podem ser pesquisadas. A média entre a marcação e a consulta, agrupada por especialidade, aparece na categoria **Tempo médio, em dias, por especialidade**. Também é possível pesquisar `tempo médio em dias entre a data da marcação e a data da consulta por especialidade`. As demais consultas agregadas devem ser executadas em `03_consultas_cenario5.sql`.

As evoluções estão relacionadas a um atendimento e a um profissional. Cada agendamento informa a especialidade escolhida, que precisa pertencer ao médico.

Os parâmetros usados nas consultas estão registrados em [Relatorio_ValoresConsultas.md](Relatorio_ValoresConsultas.md). Este repositório não inclui nem cria `clinica.db`; o arquivo deve ser criado separadamente antes de iniciar o site.