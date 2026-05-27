# Simulation Guide

Этот файл объясняет:
- почему команды запуска выглядят именно так;
- зачем используется `wsl`;
- что именно компилируется и что именно запускается;
- какие входы подаются в каждый testbench;
- какой результат нужно ожидать;
- что находится в папке `sim/`.

## 1. Структура проекта

- `rtl/` - исходные RTL-модули процессора.
- `tb/` - testbench-файлы и тестовая программа `program.hex`.
- `sim/` - результаты симуляции:
  - скомпилированные исполняемые файлы Icarus Verilog;
  - waveform-файлы `.vcd`.

Примеры:
- `rtl/pc.v` - модуль счетчика команд.
- `tb/tb_pc.v` - testbench для `pc.v`.
- `sim/pc_tb` - уже скомпилированный результат для запуска через `vvp`.
- `sim/tb_pc.vcd` - временные диаграммы теста `pc`.

Важно:
файлы в `sim/` не являются входом для проекта. Это результат компиляции и симуляции. Проверять "по одному файлу из `sim/`" как исходники не нужно, потому что это уже выходные артефакты.

## 2. Почему команда выглядит так

Если вы уже находитесь в WSL-терминале Ubuntu, используйте короткую команду:

```bash
cd /mnt/d/Users/Desktop/verilogProject
iverilog -g2012 -I rtl -o sim/pc_tb tb/tb_pc.v rtl/pc.v && vvp sim/pc_tb
```

Если вы запускаете из PowerShell, тогда нужен префикс:

```powershell
wsl bash -lc "cd /mnt/d/Users/Desktop/verilogProject && iverilog -g2012 -I rtl -o sim/pc_tb tb/tb_pc.v rtl/pc.v && vvp sim/pc_tb"
```

Разбор самой команды `iverilog ... && vvp ...`:

- `iverilog` - компилятор Verilog.
- `-g2012` - использовать синтаксис Verilog-2001/2012, чтобы не было проблем с современными конструкциями.
- `-I rtl` - добавить папку `rtl/` в список путей для `include`, потому что используется файл `rtl/isa_defs.vh`.
- `-o sim/pc_tb` - сохранить результат компиляции в файл `sim/pc_tb`.
- `tb/tb_pc.v rtl/pc.v` - список исходных файлов, которые компилируются.
- `&&` - если компиляция успешна, выполнить следующую команду.
- `vvp sim/pc_tb` - запустить скомпилированную симуляцию.

## 3. Почему используется WSL

В текущей системе `iverilog` и `vvp` доступны в WSL, но не установлены как обычные Windows-команды в `PATH`.

Поэтому запуск через WSL сейчас обязателен.

Без WSL запускать можно только если:
- установить Windows-версию Icarus Verilog;
- добавить `iverilog` и `vvp` в `PATH`;
- убедиться, что команды `iverilog -V` и `vvp -V` работают прямо в PowerShell.

Тогда команда станет такой:

```powershell
iverilog -g2012 -I rtl -o sim/pc_tb tb/tb_pc.v rtl/pc.v
vvp sim/pc_tb
```

На данный момент в вашем окружении это не работает, поэтому:
- в PowerShell нужен префикс `wsl bash -lc "..."`
- внутри WSL-терминала `wsl` писать не нужно, там запускаются просто `iverilog` и `vvp`

## 4. Почему мы не запускаем "один файл из sim"

Потому что `sim/pc_tb`, `sim/reg_tb`, `sim/simv` - это не исходный Verilog-код, а уже собранные исполняемые файлы симулятора.

Правильная схема такая:

1. Берем исходники из `tb/` и `rtl/`.
2. Компилируем их через `iverilog`.
3. Получаем исполняемый файл в `sim/`.
4. Запускаем этот файл через `vvp`.
5. Получаем текстовый результат в консоли и `.vcd` для waveform.

Если файл уже скомпилирован, можно запустить только его:

```bash
cd /mnt/d/Users/Desktop/verilogProject
vvp sim/pc_tb
```

Но это имеет смысл только если исходники после последней компиляции не менялись.

## 5. Общий принцип testbench

Каждый testbench в этом проекте выполняет одну и ту же методику проверки:

1. Создает экземпляр проверяемого RTL-блока.
2. Подает на него заранее подготовленные входные сигналы.
3. Если блок синхронный, генерирует такт `clk`.
4. После ключевых событий печатает значения сигналов в терминал через `$display`.
5. Сравнивает фактический результат с ожидаемым.
6. При ошибке выдает `ERROR: ...`.
7. Дополнительно сохраняет waveform в `sim/*.vcd`.

