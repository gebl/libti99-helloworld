#include <conio.h>
#include <system.h>

int main() {
  VDP_SET_REGISTER(0x32, 0x80);
  VDP_SET_REGISTER(0x02, 0x00);
  set_graphics(0);
  set_text();

  bgcolor(COLOR_BLACK);
  textcolor(COLOR_GRAY);
  clrscr();
  cursor(1);
  gotoxy(0,0);
  cputs("Hello world!");
  while (!kbhit()) {
  }
  exit();
  return 0;
}
