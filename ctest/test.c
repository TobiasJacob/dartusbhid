#include <hidapi/hidapi.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Start\n");
    hid_device *dev = hid_open(1155, 22352, NULL);
    char msg[5] = {2, 'h', 'i', 'y', 'u'};
    int bytes_written = hid_write(dev, msg, 5);
    printf("%i\n", bytes_written);
    char error[1000] = {0};
    wcstombs(error, hid_error(dev), 1000);
    printf("%s", error);
    char buffer[1000] = {0};
    hid_read(dev, buffer, 1000);

    printf("Success %s\n", buffer);
}