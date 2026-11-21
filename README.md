# projeto_bd
Repositório para o projeto da disciplina de Banco de Dados

## Executar o site

O site consulta os registros diretamente do banco SQLite por meio de uma API local.
Com Python 3 instalado e o arquivo `clinica.db` na raiz do projeto, execute:

```powershell
python server.py
```

Depois, acesse http://127.0.0.1:8001. Mantenha o servidor em execução enquanto usa o site. A API abre o banco em modo somente leitura e não requer dependências externas.

No site, abra **Filtros** para escolher o tipo de registro; Guias e Tabela de preços também podem ser pesquisadas. A média entre a marcação e a consulta, agrupada por especialidade, aparece na categoria **Tempo médio, em dias, por especialidade**. Também é possível pesquisar `tempo médio em dias entre a data da marcação e a data da consulta por especialidade`. As demais consultas agregadas devem ser executadas em `03_consultas_cenario5.sql`.

As evoluções estão relacionadas a um atendimento e a um profissional. Cada agendamento informa a especialidade escolhida, que precisa pertencer ao médico.

Os parâmetros usados nas consultas estão registrados em [Relatorio_ValoresConsultas.md](Relatorio_ValoresConsultas.md). Este repositório não inclui nem cria `clinica.db`; o arquivo deve ser criado separadamente antes de iniciar o site.
