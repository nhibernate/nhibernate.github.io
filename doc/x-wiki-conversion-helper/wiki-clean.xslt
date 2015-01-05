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


	<!-- Remove scripts, IE stylesheets, non-functioning search and RSS links and various irrelevant meta -->
	<xsl:template match="script"/>
	<xsl:template match="id('CommonSearch')"/>
	<xsl:template match="link[@rel='alternate'][@type='application/rss+xml']"/>
	<xsl:template match="comment()[contains(.,'[if lte IE 6]')]"/>
	<xsl:template match="meta[@name='google-site-verification']"/>
	<xsl:template match="meta[@name='GENERATOR']"/>
	<xsl:template match="meta[@http-equiv='X-UA-Compatible']"/>
	<xsl:template match="meta[@name='robots']"/>
	<xsl:template match="meta[@name='description']"/>
	<xsl:template match="meta[@name='keywords']"/>
	<xsl:template match="link[@rel='shortcut icon']"/>


        <!-- Remove the ASP.Net global postback form element (but retain the contents),
	     and the VIEWSTATE form control. -->
	<xsl:template match="div[input[@type='hidden'][@name='__VIEWSTATE']]"/>
	<xsl:template match="form[@name='aspnetForm']">
		<xsl:apply-templates select="node()"/>
	</xsl:template>


	<!-- Remove the 'Recent Commments' section -->
	<xsl:template match="div[contains(@class, 'CommonContentBox')][h3='Recent Comments']"/>


	<!-- Remove the tab headers Article/Comments/History, and grab the article contents from
	     inside the CommonPane element to reduce nesting. We won't bother trying to convert
	     comments and history. -->
	<xsl:template match="div[contains(@class, 'CommonPaneTabSet')]"/>
	<xsl:template match="div[@class='CommonPane']">
		<xsl:apply-templates select="node()"/>
	</xsl:template>


	<!-- Remove the footer contents, but keep the footer area if we want to add something
             in again. -->
	<xsl:template match="id('CommonFooter')/*"/>

	<xsl:template match="id('CommonNavigation')"/>
	<xsl:template match="id('CommonNavigation2')"/>


<!--
	<xsl:template match="id('CommonHeader')">
		<xsl:copy>
	      		You are browsing an archived copy of a Wiki page.
                        <xsl:element name="a">
				<xsl:attribute name="href">sdfds</xsl:attribute>
				Back 
			</xsl:element>
		</xsl:copy>
	</xsl:template>
-->


	<xsl:template match="div[contains(@class, 'WikiRating')]"/>
	<xsl:template match="a[contains(., '[Edit Tags]')]"/>
	<xsl:template match="div[contains(@class, 'CommonDescription')]/input[@type='hidden'][@value='nochange']"/>

	<!-- Make the page header within the content area larger. -->
	<xsl:template match="div[@class='CommonGroupedContentArea']/h2[@class='CommonContentBoxHeaderSmall']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="class"></xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- The area containing current tags and [Edit Tags] gets removed entirelys since it cannot be updated anyway. -->
	<xsl:template match="div[@class='CommonGroupedContentArea']/div[@class='CommonDescription']"/>


	<!-- Use 'Documentation' instead of 'Wikis' in the breadcrumbs. -->
	<xsl:template match="div[@class='CommonBreadCrumbArea']/div/a[.='Wikis']/text()">Documentation</xsl:template>


	<!-- Let the CommonTitle be the name of the documentation suite, instead of the singe page. Makes more
	     with the layout. -->
	<xsl:template match="id('CommonTitle')/h1">
		<xsl:copy>
			<xsl:value-of select="//div[@class='CommonBreadCrumbArea']//a[@href='default.aspx.html']"/>
		</xsl:copy>
	</xsl:template>


	<!-- Remove the left sidebar (which is empty), and move the right sidebars to the left side,
	     which is more common for the "table of contents". -->
	<xsl:template match="id('CommonSidebarLeft')"/>
	<xsl:template match="id('CommonSidebarRight')">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="id">CommonSidebarLeft</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>


	<!-- Remove some of the sidebars. -->
	<xsl:template match="div[@class='CommonSidebar']/div[@class='CommonContentBox'][h4='Shortcuts']"/>
	<xsl:template match="div[@class='CommonSidebar']/div[@class='CommonContentBox'][h4='Tags']"/>
	<xsl:template match="div[@class='CommonSidebar']/div[@class='CommonContentBox'][h4='Pages']"/>


	<!-- Rename sidebar 'Wiki Page Hierarchy' to 'Table of Contents' -->
	<xsl:template match="div[@class='CommonSidebar']/div[@class='CommonContentBox']/h4[text()='Wiki Page Hierarchy']/text()">Table of Contents</xsl:template>


	<!-- The 'Page details' section gets preserved, to keep some attribution to original author.
	     But add a note about this page being extracted from the old wiki. -->
	<xsl:template match="div[@class='CommonSidebar']/div[@class='CommonContentBox'][h4='Page Details']/div[@class='CommonContentBoxContent']">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
		<xsl:element name="div">
			This page is converted from the old nhforge.org Wiki.
		</xsl:element>
	</xsl:template>


	<!-- Remove the "X people found this article useful" from the sidebar, since it won't be updated. -->
	<xsl:template match="div[@class='WikiPageDetailsSummaryArea']"/>



</xsl:stylesheet>
