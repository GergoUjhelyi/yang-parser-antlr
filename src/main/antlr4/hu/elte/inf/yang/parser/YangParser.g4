parser grammar YangParser;
options {
tokenVocab=YangLexer;
}

@header{
import java.time.LocalDate;

import hu.elte.inf.yang.parser.definitions.YangModule;
}

pr_YangFile:
    pr_YangModule?
    pr_SubModule?
    EOF;

pr_YangModule returns[YangModule yangModule]:
    OPTSEP?
    pr_YangModuleKeyword
    OPTSEP?
    i = pr_Identifier {
        if ($i.identifier != null && $i.identifier.isEmpty()) {
            $yangModule = new YangModule();
            $yangModule.setModuleName($i.identifier);
        }
    }
    OPTSEP?
    pr_BeginChar
    pr_StatementSeparator
    pr_ModuleHeaderStatements
    pr_LinkageStatements
    pr_MetaStatements
    pr_RevisionStatements
    pr_BodyStatements
    pr_EndChar
;

pr_YangModuleKeyword returns[String stringValue]:
    MODULE
;

pr_SubModule: // TODO: create submodule class
    OPTSEP?
    SUBMODULE
    SEP?
    i = pr_Identifier
    OPTSEP?
    pr_BeginChar
    pr_SubModuleHeaderStatements
    pr_LinkageStatements
    pr_MetaStatements
    pr_RevisionStatements
    pr_BodyStatements
    pr_EndChar
    OPTSEP?
;

pr_ModuleHeaderStatements:
    (
        pr_YangVersionStatement
        |
        pr_NamespaceStatement
        |
        pr_PrefixStatement
    )+
;

pr_SubModuleHeaderStatements:
        (
            pr_YangVersionStatement
            |
            pr_BelongsToStatement
        )+
;

pr_LinkageStatements:
    (pr_ImportStatement
    |
    pr_IncludeStatement)*
;

pr_MetaStatements:
    (pr_OrganizationStatement
    |
    pr_ContactStatement
    |
    pr_DescriptionStatement
    |
    pr_ReferenceStatement
    )*
;

pr_RevisionStatements:
    (pr_RevisionStatement)*
;

pr_BodyStatements:
    (
    pr_ExtensionStatement
    )*
;

pr_YangVersionStatement:
    YANG_VERSION
    SEP?
    YANG_VERSION_ARG
    pr_StatementEnd
;

pr_NamespaceStatement:
    NAMESPACE
    SEP?
    uri = pr_URIString
    pr_StatementEnd
;

pr_PrefixStatement:
    PREFIX
    SEP?
    (pr_Identifier | pr_String) //TODO: save prefix value
    pr_StatementEnd
;

pr_BelongsToStatement:
    BELONGS_TO
    SEP?
    (pr_Identifier | pr_String)
    OPTSEP?
    pr_BeginChar
    pr_StatementSeparator
    p = pr_PrefixStatement
    pr_EndChar
    pr_StatementSeparator
;

pr_ImportStatement:
    IMPORT
    SEP?
    i = pr_Identifier
    OPTSEP?
    pr_BeginChar
    pr_StatementSeparator
        (
         pr_PrefixStatement
         |
         pr_RevisionDateStatement
         |
         pr_DescriptionStatement
         |
         pr_ReferenceStatement
        )+
    pr_EndChar
    pr_StatementSeparator
;

pr_RevisionDateStatement: //TODO: returns statement
    REVISION_DATE
    SEP?
    pr_RevisionDate //TODO: save revision date
    pr_StatementEnd
;

pr_RevisionStatement: //TODO: returns statement
    REVISION
    SEP?
    d = pr_RevisionDate
    OPTSEP?
    (
        SEMICOLON
        |
        (
            pr_BeginChar
            pr_StatementSeparator
            (pr_DescriptionStatement
            |
            pr_ReferenceStatement
            )+
            pr_EndChar
        )
    )
;

pr_DescriptionStatement: //TODO: returns statement
    DESCRIPTION
    SEP?
    pr_String
    pr_StatementEnd
;

pr_ReferenceStatement: //TODO: returns statement
    REFERENCE
    SEP?
    pr_String
    pr_StatementEnd
;

pr_UnitsStatement: //TODO: returns statement
    UNITS
    SEP?
    pr_String
    pr_StatementEnd
;

pr_IncludeStatement: //TODO: returns statement
    INCLUDE
    SEP?
    (pr_String | pr_Identifier)
    OPTSEP?
    (
        SEMICOLON
        |
        pr_BeginChar pr_StatementSeparator
        (
            pr_RevisionDate
            |
            pr_DescriptionStatement
            |
            pr_ReferenceStatement
        )+
        pr_EndChar
    )
    pr_StatementSeparator
    ;

pr_OrganizationStatement: //TODO: returns statement
    ORGANIZATION
    SEP?
    org = pr_String
    pr_StatementEnd
