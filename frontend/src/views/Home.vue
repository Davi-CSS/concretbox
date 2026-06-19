<template>
  <div>
    <h1>Lançar metragem</h1>

    <div class="metrics">
      <div class="metric">
        <span class="metric-label">Total no dia selecionado</span>
        <span class="metric-value blue">{{ fmtMetro(totalDoDia.metros) }}</span>
      </div>
      <div class="metric">
        <span class="metric-label">Valor no dia selecionado</span>
        <span class="metric-value green">{{ fmtMoney(totalDoDia.valor) }}</span>
      </div>
      <div class="metric">
        <span class="metric-label">Acumulado geral (m³)</span>
        <span class="metric-value">{{ fmtMetro(store.resumo.geral.metros) }}</span>
      </div>
      <div class="metric">
        <span class="metric-label">Acumulado geral (R$)</span>
        <span class="metric-value green">{{ fmtMoney(store.resumo.geral.valor_total) }}</span>
      </div>
    </div>

    <div class="card">
      <div class="header-row">
        <h2>Novo lançamento</h2>
        <span v-if="ehHoje" class="tag-hoje">hoje</span>
      </div>

      <div class="form-group">
        <label>Data</label>
        <input v-model="form.data" type="date" :max="hoje" />
      </div>

      <div class="form-group">
        <label>Metragem (m³)</label>
        <input v-model.number="form.metros" type="number" step="0.01" min="0.01" placeholder="0,00" />
      </div>

      <div class="form-group">
        <label>Preço por m³ (R$)</label>
        <input v-model.number="form.preco_m3" type="number" step="0.01" min="0.01" placeholder="2.20" />
        <span class="hint">Padrão: R$ 2,20/m³</span>
      </div>

      <div class="form-group">
        <label>Observação <em>(opcional)</em></label>
        <input v-model="form.observacao" type="text" placeholder="Manhã, tarde, trecho A..." maxlength="255" />
      </div>

      <div class="preview" v-if="form.metros > 0">
        {{ fmtMetro(form.metros) }} × R$ {{ Number(form.preco_m3).toFixed(2) }} =
        <strong>{{ fmtMoney(form.metros * form.preco_m3) }}</strong>
      </div>

      <p v-if="erro" class="erro">{{ erro }}</p>

      <button @click="salvar" :disabled="salvando" class="btn-primary">
        {{ salvando ? 'Salvando...' : 'Registrar' }}
      </button>
    </div>

    <div v-if="registrosDoDia.length" class="card">
      <h2>Lançamentos de {{ fmtDataBR(form.data) }}</h2>
      <ul class="lista">
        <li v-for="r in registrosDoDia" :key="r.id" class="lista-item">
          <span>{{ fmtMetro(r.metros) }} × R$ {{ Number(r.preco_m3).toFixed(2).replace('.', ',') }} = <strong>{{ fmtMoney(r.valor_total) }}</strong></span>
          <span v-if="r.observacao" class="obs">{{ r.observacao }}</span>
          <button @click="remover(r.id)" class="btn-remover" title="Remover">×</button>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRegistroStore } from '../stores/registros'

const store = useRegistroStore()
const salvando = ref(false)
const erro     = ref(null)

const hoje = new Date().toISOString().slice(0, 10)

const form = ref({ data: hoje, metros: null, preco_m3: 2.20, observacao: '' })

const ehHoje = computed(() => form.value.data === hoje)

const registrosDoDia = computed(() =>
  store.registros.filter(r => r.data.substring(0, 10) === form.value.data)
)

const totalDoDia = computed(() => ({
  metros: registrosDoDia.value.reduce((s, r) => s + r.metros, 0),
  valor:  registrosDoDia.value.reduce((s, r) => s + r.valor_total, 0),
}))

function fmtMetro(v) {
  return Number(v || 0).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' m³'
}

