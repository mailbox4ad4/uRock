UGFXOUTDIR = UGFXLib

UGFXSRCDIR = Middlewares/ugfx \
			 Middlewares/ugfx/src \
			 Middlewares/ugfx/src/gdisp \
			 Middlewares/ugfx/src/gdisp/mcufont \
			 Middlewares/ugfx/src/ginput \
			 Middlewares/ugfx/src/gevent \
			 Middlewares/ugfx/src/gtimer \
			 Middlewares/ugfx/src/gdriver

UGFXINCDIR = Middlewares/ugfx \
			 Middlewares/ugfx/src/gdisp \
			 Middlewares/ugfx/src/gdisp/mcufont \
			 Middlewares/ugfx/src/ginput \
			 Middlewares/ugfx/src/gevent \
			 Middlewares/ugfx/src/gtimer \
			 Middlewares/ugfx/src/gdriver

UGFXSRC += $(wildcard $(addsuffix /*.c,$(UGFXSRCDIR))) \
		  $(wildcard $(addsuffix /*.s,$(UGFXSRCDIR)))

UGFXSRC += Middlewares/ugfx/src/gos/freertos.c

INCLUDES += $(addprefix -I,$(UGFXINCDIR))

UGFXOBJS += $(addprefix $(OUTDIR)/$(UGFXOUTDIR)/,$(patsubst %.s,%.o,$(UGFXSRC:.c=.o)))

$(OUTDIR)/$(UGFXOUTDIR)/%.o: %.c
	@echo "   UGFX   |   CC    "$@	
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -MMD -MF $@.d -c $(INCLUDES) $< -o $@

.PHONY: clean-ugfx
clean-ugfx:
	@rm -rf $(OUTDIR)/$(UGFXOUTDIR)
	@echo "Removing UGFX Library Object Files"