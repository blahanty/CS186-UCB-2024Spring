/* Generated By:JavaCC: Do not edit this line. RookieParserDefaultVisitor.java Version 7.0.11 */
package edu.berkeley.cs186.database.cli.parser;

public class RookieParserDefaultVisitor implements RookieParserVisitor{
  public void defaultVisit(SimpleNode node, Object data){
    node.childrenAccept(this, data);
    return;
  }
  public void visit(SimpleNode node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTSQLStatementList node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTExecutableStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTExplainStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTDropTableStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTDropIndexStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTReleaseStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTSavepointStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTRollbackStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTBeginStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTCommitStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTInsertStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTInsertValues node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTUpdateStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTSelectStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTCommonTableExpression node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTDeleteStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTCreateTableStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTCreateIndexStatement node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTColumnDef node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTSelectClause node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTLimitClause node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTFromClause node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTfrom_clause node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTOrderClause node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTJoinedTable node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTSelectColumn node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTResultColumnName node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTColumnName node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTIdentifier node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTAliasedTableName node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTColumnValueComparison node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTNumericLiteral node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTIntegerLiteral node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTLiteral node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTComparisonOperator node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTOrOperator node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTAndOperator node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTNotOperator node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTMultiplicativeOperator node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTAdditiveOperator node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTExpression node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTOrExpression node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTAndExpression node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTNotExpression node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTComparisonExpression node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTAdditiveExpression node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTMultiplicativeExpression node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTFunctionCallExpression node, Object data){
    defaultVisit(node, data);
  }
  public void visit(ASTPrimaryExpression node, Object data){
    defaultVisit(node, data);
  }
}
/* JavaCC - OriginalChecksum=1556f3c521e5b5bb5c0714ab58f673a1 (do not edit this line) */
