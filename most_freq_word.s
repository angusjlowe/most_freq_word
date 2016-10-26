#The comments on the following 8 lines were taken from Decimal to Hex Calculator, Paul Jackson. They
#were provided in the source files. I will state this by using (1) from now on.

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
words:		      .space 25500 #contiguous array of bytes, 500 * 51 = 25500 bytes long
											  #500 rows and 51 columns
frequencies:	      .space 500 #==number of rows in words
 		      .align 2   #align to word length == 2^2 == 4 bytes

highest_freq_word:    .space 51
MAX_CHARS:       .word 1001 #define MAX_CHARS 1001
MAX_WORD_LENGTH: .word 51 #define MAX_WORD_LENGTH 51

#(1)
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
               sw $ra 0($sp)  #return address to location at which this function was called
               la $a0, prompt0         # void read_input(char* inp) {
               jal print_string        # print_string("\ninput: ");
               la $a0, input_sentence   # read_string(input_sentence, MAX_CHARS);
               la $a1, MAX_CHARS        # }
               jal read_string
               lw $ra, 0($sp)
               addi $sp, $sp, 4 #load into $ra the location in stack
               jr $ra

               #char_index is $s2
               #input_index is $s0
               #end_of_sentence is $s1
               #address of word is $s3
               #max_frequency is $s4
               #num_unique_words is $s5
               #num_words_with_max_frequency is $s6
output:
               addi $sp, $sp, -4 #store into stack the location at which this function was called
               sw $ra, 0($sp)
               add $a0, $s5, $0    #print_int(num_unique_words);
               jal print_int
               la $a0, newline     #print_string("\n");
               jal print_string    
               add $a0, $s4, $0    #print_int(max_frequency)
               jal print_int    
               la $a0, newline     #print_string('\n');
               jal print_string
               add $a0, $s6, $0    #print_int(num_words_with_max_frequency);
               jal print_int        
               la $a0, newline      #print_string('\n');
               jal print_string
               add $a0, $s3, $0    
               jal print_string    #print_string(word);   

               lw $ra, 0($sp)      
               addi $sp, $sp, 4 #load into $ra the location stored in stack
               jr $ra

 is_delimiting_char:                                 #int is_delimiting_char(char ch) {
               addi $t9, $0, 32			     #if ( ch == ' ') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     #return 1;
               addi $t9, $0, 44			     #} else if ( ch == ',') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     # return 1;
               addi $t9, $0, 46			     #} else if ( ch == '.') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     #return 1;
               addi $t9, $0, 33			     #} else if ( ch == '!') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     #return 1;
               addi $t9, $0, 95			     #} else if ( ch == '?') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     #return 1;
               addi $t9, $0, 63			     #} else if ( ch == '_') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     #return 1;
               addi $t9, $0, 45			     #} else if ( ch == '-') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     #return 1;
               addi $t9, $0, 40			     #} else if ( ch == '(') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     #return 1;
               addi $t9, $0, 41			     #} else if ( ch == ')') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     #return 1;
               addi $t9, $0, 0			     #} else if ( ch == '\n') {
               seq $v0, $a0, $t9
               bne $v0, $0, end_of_is_delimiting     #return 1;
               addi $t9, $0, 10
               seq $v0, $a0, $t9		     #} else if ( ch == '.') {
						     #return 1; } else {return 0;}
end_of_is_delimiting:

               jr $ra



find_word:
					#$a0 is inp*, $s3 is out*                                            
					add $t1, $0, $0 #int is_delim_ch = 0                                
					add $t2, $0, $0 #cur_char = 0                                        
					add $t3, $0, $0 #word_found = 0              
					add $s2, $0, $0 #char_index = 0
loop:
					la $a0, input_sentence # make sure a0 is input_sentence
					sne $t4, $0, $t3 #while word_found == 0                         
					bne $t4, $0, endOfProcessInput
					sne $t4, $0, $s1 #while end_of_sentence == 0
					bne $t4, $0, endOfProcessInput #stop looping if end of sentence
mainStuff:
					add $t7, $s0, $a0 #inp[input_index]
					lb  $t2, 0($t7) #cur_char = inp[input_index]                     
					add $t7, $a0, $0 #temporarily store inp* in t7
					add $a0, $t2, $0 # put cur_char in a0 register
					addi $sp, $sp, -4 #add ra to stack
					sw $ra, 0($sp)
					jal is_delimiting_char #call is_delimiting char on
							       #cur_char argument
					lw $ra, 0($sp)
					addi $sp, $sp, 4 #get back ra from stack
					add $a0, $t7, $0 #put input back in a0 register
					add $t1, $0, $v0 #is_delim_ch = return value of function call               is_delim_ch = is_delimiting_char(cur_char);
					beq $t1, $0, notDelim #go to notDelim if returned value is 0                if ( is_delim_ch == 1 ) {
					addi $t7, $0, 10 #store 10 in t7 register
					bne $t7, $t2, wordFoundOrNaw # is cur_char == 10? if not,
					                              #skip endOfSentenceFound                          if ( cur_char == '\n' ) {
