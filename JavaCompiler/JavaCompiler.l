%%
%public
%standalone
%line 

%{


public int getLine(){return yyline+1;}


%}

%column



ID = [a-zA-Z][_a-zA-Z0-9]*
SKIP = [ \t\n\r]+
UNKNOWN_TOKEN = .
INT_NUMBER = [+-]?[0-9]{1,10}
STRING_VALUE = "\""[^\"]*"\"" 
               

%%


<YYINITIAL> {
	"int"		{ return JavaCompilerLexer._INT;}
	"String"	{ return JavaCompilerLexer._STRING;}
	"if"		{ return JavaCompilerLexer._IF;}
	"else"		{ return JavaCompilerLexer._ELSE;}
	"return"	{ return JavaCompilerLexer._RETURN;}
	
	"class"		{ return JavaCompilerLexer._CLASS;}
	"public"	{ return JavaCompilerLexer._PUBLIC;}
	"private"	{ return JavaCompilerLexer._PRIVATE;}

	"static"	{ return JavaCompilerLexer._STATIC;}
	"void"		{ return JavaCompilerLexer._VOID;}
	"main"		{ return JavaCompilerLexer._MAIN;}
	"extends"	{ return JavaCompilerLexer._EXTENDS;}
	"args"		{ return JavaCompilerLexer._ARGS;}
	
	"System.out.println" {return JavaCompilerLexer._SOUT;}
	
	"new" 		{ return JavaCompilerLexer._NEW;}
	"this"		{ return JavaCompilerLexer._THIS;}
	
	
	"("             { return JavaCompilerLexer._LPAREN; }
	")"             { return JavaCompilerLexer._RPAREN; }
	"{"             { return JavaCompilerLexer._LBRACKET; }
	"}"             { return JavaCompilerLexer._RBRACKET; }
	"["		{ return JavaCompilerLexer._LSQUARE; }
	"]"		{ return JavaCompilerLexer._RSQUARE;}

	";"             { return JavaCompilerLexer._SEMICOLON; }
	"="             { return JavaCompilerLexer._ASSIGN; }

	"+"             { return JavaCompilerLexer._AROP; }
	"-"             { return JavaCompilerLexer._AROP; }
	
	","		{ return JavaCompilerLexer._COMMA;}
	"."		{ return JavaCompilerLexer._DOT;}

	"<"             { return JavaCompilerLexer._RELOP; }
	">"             { return JavaCompilerLexer._RELOP; }
	"<="            { return JavaCompilerLexer._RELOP; }
	">="            { return JavaCompilerLexer._RELOP; }
	"=="            { return JavaCompilerLexer._RELOP; }
	"!="            { return JavaCompilerLexer._RELOP; }
	
	
	{ID}		{ return JavaCompilerLexer._ID;}
	{SKIP}		{}
	{INT_NUMBER}	{ return JavaCompilerLexer._INT_NUMBER;}
	
	{STRING_VALUE}  { return JavaCompilerLexer._STRING_VALUE;}
	
	{UNKNOWN_TOKEN}	{ System.out.println("Lexical error!" );return JavaCompilerLexer._UNKNOWN_TOKEN;}

}
