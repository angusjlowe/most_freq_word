// =========================================================================
//
// Find most occuring word in a sentence
//
// Inf2C-CS Coursework 1. Task B
// OUTLINE code, to be completed as part of coursework.
//
// Angus Lowe
// October 26, 2016
//
// =========================================================================


// C Header files
#include <stdio.h>

#include <stdio.h>

void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(char c)    { printf("%c", c); }
void print_int(int num)    { printf("%d", num); }
void print_string(char* s) { printf("%s", s); }


// Maximum characters in an input sentence including terminating null character
#define MAX_CHARS 1001

// Maximum characters in a word including terminating null character
#define MAX_WORD_LENGTH 51

char input_sentence[MAX_CHARS];
char word[MAX_WORD_LENGTH];
int num_unique_words = 0;
int max_frequency = -1;
int num_words_with_max_frequency = 0;
int input_index; //global, persists across method calls unless incremented by find_word
int end_of_sentence; //lets all methods know if end_of_sentence has been reached. once changed to 1, should be immutable
int char_index; //char_index is global now as it will be accessed by multiple methods
char words[500][MAX_WORD_LENGTH]; //2-dimensional array: will have a contiguous implementation
int frequencies[500]; // a word cannot occur more than 500 times
char highest_freq_word[51]; //temporary storage location for highest_frequency_word
int location_index; //location of current word in array of words
//initialize counters
int i;
int j;
int k;

int read_input(char* inp) {
    print_string("\ninput: ");
    read_string(inp, MAX_CHARS);
}

void output(int unique_words, int max_freq, int num_words_w_max_freq, char* out) {
    print_string("output:\n");
    print_int(unique_words);
    print_string("\n");
    print_int(max_freq);
    print_string("\n");
    print_int(num_words_w_max_freq);
    print_string("\n");
    print_string(out);
    print_string("\n");
}

int is_delimiting_char(char ch) {
    if ( ch == ' ') {
        return 1;
    } else if ( ch == ',') {
        return 1;
    } else if ( ch == '.') {
        return 1;
    } else if ( ch == '!') {
        return 1;
    } else if ( ch == '?') {
        return 1;
    } else if ( ch == '_') {
        return 1;
    } else if ( ch == '-') {
        return 1;
    } else if ( ch == '(') {
        return 1;
    } else if ( ch == ')') {
        return 1;
    } else if ( ch == '\n') { // Terminate the word if newline character found
        return 1;
    } else if ( ch == '\0') { // Terminate the word if null character found
        return 1;
    } else {
        return 0;
    }
}

//this method is similar to process_input from task a, except instead of printing it just stores
//the word found into the word[] array
int find_word(char* input) {
   int is_delim_ch = 0;  //initialize boolean set by the is_delimiting_char method check
   char cur_char = '\0'; //if there is no char, set the first char in  word[] array to '\0'
                         //by default
   int word_found = 0;   //word_found starts off as false
   //each time find_word is called, reset the char_index for the
   //word[] array
   char_index = 0;
   //loop through characters until you find a delimiting one
   //all the while adding them to word[] array
   while(end_of_sentence == 0 && word_found == 0) {
      cur_char = input[input_index];

      is_delim_ch = is_delimiting_char(cur_char); // implement this!
      if(is_delim_ch == 1) {

         if(cur_char == '\n') {
            end_of_sentence = 1;
         }
         if(char_index > 0) {
            word_found = 1;
         } else {
            //do nothing
         }
      } else {
         word[char_index] = cur_char;
         char_index++;
      }
      input_index++;
   }

   word[char_index] = '\0';
   return word_found;
}


//finds location of word within array of words, which is globally available
int location_inside(char* word) {
   //default to -1 return value if nothing found
   int location = -1;
   //loop through j 'rows' of 2-d words[][] array i.e. each eord stored
   for(j = 0; j < num_unique_words; j++) {
      //default boolean value indicating identical character to true
      int is_it_the_same = 1;
      //loop through k 'columns' of 2-d words[][] array
      for(k = 0; k < char_index + 1; k ++) { //char_index + 1 is size of current word
         //only way for is_it_the_same to remain true is if all characters are same
         if(word[k] != words[j][k]) {
            is_it_the_same = 0;
            break;
         }
      }
      //if the words are the same, location in 2-d array is j
      if(is_it_the_same == 1) {
         location = j;
         break;
      }
   }
   return location;
}

//this method will update max_frequency and num_words_with_max_frequency
void update_max_frequency() {
   //if frequency of word is equal to maximum frequency, increment number of words with maximum frequency
   if(frequencies[location_index] == max_frequency) {
      num_words_with_max_frequency++;
   }
   //check if current frequency is new max
   if(frequencies[location_index] > max_frequency) {
      max_frequency = frequencies[location_index];
      for(i = 0; i < char_index + 1; i++) {
         highest_freq_word[i] = words[location_index][i];
      }
      //reset num_words_with_max_frequency since there is a new max
      num_words_with_max_frequency = 1;
   }
}

//this method will update array of frequencies, num_unique words, array of words, and
//max frequency and num_words_with_max_frequency through another helper function
void update_frequencies() {
   location_index = location_inside(word); // check if word is already in array of words built up so far
   if(location_index < 0) { //if it isn't, initialize it
      //initialize array of strings
      for(i = 0; i < char_index + 1; i++) {
         words[num_unique_words][i] = word[i]; //index of array of unique words is equal to num_unique_words so far in the program
      }
      location_index = num_unique_words; // if word is not in the array of unique words yet, let the index equal index of the newly added word
      frequencies[location_index] = 1; // now there is at least one copy of this word so it gets a frequency of 1
      num_unique_words ++; //increment num_unique_words since there is now one more
   }
   else {
      //update frequency of word which has already been initialized into array of unique words
      frequencies[location_index]++;
   }
   update_max_frequency();
}

//similar to hashmaps except 2 independent arrays, so be careful
void create_histogram(char* inp) {
      do {
         int word_found = find_word(inp);
         if(word_found == 1) {
            update_frequencies();
         }
      } while(end_of_sentence != 1);
}

void process_input(char* inp) {
      //make sure input_index, char_index, and end_of_sentence are rest with every use of create_histogram
      input_index = 0;
      char_index = 0;
      end_of_sentence = 0;
      create_histogram(inp);
      //if there is at least one word in the input then assign highest_freq_word to word
      if(max_frequency > 0) {
          int i;
          for(i = 0; i < MAX_WORD_LENGTH; i++) {
          word[i] = highest_freq_word[i];
      }
    }
}
int main() {
    while(1) {

        num_unique_words = 0;
        max_frequency = -1;
        num_words_with_max_frequency = 0;
        word[0] = '\0';

        read_input(input_sentence);

        process_input(input_sentence);

        output(num_unique_words, max_frequency, num_words_with_max_frequency, word);
    }
}
