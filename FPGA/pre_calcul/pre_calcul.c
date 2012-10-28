/** This file realizes the pre calculation of the radius.
  * Radius will be stored using the floowing convention:
  * Blade representation (numbers are the LED numbers):
  * 
  *    127 126 125 124 ... 65 64 | 0 1 2 ... 63
  *
  * In the ROM memory, the number of the pixel corresponding of one position
  * are stored for one octant : the first.
  * address:
  *  - 0 to 63    : position 0 LED 0 to 63
  *  - 64 to 127  : position 0 LED 64 to 127
  *  - 128 to 191 : position 1 LED 0 to 63
  *  - 192 to 255 : position 1 LED 64 to 127
  *       ...
  *
  * For the calcul, the even pixel are for LED from 0 to 63
  * and odd number for LED from 64 to 127.
  *
  **/

/*Included files*/
#include <stdio.h>
#include <math.h>

/*Constants definition*/
#define RADIUS_NUMBER 1024
#define LED_NUMBER 128
#define OUTPUT_NAME "pre_calcul.txt"

/*Functions' headers*/
char signed integer_part(float);

/*Functions' definitions*/

/*Global variables*/
float theta;
FILE* output_file;

/*Function main*/
int main(int argc, char *argv[])
{
  theta = 2*M_PI/RADIUS_NUMBER;
  output_file = fopen(argv[1], "w");
  long address = 0;
  float x, y;
  int signed x_int_part, y_int_part;
  int to_write;
  // For all radius on an octant
  for(int i=0 ; i<RADIUS_NUMBER/4 ; i++)
  {
    /*For LED 0 to 63*/
    for(int j=0 ; j<LED_NUMBER ; j+=2)
    {
      // Position calcul
      x = j*cos(i*theta);
      y = j*sin(i*theta);

      // Position are transformed in integer (no anti-aliasing)
      x_int_part = integer_part(x);
      y_int_part = integer_part(y);

      // Change the origin of the coordinate because in an image, origin is the top left corner
      x_int_part += 128;
      y_int_part = 128-y_int_part;

      // Pixel position calcul
      to_write = x_int_part + 256*y_int_part;

      // Write the calcul on the 
      fprintf(output_file, "@%X\n", (unsigned int)address);
      fprintf(output_file, "%X\n", to_write);
      address++;
    }
    /*For LED 64 to 127*/
    for(int j=1 ; j<LED_NUMBER ; j+=2)
    {
      // Position calculation
      x = -1*j*cos(i*theta);
      y = -1*j*sin(i*theta);

      // Position are transformed in integer (no anti-aliasing)
      x_int_part = integer_part(x);
      y_int_part = integer_part(y);

      // Change the origin of the coordinate because in an image, origin is the top left corner
      x_int_part += 128;
      y_int_part = 128-y_int_part;

      // Pixel position calcul
      to_write = x_int_part + 256*y_int_part;

      // Write the calcul on the 
      fprintf(output_file, "@%X\n",(unsigned int)address);
      fprintf(output_file, "%X\n", (unsigned int)to_write);
      address++;
    }
  }

  // Close the output file
  fclose(output_file);
  return 0;
}

/*This function returns the integer part of the number given in argument*/
char signed integer_part(float number)
{
  if(number >= 0)
    return floor(number);
  return ceil(number);
}

