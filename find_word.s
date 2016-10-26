

#==================================================================
# DATA SEGMENT
#==================================================================
	.data
#------------------------------------------------------------------
# Constant strings for output messages
#------------------------------------------------------------------

prompt0:         .asciiz  "\ninput: "
outmsg:          .asciiz  "output:\n"
newline:         .asciiz  "\n"
input_sentence:       .space 1001 #char input_sentence[MAX_CHARS];
word:                 .space 51  #char word[MAX_WORD_LENGTH];
MAX_CHARS:       .word 1001 #define MAX_CHARS 1001
MAX_WORD_LENGTH: .word 51 #define MAX_WORD_LENGTH 51

#------------------------------------------------------------------
# Global variables in memory
#------------------------------------------------------------------
# None for this program.  Registers used instead.

#==================================================================
# TEXT SEGMENT
#==================================================================
	.text

read_string:						#void read_string(char* s, int size) { fgets(s, size, stdin); }
               li $v0, 8
               syscall
               jr $ra


print_char:							#void print_char(char c) { printf("%c", c); }
               li $v0, 11
               syscall
               jr $ra

print_int:						  #void print_int(int num) { printf("%d", num); }
               li $v0, 1
               syscall
               jr $ra

print_string:						#void print_string(char* s) { printf("%s", s); }
               li $v0, 4
               syscall
               jr $ra


read_input:
               addi $sp, $sp, -4
               sw $ra 0($sp)  		#return address to location at which this function was called
               la $a0, prompt0         # void read_input(char* inp) {
               jal print_string        # print_string("\ninput: ");
               la $a0, input_sentence   # read_string(input_sentence, MAX_CHARS);
               la $a1, MAX_CHARS        # }
               jal read_string
               lw $ra, 0($sp)
               addi $sp, $sp, 4 #load into $ra the location in stack
               jr $ra

output:
               addi $sp, $sp, -4 #store into stack the location at which this function was called
               sw $ra, 0($sp)
               jal print_string    #void output(char* out) {
               la $a0, newline     #print_string(out);
               jal print_string     #print_string("\n");
               lw $ra, 0($sp)       #}
               addi $sp, $sp, 4 #load into $ra the location stored in stack
               jr $ra

 is_delimiting_char:                                       #int is_delimiting_char(char ch) {
               addi $t9, $0, 32				      #if ( ch == ' ') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting		 #return 1;
               addi $t9, $0, 44				         #} else if ( ch == ',') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting		# return 1;
               addi $t9, $0, 46				        #} else if ( ch == '.') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting		#return 1;
               addi $t9, $0, 33					#} else if ( ch == '!') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting                #return 1;
               addi $t9, $0, 95				        #} else if ( ch == '?') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting		#return 1;
               addi $t9, $0, 63					#} else if ( ch == '_') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting		#return 1;
               addi $t9, $0, 45					#} else if ( ch == '-') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting		#return 1;
               addi $t9, $0, 40					#} else if ( ch == '(') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting		#return 1;
               addi $t9, $0, 41					#} else if ( ch == ')') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting		#return 1;
               addi $t9, $0, 0					#} else if ( ch == '\n') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting		#return 1;
               addi $t9, $0, 10
               seq $v0, $a0, $t9				#} else if ( ch == '.') {
								#return 1; } else {return 0;}
end_of_is_delimiting:

               jr $ra


#--------------------------------------------------------------
# MAIN code
#--------------------------------------------------------------

	.globl main        # Declare main label to be globally visible.
                      # Needed for correct operation with MARS

                     #return values store in v registers, argument values in a registers

                      #  ' ' is 32, ',' is 44, '.' is 46, '!' 33, '_' is 95
                      # '?' is 63, '-' is 45, '(' is 40, ')' is 41, '\0' is 0,
                      # '\n' is 10
process_input:
					#$a0 is inp*, $a1 is out*                                              int process_input(char* inp, char* out) {
					add $t0, $0, $0 #int char_index = 0                                        int char_index = 0;
					add $t1, $0, $0 #int is_delim_ch = 0                                       int is_delim_ch = 0;
					add $t2, $0, $0 #cur_char = 0                                              char cur_char = '\0';
					add $t3, $0, $0 #word_found = 0                                            int word_found = 0;
