--------------------------------------SYNTAX ANALYZER-----------------------
/* This is our version of syntax analyzer combined with the lexical of the first part */
/* The syntax analyzer's functionalities are included in file "ptucc_parser.y" */

/* Functionalities not included in our syntax analyzer*/
	#casting in a basic or complex type
	#declare a type in order to be used in the body of our program (this types is translated into typedef in c)
	#return and result commands are not exluded from procedure body 

/* The functionalities mentioned above weren't implemented because of lack of time  and due to pressure by other courses */

/* We are willing to present to you how they can be implemented */

/*-------------------------------HOW TO RUN OUR CODE------------------------*/

	1)Determine the directory in which is located the given project
	2)Execute the command touch .depend
	3)Execute the command make
	4)Execute the command ptucc < example.ptuc where example is one of samples included in the given folder
	5)--Unecessary Step-- If you would like to export the code translated into c reform the command above into something like this:
	  ptucc < example.ptuc > exported_file where exported_file is name of file which you would like to include our translated c program
