const form = document.getElementById('searchForm');
const input = document.getElementById('search');
const resultsBody = document.getElementById('resultsBody');
const resultsHeadRow = document.getElementById('resultsHeadRow');
const emptyState = document.getElementById('emptyState');
const resultCount = document.getElementById('resultCount');
const resultsTitle = document.getElementById('resultsTitle');
const fieldOptions = document.getElementById('fieldOptions');
const filterToggle = document.getElementById('filterToggle');
const filtersPanel = document.getElementById('filtersPanel');
const allFilter = document.querySelector('[data-all-filter]');
const categoryFilters = [...document.querySelectorAll('[data-category-filter]')];
let records = [];
let fieldFilters = [];

const columnOrder = [
  'Nome', 'CPF', 'CRM', 'Matrícula', 'Cargo/área', 'Vínculo', 'Unidade', 'Especialidades',
  'COREN', 'UF de registro', 'Registro profissional', 'Área de atuação', 'Setor',
  'Data de admissão', 'Data de nascimento', 'E-mail', 'Prontuário', 'CNS', 'Sexo',
  'Nome da mãe', 'Endereço', 'Município', 'Telefone', 'Plano', 'TUSS', 'Tipo', 'Preparo',
  'Tempo estimado', 'ID agendamento', 'ID atendimento', 'Data', 'Hora', 'Canal',
  'Forma de pagamento', 'Situação', 'Sala', 'Motivo do cancelamento', 'Hora início',
  'Hora término', 'CID', 'Prazo de retorno', 'Dia da semana', 'Horário de início',
  'Horário de término', 'Horário de funcionamento', 'Data de inauguração', 'Vigência',
  'Duração da consulta', 'Código', 'Código da unidade', 'Acomodação', 'Abrangência',
  'Carência', 'CNPJ', 'Registro ANS', 'Contato', 'Especialidade', 'Data de marcação',
  'ID guia', 'Competência', 'Valor apresentado', 'Valor pago', 'Valor glosado',
  'ID preço', 'Operadora', 'Valor', 'Data de vigência', 'Tempo médio (dias)',
  'Detalhes', 'Informações'
];

const fieldLabels = {
  'Município': 'Cidade / Município',
  'TUSS': 'Código TUSS',
  'Especialidades': 'Especialidade(s)',
  'UF de registro': 'UF de registro',
  'Data de admissão': 'Data de admissão',
  'Data de nascimento': 'Data de nascimento'
};

function normalize(value) {
  return String(value).normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();
}

function normalizeSearch(value) {
  return normalize(value).replace(/[^a-z0-9]+/g, ' ').trim();
}

function hasValue(value) {
  return value !== null && value !== undefined && String(value).trim() !== '';
}

function orderedFields(sourceRecords) {
  const fields = [...new Set(sourceRecords.flatMap(record => Object.keys(record.data)))]
    .filter(field => sourceRecords.some(record => hasValue(record.data[field])));
  return [
    ...columnOrder.filter(field => fields.includes(field)),
    ...fields.filter(field => !columnOrder.includes(field))
  ];
}

function buildFieldFilters() {
  const fields = orderedFields(records).filter(field => field !== 'Detalhes' && field !== 'Informações');
  fieldOptions.replaceChildren();

  fields.forEach(field => {
    const label = document.createElement('label');
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.value = field;
    checkbox.dataset.fieldFilter = '';
    label.append(checkbox, document.createTextNode(` ${fieldLabels[field] || field}`));
    fieldOptions.appendChild(label);
  });

  fieldFilters = [...fieldOptions.querySelectorAll('[data-field-filter]')];
  [...fieldFilters, ...categoryFilters].forEach(filter => {
    filter.addEventListener('change', () => {
      allFilter.checked = false;
      updateResults();
    });
  });
}

