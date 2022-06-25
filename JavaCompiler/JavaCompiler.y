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
  
  ArrayList<Param> currentParams = new ArrayList<>();
  
  ArrayList<Value> calledParams = new ArrayList<>();
  
  public boolean isSemanticGood = true;
  
  int depth = 0;
  
  Method currentMethod = null;
  
  public void setIsSemanticGood(boolean isGood){
    
    isSemanticGood = isGood;
  }
  
  public Value getSymbolValue(String symbolName){
    Value v = null;
    
    for(Method m:mainClass.methodList){
      if(m.methodName.equals(symbolName)){
        v = new Value(m.type, null);  
      }
    }
    for (Variable var:mainClass.variableList){
      if(var.variableName.equals(symbolName)){
        v = new Value(var.type, symbolName);
      }
    }
    if(depth != 0){
      for (Variable var:currentMethod.variables){   
        if(var.variableName.equals(symbolName)){
        if (var.depth == depth && var.method.methodName.equals(currentMethod.methodName)){
          v = new Value(var.type, symbolName);
        }
        
       }
     }
    
    }
    return v;
  
  }

  public static void main(String args[]) throws IOException {
    JavaCompilerLexer lexer = new JavaCompilerLexer(System.in);
    JavaCompiler parser = new JavaCompiler(lexer);
    if(parser.parse()){
      System.out.println("Parsing Result = SUCCESS");
      }
    else{
    	System.out.println("Parsing Result = ERROR");
    }
    if(parser.isSemanticGood){
    
    System.out.println("Semantic Result = SUCCESS");
    }
    else{
    System.out.println("Semantic Result = ERROR");
    }

    return;
  }
}




%token _IF
%token _ELSE
%token _RETURN
%token _CLASS
%token _PUBLIC
%token _PRIVATE
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
%token <String> _INT_NUMBER
%token <String> _INT
%token <String> _STRING
%token <String> _VOID
%token <String> _STRING_VALUE

%type <Value> given_value
%type <Value> exp
%type <String> type 
%type <String> variable_type
%type <String> literal
%type <Method> method_call
%type <Value> num_exp

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
  : _PUBLIC _STATIC _VOID _MAIN _LPAREN _RPAREN
    {
    
       if(mainClass.hasMethod("main")){
       System.err.println("Error, redefinition of method " + $3);
       setIsSemanticGood(false);
       
     }
     else{
     	Method m = new Method("main", $3, new ArrayList<Param>());
        mainClass.addMethod(m);
        currentMethod = m;
        depth = 1;
     }
  
  
  }
   _LBRACKET statement_list _RBRACKET {currentMethod = null; depth=0;}

  
method_declaration
  : _PUBLIC type _ID _LPAREN _RPAREN
   {
     if(mainClass.hasMethod($3)){
       System.err.println("Error, redefinition of method " + $3);
       setIsSemanticGood(false);   
     }
     else{
     	Method m = new Method($3, $2, new ArrayList<Param>());
     	currentMethod = m;
        mainClass.addMethod(m);
        depth = 1;
     }
   }
   _LBRACKET statement_list _RBRACKET {currentMethod = null; depth=0;}

  | _PUBLIC type _ID _LPAREN parameters _RPAREN
    {
     if(mainClass.hasMethod($3)){
       System.err.println("Error, redefinition of method " + $3);
       setIsSemanticGood(false);
     }
     else{
        Method m = new Method($3, $2, currentParams);
     	currentMethod = m;
        mainClass.addMethod(m);   
        depth = 1;

     }
  
  }
  
   _LBRACKET statement_list _RBRACKET {currentMethod = null; depth=0;}
   
   

  ;
  
parameters
  : parameters _COMMA variable_type _ID { currentParams.add(new Param($4,$3));}
  | variable_type _ID {currentParams = new ArrayList<>(); currentParams.add(new Param($2, $1));}
  ;
  

variable_declaration
  : variable_type _ID _SEMICOLON 
  {
    if (depth == 0){
      Method m = new Method();
      Variable var = new Variable($2, $1, depth, m);
      
      if(mainClass.hasVariable(var)){
      
        System.err.println("Error, redefinition of variable " + $2);
        setIsSemanticGood(false);
      
      }
      else{
      
        mainClass.addVariable(var);
      }
    }
    
    else{
      Method m = mainClass.getMethodByName(currentMethod.methodName);
      Variable var = new Variable($2, $1, depth, m);
      if(currentMethod.hasVariable(var) || currentMethod.hasParamWithSameName(var)){
      
      System.err.println("Error, variable " + $2 + " already exists in current scope");
      setIsSemanticGood(false);
      }
      else{
        for(Method method:mainClass.methodList){
          if(method.methodName.equals(currentMethod.methodName)){
          method.addVariable(var);
          }
        }   
      }
    }
  }
  | variable_type _ID _ASSIGN given_value _SEMICOLON
    { 
    
      if(!$1.equals($4.type)){
      
        System.err.println("Error, wrong value given to a variable "+$2 +" with type "  + $1);
      }
    
    if (depth == 0){
      Method m = new Method();
      Variable var = new Variable($2, $1, $4.value,depth, m); 
      if(mainClass.hasVariable(var)){
      
        System.err.println("Error, redefinition of variable " + $2);
        setIsSemanticGood(false);
      
      }
      else{
      
        mainClass.addVariable(var);
      }
    }
    
    else{
      Method m = mainClass.getMethodByName(currentMethod.methodName);
      Variable var = new Variable($2, $1, $4.value,depth, m);
      
      if(currentMethod.hasVariable(var) || currentMethod.hasParamWithSameName(var)){
      
      System.err.println("Error, variable " + $2 + " already exists in current scope");
      setIsSemanticGood(false);
      }
      else{
      
      for(Method method:mainClass.methodList){
        if(method.methodName.equals(currentMethod.methodName)){
          method.addVariable(var);
          }
        
      }

    }

  }
  }
  
  ;

