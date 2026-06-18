import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: { 'Content-Type': 'application/json' },
})

export default {
  // Registros
  listar(params = {})         { return api.get('/registros', { params }) },
  criar(dados)                { return api.post('/registros', dados) },
  atualizar(id, dados)        { return api.put(`/registros/${id}`, dados) },
  remover(id)                 { return api.delete(`/registros/${id}`) },

  // Resumo geral
  resumo()                    { return api.get('/registros/resumo') },
}
