#include "riscv_test.h"

RVTEST_RV32U

RVTEST_CODE_BEGIN
        /* Тривиальный вариант: конкатенация нулей с нулями */
        .word 0x0000038B /* 12{0}, x0, 000, t2 (x7), 0001011 ; cnci t2, x0, 0 */
        li t1, 0x000
        bne t1, t2, fail

        /* Теперь с единицами */
        .word 0x7FF0038B /* 0+11{1}, x0, 000, t2 (x7), 0001011 ; cnci t2, t1, 0xFFF */
        li t1, 0x000007FF
        bne t1, t2, fail

        /* Проверка, что старший бит константы не расширяется знаково */
        .word 0xFFF0038B /* 0+11{1}, x0, 000, t2 (x7), 0001011 ; cnci t2, t1, 0xFFF */
        li t1, 0x00000FFF
        bne t1, t2, fail

        /* Чтение из t1, а не x0 */
        .word 0xFFF3038B /* 0+11{1}, t1 (x6), 000, t2 (x7), 0001011 ; cnci t2, t1, 0xFFF */
        li t1, 0x00000FFF
        bne t1, t2, fail

        /* Чтение и запись в t2, проверка затирания единиц нулями */
        .word 0x0003838B /* 12{0}, t2, 000, t2, 0001011 ; cnci t2, t2, 0 */
        li t1, 0x00000000
        bne t1, t2, fail

        /* Проверка сохранения старшей части регистра, чтение из t2, запись в t1 */
        li t2, 0xFFFFF000
        .word 0x0003830B /* 12{0}, t2 (x7), 000, t1 (x6), 0001011 ; cnci t1, t2, 0 */
        bne t1, t2, fail

        /* И если записывать единицы тоже */
        .word 0xFFF3830B /* 12{1}, t2 (x7), 000, t1 (x6), 0001011 ; cnci t1, t2, 0 */
        li t2, 0xFFFFFFFF
        bne t1, t2, fail

        /* Запись в x0 дает 0 */
        .word 0xFFF3000B /* 12{1}, t1 (x6), 000, x0, 0001011 ; cnci x0, t1, 0xFFF */
        xor t1, t1, t1 /* Нельзя проверять через сам x0 */
        bne x0, t1, fail

        RVTEST_PASS
fail:
        RVTEST_FAIL
RVTEST_CODE_END

RVTEST_DATA_BEGIN
RVTEST_DATA_END
