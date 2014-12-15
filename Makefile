PROJECT = main

TOOLDIR = tool

OUTDIR = build
EXECUTABLE = $(OUTDIR)/$(PROJECT).elf
BIN_IMAGE = $(OUTDIR)/$(PROJECT).bin
HEX_IMAGE = $(OUTDIR)/$(PROJECT).hex
MAP_FILE = $(OUTDIR)/$(PROJECT).map
LIST_FILE = $(OUTDIR)/$(PROJECT).lst

# Toolchain configurations
CROSS_COMPILE ?= arm-none-eabi-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
SIZE = $(CROSS_COMPILE)size

# Cortex-M4 implements the ARMv7E-M architecture
CPU = cortex-m4
CFLAGS = -mcpu=$(CPU) -march=armv7e-m -mtune=cortex-m4
CFLAGS += -mlittle-endian -mthumb
# Need study
CFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=hard

# Basic configurations
CFLAGS += -g3 -std=c99 -Wall  \
		  -DUSER_NAME=\"$(USER)\"

# Optimizations
CFLAGS += -O0 -ffast-math \
		  -ffunction-sections -fdata-sections \
		  -fno-common \
		  --param max-inline-insns-single=1000

# specify STM32F429
CFLAGS += -DSTM32F429xx

# to run from FLASH
CFLAGS += -DVECT_TAB_FLASH
LDFLAGS += -Wl,--gc-sections -Wl,-Map=$(MAP_FILE) -TSTM32F429I_DISCO/STM32F429ZI_FLASH.ld

#files
SRCDIR = src \
		 src/audio-effects \
		 Drivers/STM32F4xx_HAL_Driver/Src \
		 Drivers/CMSIS/DSP_Lib/Source/FastMathFunctions \
		 Drivers/CMSIS/DSP_Lib/Source/BasicMathFunctions \
		 Drivers/CMSIS/DSP_Lib/Source/SupportFunctions \
		 Drivers/CMSIS/DSP_Lib/Source/FilteringFunctions \
		 Drivers/BSP/STM32F429I-Discovery \
		 Middlewares/Third_Party/FreeRTOS/Source \
		 Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F \
		 Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS \
		 Utilities/Fonts \
		 Utilities/CPU

INCDIR = inc \
		 inc/audio-effects \
		 Drivers/CMSIS/Device/ST/STM32F4xx/Include \
		 Drivers/CMSIS/Include \
		 Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS \
		 Drivers/STM32F4xx_HAL_Driver/Inc \
		 Drivers/BSP/STM32F429I-Discovery \
		 Middlewares/Third_Party/FreeRTOS/Source/include \
		 Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F \
		 Utilities/Fonts \
		 Utilities/CPU

SRC += $(wildcard $(addsuffix /*.c,$(SRCDIR))) \
	  $(wildcard $(addsuffix /*.s,$(SRCDIR)))

SRC += Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery.c

SRC += Middlewares/Third_Party/FreeRTOS/Source/portable/MemMang/heap_4.c

SRC += Drivers/BSP/Components/ili9341/ili9341.c

SRC += Drivers/BSP/Components/stmpe811/stmpe811.c

OBJS += $(addprefix $(OUTDIR)/,$(patsubst %.s,%.o,$(SRC:.c=.o)))

INCLUDES = $(addprefix -I,$(INCDIR))

all: $(BIN_IMAGE)

$(BIN_IMAGE): $(EXECUTABLE)
	@$(OBJCOPY) -O binary $^ $@
	@$(OBJCOPY) -O ihex $^ $(HEX_IMAGE)
	@$(OBJDUMP) -h -S -D $^ > $(LIST_FILE)
	@echo "  OBJCOPY  "$@	
	@echo "  OBJCOPY  "$(HEX_IMAGEX)	
	@echo "  OBJDUMP  "$(LIST_FILE)
	@$(SIZE) $(EXECUTABLE)
	
$(EXECUTABLE): $(OBJS)
	@echo "    LD     "$@	
	@$(CROSS_COMPILE)gcc $(CFLAGS) $(LDFLAGS) -lc -lgcc -lnosys -lm -o $@ $^

$(OUTDIR)/%.o: %.c
	@echo "    CC     "$@	
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $(INCLUDES) $< -o $@

$(OUTDIR)/%.o: %.s
	@echo "    CC     "$@	
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $(INCLUDES) $< -o $@

flash:
	st-flash write $(BIN_IMAGE) 0x8000000

openocd_flash:
	openocd \
	-f board/stm32f429discovery.cfg \
	-c "init" \
	-c "reset init" \
	-c "flash probe 0" \
	-c "flash info 0" \
	-c "flash write_image erase $(BIN_IMAGE)  0x08000000" \
	-c "reset run" -c shutdown

.PHONY: clean
clean:
	rm -rf $(OUTDIR)/*

dbg: $(EXECUTABLE)
	openocd -f board/stm32f429discovery.cfg >/dev/null & \
    echo $$! > $(OUTDIR)/openocd_pid && \
    $(CROSS_COMPILE)gdb -x $(TOOLDIR)/gdbscript && \
    cat $(OUTDIR)/openocd_pid |`xargs kill 2>/dev/null || test true` && \
    rm -f $(OUTDIR)/openocd_pid
