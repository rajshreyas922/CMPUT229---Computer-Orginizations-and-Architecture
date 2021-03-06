#include <netinet/ip.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <netinet/in.h>
#include <string.h>

/**
*	Packet Generator for packet forwarding lab
*	Author: Taylor Lloyd
*	Date: June 20, 2012
*
*	Fall 2020 Modifications
*	Author: Quinn Pham
*	Date: July 22, 2020
*
*	This code represents the minimum possible to generate
*	lab-compatible packet files. As such there is very little
*	input verification. It is the user's responsibility to
*	ensure appropriate input
*/

/*
	Custom struct representing an IP packet header
*/
struct cip {
   uint8_t        ip_hl:4, /* both fields are 4 bits */
                  ip_v:4;
   uint8_t        ip_dscp:6;
   uint8_t		  ip_ecn:2;
   uint16_t       ip_len;
   uint16_t       ip_id;
   uint16_t       ip_off;
   uint8_t        ip_ttl;
   uint8_t        ip_p;
   uint16_t       ip_sum;
   struct in_addr ip_src;
   struct in_addr ip_dst;
   char	 	  head[100];
};

//Calculates a ones-complement sum for a given package of data
uint16_t ip_checksum(void* vdata,size_t length) {
  size_t i;

    // Cast the data pointer to one that can be indexed.
    char* data=(char*)vdata;

    // Initialise the sum.
    uint32_t acc=0x0000;

    // Handle complete 16-bit blocks.
    for (i=0;i<length;i+=2) {
        uint16_t word;
        memcpy(&word,data+i,2);
        acc+=ntohs(word);
        if (acc>0xffff) {
            acc-=0xffff; // -0x10000 + 0x0001
        }
    }
    // Return the checksum in network byte order.
    return htons(~acc);
}

int main(int argc, char **argv) {

	//Create the packet
	struct cip packet;
	char data[1000];

	//Read the filename we'll be saving to
	printf("Enter the filename to save the packet\n");
	char file[1000];
	scanf("%s", file);

	//Read IP Version
	printf("\nEnter IP version(0-15):\n");
	int input;
	scanf("%d", &input);
	packet.ip_v = input;

	//Read header size
	printf("\nEnter Header Length(5-15):\n");
	scanf("%d", &input);
	packet.ip_hl = input;

	//Read service type 
	printf("\nEnter type of service(0-63):\n");
	scanf("%d", &input);
	packet.ip_dscp = input;

	//Automatically set ECN to 0
	printf("\nECN automatically set to 0.\n");
	packet.ip_ecn = htons(0x0);

	//Read size of header + data
	printf("\nEnter packet total size(%d-128):\n", packet.ip_hl*4);
	scanf("%d", &input);
	packet.ip_len = htons(input);

	//Read IP ID number 
	printf("\nEnter ip ID number(0-65535):\n");
	scanf("%d", &input);
	packet.ip_id = htons(input);

	//Fragment and Flags. Flags will be 1 (Don't Fragment). Fragment Offset will be 0.
	printf("\nFlags automatically set to 1 (Don't Fragment)\n");
	printf("\nFragment Offset automatically set to 0\n");
	packet.ip_off = htons(0x0100);

	//Time To Live value
	printf("\nEnter TTL(0-255):\n");
	scanf("%d", &input);
	packet.ip_ttl = input;

	//Protocol automatically set to 6 (TCP)
	printf("\nProtocol automatically set to 6 (TCP)\n");
	packet.ip_p = 0x6;

	//Get source & dest IPs
	char ip[100];
	printf("\nEnter source IP(x.x.x.x):\n");
	scanf("%s",ip);
	inet_pton(AF_INET,ip,&(packet.ip_src));

	printf("\nEnter destination IP(x.x.x.x):\n");
	scanf("%s",ip);
	inet_pton(AF_INET,ip,&(packet.ip_dst));

	//Some sanity checking
	if(ntohs(packet.ip_len)<packet.ip_hl*4) {
	 	printf("\nPacket sized for just header.");
	        packet.ip_len = htons(packet.ip_hl*4);
		printf(" (%d bytes)\n", ntohs(packet.ip_len));
	}
	if(((unsigned int)packet.ip_hl)*4 > 20) {
		printf("\nEnter %d chars of remaining header\n", ((unsigned int)packet.ip_hl)*4-20);
		scanf("%s",packet.head);
	}

	//Checksum
	printf("\nValid Checksum? (1/0):\n");
	scanf("%d",&input);
	if(input == 1) {
		packet.ip_sum = 0;
		packet.ip_sum = ip_checksum(&packet, packet.ip_hl*4);
		uint16_t bigEndian_sum = ((packet.ip_sum << 8) & 0xff00) | ((packet.ip_sum >> 8) & 0x00ff);		//swap the bytes so checksum is presented in big endian byte order
		printf("Checksum for %d bytes: 0x%0.4x",packet.ip_hl*4,
			bigEndian_sum);
	} else {
		printf("\nChecksum Value(0-65535):\n");
		scanf("%d",&input);
		packet.ip_sum = htons(input);
	}

	//Get some packet data if we have space
	if(packet.ip_hl*4 < ntohs(packet.ip_len)) {
		printf("\nEnter %d or more chars of packet data:\n", ntohs(packet.ip_len)-packet.ip_hl*4);
		scanf("%s",data);
	}

	//Dump all the collected info into a file
	FILE* f = fopen(file, "w");
	int success = fwrite(&packet, sizeof(char), ((unsigned int)packet.ip_hl)*4,f);
	if(success <= 0) {
		printf("Error writing packet header");
	}
	success = fwrite(&data, sizeof(char),ntohs(packet.ip_len)-(4*packet.ip_hl),f);
	if(success < 0) {
		printf("Error writing packet data");
	}
	fflush(f);
	fclose(f);
	printf("\nPacket Written.\n");
	return 0;
}
