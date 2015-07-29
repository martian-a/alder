<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:d="http://ns.kaikoda.com/documentation/xml"
    xmlns:sch="http://ns.kaikoda.com/xspec/schematron/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    exclude-result-prefixes="#all"
    version="2.0">
    
    <d:doc>
        <d:title>Alder Function Library</d:title>
        <d:desc>
            <d:p>A collection of helper functions designed to aid with using XSpec to test Schematron.</d:p>
        </d:desc>    
        <d:author>Sheila Thomson</d:author>
        <d:created>2015-07-28</d:created>
        <d:note>
            <d:p>For more information about XSpec, a unit testing framework, see <d:link href="https://github.com/expath/xspec" />.</d:p>
        </d:note>
        <d:note>
            <d:p>For more information about Schematron, an XML schema language, see <d:link href="http://www.schematron.com/overview.html" />.</d:p>
        </d:note>
        <d:history>
            <d:change date="2015-07-28">
                <d:desc>
                    <d:ul>
                        <d:ingress>Initial functions:</d:ingress>
                        <d:li>pattern-is-active</d:li>
                        <d:li>constraint-passes</d:li>
                        <d:li>constraint-fails</d:li>
                        <d:egress>and templates to embed them in a compiled XSpec test stylesheet.</d:egress>
                    </d:ul>
                </d:desc>                
            </d:change>
        </d:history>
    </d:doc>
    
    
    <d:doc ref="var.self">
        <d:desc>A pointer to the document node of this stylesheet.</d:desc>
        <d:note>This is used during the process to embed the library functions in a compiled test stylesheet.</d:note>
    </d:doc>
    <xsl:variable name="self" select="document('')" as="document-node()" d:id="var.self" />
    
    
    <d:doc ref="match.root">
        <d:desc>
            <d:p>Intended to match the root of a compiled XSpec test stylesheet.</d:p>
            <d:p>Starts an identity transform and which is interrupted only to merge in the library functions.</d:p>
        </d:desc>
        <d:note>This is used during the process to embed the library functions in a compiled test stylesheet.</d:note>
    </d:doc>
    <xsl:template match="document-node()">
        <xsl:apply-templates />
    </xsl:template>
    
        
    <d:doc ref="match.stylesheet">
        <d:desc>Copies the root element of the XSpec test stylesheet and appends the library functions to it's contents.</d:desc>
        <d:note>This is used during the process to embed the library functions in a compiled test stylesheet.</d:note>
    </d:doc>
    <xsl:template match="document-node()/xsl:stylesheet" priority="10" d:id="match.stylesheet">
        <xsl:copy>
            <xsl:apply-templates select="@*, node()" />
            <xsl:apply-templates select="@sch:extend[. = 'true']" mode="embed-library" />
        </xsl:copy>
    </xsl:template>
    
    
    <d:doc ref="match.extend">
        <d:desc>Copies all the functions in this stylesheet into the XSpec test stylesheet.</d:desc>
        <d:note>This is used during the process to embed the library functions in a compiled test stylesheet.</d:note>
    </d:doc>
    <xsl:template match="document-node()/xsl:stylesheet/@sch:extend" mode="embed-library" d:id="match.extend">
        <xsl:copy-of select="$self/xsl:stylesheet/xsl:function" />
    </xsl:template>
    
    
    <d:doc ref="suppress.extend">
        <d:desc>
            <d:p>Suppress the sch:extend atribute as it's not required after this point in the process.</d:p>
        </d:desc>
        <d:note>The presence of this attribute on the root element of the source file signals that this library should be embedded.</d:note>
        <d:note>This is used during the process to embed the library functions in a compiled test stylesheet.</d:note>        
    </d:doc>
    <xsl:template match="document-node()/xsl:stylesheet/@sch:extend" d:id="suppress.extend" />
    
    
    <d:doc ref="copy.element">
        <d:desc>Copy any otherwise unmatched element.</d:desc>
        <d:note>This is used during the process to embed the library functions in a compiled test stylesheet.</d:note>
    </d:doc>
    <xsl:template match="element()" d:id="copy.element">
        <xsl:copy>
            <xsl:apply-templates select="@*, node()" />
        </xsl:copy>
    </xsl:template>
    
    
    <d:doc ref="copy.remnants">
        <d:desc>Copy any otherwise unmatched element.</d:desc>    
        <d:note>This is used during the process to embed the library functions in a compiled test stylesheet.</d:note>
    </d:doc>
    <xsl:template match="@* | comment() | processing-instruction()" d:id="copy.remnants">
        <xsl:copy />
    </xsl:template>
    
    
    <d:doc>
        <d:desc>Checks whether a pattern with the id specified ($pattern-id) is present in a Schematron validation result (SVRL).</d:desc>
        <d:return>True if the pattern is found; false if it's not.</d:return>
    </d:doc>
    <xsl:function name="sch:pattern-is-active" as="xs:boolean">
        <xsl:param name="context" as="document-node()" />
        <xsl:param name="pattern-id" as="xs:string" />
        
        <xsl:value-of select="if ($context/*:schematron-output/*:active-pattern[@id = $pattern-id]) then true() else false()" />
        
    </xsl:function>
    
    
    <d:doc>
        <d:desc>
            <d:p>Checks whether a constraint with the id specified ($constraint-id) is present in a Schematron validation result (SVRL).</d:p>
            <d:p>The constraint may have been expressed as either an assert or a report.</d:p>
            <d:p>The constraint id may have been expressed as either an attribute (@id) or appended to the end of the constraint message, eg. [ID: title-missing]</d:p>
        </d:desc>
        <d:return>True if the constraint is found; false if it's not.</d:return>
        <d:note>This function has a dependency on sch:constraint-fails.</d:note>
    </d:doc>
    <xsl:function name="sch:constraint-passes" as="xs:boolean">
        <xsl:param name="context" as="document-node()" />
        <xsl:param name="constraint-id" as="xs:string" />
        
        <xsl:value-of select="if (sch:constraint-fails($context, $constraint-id) = 0) then true() else false()" />
        
    </xsl:function>
    
    
    <d:doc>
        <d:desc>
            <d:p>Checks how many times a constraint with the id specified ($constraint-id) is present in a Schematron validation result (SVRL).</d:p>
            <d:p>The constraint may have been expressed as either an assert or a report.</d:p>
            <d:p>The constraint id may have been expressed as either an attribute (@id) or appended to the end of the constraint message, eg. [ID: title-missing]</d:p>
        </d:desc>
        <d:return>A count of the number of times this constraint is found.</d:return>
    </d:doc>
    <xsl:function name="sch:constraint-fails" as="xs:integer">
        <xsl:param name="context" as="document-node()" />
        <xsl:param name="constraint-id" as="xs:string" />
        
        <xsl:value-of select="if (
                $context/*:schematron-output/*
                    [local-name() = ('failed-assert','successful-report')]
                    [
                        @id = $constraint-id or
                        (
                            not(@id) and
                            ends-with(., concat('[ID: ', $constraint-id, ']'))
                        )
                    ]
            ) 
            then true() 
            else false()" />
        
    </xsl:function>
    
</xsl:stylesheet>