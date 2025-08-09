/*
 * How many programmers does it take to change a light bulb?
 * None. That’s a hardware problem.
 */

#include <stdlib.h>

#include "core/core.h"
#include "drivers/drivers.h"
#include "init/init.h"
#include "io/io.h"
#include "utils/utils.h"

int main(int argc, char *argv[])
{
    int num;

    (void) argc;
    (void) argv;

    num = init();
    num = utils(num);
    num = drivers(num);
    num = core(num);

    io_print(APP_MESSAGE, num);

    return EXIT_SUCCESS;
}