То есть вход в симуляцию - это не ввод с клавиатуры, а сигналы, которые сам testbench формирует внутри Verilog-кода.

Важно:
теперь testbench настроены так, чтобы в терминале были видны изменения состояний. Это позволяет сначала смотреть текстовый лог и только потом, если нужно, переходить к `.vcd`.

## 6. Порядок запуска: от малого к большому

Во всех примерах ниже используются команды для терминала WSL. Если вы уже находитесь в Ubuntu-терминале, запускайте именно их.

### 6.1. Program Counter

За что отвечает блок:
- `program_counter` хранит адрес текущей инструкции.
- Если `pc_load = 0`, на каждом такте адрес увеличивается на `1`.
- Если `pc_load = 1`, вместо инкремента загружается значение `pc_next`.
- Если `rst_n = 0`, `PC` сбрасывается в `0`.

Почему этот блок важен:
- без корректного `PC` процессор не сможет последовательно читать инструкции;
- команды `JUMP` и `BEQ` в итоге сводятся к управлению `pc_load` и `pc_next`.

Исходники:
- `tb/tb_pc.v`
- `rtl/pc.v`

Команда:

```bash
cd /mnt/d/Users/Desktop/verilogProject
iverilog -g2012 -I rtl -o sim/pc_tb tb/tb_pc.v rtl/pc.v && vvp sim/pc_tb
```

Что подается на вход:
- `clk` генерируется автоматически: каждые `5 ns` меняет состояние;
- `rst_n = 0`, затем `rst_n = 1`;
- `pc_load = 0`, чтобы проверить обычный ход по инструкциям;
- затем `pc_load = 1` и `pc_next = 16'h0042`, чтобы проверить переход.

Что именно мы проверяем:
- во время сброса `pc_current` должен быть `0`;
- после снятия сброса счетчик должен идти `0 -> 1 -> 2 -> ...`;
- при активации `pc_load` счетчик должен принять `pc_next`;
- после загрузки перехода он снова должен начать инкрементироваться.

Что означает лог в терминале:
- `pc_current` - текущее значение счетчика команд;
- `pc_load` - команда "загрузи адрес перехода";
- `pc_next` - сам адрес перехода.

Что увидите в терминале:

```text
=== PC test start ===
Block purpose: program counter stores current instruction address.
Signals: rst_n resets PC, pc_load loads jump target, pc_next is jump address.
[PC] reset active: rst_n=0 pc_load=0 pc_next=0x0000 pc_current=0x0000
[PC] reset released: rst_n=1 pc_current=0x0000
[PC] increment step 1: pc_current=0x0001 (1)
[PC] increment step 2: pc_current=0x0002 (2)
[PC] request jump: pc_load=1 pc_next=0x0042
[PC] after jump load: pc_current=0x0042 (66)
[PC] increment after jump: pc_current=0x0043 (67)
PC tests completed.
```

Ожидаемый результат:
- видно, что счетчик сначала стоит в `0`;
- потом увеличивается;
- потом загружает `0x0042`;
- потом становится `0x0043`.

### 6.2. Register File

За что отвечает блок:
- `register_file` хранит регистры общего назначения процессора;
- имеет два порта чтения и один порт записи;
- регистр `R0` аппаратно считается нулевым и не должен изменяться.

Почему этот блок важен:
- все арифметические, логические и часть операций памяти работают через регистры;
- если регистровый файл работает неверно, весь процессор будет выдавать неверные результаты.

Исходники:
- `tb/tb_reg_file.v`
- `rtl/reg_file.v`

Команда:

```bash
cd /mnt/d/Users/Desktop/verilogProject
iverilog -g2012 -I rtl -o sim/reg_tb tb/tb_reg_file.v rtl/reg_file.v && vvp sim/reg_tb
```

Что подается на вход:
- `clk`;
- `rst_n`;
- `read_addr1`, `read_addr2`;
- `write_addr`, `write_data`;
- `reg_write`.

Что именно мы делаем:
- проверяем, что после сброса регистры пустые;
- читаем `R0` и убеждаемся, что там всегда `0`;
- записываем `0x1234` в `R1`;
- записываем `0x5678` в `R2`;
- читаем сразу два регистра;
- пытаемся записать в `R0` и убеждаемся, что он не меняется.

Что увидите в терминале:

```text
=== Register file test start ===
Block purpose: stores 8 general-purpose registers and serves two read ports plus one write port.
[REG] reset released. All registers must be zero.
[REG] read R0 -> 0x0000
[REG] write request: reg_write=1 write_addr=R1 write_data=0x1234
[REG] read R1 -> 0x1234
[REG] write request: reg_write=1 write_addr=R2 write_data=0x5678
[REG] dual read: R1=0x1234 R2=0x5678
[REG] forbidden write request: write_addr=R0 write_data=0xAAAA
[REG] read R0 after forbidden write -> 0x0000
Register file tests completed.
```

Ожидаемый результат:
- `R1 = 0x1234`
- `R2 = 0x5678`
- `R0 = 0x0000`

### 6.3. Data Memory

За что отвечает блок:
- `data_memory` хранит данные, а не инструкции;
- используется командами `LOAD` и `STORE`.

Почему этот блок важен:
- через него процессор читает и сохраняет результаты вычислений;
- ошибки здесь приводят к неправильной работе памяти данных.

Исходники:
- `tb/tb_data_mem.v`
- `rtl/data_mem.v`

Команда:

```bash
cd /mnt/d/Users/Desktop/verilogProject
iverilog -g2012 -I rtl -o sim/data_tb tb/tb_data_mem.v rtl/data_mem.v && vvp sim/data_tb
```

Что подается на вход:
- `clk`;
- `mem_write`;
- `addr`;
- `write_data`.

Что именно мы делаем:
- записываем `16'hBEEF` по адресу `10`;
- читаем значение по этому же адресу;
- затем пытаемся "записать" новое значение без `mem_write`;
- убеждаемся, что память не изменилась.

Что увидите в терминале:

```text
=== Data memory test start ===
Block purpose: stores data words for LOAD and STORE operations.
[DMEM] write request: mem_write=1 addr=10 write_data=0xBEEF
[DMEM] stored value at addr=10
[DMEM] read: addr=10 read_data=0xBEEF
[DMEM] no-write check: mem_write=0 addr=10 attempted_data=0xDEAD
[DMEM] read after blocked write: addr=10 read_data=0xBEEF
Data memory tests completed.
```

Ожидаемый результат:
- чтение после записи возвращает `0xBEEF`;
- без разрешения записи память не меняется.

### 6.4. Instruction Memory

За что отвечает блок:
- `instruction_memory` хранит программу процессора;
- на вход получает адрес инструкции;
- на выход выдает 16-битную инструкцию.

Почему этот блок важен:
- это источник команд для всего процессора;
- если в память команд загружаются неверные коды, остальные блоки будут работать неправильно даже при исправной логике.

Исходники:
- `tb/tb_instr_mem.v`
- `rtl/instr_mem.v`
- `tb/program.hex`

Что такое `.hex`:
- `tb/program.hex` - это текстовый файл с машинным кодом программы;
- каждая строка - одна 16-битная инструкция в шестнадцатеричном виде;
- этот файл загружается в `instruction_memory` через `$readmemh`.

Команда:

```bash
cd /mnt/d/Users/Desktop/verilogProject
iverilog -g2012 -I rtl -o sim/instr_tb tb/tb_instr_mem.v rtl/instr_mem.v && vvp sim/instr_tb
```

Что подается на вход:
- адрес `addr`.

Что именно мы делаем:
- подаем `addr = 0`, затем `1`, затем `2`;
- смотрим, какие инструкции приходят на выход;
- убеждаемся, что программа прочиталась правильно.

Какие команды мы видим в начале программы:
- `7205` -> `LDI R1, 5`
- `7403` -> `LDI R2, 3`
- `1650` -> `ADD R3, R1, R2`

Что увидите в терминале:

```text
=== Instruction memory test start ===
Block purpose: stores program instructions loaded from tb/program.hex.
program.hex format: one 16-bit instruction per line in hexadecimal.
[IMEM] addr=0 instr=0x7205 -> LDI R1, 5
[IMEM] addr=1 instr=0x7403 -> LDI R2, 3
[IMEM] addr=2 instr=0x1650 -> ADD R3, R1, R2
Instruction memory tests completed.
```

Ожидаемый результат:
- по адресу `0` должна читаться инструкция загрузки `5` в `R1`;
- по адресу `1` должна читаться инструкция загрузки `3` в `R2`;
- по адресу `2` должна читаться инструкция сложения `R1` и `R2`.

### 6.5. Control Unit

