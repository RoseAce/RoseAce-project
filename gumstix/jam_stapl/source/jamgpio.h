/*Header of functions defines in gpio.c*/

void interface_init();
void interface_exit();
void gpio_set_tdi();
void gpio_clear_tdi();
void gpio_set_tms();
void gpio_clear_tms();
void gpio_set_tck();
void gpio_clear_tck();
void gpio_set_tdo();
void gpio_clear_tdo();
int gpio_status_tdo();
