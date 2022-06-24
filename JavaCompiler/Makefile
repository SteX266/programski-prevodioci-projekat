default:
	clear
	jflex JavaCompiler.l
	bison JavaCompiler.y -L java
	javac *.java
	
clean:
	rm JavaCompiler.java *.class Yylex.java Yylex.java\~
