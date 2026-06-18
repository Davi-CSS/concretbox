<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('registros', function (Blueprint $table) {
            $table->id();
            $table->date('data');
            $table->decimal('metros', 8, 2);
            $table->decimal('preco_m3', 8, 2)->default(2.20);
            $table->decimal('valor_total', 10, 2)->storedAs('metros * preco_m3');
            $table->string('observacao')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('registros');
    }
};
