<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Registro extends Model
{
    protected $fillable = [
        'data',
        'metros',
        'preco_m3',
        'observacao',
    ];

    protected $casts = [
        'data'        => 'date',
        'metros'      => 'float',
        'preco_m3'    => 'float',
        'valor_total' => 'float',
    ];
}
