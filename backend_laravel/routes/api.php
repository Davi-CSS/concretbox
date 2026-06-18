<?php

use App\Http\Controllers\RegistroController;
use Illuminate\Support\Facades\Route;

Route::prefix('registros')->group(function () {
    Route::get('/',          [RegistroController::class, 'index']);
    Route::post('/',         [RegistroController::class, 'store']);
    Route::get('/resumo',    [RegistroController::class, 'resumo']);
    Route::get('/{registro}',    [RegistroController::class, 'show']);
    Route::put('/{registro}',    [RegistroController::class, 'update']);
    Route::delete('/{registro}', [RegistroController::class, 'destroy']);
});