endOfSentenceFound:
					addi $s1, $0, 1 #end_of_sentence == 1 if newline character reached                 end_of_sentence = 1;
														        #}
wordFoundOrNaw:
					slt $t7, $0, $s2 # is 0 < char_index? if yes, t7 register == 1                  if ( char_index > 0 ) {
					beq $t7, $0, doNothing # if 0 < char_index, continue. else, skip to doNothing,
							       # which jumps to end of while loop
					addi $t3, $0, 1 # word_found == 1 if 0 < char_index                                  word_found = 1;
doNothing:													   #     } else {}
					j incrementInputIndex #skip the notDelim effects
notDelim:
					add $t7, $s3, $s2 #t7 register has address of word[char_index]              } else {
					sb  $t2, 0($t7) #store cur_char in word[char_index]                           word[char_index] = cur_char;
					addi $s2, $s2, 1 #increment char_index                                        char_index++;
incrementInputIndex:                                                                                                 #}
					addi $s0, $s0, 1                                                              #input_index++;
					addi $t7, $0, 1	#set t7 register to 1                                     # }
					bne $t7, $0, loop #always loop
endOfProcessInput:
					add $t7, $s3, $s2 #out[char_index]                                          word[char_index] = '\0';
					sb $0, 0($t7) # out[char_index] = 0 == '\0'
					add $v0, $0, $t3 # return word_found                                        return word_found; }
					jr $ra



location_inside:
             				  #a0 register has argument, pointer to word
              				addi $v0, $0, -1 #location = -1
              			        add $t0, $0, $0 # int j = 0
               				add $t1, $0, $0 # int k = 0
firstLoop:
					slt $t3, $t0, $s5
					beq $t3, $0, endLocationInside
					addi $t2, $0, 1 # int is_it_the_same = 1;
secondLoop:
					#implement this
					add $t3, $t1, $a0 #t3 register has address of kth element of word
					lb $t7, 0($t3) #t7 register has value of word[k]
					addi $t4, $0, 500
					mult $t4, $t0 #row j of contiguous array
					mflo $t4
					add $t4, $t4, $t1 #row j column k of contiguous array
					la $t5, words
					add $t5, $t5, $t4 #row j column k of words
					lb $t6, 0($t5) #t5 register has words[j][k]
areTheyDifferent:
					sne $t4, $t6, $t7 #words[j][k] == word[k]?
					beq $t4, $0, backToSecondLoop #if t6 == t3 then loop again
					add $t2, $0, $0 #otherwise, is_it_the_same = 0 and break from second loop
					j sameOrNaw #break
backToSecondLoop:
					addi $t1, $t1, 1 #increment k
					addi $t7, $s2, 1 #char_index + 1
					bne $t1, $t7, secondLoop
sameOrNaw:
					beq $0, $t2, backToFirstLoop #if is it the same == 0 perform the first loop again
					add $v0, $0, $t0 #otherwise location = j and then return this
					j endLocationInside #break
backToFirstLoop:
					addi $t0, $t0, 1 #increment j
					bne $t0, $s5, firstLoop #loop back to firstLoop
endLocationInside:
					jr $ra




update_max_frequency:
					la $t0, frequencies
					add $t1, $0, $s7
					sll $t1, $t1, 2
					add $t0, $t0, $t1 #frequencies[location_index]
					lw $t1, 0($t0) #frequencies[location_index] value
					bne $t1, $s4, isGreater #if(frequencies[location_index]==max_frequency) execute the next line
					addi $s6, $s6, 1 #num_words_with_max_frequency++;
isGreater:
					slt $t2, $s4, $t1 #t2==1 if frequencies[location_index] > max_frequency
					beq $t2, $0, exitUpdateMaxFrequency
					add $s4, $0, $t1 # max_frequency = frequencies[location_index]
					add $t0, $0, $0 # i = 0
highestFreqWordLoop:
					la $t1, highest_freq_word
					add $t1, $t1, $t0 # highest_frequency_word[i]
					la $t2, words
					li $t3, 500
					mult $t3, $s7 # words[location_index]
					mflo $t4
					add $t4, $t4, $t0
					add $t2, $t2, $t4 # words[locatin_index][i]
					lb $t3, 0($t2) # words[location_index][i] value
					sb $t3, 0($t1) # highest_frequency_word[i] = words[location_index][i]
					addi $t0, $t0, 1 #increment i
					addi $t1, $s2, 1 #char_index + 1
					bne $t0, $t1, highestFreqWordLoop
					#reset num_words_with_max_frequency since there is a new max
					addi $s6, $0, 1 #num_words_with_max_frequency = 1
exitUpdateMaxFrequency:
					jr $ra


update_frequencies:
					addi $sp, $sp, -4
					sw $ra, 0($sp)
					add $t0, $a0, $0 # temporarily store a0 in t0
					add $a0, $s3, $0 # put address of word into a0 register
					jal location_inside #is the word already in the 2d contiguous array of words? -1 means no
					add $a0, $t0, $0 #put the address of input_sentence back into a0 register
					lw $ra, 0($sp)
					addi $sp, $sp 4
					add $s7, $0, $v0 #location _index = location_inside(word)
					slt $t0, $s7, $0 #if location_index < 0, t0 = 1
					beq $0, $t0, updateFrequency #if t0 == 0 updateFrequency
					#otherwise, store new word in words
					#implement for loop and location < 0 case
