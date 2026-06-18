<?php

namespace App\Http\Controllers;

use App\Models\Registro;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class RegistroController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Registro::query()->orderBy('data', 'desc')->orderBy('created_at', 'desc');

        if ($request->filled('data')) {
            $query->whereDate('data', $request->data);
        }

        if ($request->filled('mes')) {
            $query->whereYear('data', substr($request->mes, 0, 4))
                  ->whereMonth('data', substr($request->mes, 5, 2));
        }

        $registros = $query->get();

        $totais = [
            'metros'      => round($registros->sum('metros'), 2),
            'valor_total' => round($registros->sum('valor_total'), 2),
            'quantidade'  => $registros->count(),
        ];

        return response()->json([
            'data'   => $registros,
            'totais' => $totais,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'data'        => 'required|date',
            'metros'      => 'required|numeric|min:0.01',
            'preco_m3'    => 'required|numeric|min:0.01',
            'observacao'  => 'nullable|string|max:255',
        ]);

        $registro = Registro::create($validated);

        return response()->json($registro, 201);
    }

    public function show(Registro $registro): JsonResponse
    {
        return response()->json($registro);
    }

    public function update(Request $request, Registro $registro): JsonResponse
    {
        $validated = $request->validate([
            'data'       => 'sometimes|date',
            'metros'     => 'sometimes|numeric|min:0.01',
            'preco_m3'   => 'sometimes|numeric|min:0.01',
            'observacao' => 'nullable|string|max:255',
        ]);

        $registro->update($validated);

        return response()->json($registro);
    }

    public function destroy(Registro $registro): JsonResponse
    {
        $registro->delete();

        return response()->json(['message' => 'Registro removido.']);
    }

    public function resumo(): JsonResponse
    {
        $porDia = Registro::selectRaw('data, SUM(metros) as metros, SUM(valor_total) as valor_total')
            ->groupBy('data')
            ->orderBy('data', 'desc')
            ->get();

        $geral = [
            'metros'      => round(Registro::sum('metros'), 2),
            'valor_total' => round(Registro::sum('valor_total'), 2),
            'dias'        => Registro::distinct('data')->count('data'),
        ];

        return response()->json([
            'por_dia' => $porDia,
            'geral'   => $geral,
        ]);
    }
}
