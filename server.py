import json
import logging
import sqlite3
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parent
DATABASE = ROOT / "clinica.db"
WEB_ROOT = ROOT / "LandingPage"


def load_records():
    if not DATABASE.is_file():
        raise FileNotFoundError(f"Banco de dados não encontrado: {DATABASE}")

    connection = sqlite3.connect(DATABASE)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA query_only = ON")

    try:
        return _build_records(connection)
    finally:
        connection.close()


def _build_records(connection):
    def rows(query):
        return [dict(row) for row in connection.execute(query)]

    records = []

    def add(category, data):
        searchable = " ".join(
            str(value) for value in data.values() if value is not None and str(value).strip()
        )
        records.append({
            "type": category,
            "data": data,
            "searchText": f"{category} {searchable}".casefold(),
        })

    for row in rows("""
        SELECT p.*, u.nome AS unidade_nome, u.municipio,
               a.setor, m.crm, m.uf_registro,
               e.corem, e.uf_respectivo,
               t.registro_profissional, t.area_atuacao,
               GROUP_CONCAT(DISTINCT esp.nome) AS especialidades
        FROM PROFISSIONAIS p
        LEFT JOIN UNIDADES u ON u.codigo = p.codigo_unidade
        LEFT JOIN ADMINISTRACAO a ON a.matricula_profissionais = p.matricula
        LEFT JOIN MEDICO m ON m.matricula_profissionais = p.matricula
        LEFT JOIN ENFERMEIRO e ON e.matricula_profissionais = p.matricula
        LEFT JOIN TECNICO t ON t.matricula_profissionais = p.matricula
        LEFT JOIN MEDICO_ESPECIALIDADE me ON me.matricula_medico = m.matricula_profissionais
        LEFT JOIN ESPECIALIDADE esp ON esp.codigo = me.codigo_especialidade
        GROUP BY p.matricula
        ORDER BY p.matricula
    """):
        cargo = (
            "Médico" if row["crm"] else
            "Enfermeiro" if row["corem"] else
            "Técnico" if row["registro_profissional"] else
            row["setor"]
        )
        especialidades = row["especialidades"] or ""
        add("Profissional", {
            "Nome": row["nome"],
            "CPF": row["cpf"],
            "Código da unidade": row["codigo_unidade"],
            "Data de nascimento": row["data_nascimento"],
            "Telefone": row["telefone"],
            "E-mail": row["email"],
            "CRM": row["crm"] or "",
            "UF de registro": row["uf_registro"] or row["uf_respectivo"] or "",
            "Matrícula": row["matricula"],
            "Cargo/área": cargo,
            "Vínculo": row["tipo_vinculo"],
            "Unidade": row["unidade_nome"] or "",
            "Município": row["municipio"] or "",
            "Especialidades": especialidades,
            "COREN": row["corem"] or "",
            "UF do COREN": row["uf_respectivo"] or "",
            "Registro profissional": row["registro_profissional"] or "",
            "Área de atuação": row["area_atuacao"] or "",
            "Setor": row["setor"] or "",
            "Data de admissão": row["data_admissao"],
            "Detalhes": f"Matrícula {row['matricula']} • {cargo or ''} • {row['tipo_vinculo'] or ''}",
            "Informações": " • ".join(value for value in (especialidades, row["area_atuacao"], row["municipio"]) if value),
        })

    patient_rows = rows("""
        SELECT p.*, pr.numero_prontuario, pr.cns,
               GROUP_CONCAT(DISTINCT pl.nome) AS planos
        FROM PACIENTES p
        LEFT JOIN PRONTUARIO pr ON pr.cpf_paciente = p.cpf
        LEFT JOIN POSSUI_PLANO pp ON pp.numero_prontuario = pr.numero_prontuario
        LEFT JOIN PLANOS pl ON pl.codigo = pp.codigo_plano
        GROUP BY p.cpf
        ORDER BY p.nome
    """)
    for row in patient_rows:
        plano = row["planos"] or ""
        prontuario = row["numero_prontuario"]
        cns = row["cns"]
        add("Paciente", {
            "Nome": row["nome"],
            "CPF": row["cpf"],
            "Prontuário": prontuario,
            "Número do prontuário": prontuario,
            "CPF do paciente": row["cpf"],
            "Data de nascimento": row["data_nascimento"],
            "Sexo": row["sexo"],
            "Nome da mãe": row["nome_mae"],
            "Endereço": row["endereco"],
            "Telefone": row["telefone"],
            "CNS": cns,
            "Plano": plano,
        })

    for row in rows("""
        SELECT pr.*, p.nome
        FROM PRONTUARIO pr
        LEFT JOIN PACIENTES p ON p.cpf = pr.cpf_paciente
        ORDER BY pr.numero_prontuario
    """):
        add("Prontuário", {
            "Número do prontuário": row["numero_prontuario"],
            "CPF do paciente": row["cpf_paciente"],
            "Nome": row["nome"],
            "CNS": row["cns"],
        })

    for row in rows("""
        SELECT pp.*, pr.cpf_paciente, pl.nome AS plano
        FROM POSSUI_PLANO pp
        LEFT JOIN PRONTUARIO pr ON pr.numero_prontuario = pp.numero_prontuario
        LEFT JOIN PLANOS pl ON pl.codigo = pp.codigo_plano
        ORDER BY pp.numero_prontuario, pp.codigo_plano
    """):
        add("Vínculo de plano", {
            "Número do prontuário": row["numero_prontuario"],
            "CPF do paciente": row["cpf_paciente"],
            "Código do plano": row["codigo_plano"],
            "Plano": row["plano"],
            "Número da carteirinha": row["numero_carteirinha"],
            "Data início do plano": row["data_inicio"],
            "Data fim do plano": row["data_fim"],
            "Condição do plano": row["condicao"],
        })

    for row in rows("SELECT * FROM UNIDADES ORDER BY codigo"):
        add("Unidade", {
            "Código": row["codigo"],
            "Nome": row["nome"],
            "Unidade": row["nome"],
            "Endereço": row["endereco"],
            "Município": row["municipio"],
            "Telefone": row["telefone"],
            "Horário de funcionamento": row["horario_funcionamento"],
            "Data de inauguração": row["data_inauguracao"],
            "Detalhes": f"{row['endereco'] or ''} • {row['municipio'] or ''}",
            "Informações": f"Telefone {row['telefone'] or ''} • Horário {row['horario_funcionamento'] or ''} • Inauguração {row['data_inauguracao'] or ''}",
        })

    for row in rows("""
        SELECT pe.*, s.id_atendimento, s.data_solicitacao, s.indicacao_clinica,
               s.carater, s.status_exame,
               GROUP_CONCAT(DISTINCT esp.nome) AS especialidades
        FROM PROCEDIMENTO_EXAME pe
        LEFT JOIN SOLICITA s ON s.codigo_TUSS_procedimento = pe.codigo_TUSS
        LEFT JOIN ATENDIMENTO a ON a.id_atendimento = s.id_atendimento
        LEFT JOIN AGENDAMENTO ag ON ag.id_agendamento = a.id_agendamento
        LEFT JOIN MEDICO_ESPECIALIDADE me ON me.matricula_medico = ag.matricula_medico
        LEFT JOIN ESPECIALIDADE esp ON esp.codigo = me.codigo_especialidade
        GROUP BY pe.codigo_TUSS
        ORDER BY pe.codigo_TUSS
    """):
        add("Procedimento", {
            "Nome": row["nome"],
            "TUSS": row["codigo_TUSS"],
            "Tipo": row["tipo"],
            "Preparo": row["preparo_exigido"],
            "Tempo estimado": row["tempo_estimado"],
            "Código do exame principal": row["cod_exame_princ"],
            "ID atendimento": row["id_atendimento"],
            "Data da solicitação": row["data_solicitacao"],
            "Indicação clínica": row["indicacao_clinica"],
            "Caráter": row["carater"],
            "Status do exame": row["status_exame"],
            "Especialidade": row["especialidades"],
            "Detalhes": f"TUSS {row['codigo_TUSS']} • {row['tipo'] or ''}",
            "Informações": f"Preparo: {row['preparo_exigido'] or ''} • Tempo: {row['tempo_estimado'] or ''} • Atendimento: {row['id_atendimento'] or 'não solicitado'}",
        })

    for row in rows("""
        SELECT s.*, pe.nome AS procedimento
        FROM SOLICITA s
        LEFT JOIN PROCEDIMENTO_EXAME pe ON pe.codigo_TUSS = s.codigo_TUSS_procedimento
        ORDER BY s.id_atendimento, s.codigo_TUSS_procedimento
    """):
        add("Solicitação", {
            "ID atendimento": row["id_atendimento"],
            "TUSS": row["codigo_TUSS_procedimento"],
            "Procedimento": row["procedimento"],
            "Data da solicitação": row["data_solicitacao"],
            "Indicação clínica": row["indicacao_clinica"],
            "Caráter": row["carater"],
            "Status do exame": row["status_exame"],
        })

    for row in rows("""
        SELECT ag.*, p.nome AS paciente, prof.nome AS medico, s.equipamento
        FROM AGENDAMENTO ag
        LEFT JOIN PACIENTES p ON p.cpf = ag.cpf_paciente
        LEFT JOIN PROFISSIONAIS prof ON prof.matricula = ag.matricula_medico
        LEFT JOIN SALAS s ON s.numero_sala = ag.numero_sala
        ORDER BY ag.id_agendamento
    """):
        add("Agendamento", {
            "ID agendamento": row["id_agendamento"],
            "Paciente": row["paciente"],
            "Médico": row["medico"],
            "Data": row["data"],
            "Hora": row["hora"],
            "Canal": row["canal"],
            "Forma de pagamento": row["forma_pagamento"],
            "Situação": row["situacao"],
            "Sala": row["numero_sala"],
            "Data do cancelamento": row["data_cancelamento"],
            "Motivo do cancelamento": row["motivo_cancelamento"],
            "Matrícula da administração": row["matricula_administracao"],
            "Equipamentos da sala": row["equipamento"],
            "Detalhes": f"Agendamento {row['id_agendamento']} • {row['data'] or ''} às {row['hora'] or ''}",
            "Informações": f"{row['situacao'] or ''} • {row['canal'] or ''} • {row['forma_pagamento'] or ''} • Sala {row['numero_sala'] or ''} {row['motivo_cancelamento'] or ''}",
        })

    for row in rows("""
        SELECT a.*, ag.data, ag.hora, ag.cpf_paciente, p.nome AS paciente,
               prof.nome AS profissional, m.crm,
               GROUP_CONCAT(DISTINCT esp.nome) AS especialidades
        FROM ATENDIMENTO a
        LEFT JOIN AGENDAMENTO ag ON ag.id_agendamento = a.id_agendamento
        LEFT JOIN PACIENTES p ON p.cpf = ag.cpf_paciente
        LEFT JOIN PROFISSIONAIS prof ON prof.matricula = ag.matricula_medico
        LEFT JOIN MEDICO m ON m.matricula_profissionais = prof.matricula
        LEFT JOIN MEDICO_ESPECIALIDADE me ON me.matricula_medico = m.matricula_profissionais
        LEFT JOIN ESPECIALIDADE esp ON esp.codigo = me.codigo_especialidade
        GROUP BY a.id_atendimento
        ORDER BY a.id_atendimento
    """):
        add("Atendimento", {
            "ID atendimento": row["id_atendimento"],
            "ID agendamento": row["id_agendamento"],
            "Paciente": row["paciente"],
            "Profissional": row["profissional"],
            "CRM": row["crm"],
            "Data": row["data"],
            "Hora início": row["hora_inicio"],
            "Hora término": row["hora_termino"],
            "Queixa principal": row["queixa_principal"],
            "CID": row["teses_diagnosticas_CID"],
            "Conduta": row["conduta"],
            "Especialidades": row["especialidades"],
            "Prazo de retorno": row["prazo_retorno"],
            "Detalhes": f"Atendimento {row['id_atendimento']} • Agendamento {row['id_agendamento']}",
            "Informações": " • ".join(value for value in (
                f"{row['hora_inicio'] or ''}–{row['hora_termino'] or ''}",
                row["teses_diagnosticas_CID"],
                row["especialidades"],
                f"Retorno em {row['prazo_retorno']} dias" if row["prazo_retorno"] is not None else None,
            ) if value),
        })

    for row in rows("""
        SELECT a.*, p.nome AS profissional, u.nome AS unidade_nome, u.municipio
        FROM AGENDAS a
        LEFT JOIN MEDICO m ON m.crm = a.crm_medico
        LEFT JOIN PROFISSIONAIS p ON p.matricula = m.matricula_profissionais
        LEFT JOIN UNIDADES u ON u.codigo = a.codigo_unidade
        ORDER BY a.crm_medico, a.codigo_unidade, a.dia_semana, a.hora_inicio
    """):
        add("Agenda", {
            "Profissional": row["profissional"],
            "CRM": row["crm_medico"],
            "CRM médico": row["crm_medico"],
            "Unidade": row["unidade_nome"],
            "Município": row["municipio"],
            "Código da unidade": row["codigo_unidade"],
            "Dia da semana": row["dia_semana"],
            "Horário de início": row["hora_inicio"],
            "Horário de término": row["hora_termino"],
            "Vigência": row["periodo_vigencia"],
            "Duração da consulta": row["duracao_consulta"],
            "Detalhes": f"CRM {row['crm_medico']} • {row['dia_semana']}, {row['hora_inicio']}–{row['hora_termino']}",
            "Informações": f"{row['unidade_nome'] or ''} • Vigência até {row['periodo_vigencia'] or ''} • Consulta {row['duracao_consulta'] or ''}",
        })

    for row in rows("SELECT * FROM PLANOS ORDER BY codigo"):
        add("Plano", {
            "Nome": row["nome"],
            "Código": row["codigo"],
            "Acomodação": row["tipo_acomodacao"],
            "Tipo de acomodação": row["tipo_acomodacao"],
            "Abrangência": row["abrangencia"],
            "Carência": f"{row['prazo_carencia']} dias" if row["prazo_carencia"] is not None else "",
            "Prazo de carência": row["prazo_carencia"],
            "Detalhes": f"Código {row['codigo']} • {row['tipo_acomodacao'] or ''}",
            "Informações": f"{row['abrangencia'] or ''} • Carência {row['prazo_carencia'] if row['prazo_carencia'] is not None else ''} dias",
        })

    for row in rows("SELECT * FROM OPERADORES ORDER BY razao_social"):
        add("Operadora", {
            "Nome": row["razao_social"],
            "CNPJ": row["cnpj"],
            "Registro ANS": row["registro_ans"],
            "Contato": row["contato_administrativo"],
            "Detalhes": f"CNPJ {row['cnpj']} • {row['registro_ans'] or ''}",
            "Informações": f"Contato {row['contato_administrativo'] or ''}",
        })

    for row in rows("SELECT * FROM ESPECIALIDADE ORDER BY codigo"):
        add("Especialidade", {
            "Código": row["codigo"],
            "Nome": row["nome"],
            "Conselho": row["conselho"],
        })

    for row in rows("""
        SELECT m.matricula_profissionais, p.nome, m.crm, esp.codigo, esp.nome AS especialidade
        FROM MEDICO_ESPECIALIDADE me
        JOIN MEDICO m ON m.matricula_profissionais = me.matricula_medico
        JOIN PROFISSIONAIS p ON p.matricula = m.matricula_profissionais
        JOIN ESPECIALIDADE esp ON esp.codigo = me.codigo_especialidade
        ORDER BY m.matricula_profissionais, esp.codigo
    """):
        add("Especialidade médica", {
            "Matrícula do médico": row["matricula_profissionais"],
            "Nome": row["nome"],
            "CRM": row["crm"],
            "Código da especialidade": row["codigo"],
            "Nome da especialidade": row["especialidade"],
        })

    for row in rows("SELECT * FROM SALAS ORDER BY numero_sala"):
        add("Sala", {
            "Número da sala": row["numero_sala"],
            "Capacidade": row["capacidade"],
            "Equipamentos": row["equipamento"],
        })

    for row in rows("SELECT * FROM MEDICAMENTOS ORDER BY codigo_medicamento"):
        add("Medicamento", {
            "Nome": row["nome_comercial"],
            "Código do medicamento": row["codigo_medicamento"],
            "Princípio ativo": row["principio_ativo"],
            "Nome comercial": row["nome_comercial"],
            "Apresentação": row["apresentacao"],
            "Concentração": row["concentracao"],
            "Tarja": row["tarja"],
        })

    for row in rows("""
        SELECT pr.*, m.nome_comercial, m.principio_ativo
        FROM PRESCREVE pr
        LEFT JOIN MEDICAMENTOS m ON m.codigo_medicamento = pr.codigo_medicamento
        ORDER BY pr.id_atendimento, pr.seq_item
    """):
        add("Prescrição", {
            "ID atendimento": row["id_atendimento"],
            "Código do medicamento": row["codigo_medicamento"],
            "Medicamento": row["nome_comercial"],
            "Princípio ativo": row["principio_ativo"],
            "Sequência do item": row["seq_item"],
            "Quantidade": row["quantidade"],
            "Posologia": row["posologia"],
            "Duração do tratamento": row["duracao_tratamento"],
            "Via de administração": row["via_administracao"],
        })

    for row in rows("""
        SELECT e.*, p.nome AS paciente, prof.nome AS profissional
        FROM EVOLUCAO e
        LEFT JOIN PRONTUARIO pr ON pr.numero_prontuario = e.numero_prontuario
        LEFT JOIN PACIENTES p ON p.cpf = pr.cpf_paciente
        LEFT JOIN PROFISSIONAIS prof ON prof.matricula = e.matricula_profissional
        ORDER BY e.seq_evolucao
    """):
        add("Evolução", {
            "Sequência da evolução": row["seq_evolucao"],
            "Prontuário": row["numero_prontuario"],
            "Paciente": row["paciente"],
            "Matrícula": row["matricula_profissional"],
            "Profissional": row["profissional"],
            "Data e hora": row["data_hora"],
            "Peso": row["peso"],
            "Altura": row["altura"],
            "Frequência cardíaca": row["frequencia_cardiaca"],
            "Temperatura": row["temperatura"],
            "Pressão arterial": row["pressao"],
            "Detalhes": f"Prontuário {row['numero_prontuario']} • Profissional {row['matricula_profissional']}",
            "Informações": row["texto_evolucao"],
        })

    return records


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(WEB_ROOT), **kwargs)

    def do_GET(self):
        if urlparse(self.path).path != "/api/records":
            return super().do_GET()

        try:
            payload = json.dumps(load_records(), ensure_ascii=False).encode("utf-8")
        except (sqlite3.Error, OSError) as error:
            logging.exception("Não foi possível carregar registros do banco de dados")
            payload = json.dumps({"error": str(error)}, ensure_ascii=False).encode("utf-8")
            self.send_response(500)
        else:
            self.send_response(200)

        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    server = ThreadingHTTPServer(("127.0.0.1", 8001), Handler)
    print("Acesse http://127.0.0.1:8001")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServidor encerrado.")
    finally:
        server.server_close()
