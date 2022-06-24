%language "Java"

%define api.prefix {JavaCompiler}
%define api.parser.class {JavaCompiler}
%define api.parser.public
%define parse.error verbose

%code imports{
  import java.io.InputStream;
  import java.io.InputStreamReader;
  import java.io.Reader;
  import java.io.IOException;
  import java.io.StreamTokenizer;
  import java.util.*;
  
}

%code {
  
  
  public String getSymbol(){
    return "abbc";
  }
  
  MainClass mainClass = new MainClass();

  

  public static void main(String args[]) throws IOException {
    JavaCompilerLexer lexer = new JavaCompilerLexer(System.in);
    JavaCompiler parser = new JavaCompiler(lexer);
    if(parser.parse()){
      System.out.println("Parsing Result = SUCCESS");
      }
    else{
    	System.out.println("Parsing Result = ERROR");
    }
    return;
  }
}




%token _IF
%token _ELSE
%token _RETURN
%token _CLASS
%token _PUBLIC
%token _STATIC

%token _MAIN
%token _EXTENDS
%token _SOUT
%token _NEW
%token _THIS
%token _ARGS


%token _LPAREN
%token _RPAREN
%token _LBRACKET
%token _RBRACKET
%token _LSQUARE
%token _RSQUARE

%token _SEMICOLON
%token _ASSIGN
%token _AROP
%token _RELOP
%token _UNKNOWN_TOKEN
%token _COMMA
%token _DOT

%token <String> _ID
%token <Integer> _INT_NUMBER
%token <String> _INT
%token <String> _STRING
%token <String> _VOID

%type <String> type 
%type <String> variable_type


%%



program
  : main_class
  ;
  
main_class
  : _CLASS _ID _LBRACKET declaration_list _RBRACKET
  ;

declaration_list
  :  declaration_list declaration
  | //empty 
  ;

declaration
  : variable_declaration
  | main_method_declaration
  | method_declaration
  ;
  
main_method_declaration
  : _PUBLIC _STATIC _VOID _MAIN _LPAREN _STRING _ARGS _LSQUARE _RSQUARE  _RPAREN _LBRACKET statement_list _RBRACKET
  
method_declaration
  : _PUBLIC type _ID _LPAREN _RPAREN _LBRACKET statement_list _RBRACKET
   {
     if(mainClass.hasMethod($3)){
     
       
     }
   	mainClass.addMethod(new Method($3, $2, new ArrayList<Param>()));
   	for (Method m:mainClass.getMethods()){
   	  System.out.println(m.methodName);
   	
   	}
   
   
   }
  | _PUBLIC type _ID _LPAREN parameters _RPAREN _LBRACKET statement_list _RBRACKET
  {
  
  
  
  }

  
  ;
  
parameters
  : parameters _COMMA variable_type _ID
  | variable_type _ID 
  ;
  
variable_declaration
  : variable_type _ID _SEMICOLON
  ;


statement_list
  : statement_list statement
  |
  ;
  
statement
  : variable_declaration
  | compound_statement
  | assignment_statement
  | if_statement
  | return_statement
  | method_call
  | print_statement
  ;
  
print_statement
  : _SOUT _LPAREN _INT_NUMBER _RPAREN _SEMICOLON

method_call
  : _THIS _DOT _ID _LPAREN _RPAREN _SEMICOLON
  | _THIS _DOT _ID _LPAREN method_params _RPAREN _SEMICOLON
  ;
  
method_params
  : method_params _COMMA param
  | param
  ;

param
  : _INT_NUMBER
  | _ID
  ;
  
type
  : _VOID {$$="void";}
  | variable_type {$$ = $1;}
  ;
  
variable_type
  : _INT {$$ = "int";}
  | _STRING {$$= "String";}
  ;


compound_statement
  : _LBRACKET statement_list _RBRACKET
  ;

assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON
  ;

num_exp
  : exp
  | num_exp _AROP exp
  ;

exp
  : literal 
  | _ID
  | function_call
  | _LPAREN num_exp _RPAREN
  ;

literal
  : _INT_NUMBER 
  ;

function_call
  : _ID _LPAREN argument _RPAREN
  ;

argument
  : /* empty */
  | num_exp
  ;

if_statement
  : if_part _ELSE statement
  ;

if_part
  : _IF _LPAREN rel_exp _RPAREN statement
  ;

rel_exp
  : num_exp _RELOP num_exp
  ;

return_statement
  : _RETURN num_exp _SEMICOLON
  ;




%%

class JavaCompilerLexer implements JavaCompiler.Lexer {

  InputStreamReader it;
  Yylex yylex;
  
  
  String yylval;
  
  
  public int getLine(){
   return yylex.getLine();
  }

  public JavaCompilerLexer(InputStream is){
    it = new InputStreamReader(is);
    yylex = new Yylex(it);
    yylval = yylex.yytext();
  }
  

  @Override
  public void yyerror (String s){
    System.err.println("Error at line " + getLine() + ". " + s);
  }

  @Override
  public Object getLVal() {
    
    return yylex.yytext();
  }

  @Override
  public int yylex () throws IOException{
    return yylex.yylex();
}


}



class MainClass{

  String className;
  List<Method> methodList;
  List<Variable> variableList;
  
  public MainClass(){
    this.methodList = new ArrayList<>();
    this.variableList = new ArrayList<>();
  
  }
  public void addMethod(Method method){
    this.methodList.add(method);
  
  }
  public void addVariable(Variable variable){
  
    this.variableList.add(variable);
  }
  public List<Method> getMethods(){
  
  	return this.methodList;
  }
  public boolean hasMethod(String methodName){
    for (Method m:this.methodList){
    	if(m.methodName.equals(methodName)){
    	
    	  return true;
    	}
    
    }
    return false;
  }

}
class Method{
  public String methodName;
  public String type;
  public List<Param> params;
  
  public Method(){this.params = new ArrayList<>();}
  
  public Method(String methodName, String type, List<Param> params){
    this.methodName = methodName;
    this.type = type;
    this.params = params;
  
  }

}
class Variable{
  public String variableName;
  public String type;
  public String value;
  
  public Variable(){}

}
class Param{
  public String paramName;
  public String paramType;
  
  public Param(){}
  
  public Param(String paramName, String paramType){
    this.paramName = paramName;
    this.paramType = paramType;
  
  }
}