function render(results, query = '') {
  resultsBody.replaceChildren();
  resultsHeadRow.replaceChildren();
  resultCount.textContent = `${results.length} ${results.length === 1 ? 'resultado' : 'resultados'}`;
  const selectedCategoryFilters = categoryFilters.filter(filter => filter.checked);
  const selectedCategories = selectedCategoryFilters.map(filter => filter.value);
  const selectedCategoryLabels = selectedCategoryFilters.map(filter => filter.parentElement.textContent.trim());
  const selectedFields = fieldFilters.filter(filter => filter.checked).map(filter => filter.value);
  resultsTitle.textContent = query
    ? `Resultados para “${query}”`
    : selectedCategories.length
      ? selectedCategoryLabels.join(', ')
      : selectedFields.length
        ? `Campos selecionados: ${selectedFields.join(', ')}`
        : 'Todos os registros';

  if (!results.length) {
    emptyState.hidden = false;
    const hasActiveFilters = fieldFilters.some(filter => filter.checked) || categoryFilters.some(filter => filter.checked);
    if (query || hasActiveFilters) {
      emptyState.innerHTML = '<strong>Nenhum registro encontrado.</strong><p>Altere a pesquisa ou os campos selecionados.</p>';
    }
    return;
  }

  emptyState.hidden = true;
  const selectedRecords = selectedCategories.length
    ? records.filter(record => selectedCategories.includes(record.type))
    : results;
  let columns = selectedFields;

  if (!columns.length) {
    columns = orderedFields(selectedRecords).filter(column => column !== 'Categoria');
    if (selectedCategories.length !== 1) columns.unshift('Categoria');
  }

  columns.forEach(column => {
    const header = document.createElement('th');
    header.scope = 'col';
    header.textContent = fieldLabels[column] || column;
    resultsHeadRow.appendChild(header);
  });

  results.forEach(item => {
    const row = document.createElement('tr');
    columns.forEach(column => {
      const cell = document.createElement('td');
      const value = column === 'Categoria' ? item.type : item.data[column];
      cell.textContent = hasValue(value) ? value : '—';
      if (column === 'Nome') cell.className = 'name-cell';
      row.appendChild(cell);
    });
    resultsBody.appendChild(row);
  });
}

function filterRecords(query = '') {
  const tokens = normalizeSearch(query).split(/\s+/).filter(Boolean);
  const selectedFields = fieldFilters.filter(filter => filter.checked).map(filter => filter.value);
  const selectedCategories = categoryFilters.filter(filter => filter.checked).map(filter => filter.value);

  return records.filter(record => {
    if (selectedCategories.length && !selectedCategories.includes(record.type)) return false;
    if (!selectedFields.every(field => hasValue(record.data[field]))) return false;
    return tokens.every(token => record.searchText.includes(token));
  });
}

function updateResults() {
  render(filterRecords(input.value), input.value.trim());
}

form.addEventListener('submit', event => {
  event.preventDefault();
  updateResults();
});

filterToggle.addEventListener('click', () => {
  const isOpening = filtersPanel.hidden;
  filtersPanel.hidden = !isOpening;
  filterToggle.setAttribute('aria-expanded', String(isOpening));
  filterToggle.setAttribute('aria-label', isOpening ? 'Fechar filtros' : 'Abrir filtros');
});

allFilter.addEventListener('change', () => {
  if (allFilter.checked) {
    fieldFilters.forEach(filter => { filter.checked = false; });
    categoryFilters.forEach(filter => { filter.checked = false; });
  }
  updateResults();
});

async function loadRecords() {
  resultCount.textContent = 'Carregando registros...';
  try {
    const response = await fetch('/api/records');
    if (!response.ok) {
      throw new Error(`O servidor respondeu com status ${response.status}.`);
    }

    records = await response.json();
    if (!Array.isArray(records)) {
      throw new Error('A resposta da API não contém uma lista de registros.');
    }
    records = records.map(record => ({
      ...record,
      searchText: normalizeSearch([
        record.type,
        ...Object.entries(record.data).flatMap(([field, value]) => [field, value])
      ].filter(hasValue).join(' '))
    }));

    buildFieldFilters();
    updateResults();
  } catch (error) {
    console.error('Falha ao carregar os registros do banco de dados:', error);
    resultCount.textContent = 'Falha ao carregar os dados';
    emptyState.hidden = false;
    emptyState.innerHTML = '<strong>Não foi possível carregar os dados do banco.</strong><p>Verifique se o servidor está em execução e tente novamente.</p>';
  }
}

loadRecords();