За что отвечает блок:
- `control_unit` декодирует поле `opcode`;
- по коду операции формирует управляющие сигналы для остальных блоков.

Какие сигналы здесь самые важные:
- `reg_write` - разрешение записи в регистр;
- `mem_write` - разрешение записи в память;
- `alu_op` - какую операцию должна выполнить ALU;
- `alu_src_b_sel` - что подавать на второй вход ALU;
- `pc_load` и `pc_next` - управление переходами.

Почему этот блок важен:
- это "мозг управления" процессора;
- он не хранит данные, а решает, что должны делать остальные блоки на текущей инструкции.

Исходники:
- `tb/tb_control_unit.v`
- `rtl/control_unit.v`
- `rtl/isa_defs.vh`

Команда:

```bash
cd /mnt/d/Users/Desktop/verilogProject
iverilog -g2012 -I rtl -o sim/ctrl_tb tb/tb_control_unit.v rtl/control_unit.v && vvp sim/ctrl_tb
```

Что подается на вход:
- `clk`;
- `rst_n`;
- искусственно заданная `instruction`;
- `zero_flag`.

Что именно мы делаем:
- отдельно подаем в `control_unit` закодированные инструкции;
- смотрим, какие управляющие сигналы на них появляются;
- проверяем `ADD`, `LOAD`, `STORE`, `JUMP`.

Что увидите в терминале:

```text
=== Control unit test start ===
Block purpose: decodes opcode and generates control signals for the datapath.
Signals of interest: reg_write, mem_write, alu_op, alu_src_b_sel, pc_load, pc_next.
[CTRL] expected behavior for ADD: write result to register, ALU performs ADD.
[CTRL] apply instruction=0x1298
[CTRL] outputs: reg_write=1 mem_write=0 alu_op=0x1 alu_src_b_sel=0 pc_load=0 pc_next=0x0000 state=...
[CTRL] expected behavior for LOAD: address via ALU add, then register write enabled.
[CTRL] apply instruction=0x5941
[CTRL] outputs: reg_write=1 mem_write=0 alu_op=0x1 alu_src_b_sel=1 pc_load=0 pc_next=0x0000 state=...
[CTRL] expected behavior for STORE: address via ALU add, then memory write enabled.
[CTRL] apply instruction=0x6DC1
[CTRL] outputs: reg_write=0 mem_write=1 alu_op=0x1 alu_src_b_sel=1 pc_load=0 pc_next=0x0000 state=...
[CTRL] JUMP outputs: pc_load=1 pc_next=0x0000 state=...
Control unit tests completed.
```

Ожидаемый результат:
- для `ADD` активируется запись в регистр;
- для `LOAD` активируется запись в регистр и адрес считается через ALU;
- для `STORE` активируется запись в память;
- для `JUMP` активируется `pc_load`.

### 6.6. Верхний уровень процессора

За что отвечает блок:
- `top_cpu` объединяет все модули в единое процессорное ядро;
- именно здесь видно, как модули начинают работать вместе как CPU.

Почему этот блок важен:
- отдельные модули могут быть правильными по одиночке, но ошибка часто проявляется только в интеграции;
- именно верхний тест показывает, что ядро действительно исполняет программу.

Исходники:
- `tb/tb_top_cpu.v`
- все файлы из `rtl/`
- `tb/program.hex`

Команда:

```bash
cd /mnt/d/Users/Desktop/verilogProject
iverilog -g2012 -I rtl -o sim/simv tb/tb_top_cpu.v rtl/*.v && vvp sim/simv
```

Что подается на вход:
- `clk`;
- `rst_n`.

Что происходит внутри:
- `PC` выбирает адрес инструкции;
- `instruction_memory` читает инструкцию из `tb/program.hex`;
- `control_unit` декодирует opcode;
- `register_file` читает и пишет регистры;
- `ALU` выполняет арифметику и логику;
- `data_memory` выполняет `LOAD` и `STORE`.

Что вы увидите в терминале:
- номер такта `cycle`;
- текущий адрес `pc`;
- код инструкции `instr`;
- значения регистров `R1..R7`;
- изменение `MEM[1]`.

Это позволяет визуально проследить выполнение программы без открытия waveform.

## 7. Какая программа выполняется в верхнем тесте

Программа хранится в `tb/program.hex`.

Файл `.hex` нужен для того, чтобы instruction memory загрузила не абстрактные данные, а реальную программу процессора.

Текущие инструкции:

