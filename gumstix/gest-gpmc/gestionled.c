#include "roseace_gpmc.h"
#include "roseace_utilities.h"

#include <stdlib.h>
#include <stdio.h>

unsigned short saved_data[259];

/* FILE FORMAT
 *
 * Every value in the file are unsigned short
 * From 0 to maxpixel*2+1 there are the DC value correponding to the npixel value
 * In npixel*2 there is the {1'b0,green,1'b0,red} component and in npixel*2+1 there is the {9'b0,blue} component
 * DC -> 0 to 255
 * 
 * In 256 there is {1'b0,green,1'b0,red} component and in 257 there is the {8'b0,blue} component
 * BC -> 256 to 257
 *
 * In 258 there is the FC configuration value {X,FC}
 * FC -> 258
 */
void file_function(char * file_name) {
  //Load the values of the file
  FILE * file;
  file = fopen(file_name, "r");
  unsigned short value;
  for(int i = 0; i < 259; i++) {
    fscanf(file, "%hx", &value);
    if (value) {
      send_configure_to_fpga(value, i*2);
    }
  }
  send_command_to_fpga(1, 518);
  fclose(file);
}

void save_function() {
  //Write savec_data in a file
  printf("Name of the configuration file ?\n");
  char file_name[30];
  scanf("%s",file_name);
  FILE * file;
  file = fopen(file_name, "w+");
  for(int i = 0; i < 259; i++) {
    fprintf(file, "%x\n", saved_data[i]);
  }
  fclose(file);
}

void fc_function() {
  printf("1 - Red adjustement\n2 - Green adjustement\n4 - Blue adjustement\n8 - Auto repeat\n16 - Display reset mode\n64 - 10 bits GS mode\n96 - 8 bits GS mode\nRecommended value : 120\n");
  printf("Make the addition = ");
  unsigned char fc;
  scanf("%hhu",&fc);
  send_configure_to_fpga(fc, 129*4);
  saved_data[129*2] = fc;
  printf("\n");
}

void bc_function() {
  printf("\n0< R G B <255 = ");
  unsigned char red, green, blue;
  scanf("%hhu %hhu %hhu", &red, &green, &blue);
  send_configure_to_fpga((green << 8) | red, 128*4);
  send_configure_to_fpga(blue, 128*4+2);
  saved_data[128*2] = (green << 8) | red;
  saved_data[128*2+1] = blue;
  printf("\n");
}

void dc_function() {
  printf ("Num pixel = ");
  unsigned char npixel;
  scanf("%hhu", &npixel);
  printf("\n0< R G B <127 = "); 
  unsigned char red, green, blue;
  scanf("%hhu %hhu %hhu", &red, &green, &blue);
  send_configure_to_fpga(((green & 0x7f) << 8) | (red & 0x7f) , npixel*4);
  send_configure_to_fpga((blue & 0x7f), npixel*4+2);
  saved_data[(npixel*2)] = ((green & 0x7f) << 8) | (red & 0x7f);
  saved_data[(npixel*2+1)] = (blue & 0x7f);
  printf("\n");
}

int main(int argc, char *argv[]) {
  roseace_init_gpmc();
  //Interactive mode
  if (argc == 1) {
    while (1) {
      printf("Choose your mode:\ndc, bc, fc, done or save\n");
      char choice[5];
      scanf("%s",choice);
      if (strncmp(choice, "dc",2)==0) {
	dc_function();
      } 

      else if (strcmp(choice, "bc")==0) {
	bc_function();
      } 

      else if (strcmp(choice, "fc")==0) {
	fc_function();
      } 

      else if (strcmp(choice, "done")==0) {
	send_command_to_fpga(1, 518);
	printf("\n");
      } 

      else if (strcmp(choice, "save")==0) {
	save_function();
      }

      else {
	printf("Bad choice\n");
      }      
    }
  }
  //file mode
  else if (argc > 1) {
    file_function(argv[1]);
  }
  return 0;
}