function fmtMoney(v) {
  return 'R$ ' + Number(v || 0).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function fmtDataBR(d) {
  const data = d.substring(0, 10)
  const [y, m, day] = data.split('-')
  return `${day}/${m}/${y}`
}

async function carregarDia() {
  await store.carregar({ data: form.value.data })
}

async function salvar() {
  if (!form.value.metros || form.value.metros <= 0) {
    erro.value = 'Informe a metragem.'
    return
  }
  if (!form.value.data) {
    erro.value = 'Informe a data.'
    return
  }
  erro.value   = null
  salvando.value = true
  try {
    await store.adicionar({
      data:       form.value.data,
      metros:     form.value.metros,
      preco_m3:   form.value.preco_m3 || 2.20,
      observacao: form.value.observacao || null,
    })
    form.value = { ...form.value, metros: null, observacao: '' }
  } catch (e) {
    erro.value = 'Erro ao salvar. Tente novamente.'
  } finally {
    salvando.value = false
  }
}

async function remover(id) {
  if (!confirm('Remover este lançamento?')) return
  await store.remover(id)
}

watch(() => form.value.data, () => {
  carregarDia()
})

onMounted(async () => {
  await carregarDia()
  await store.carregarResumo()
})
</script>

<style scoped>
h1 { font-size: 20px; font-weight: 600; margin-bottom: 1.25rem; }
h2 { font-size: 15px; font-weight: 600; margin-bottom: 1rem; color: #3d3d3a; }

.header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.header-row h2 { margin-bottom: 0; }

.tag-hoje {
  font-size: 11px;
  background: #eaf3de;
  color: #3b6d11;
  border-radius: 4px;
  padding: 2px 8px;
  font-weight: 500;
}

.metrics {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 12px;
  margin-bottom: 1.5rem;
}

.metric {
  background: #fff;
  border: 1px solid #e5e3dc;
  border-radius: 10px;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.metric-label { font-size: 12px; color: #73726c; }
.metric-value { font-size: 20px; font-weight: 600; }
.metric-value.green { color: #0f6e56; }
.metric-value.blue  { color: #185fa5; }

.card {
  background: #fff;
  border: 1px solid #e5e3dc;
  border-radius: 12px;
  padding: 1.25rem;
  margin-bottom: 1.25rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 1rem;
}

.form-group label {
  font-size: 13px;
  color: #3d3d3a;
  font-weight: 500;
}

.form-group input {
  border: 1px solid #d3d1c7;
  border-radius: 8px;
  padding: 8px 12px;
  font-size: 14px;
  color: #1c1c1a;
  background: #fff;
  outline: none;
  transition: border-color 0.15s;
}

.form-group input:focus { border-color: #185fa5; }

.hint { font-size: 11px; color: #888780; }

.preview {
  background: #eaf3de;
  color: #3b6d11;
  border-radius: 8px;
  padding: 10px 14px;
  font-size: 14px;
  margin-bottom: 1rem;
}

.btn-primary {
  background: #1c1c1a;
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 10px 20px;
  font-size: 14px;
  cursor: pointer;
  width: 100%;
  transition: opacity 0.15s;
}

.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-primary:hover:not(:disabled) { opacity: 0.85; }

.erro { color: #a32d2d; font-size: 13px; margin-bottom: 0.75rem; }

.lista { list-style: none; display: flex; flex-direction: column; gap: 8px; }

.lista-item {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 13px;
  padding: 8px 10px;
  background: #f5f5f4;
  border-radius: 8px;
}

.lista-item span:first-child { flex: 1; }

.obs {
  font-size: 11px;
  color: #888780;
  flex-shrink: 0;
}

.btn-remover {
  background: none;
  border: none;
  cursor: pointer;
  color: #a32d2d;
  font-size: 16px;
  line-height: 1;
  padding: 2px 6px;
  border-radius: 4px;
  flex-shrink: 0;
}

.btn-remover:hover { background: #fcebeb; }
</style>