storeWord:
					add $t0, $0, $0 # i = 0
storeWordLoop:
					li $t1, 500
					mult $t1, $s5 # $s5 is num_unique words
					mflo $t2
					add $t2, $t2, $t0
					la $t3, words
					add $t3, $t3, $t2 #words[num_unique_words][i]
					add $t4, $s3, $t0 #word[i]
					lb $t5, 0($t4) #word[i] value
					sb $t5, 0($t3) #words[num_unique_words][i] = word[i]
					addi $t0, $t0, 1 #increment i
					addi $t1, $s2, 1 # char_index + 1
					bne $t0, $t1, storeWordLoop
initializeStuff:
					add $s7, $0, $s5
					la $t0, frequencies
					add $t1, $0, $s7
					sll $t1, $t1, 2
					add $t1, $t0, $t1 # frequencies[location_index]
					lw $t2, 0($t1)
					addi $t2, $0, 1
					sw $t2, 0($t1) # frequencies[location_index] = 1
					addi $s5, $s5, 1 # num_unique_words ++;
					j endOfUpdateFrequencies

updateFrequency:
					la $t1, frequencies
					add $t2, $0, $s7
					sll $t2, $t2, 2
					add $t1, $t1, $t2 #frequencies[locatio_index]
					lw $t3, 0($t1)  #frequencies[location_index]
					addi $t3, $t3, 1 #increment frequencies[location_index]
               				sw $t3, 0($t1) # frequencies[location_index] += 1

endOfUpdateFrequencies:
					addi $sp, $sp, -4
					sw $ra, 0($sp)
					jal update_max_frequency
					lw $ra, 0($sp)
					addi $sp, $sp, 4
					jr $ra



create_histogram:
          #a0 register has argument, address to input_sentence
doWhile:
				   #load argument for find_word
               addi $sp, $sp, -4
               sw $ra, 0($sp)
	       jal find_word
               lw $ra, 0($sp)
               addi $sp, $sp, 4
	       add $t3, $0, $v0	 #word_found = find_word(inp)            
updateFrequenciesOrNaw:
	       beq $0, $t3, doWhileCheck #if (word_found == 0) continue to doWhileCheck           
					#a0 still holds pointer to word as argument (hopefully)
               addi $sp, $sp, -4
               sw $ra, 0($sp)
	       jal update_frequencies #output(word)
               lw $ra, 0($sp)
               addi $sp, $sp, 4                                                     
doWhileCheck:
	       beq $s1, $0, doWhile #while(end_of_sentence != 1)
               jr $ra



process_input:
               #a0 has argument, address to input_sentence
               add $s0, $0, $0 #reset input_index upon process-input call
               add $s1, $0, $0 #reset end_of_sentence upon call
               add $s2, $0, $0 #reset char_index upon call
               addi $sp, $sp, -4
               sw $ra, 0($sp)
               jal create_histogram #call create_histogram with a0, pointer to word, as input
               lw $ra 0($sp)
               addi $sp, $sp, 4
               #if there is at least one word in the input then copy highest_freq_word
               #to word
               slt $t7, $0, $s4 #if(max_frequency>0)
               beq $0, $t7, finishProcessInput
               add $t7, $0, $0 #initialize counter i
copyLoop:
               la $t0, highest_freq_word
               add $t5, $t7, $s3 #t5 has address of word[i]
               add $t6, $t7, $t0 #t6 has address of highest_freq_word[i]
               lb $t1, 0($t6) #load character from highest_freq_word[i]
               sb $t1, 0($t5) #store character into word[i] from highest_freq_word[i]
               addi $t7, $t7, 1 #increment index
               addi $t5, $0, 51
               bne $t7, $t5, copyLoop #for(i<51)
finishProcessInput:
               jr $ra


#(1)


#--------------------------------------------------------------
# MAIN code
#--------------------------------------------------------------

	.globl main        # Declare main label to be globally visible.
                      # Needed for correct operation with MARS

                     #return values store in v registers, argument values in a registers

                      #  ' ' is 32, ',' is 44, '.' is 46, '!' 33, '_' is 95
                      # '?' is 63, '-' is 45, '(' is 40, ')' is 41, '\0' is 0,
                      # '\n' is 10

main:
			#char_index is $s2
			#input_index is $s0
			#end_of_sentence is $s1
			#address of word is $s3
			#max_frequency is $s4
			#num_unique_words is $s5
			#num_words_with_max_frequency is $s6
			#location_index is $s7
foreverLand:
	       la $s3, word
               add $s5, $0, $0 #num_unique_words = 0;
               addi $s4, $0, -1 #max_frequency = -1 by default
               add $s6, $0, $0 #num_words_with_max_frequency = 0;
               sb $0, 0($s3) #word[0] = '\0'

               jal read_input
	       la $a0, input_sentence
               jal process_input
               jal output
               addi $t0, $0, 1
               bne $0, $t0, foreverLand

	       li $v0, 10
	       syscall
