<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Output HTML5. -->
	<xsl:output method="html" doctype-system="about:legacy-compat"/>


	<!-- Basic identity transform - copy everything. -->
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>



	<!-- The 'Page details' section gets preserved, to keep some attribution to original author.
	     But add a note about this page being extracted from the old wiki. -->
<!--	<xsl:template match="div[@class='CommonSidebar']/div[@class='CommonContentBox'][h4='Page Details']/div[@class='CommonContentBoxContent']//div[@class='CustomWikiPageDetailsContent']/a">
dfdf
		<xsl:apply-templates select="node()"/>
dd
	</xsl:template>-->


	<!-- Remove some of the sidebars. -->
	<xsl:template match="div[@class='CommonSidebar']/div[@class='CommonContentBox'][h4='Page Details']"/>


	<xsl:template match="id('CommonTitle')">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:call-template name="new-page-details"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="new-page-details">
		<xsl:apply-templates mode="page-details" select="//div[@class='CommonSidebar']/div[@class='CommonContentBox'][h4='Page Details']/div[@class='CommonContentBoxContent']"/>
	</xsl:template>

	<xsl:template mode="page-details" match="div">
		<xsl:element name="div">
			<xsl:attribute name="class">CommonByline</xsl:attribute>
			<xsl:element name="span">This page is converted from the old nhforge.org Wiki.</xsl:element>
			<xsl:text> </xsl:text>
			<xsl:for-each select="./div[@class='CustomWikiPageDetailsArea']">
				<xsl:element name="span">
					<xsl:attribute name="class">revision</xsl:attribute>
					<xsl:value-of select="normalize-space(div[@class='CustomWikiPageDetailsTitle'])"/><xsl:text> </xsl:text>
					<xsl:element name="span">
						<xsl:attribute name="class">author</xsl:attribute>
						<xsl:value-of select="normalize-space(div[@class='CustomWikiPageDetailsContent'])"/>
					</xsl:element>
				</xsl:element>
				<xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
