# Variables
ASM = nasm
ASMFLAGS = -f elf64
LD = ld
TARGET = mivi

# Find all .asm files and define corresponding .o files
SRCS = main.asm openfile.asm screenmanipulation.asm terminalsettings.asm
OBJS = $(SRCS:.asm=.o)

# Default rule (runs when you type 'make')
all: $(TARGET)

# Link object files into the final executable
$(TARGET): $(OBJS)
	$(LD) -o $(TARGET) $(OBJS)

# Compile .asm files into .o files
%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

# Clean up build files
clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean

