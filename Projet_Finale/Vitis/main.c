#include "xil_io.h"

#define AXI_GPIO_2_BASEADDR 0x40000000

int main(void)
{
    Xil_Out32(AXI_GPIO_2_BASEADDR, 0x1);

    while (1)
    {
    }

    return 0;
}
