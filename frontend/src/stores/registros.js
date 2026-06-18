import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../services/api'

export const useRegistroStore = defineStore('registros', () => {
  const registros  = ref([])
  const resumo     = ref({ por_dia: [], geral: { metros: 0, valor_total: 0, dias: 0 } })
  const carregando = ref(false)
  const erro       = ref(null)

  const totalMetrosDia = computed(() => (data) => {
    return registros.value
      .filter(r => r.data === data)
      .reduce((s, r) => s + r.metros, 0)
  })

  const totalValorDia = computed(() => (data) => {
    return registros.value
      .filter(r => r.data === data)
      .reduce((s, r) => s + r.valor_total, 0)
  })

  async function carregar(params = {}) {
    carregando.value = true
    erro.value = null
    try {
      const res = await api.listar(params)
      registros.value = res.data.data
    } catch (e) {
      erro.value = 'Erro ao carregar registros.'
    } finally {
      carregando.value = false
    }
  }

  async function carregarResumo() {
    try {
      const res = await api.resumo()
      resumo.value = res.data
    } catch (e) {
      erro.value = 'Erro ao carregar resumo.'
    }
  }

  async function adicionar(dados) {
    const res = await api.criar(dados)
    registros.value.unshift(res.data)
    await carregarResumo()
    return res.data
  }

  async function remover(id) {
    await api.remover(id)
    registros.value = registros.value.filter(r => r.id !== id)
    await carregarResumo()
  }

  return { registros, resumo, carregando, erro, totalMetrosDia, totalValorDia, carregar, carregarResumo, adicionar, remover }
})