loop:
					sne $t4, $0, $t3 #while word_found == 0                                    while( end_of_sentence == 0 && word_found == 0 ) {
					bne $t4, $0, endOfProcessInput
					sne $t5, $0, $s1 #while end_of_sentence == 0
					bne $t5, $0, endOfProcessInput #stop looping if end of sentence
mainStuff:
					add $t7, $s0, $a0 #inp[input_index]
					lb  $t2, 0($t7) #cur_char = inp[input_index]                               cur_char = inp[input_index];
					add $t7, $a0, $0 #temporarily store inp* in t7
					add $a0, $t2, $0 # put cur_char in a0 register
					addi $sp, $sp, -4 #add ra to stack
					sw $ra, 0($sp)
					jal is_delimiting_char #call is_delimiting char on
							       #cur_char argument
					lw $ra, 0($sp)
					addi $sp, $sp, 4 #get back ra from stack
					add $a0, $t7, $0 #put input back in a0 register
					add $t1, $0, $v0 #is_delim_ch = return value of function call              is_delim_ch = is_delimiting_char(cur_char);
					beq $t1, $0, notDelim #go to notDelim if returned value is 0               if ( is_delim_ch == 1 ) {
					addi $t7, $0, 10 #store 10 in t7 register
					bne $t7, $t2, wordFoundOrNaw # is cur_char == 10? if not,
					                              #skip endOfSentenceFound                     if ( cur_char == '\n' ) {
endOfSentenceFound:
					addi $s1, $0, 1 #end_of_sentence == 1 if newline character reached         end_of_sentence = 1;
																											   #}
wordFoundOrNaw:
					slt $t7, $0, $t0 # is 0 < char_index? if yes, t7 register == 1             if ( char_index > 0 ) {
					beq $t7, $0, doNothing # if 0 < char_index, continue. else, skip
							       # to doNothing, which jumps to end of while loop
					addi $t3, $0, 1 # word_found == 1 if 0 < char_index                        word_found = 1;
doNothing:																											#     } else {}
					j incrementInputIndex #skip the notDelim effects
notDelim:
					add $t7, $a1, $t0 #t7 register has address of out[char_index]             } else {
					sb  $t2, 0($t7) #store cur_char in out[char_index]                         out[char_index] = cur_char;
					addi $t0, $t0, 1 #increment char_index                                     char_index++;
incrementInputIndex:                                                                                             #}
					addi $s0, $s0, 1                                                         #input_index++;
					addi $t7, $0, 1	#set t7 register to 1                                  # }
					bne $t7, $0, loop #always loop
endOfProcessInput:
					add $t7, $a1, $t0 #out[char_index]                                     out[char_index] = '\0';
					sb $0, 0($t7) # out[char_index] = 0 == '\0'
					add $v0, $0, $t3 # return word_found                                   return word_found; }
					jr $ra


main:														#int main() {
					add $t3, $0, $0 #int word_found = 0, perhaps redundant    		   #int word_found = 0;
foreverLand:         												   #while(1) {
					add $s0, $0, $0 #int input_index = 0					   input_index = 0;
					add $s1, $0, $0 #int end_of_sentence = 0				   end_of_sentence = 0;
					jal read_input #read_input(input_sentence)				   read_input(input_sentence);
					la $a0, outmsg
					jal print_string							   # print_string("output:\n");
doWhile:														#do {
					la $a0, input_sentence #load 2 arguments for process_input
					la $a1, word
					jal process_input
					add $t3, $0, $v0		  		                                  #word_found = process_input(input_sentence, word)
outputWordOrNaw:
					beq $0, $t3, doWhileCheck #if (word_found == 0) continue to doWhileCheck          if ( word_found == 1 ) {
					la $a0, word
					jal output #output(word)                                                          output(word);
doWhileCheck:				beq $s1, $0, doWhile #while(end_of_sentence != 1)			          }
										                                        #} while ( end_of_sentence != 1 );
														   #}
		                        addi $t6, $0,1				                                   #return 0;
					bne $0, $t6,foreverLand						        #}

              				li $v0, 10
              				syscall
