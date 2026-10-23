MODEL = 760D
FW_VERSION = 101

TOP_DIR = ../..

AUTOEXEC_BASE = 0x800000
FIR_BASE = 0x800120

FIRMWARE_ID = 0x80000347
MAIN_FIRMWARE_ADDR = 0xFE0A0000

# user_mem_start from cstart struct. Align to 0x10 up
# 760D: 0x001cc400 at fe0cd27c (cstart literal pool), same as 750D
RESTARTSTART = 0x001cc400

# Cortex R4
CFLAGS_PLATFORM += -mthumb -mlong-calls
PLATFORM_ARCH = armv7-r

ML_BOOT_OBJ = boot-d678.o
ML_SRC_EXTRA_OBJS += $(BUILD_DIR)/function_overrides.o

include ../Makefile
.DEFAULT_GOAL := $(BUILD_DIR)/cam_complete
