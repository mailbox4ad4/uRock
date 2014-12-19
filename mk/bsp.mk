BSPSRCDIR = Drivers/BSP/STM32F429I-Discovery \
			Utilities/Fonts

BSPINCDIR = Drivers/BSP/STM32F429I-Discovery \
			Utilities/Fonts

BSPSRC += $(wildcard $(addsuffix /*.c,$(BSPSRCDIR))) \
		  $(wildcard $(addsuffix /*.s,$(BSPSRCDIR)))

BSPSRC += Drivers/BSP/STM32F429I-Discovery/stm32f429i_discovery.c
BSPSRC += Drivers/BSP/Components/ili9341/ili9341.c
BSPSRC += Drivers/BSP/Components/stmpe811/stmpe811.c

INCLUDES += $(addprefix -I,$(BSPINCDIR))

BSPOBJS += $(addprefix $(OUTDIR)/,$(patsubst %.s,%.o,$(BSPSRC:.c=.o)))

$(OUTDIR)/%.o: %.c
	@echo "    CC     "$@	
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -MMD -MF $@.d -c $(INCLUDES) $< -o $@

.PHONY: clean-bsp
clean-bsp:
	rm -rf $(BSPOBJS)
