/*
	emxx_vibrate.c 2011-04-11 hengai
*/
#include <asm/arch-emxx/gpio.h>
#include <asm/io.h>
#include <configs/emev.h>
////////////////////////////////////////////////////////////////////////////////
/*
vibrate GPIO: GPIO_P5, high=on
*/
////////////////////////////////////////////////////////////////////////////////
#ifndef mdelay
#define mdelay(n) (\
	(__builtin_constant_p(n) && (n)<=5) ? udelay((n)*1000) : \
	({unsigned long __ms=(n); while (__ms--) udelay(1000);}))
#endif
////////////////////////////////////////////////////////////////////////////////
void vibrate_on(void)
{
	gpio_direction_output(GPIO_P5, 1);
}

void vibrate_off(void)
{
	gpio_direction_output(GPIO_P5, 0);
}

void vibrate_trigger(int ms)
{
	vibrate_on();
	mdelay(ms);
	vibrate_off();
}

