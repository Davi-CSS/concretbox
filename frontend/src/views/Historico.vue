<template>
  <div>
    <div class="header-row">
      <h1>Histórico</h1>
      <input v-model="mesFiltro" type="month" @change="filtrar" />
    </div>

    <div class="metrics">
      <div class="metric">
        <span class="metric-label">Total m³ (período)</span>
        <span class="metric-value blue">{{ fmtMetro(totais.metros) }}</span>
      </div>
      <div class="metric">
        <span class="metric-label">Total R$ (período)</span>
        <span class="metric-value green">{{ fmtMoney(totais.valor_total) }}</span>
      </div>
      <div class="metric">
        <span class="metric-label">Dias trabalhados</span>
        <span class="metric-value">{{ diasComRegistro }} dias</span>
      </div>
    </div>

    <div v-if="store.carregando" class="vazio">Carregando...</div>

    <div v-else-if="!diasAgrupados.length" class="vazio">
      Nenhum registro para o período selecionado.
    </div>

    <div v-else class="card" v-for="dia in diasAgrupados" :key="dia.data">
      <div class="dia-header">
        <span class="dia-data">{{ fmtDataBR(dia.data) }}</span>
        <span class="dia-total">{{ fmtMetro(dia.metros) }} · {{ fmtMoney(dia.valor) }}</span>
      </div>
      <ul class="lista">
        <li v-for="r in dia.registros" :key="r.id" class="lista-item">
          <span>{{ fmtMetro(r.metros) }} × R$ {{ Number(r.preco_m3).toFixed(2).replace('.', ',') }} = <strong>{{ fmtMoney(r.valor_total) }}</strong></span>
          <span v-if="r.observacao" class="obs">{{ r.observacao }}</span>
          <button @click="remover(r.id)" class="btn-remover" title="Remover">×</button>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRegistroStore } from '../stores/registros'

const store = useRegistroStore()

const mesFiltro = ref(new Date().toISOString().slice(0, 7))

const totais = computed(() => ({
  metros:      store.registros.reduce((s, r) => s + r.metros, 0),
  valor_total: store.registros.reduce((s, r) => s + r.valor_total, 0),
}))

const diasAgrupados = computed(() => {
  const mapa = {}
  store.registros.forEach(r => {
    if (!mapa[r.data]) mapa[r.data] = { data: r.data, metros: 0, valor: 0, registros: [] }
    mapa[r.data].metros += r.metros
    mapa[r.data].valor  += r.valor_total
    mapa[r.data].registros.push(r)
  })
  return Object.values(mapa).sort((a, b) => b.data.localeCompare(a.data))
})

const diasComRegistro = computed(() => diasAgrupados.value.length)

function fmtMetro(v) {
  return Number(v || 0).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' m³'
}

function fmtMoney(v) {
  return 'R$ ' + Number(v || 0).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function fmtDataBR(d) {
  const data = d.substring(0, 10)
  const [y, m, day] = data.split('-')
  const weekdays = ['dom', 'seg', 'ter', 'qua', 'qui', 'sex', 'sáb']
  const wd = weekdays[new Date(+y, +m - 1, +day).getDay()]
  return `${wd}, ${day}/${m}/${y}`
}

async function filtrar() {
  await store.carregar({ mes: mesFiltro.value })
}

async function remover(id) {
  if (!confirm('Remover este lançamento?')) return
  await store.remover(id)
}

onMounted(() => filtrar())
</script>

<style scoped>
h1 { font-size: 20px; font-weight: 600; }

.header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 1.25rem;
  flex-wrap: wrap;
}

.header-row input[type="month"] {
  border: 1px solid #d3d1c7;
  border-radius: 8px;
  padding: 6px 12px;
  font-size: 13px;
  color: #1c1c1a;
  background: #fff;
  outline: none;
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

.vazio {
  text-align: center;
  color: #888780;
  font-size: 14px;
  padding: 3rem 0;
}

.card {
  background: #fff;
  border: 1px solid #e5e3dc;
  border-radius: 12px;
  padding: 1.25rem;
  margin-bottom: 1rem;
}

.dia-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.75rem;
  flex-wrap: wrap;
  gap: 8px;
}

.dia-data  { font-size: 14px; font-weight: 600; color: #1c1c1a; }
.dia-total { font-size: 13px; color: #0f6e56; font-weight: 500; }

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

.obs { font-size: 11px; color: #888780; flex-shrink: 0; }

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