;

pr_ContactStatement: //TODO: returns statement
    CONTACT
    SEP?
    c = pr_String
    pr_StatementEnd
;

pr_ExtensionStatement: //TODO: returns statement
    EXTENSION
    SEP?
    pr_Identifier
    OPTSEP?
    (
    SEMICOLON
    |
        (
            pr_BeginChar
            pr_StatementSeparator
            (
                pr_ArgumentStatement
                |
                //TODO: status statement
                pr_DescriptionStatement
                |
                pr_ReferenceStatement
            )+
            pr_EndChar
        )
    ) pr_StatementSeparator
;

pr_ArgumentStatement: //TODO: returns statement
    ARGUMENT
    SEP?
    (pr_Identifier | pr_String)
    OPTSEP?
    (
        SEMICOLON
    |
        (
            pr_BeginChar
            pr_StatementSeparator
            pr_YinElementStatement
            pr_EndChar
        )
    )
    pr_StatementSeparator
;

pr_YinElementStatement: //TODO: returns statement
    YIN_ELEMENT
    SEP?
    pr_YinElementArguement
    pr_StatementEnd
;

pr_YinElementArguement: //TODO: returns boolean
    TRUE | FALSE;

pr_FeatureStatement: //TODO: returns statement
    FEATURE
    SEP?
    feature_id = pr_Identifier
    OPTSEP?
    (SEMICOLON
    |
    (pr_BeginChar
     pr_StatementSeparator
     )
     )
;

pr_StatusStatement:
    STATUS
    SEP?
    s = pr_StatusArguement
    pr_StatementEnd
;

pr_StatusArguement: //TODO: returns status
    CURRENT
    |
    OBSOLETE
    |
    DEPRECATED
;

pr_UnknownStatement:
   prefix = pr_Identifier
   COLON
   i = pr_Identifier
   (SEP pr_Identifier)? //TODO: change pr_Identifier rule to pr_String
   OPTSEP?
         (
             SEMICOLON
           | pr_BeginChar OPTSEP
                 ((pr_YangStatement | pr_UnknownStatement) OPTSEP)*
             pr_EndChar
         )
         pr_StatementSeparator
    ;

pr_StatementSeparator:
    (WS | SP | pr_UnknownStatement)*
    ;

pr_YangStatement:
    s1 = pr_YangVersionStatement
;

pr_StatementEnd:
    OPTSEP?
    (
     SEMICOLON
     |
     pr_BeginChar
     pr_StatementSeparator
     pr_EndChar
    )
    pr_StatementSeparator;


pr_Identifier returns[String identifier]:
    IDENTIFIER
{
    if ($IDENTIFIER.getTokenIndex() >= 0) {
        final String text = $IDENTIFIER.text;
        if (text != null) {
            $identifier = text;
        }
    }
};

pr_String returns[String stringValue]:
    s = DOUBLE_QUOTE_STRING
{
    final String text = $s.text;
    if (text != null) {
        $stringValue = text.substring(1, text.length() - 1);
    }
};

pr_BeginChar:
    BEGINCHAR; // TODO: bracket counter++?

pr_EndChar:
    ENDCHAR; // TODO: bracket counter--?

pr_URIString returns[String uriValue]: //Architect Decision #1: Don't create parser rules for RFC 3986, semantic check only after parsing
    DOUBLE_QUOTE_STRING
{
    final String text = $DOUBLE_QUOTE_STRING.text;
    if (text != null) {
        $uriValue = text;
    }
};

pr_RevisionDate returns[LocalDate revisonDate]:
    DATE_ARG
{
        final String text = $DATE_ARG.text;
        if (text != null) {
            $revisonDate = LocalDate.parse(text);
        }
};

pr_ErrorMessageStatement: //TODO: returns statement
    ERROR_MESSAGE
    SEP?
    m = pr_String
    pr_StatementEnd
;

pr_ErrorAppTagStatement: //TODO: returns statement
    ERROR_APP_TAG
    SEP?
    t = pr_String
    pr_StatementEnd
;

// Ranges

pr_RangeStatement:
    RANGE
    SEP?
    pr_RangeArguement
    OPTSEP?
    (SEMICOLON
        |
        (pr_BeginChar
        pr_StatementSeparator
        (pr_ReferenceStatement | pr_DescriptionStatement | pr_ErrorMessageStatement | pr_ErrorAppTagStatement)*
        pr_EndChar)
    )
;

pr_RangeArguement:
    pr_RangePart
    (
        OPTSEP?
        VERTICAL_LINE
        OPTSEP?
        pr_RangePart
    )*

;

pr_RangePart:
    pr_RangeBoundary
    (
        OPTSEP?
        RANGE_DOTS
        OPTSEP?
        pr_RangeBoundary
    )?
;

pr_RangeBoundary:
    MIN | MAX | INTEGER_VALUE | DECIMAL_VALUE
;
