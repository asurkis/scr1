# Лабораторная работа Lab2 SCR1 sim
## Задание
| Вариант | Вид исключения | Тест | Reset Vector | Trap Vector | При обработке |
| ------- | -------------- | ---- | ------------ | ----------- | ------------- |
| 15 | Environment call from M-mode | `isa/rv32mi/scall.S` | `0xe00` | `0x840` | Вывод строки `ecall` |


1. Необходимо добавить копию репозитория SCR1 https://github.com/syntacore/scr1 в ваш личный аккаунт на GitHub (который вы заводили для предыдущих лабораторных). Это будет ваш рабочий репозиторий, в котором вы сможете делать любые изменения с проектом. Копирование производится командой fork https://help.github.com/en/articles/fork-a-repo.
1. В репозитории создать ветку с именем lab_sim. В этой ветке вы будете коммитить все изменения проекта для данной лабораторной.
    - Убедитесь, что проект собирается и все тесты проходят в симуляции до внесения изменений в проект. Подробная инструкция по сборке описана в SCR1 User Manual раздел "Simulation enviroment".
    - В качестве программы-симулятора мы рекомендуем использовать Verilator, но по желанию вы можете использовать любую из поддерживаемого списка.

1. Включить параметр `TRACE`, чтобы при симуляции генерировался трейслог. Отредактировать список тестов, чтобы на выполнение остался только один riscv_isa тест по варианту задания. Запустить симуляцию для Verilator и убедиться, что успешно собирается и проходит только один выбранный тест и трейслог прохождения находится в директории `build`.
1. В соответствии с вариантом задания модифицировать обработку исключений `trap_vector` в файле `./sim/tests/common/riscv_macros.h`.
1. Установить в файле `./src/includes/scr1_arch_description.svh` параметры ядра Reset Vector и Trap Vector в соответствии с вариантом задания.
1. Изменить linker-скрипт `./sim/tests/common/link.ld` и участвующие в сборке файлы программы для корректного запуска теста с новыми значениями Reset Vector и Trap Vector.
1. Сохранить в директории `./results`: результат симуляции (`test_results.txt`), дизассемблер теста (`*.dump`) и трейс лог (`tracelog_core_0.log`).
1. Создать в директории `./results` файл с отчетом по проделанной README.md.
1. Запушить все произведенные изменения в ветку `lab_sim`.

## Выполнение
1. Запустил `make clean; make`, чтобы убедиться, что успешно проходят все тесты.
1. Добавил строку 68: `rv32_isa_tests = isa/rv32mi/scall.S` к `sim/tests/riscv_isa/rv32_tests.inc`.
1. Запустил `make clean; make TARGETS=riscv_isa TRACE=1`, чтобы убедиться, что прогоняется только нужный тест и записывается трассировка.
1. Добавил к файлу `sim/tests/common/riscv_macros.h` строки 110-111:
    ```
    .org 0x740, 0; \
    .balign 64;    \
    ```
    и 146:
    ```
    .org 0xD20, 0; \
    ```
    (директива `.org` устанавливает позицию относительно начала секции, а не в абсолютных адресах,
    поэтому значение пришлось искать подбором)
1. Поменял строки 141-142 в файле `src/includes/scr1_arch_description.svh`:
    ```
    parameter bit [`SCR1_XLEN-1:0] SCR1_ARCH_RST_VECTOR = 'he00; // Reset vector value (start address after reset)
    parameter bit [`SCR1_XLEN-1:0] SCR1_ARCH_MTVEC_BASE = 'h840; // MTVEC.base field reset value, or constant value for MTVEC.base bits that are hardwired
    ```
    (поменял значения с `'h200` и `'h1c00` на `'he00` и `'h840` соответственно)
1. Запустил `make clean && make TARGETS=riscv_isa TRACE=1`, чтобы убедиться, что адреса меток установлены успешно:
    1. Убедился, что тест проходит успешно:
        ```
        scall.hex		OK	  PASS
        ```
    1. Посмотрел адреса `build/verilator_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_1/scall.dump`:
        1. ```
            00000840 <trap_vector>:
            ```
        1. ```
            00000e00 <_start>:
            ```
    1. Посмотрел трассировку `build/verilator_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_1/tracelog_core_0.log`:
        1. Программа начинается с адреса `00000e00`
        1. Для обработки исключения (exception) переходит по адресу `00000840`
1. Добавил строки 209-212 в файле ``:
    ```
    #define EXTRA_DATA                   \
      .section .data;                    \
      .balign 64;                        \
      variant_string: .string "ecall\n";
    ```
1. Добавил код на строках 129-138 в файле `sim/tests/common/riscv_macros.h`:
    ```
    _handle_machine_ecall:         \
            la t0, variant_string; \
            la t1, 0xF0000000;     \
            addi t2, x0, 0;        \
    1:      lb t2, 0(t0);          \
            beq t2, x0, 2f;        \
            sb t2, 0(t1);          \
            addi t0, t0, 1;        \
            j 1b;                  \
    2:      j _report;             \
    ```
1. Поменял строку 120 в файле `sim/tests/common/riscv_macros.h`:
    ```
            beq a4, a5, _handle_machine_ecall; \
    ```
1. Запустил `make clean && make TARGETS=riscv_isa TRACE=1`:
    1. Убедился, что тест проходит успешно:
        ```
        scall.hex		OK	  PASS
        ```
    1. Посмотрел адреса `build/verilator_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_1/scall.dump`:
        1. ```
            00000840 <trap_vector>:
            ```
        1. ```
            00000e00 <_start>:
            ```
        1. ```
            0000086c <_handle_machine_ecall>:
            ```
    1. Посмотрел трассировку `build/verilator_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_1/tracelog_core_0.log`:
        1. Программа начинается с адреса `00000e00`
        1. Для обработки исключения (exception) переходит по адресу `00000840`
        1. Во время трассировки проходит по циклу `0000087c..0000088a` 5 раз, на 6 &mdash; выходит
    1. Посмотрел вывод теста в терминале:
        ```
        ---Test:                        scall.hex
        ecall
        Test passed
        ```
        и в файле `build/verilator_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_1/sim_results.txt`:
        ```
        scr1_top_tb_ahb
        [0;34m---Test:                        scall.hex[0m
        ecall
        [0;32mTest passed[0m

        #--------------------------------------
        # Summary: 1/1 tests passed
        #--------------------------------------

        - /hdd/homework/comp-arch/scr1/src/tb/scr1_top_tb_runtests.sv:181: Verilog $finish
        ```
        чтобы убедиться, что выводится строка &laquo;ecall&raquo;
1. Скопировал файлы `test_results.txt`, `scall.dump`, `tracelog_core_0.log` и `sim_results.txt`
    из директории `build/verilator_AHB_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_1`
    в директорию `results`.
## Результаты
- Из результата симуляции `test_results.txt` видно, что был выбран только необходимый тест и тест успешно выполнился.
- Из дампа теста `scall.dump` видно, что `trap_vector` корректно установлен по адресу `0x840`, а `_start` по адресу `0xe00`.
- Из трейслога `tracelog_core_0.log` видно, что процессор начинает работать с адреса `0xe00` и при возникновении `exception` проходит по адресу `0x840`, а также проходит по циклу `0x87c..0x88a` для вывода строки &laquo;ecall&raquo;.
- Из результата симуляции `sim_results.txt` видно, что строка &laquo;ecall&raquo; выводится в терминал.