```text
Адрес  Код    Смысл
0      7205   LDI   R1, 5
1      7403   LDI   R2, 3
2      1650   ADD   R3, R1, R2
3      6601   STORE R3, [R0 + 1]
4      5801   LOAD  R4, [R0 + 1]
5      2B18   SUB   R5, R4, R3
6      9008   BEQ   8
7      7C01   LDI   R6, 1
8      4E50   OR    R7, R1, R2
9      8009   JUMP  9
```

Какие команды ISA здесь тестируются:
- `LDI`
- `ADD`
- `STORE`
- `LOAD`
- `SUB`
- `BEQ`
- `OR`
- `JUMP`

Смысл программы:

1. Записать число `5` в `R1`.
2. Записать число `3` в `R2`.
3. Сложить их и записать результат `8` в `R3`.
4. Сохранить `R3` в память по адресу `1`.
5. Прочитать память по адресу `1` в `R4`.
6. Вычесть `R3` из `R4`, получить `0` в `R5`.
7. Если результат равен нулю, перейти на адрес `8`.
8. Пропустить инструкцию `LDI R6, 1`.
9. Выполнить `OR R1, R2` и записать результат `7` в `R7`.
10. Зациклиться на инструкции `JUMP 9`.

## 8. Что должно получиться в верхнем тесте

После выполнения программы testbench проверяет:

- `R1 = 5`
- `R2 = 3`
- `R3 = 8`
- `R4 = 8`
- `R5 = 0`
- `R6 = 0`
- `R7 = 7`
- `RAM[1] = 8`
- `PC = 9`

Пример того, что вы будете видеть в терминале:

```text
=== Top CPU test start ===
Block purpose: integrates PC, instruction memory, control unit, register file, ALU and data memory.
The CPU executes the program from tb/program.hex and we observe register and memory changes.
[CPU] cycle=1 pc=1 instr=0x7403 state=...
[CPU] cycle=2 pc=2 instr=0x1650 state=... R1=5 ...
[CPU] cycle=3 pc=3 instr=0x6601 state=... R1=5 R2=3 ...
[CPU] cycle=4 pc=4 instr=0x5801 state=... R3=8 MEM[1]=8
...
[CPU] cycle=16 pc=9 instr=0x8009 state=... R7=7 MEM[1]=8
Top-level simulation PASSED.
```

Что нужно увидеть глазами:
- сначала появляются значения в `R1` и `R2`;
- потом в `R3` появляется сумма `8`;
- затем в `MEM[1]` появляется `8`;
- потом `R4` получает `8` из памяти;
- затем `R5` становится `0`;
- команда `BEQ` пропускает запись `R6 = 1`, поэтому `R6` остается `0`;
- в `R7` появляется `7`;
- `PC` зацикливается на адресе `9`.

## 9. Что смотреть в waveform

Для отчета полезно открыть `sim/tb_top_cpu.vcd` и посмотреть:

- `clk`
- `rst_n`
- `pc_out`
- `instr_out`
- `state_out`
- `uut.ctrl.pc_load`
- `uut.ctrl.reg_write`
- `uut.ctrl.mem_write`
- `uut.alu_result`
- `uut.regfile.registers[1]`
- `uut.regfile.registers[2]`
- `uut.regfile.registers[3]`
- `uut.regfile.registers[4]`
- `uut.regfile.registers[5]`
- `uut.regfile.registers[7]`
- `uut.dmem.ram[1]`

Тогда на диаграмме будет видно:
- выбор инструкции;
- изменение `PC`;
- запись в регистры;
- запись и чтение памяти;
- момент условного перехода;
- переход в конечный бесконечный цикл.

## 10. Удобная схема работы

Рекомендуемый порядок:

1. Запустить `tb_pc`.
2. Запустить `tb_reg_file`.
3. Запустить `tb_data_mem`.
4. Запустить `tb_instr_mem`.
5. Запустить `tb_control_unit`.
6. Запустить `tb_top_cpu`.
7. Если итог не проходит, открыть соответствующий `.vcd`.

## 11. Важное замечание про ALU

В папке `tb/` есть файл `tb_alu.v`, но сейчас он пустой и в проверках не используется.

Это значит:
- модуль `alu.v` сейчас проверяется косвенно через `tb_control_unit` и `tb_top_cpu`;
- при желании можно отдельно добавить полноценный `tb_alu.v`, который будет проверять `ADD`, `SUB`, `AND`, `OR`, `XOR`, `NOT` напрямую.