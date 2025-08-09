#
# A SQL query walks into a bar, walks up to two tables and asks:
# "Can I join you?"
#

.section .data
fmt:
    .string "%s Result: %d\n"

.section .text
.global io_print

.extern fprintf
.extern stdout

#
# void io_print(const char *, int);
#    %rdi: 1st argument
#    %esi: 2nd argument
#
io_print:
    movl    %esi, %ecx          # 4th argument to fprintf (32-bit int)
    movq    %rdi, %rdx          # 3rd argument to fprintf (string)
    leaq    fmt(%rip), %rsi     # 2nd argument: pointer to format string
    movq    stdout(%rip), %rdi  # 1st argument: pointer to stdout

    xor     %eax, %eax          # Clear %al for variadic function call
    call    fprintf

    ret