given_value
  : _STRING_VALUE {$$ = new Value("String", $1);}
  | literal {$$ = new Value("int", $1);}
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
  {
    if(mainClass.hasMethod($3)){
      if(mainClass.getMethodByName($3).params.size()>0){
        System.err.println("Error, method doesn't require any parameters");
      }
      $$ = mainClass.getMethodByName($3);
    }
    
    else{
      System.err.println("Error, method not declared!");
      setIsSemanticGood(false);
      $$ = new Method();
    }  
  }
  | _THIS _DOT _ID _LPAREN called_params _RPAREN _SEMICOLON
  {
    if(mainClass.hasMethod($3)){
      Method method = mainClass.getMethodByName($3);
      $$ = method;
      if(method.params.size() != calledParams.size()){

        System.err.println("Error, wrong number of parameters!");
        setIsSemanticGood(false);
      }
      else{
      	int count = 0;
        for (Param p:method.params){
          if(!p.paramType.equals(calledParams.get(count).type)){
          
            System.err.println("Error, wrong type of function parameters!");
            setIsSemanticGood(false);
          }
        
        }
      
      }
    }
    
    else{
      System.err.println("Error, method not declared!");
      setIsSemanticGood(false);
      $$ = new Method();
    }  
  }
  ;
  
called_params
  : called_params _COMMA exp {calledParams.add($3);}
  | exp  {calledParams = new ArrayList<>();calledParams.add($1);}
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
  : _LBRACKET{depth++;} statement_list _RBRACKET {depth--;}
  ;

assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON 
  {
    Value v = getSymbolValue($1);
    if(v == null){
      System.err.println("Error, not declared!");
    }
    else{
      if(!v.type.equals($3.type)){
        System.err.println("incompatible types in assignment");
      
      }
    
    }
  
  }
  ;

num_exp
  : exp {$$ = $1;}
  | num_exp _AROP exp 
  {
  if($1 != null && $3!=null){
    if (!$1.type.equals($3.type)){
  	
  	System.err.println("Error, not same type!");
  	setIsSemanticGood(false);
    }
    }
        else{
      System.err.println("Error, not declared or doesn't have value!");
    }
  }
  ;

exp
  : given_value  {$$ = $1;}
  | _ID {
  Value v = getSymbolValue($1);
  if(v == null){
    	System.err.println("Error, not declared!");
  	setIsSemanticGood(false);
  	$$ = new Value();
  }
  else{
  
    $$ = v;
  }
  
  
  
  }
  | method_call {$$ = new Value($1.type, null);}
  | _LPAREN num_exp _RPAREN {$$ = new Value("int", null);}
  ;

literal
  : _INT_NUMBER {$$ = $1;}
  ;


if_statement
  : if_part _ELSE statement
  ;

if_part
  : _IF _LPAREN rel_exp _RPAREN statement
  ;

rel_exp
  : num_exp _RELOP num_exp {
  
  if($1 != null && $3!=null){
    if(!$1.type.equals($3.type)){
    
      System.err.println("Error, not same type!");
      setIsSemanticGood(false);
    }
    }
    else{
      System.err.println("Error, not declared or doesn't have value!");
    }
  
  }
  ;

return_statement
  : _RETURN num_exp _SEMICOLON
  {
    if(!$2.type.equals(currentMethod.type)){
      System.err.println("Error, return value with type "+$2.type +"is not the right type!");
      setIsSemanticGood(false);    
    }
  }
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
  
   public boolean hasVariable(Variable variable){
    for (Variable v:this.variableList){
      if (variable.variableName.equals(v.variableName)){
        return true;
      }

    }
    return false;
  }
  
  public Method getMethodByName(String methodName){
   for (Method m:this.methodList){
    	if(m.methodName.equals(methodName)){
    	
    	  return m;
    	}
    
    }
    return new Method(); 
  }


}
class Method{
  public String methodName;
  public String type;
  public List<Param> params;
  public List<Variable> variables;
  
  public Method(){this.params = new ArrayList<>(); this.variables = new ArrayList<>();}
  
  
  public Method(String methodName, String type, ArrayList<Param> params){
    this.methodName = methodName;
    this.type = type;
    this.params = params;
    this.variables = new ArrayList<>();
  
  }
  
  public boolean hasVariable(Variable variable){
    for (Variable v:this.variables){
      if (variable.variableName.equals(v.variableName)){
        return true;
      }
    }
    return false;
  
  
  }
  
  public boolean hasParamWithSameName(Variable variable){
    for (Param p:this.params){
      if(p.paramName.equals(variable.variableName)){
        return true;
      }
    }
    return false;
  }
  
  public void addVariable(Variable var){
    this.variables.add(var);
  }
}
class Variable{
  public String variableName;
  public String type;
  public String value;
  
  public int depth;
  public Method method;
  
  public Variable(){}
  
  public Variable(String variableName, String type, int depth, Method method){
    this.variableName = variableName;
    this.type = type;
    this.method = method;
    this.depth = depth;
    
  }
  
    public Variable(String variableName, String type, String value, int depth, Method method){
    this.variableName = variableName;
    this.type = type;
    this.value = value;
    this.depth = depth;
    this.method = method;
  }

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
class Value{
  public String type;
  public String value;
  
  public Value(String type, String value){
  	this.type = type;
  	this.value = value;
  
  }
  public Value(){
    this.type ="";
    this.value = "";
  
  }


}



